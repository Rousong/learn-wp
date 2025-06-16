import 'package:get/get.dart' hide Value;
import 'package:drift/drift.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/database/DAO/achievements_dao.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/services/achievement/achievement_data.dart';
import 'package:trade_flex/core/services/achievement/achievement_cache_manager.dart';
import 'package:trade_flex/core/services/achievement/achievement_watcher.dart';
import 'package:trade_flex/core/services/achievement/achievement_checker_manager.dart';
import 'package:trade_flex/core/utils/achievement_utils.dart';
import 'package:trade_flex/core/utils/snackbar_utils.dart';

/// 重构后的成就服务
/// 轻量级成就服务，主要负责协调各个管理器
class AchievementService extends GetxService {
  static AchievementService get instance => Get.find<AchievementService>();

  final _achievementsDao = AchievementsDAO.instance;

  // 成就缓存
  final RxList<Achievement> _achievements = <Achievement>[].obs;
  final RxBool _isInitialized = false.obs;

  // 已解锁成就缓存（避免重复检查）
  final Set<String> _unlockedAchievementIds = {};

  // 管理器实例
  late final AchievementCacheManager _cacheManager;
  late final AchievementWatcher _watcher;
  late final AchievementCheckerManager _checkerManager;

  /// 所有成就列表
  List<Achievement> get achievements => _achievements;

  /// 是否已初始化
  bool get isInitialized => _isInitialized.value;

  /// 已解锁的成就数量
  int get unlockedCount => _achievements.where((a) => a.unlocked).length;

  /// 总成就数量
  int get totalCount => _achievements.length;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeService();
  }

  @override
  void onClose() {
    // 取消所有数据库监控订阅
    _watcher.dispose();
    super.onClose();
  }

  /// 初始化服务
  Future<void> _initializeService() async {
    try {
      LogService.instance.i('开始初始化重构后的成就服务...');
      
      // 初始化管理器
      _cacheManager = AchievementCacheManager.instance;
      _watcher = AchievementWatcher.instance;
      _checkerManager = AchievementCheckerManager.instance;
      
      // 初始化检查器
      _checkerManager.initializeCheckers();
      
      // 加载现有成就
      final existingAchievements = await _achievementsDao.getAllAchievements();
      
      if (existingAchievements.isEmpty) {
        // 如果没有成就数据，初始化默认成就
        await _initializeDefaultAchievements();
      } else {
        _achievements.assignAll(existingAchievements);
      }
      
      // 更新已解锁成就缓存
      _updateUnlockedAchievementsCache();
      
      // 设置数据库监控
      _setupDatabaseWatchers();
      
      _isInitialized.value = true;
      LogService.instance.i('成就服务初始化完成，共加载 ${_achievements.length} 个成就');
    } catch (e) {
      LogService.instance.e('成就服务初始化失败: $e');
    }
  }

  /// 设置数据库监控系统
  void _setupDatabaseWatchers() {
    LogService.instance.d('设置数据库监控系统...');
    
    // 设置数据变化回调
    _watcher.setOnDataChangedCallback(_processOptimizedAchievementChecks);
    
    // 设置扩展的数据库监控
    _watcher.setupDatabaseWatchers();
    
    // 设置成就数据监控
    _watcher.setupAchievementWatcher((achievements) {
      _achievements.assignAll(achievements);
      _updateUnlockedAchievementsCache();
    });
    
    LogService.instance.d('数据库监控系统设置完成');
  }

  /// 优化的成就检查处理
  Future<void> _processOptimizedAchievementChecks(Set<String> changedDataTypes) async {
    if (!_isInitialized.value) return;

    try {
      // 获取基础数据和复杂数据
      final basicStats = await _cacheManager.getBasicStatsCache();
      final complexStats = await _cacheManager.getComplexStatsCache();
      
      // 使用检查器管理器处理成就检查
      await _checkerManager.processOptimizedAchievementChecks(
        changedDataTypes,
        basicStats,
        complexStats,
        _achievements,
        _unlockedAchievementIds,
      );
    } catch (e) {
      LogService.instance.e('处理优化成就检查失败: $e');
    }
  }

  /// 重新加载成就数据
  Future<void> reloadAchievements() async {
    try {
      final achievements = await _achievementsDao.getAllAchievements();
      _achievements.assignAll(achievements);
      _updateUnlockedAchievementsCache();
      
      // 清空缓存
      _cacheManager.clearAllCaches();
      
      LogService.instance.i('成就数据重新加载完成');
    } catch (e) {
      LogService.instance.e('重新加载成就数据失败: $e');
    }
  }

  /// 手动解锁成就（用于测试）
  Future<void> manualUnlockAchievement(String achievementId) async {
    final achievement = _achievements.firstWhereOrNull((a) => a.achievementId == achievementId);
    if (achievement != null && !achievement.unlocked) {
      final now = DateTime.now();
      
      // 更新数据库
      await _achievementsDao.updateAchievement(
        achievement.id,
        AchievementsCompanion(
          unlocked: const Value(true),
          unlockDate: Value(now),
          updateTime: Value(now),
        ),
      );
      
      // 更新缓存
      _unlockedAchievementIds.add(achievementId);
      
      // 显示解锁通知
      _showAchievementUnlockedNotification(achievementId);
      
      // 重新加载成就数据以更新UI
      await reloadAchievements();
      
      LogService.instance.i('手动解锁成就: $achievementId');
    }
  }

  /// 显示成就解锁通知
  void _showAchievementUnlockedNotification(String achievementId) {
    final achievementTitle = AchievementUtils.getAchievementTitle(achievementId);
    SnackbarUtils.achievementUnlocked(achievementTitle);
  }

  /// 重置所有成就（用于测试）
  Future<void> resetAllAchievements() async {
    try {
      for (final achievement in _achievements) {
        if (achievement.unlocked) {
          await _achievementsDao.updateAchievement(
            achievement.id,
            AchievementsCompanion(
              unlocked: const Value(false),
              unlockDate: const Value.absent(),
              updateTime: Value(DateTime.now()),
            ),
          );
        }
      }
      
      await reloadAchievements();
      LogService.instance.i('所有成就已重置');
    } catch (e) {
      LogService.instance.e('重置成就失败: $e');
    }
  }

  /// 强制触发成就检查（用于测试）
  Future<void> forceTriggerAchievementCheck() async {
    try {
      // 获取基础数据和复杂数据
      final basicStats = await _cacheManager.getBasicStatsCache();
      final complexStats = await _cacheManager.getComplexStatsCache();
      
      // 执行全量成就检查
      await _checkerManager.processFullAchievementCheck(
        basicStats,
        complexStats,
        _achievements,
        _unlockedAchievementIds,
      );
      
      LogService.instance.i('强制触发成就检查完成');
    } catch (e) {
      LogService.instance.e('强制触发成就检查失败: $e');
    }
  }

  /// 更新已解锁成就缓存
  void _updateUnlockedAchievementsCache() {
    _unlockedAchievementIds.clear();
    for (final achievement in _achievements) {
      if (achievement.unlocked) {
        _unlockedAchievementIds.add(achievement.achievementId);
      }
    }
  }

  /// 初始化默认成就
  Future<void> _initializeDefaultAchievements() async {
    // 从成就数据文件获取所有默认成就
    final defaultAchievements = AchievementData.getDefaultAchievements();

    // 批量插入成就
    for (final achievement in defaultAchievements) {
      final inserted = await _achievementsDao.insertAchievement(achievement);
      _achievements.add(inserted);
    }

    LogService.instance.i('默认成就初始化完成，共创建 ${defaultAchievements.length} 个成就');
  }
} 