import 'package:get/get.dart' hide Value;
import 'package:drift/drift.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/database/database_provider.dart';
import 'package:trade_flex/core/database/DAO/achievements_dao.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/utils/snackbar_utils.dart';
import 'dart:async';

/// 成就服务
/// 使用Drift数据库监控机制自动检测数据变化并解锁成就
class AchievementService extends GetxService {
  static AchievementService get instance => Get.find<AchievementService>();

  final _achievementsDao = AchievementsDAO.instance;

  // 成就缓存
  final RxList<Achievement> _achievements = <Achievement>[].obs;
  final RxBool _isInitialized = false.obs;

  // 数据库监控流订阅
  StreamSubscription<List<TradingTransaction>>? _tradingTransactionsSubscription;
  StreamSubscription<List<Achievement>>? _achievementsSubscription;

  // 性能优化相关
  final Map<String, dynamic> _statsCache = {}; // 统计数据缓存
  DateTime? _lastCacheUpdate; // 最后缓存更新时间
  static const Duration _cacheValidDuration = Duration(minutes: 5); // 缓存有效期
  
  // 防抖处理
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(seconds: 1); // 防抖延迟

  // 已解锁成就缓存（避免重复检查）
  final Set<String> _unlockedAchievementNames = {};

  /// 获取数据库实例
  AppDatabase get _database => DatabaseProvider.instance.database;

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
    await _initializeAchievements();
    await _setupDatabaseWatchers();
    _isInitialized.value = true;
  }

  @override
  void onClose() {
    _tradingTransactionsSubscription?.cancel();
    _achievementsSubscription?.cancel();
    _debounceTimer?.cancel();
    super.onClose();
  }

  /// 设置数据库监控器
  Future<void> _setupDatabaseWatchers() async {
    try {
      LogService.instance.i('设置数据库监控器');

      // 监控交易记录表的变化
      _tradingTransactionsSubscription = _database.select(_database.tradingTransactions).watch().listen(
        (transactions) {
          _onTradingTransactionsChanged(transactions);
        },
        onError: (error) {
          LogService.instance.e('交易记录监控出错: $error');
        },
      );

      // 监控成就表的变化（用于实时更新UI）
      _achievementsSubscription = _database.select(_database.achievements).watch().listen(
        (achievements) {
          _onAchievementsChanged(achievements);
        },
        onError: (error) {
          LogService.instance.e('成就监控出错: $error');
        },
      );

      LogService.instance.i('数据库监控器设置完成');
    } catch (e) {
      LogService.instance.e('设置数据库监控器失败: $e');
    }
  }

  /// 当交易记录发生变化时触发
  void _onTradingTransactionsChanged(List<TradingTransaction> transactions) {
    // 使用防抖处理，避免频繁触发
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      _processAchievementChecks(transactions);
    });
  }

  /// 当成就数据发生变化时触发
  void _onAchievementsChanged(List<Achievement> achievements) {
    // 更新本地缓存
    _achievements.assignAll(achievements);
    _updateUnlockedAchievementsCache();
  }

  /// 处理成就检查
  Future<void> _processAchievementChecks(List<TradingTransaction> transactions) async {
    try {
      LogService.instance.d('开始处理成就检查，当前交易记录数: ${transactions.length}');

      // 清空缓存，强制重新计算统计数据
      _statsCache.clear();
      _lastCacheUpdate = null;

      // 并行检查所有成就
      await Future.wait([
        _checkFirstTradeAchievement(transactions),
        _checkFirstProfitAchievement(transactions),
        _checkTradeCountAchievements(transactions),
        _checkMidnightTraderAchievement(transactions),
        _checkLightSpeedTraderAchievement(transactions),
        _checkRiskControlAchievement(transactions),
        _checkAnalysisMasterAchievement(transactions),
        _checkTagLoverAchievement(),
        _checkPositionHolderAchievement(),
      ]);

      LogService.instance.d('成就检查处理完成');
    } catch (e) {
      LogService.instance.e('处理成就检查失败: $e');
    }
  }

  /// 初始化成就系统
  Future<void> _initializeAchievements() async {
    try {
      LogService.instance.i('初始化成就系统');
      
      // 从数据库加载现有成就
      final existingAchievements = await _achievementsDao.getAllAchievements();
      
      if (existingAchievements.isEmpty) {
        // 如果数据库中没有成就，则初始化默认成就
        await _initializeDefaultAchievements();
      } else {
        // 加载现有成就到缓存
        _achievements.assignAll(existingAchievements);
      }

      // 初始化已解锁成就缓存
      _updateUnlockedAchievementsCache();

      LogService.instance.i('成就系统初始化完成，共 ${_achievements.length} 个成就');
    } catch (e) {
      LogService.instance.e('成就系统初始化失败: $e');
    }
  }

  /// 更新已解锁成就缓存
  void _updateUnlockedAchievementsCache() {
    _unlockedAchievementNames.clear();
    for (final achievement in _achievements) {
      if (achievement.unlocked) {
        _unlockedAchievementNames.add(achievement.name);
      }
    }
  }

  /// 初始化默认成就
  Future<void> _initializeDefaultAchievements() async {
    final defaultAchievements = [
      // 基础成就
      AchievementsCompanion.insert(
        name: '初出茅庐',
        description: '完成您的第一笔交易记录',
        icon: 'flag_outlined',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: DateTime.now(),
        updateTime: DateTime.now(),
      ),
      AchievementsCompanion.insert(
        name: '盈利之始',
        description: '首次实现单笔盈利',
        icon: 'trending_up',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: DateTime.now(),
        updateTime: DateTime.now(),
      ),
      AchievementsCompanion.insert(
        name: '交易达人',
        description: '累计完成 10 笔交易记录',
        icon: 'checklist',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: DateTime.now(),
        updateTime: DateTime.now(),
      ),
      AchievementsCompanion.insert(
        name: '持仓能手',
        description: '同时持有 3 个不同的活跃仓位',
        icon: 'inventory_2_outlined',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: DateTime.now(),
        updateTime: DateTime.now(),
      ),
      AchievementsCompanion.insert(
        name: '百炼成钢',
        description: '累计完成 100 笔交易记录',
        icon: 'star_border',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: DateTime.now(),
        updateTime: DateTime.now(),
      ),
      AchievementsCompanion.insert(
        name: '风险控制者',
        description: '连续 5 笔交易设置止损',
        icon: 'shield_outlined',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: DateTime.now(),
        updateTime: DateTime.now(),
      ),
      AchievementsCompanion.insert(
        name: '分析大师',
        description: '为一笔交易添加 5 条以上分析笔记',
        icon: 'analytics_outlined',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: DateTime.now(),
        updateTime: DateTime.now(),
      ),
      AchievementsCompanion.insert(
        name: '标签爱好者',
        description: '创建并使用 10 个不同的标签',
        icon: 'label_important_outline',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: DateTime.now(),
        updateTime: DateTime.now(),
      ),
      // 隐藏成就
      AchievementsCompanion.insert(
        name: '午夜交易员',
        description: '在凌晨 0 点到 3 点之间添加了一笔交易',
        icon: 'nightlight_round',
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: DateTime.now(),
        updateTime: DateTime.now(),
      ),
      AchievementsCompanion.insert(
        name: '光速操作',
        description: '在 1 分钟内完成开仓和平仓',
        icon: 'flash_on',
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: DateTime.now(),
        updateTime: DateTime.now(),
      ),
    ];

    // 批量插入成就
    for (final achievement in defaultAchievements) {
      final inserted = await _achievementsDao.insertAchievement(achievement);
      _achievements.add(inserted);
    }

    LogService.instance.i('默认成就初始化完成');
  }

  /// 检查缓存是否有效
  bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheValidDuration;
  }

  /// 获取或更新统计数据缓存
  Future<Map<String, dynamic>> _getStatsCache(List<TradingTransaction> transactions) async {
    if (_isCacheValid() && _statsCache.isNotEmpty) {
      return _statsCache;
    }

    // 更新缓存
    try {
      _statsCache['totalTrades'] = transactions.length;
      _statsCache['hasProfitableTrade'] = transactions.any((t) => 
        t.profitOrLoss != null && 
        double.tryParse(t.profitOrLoss!) != null && 
        double.parse(t.profitOrLoss!) > 0
      );
      _lastCacheUpdate = DateTime.now();
      
      LogService.instance.d('统计数据缓存已更新');
    } catch (e) {
      LogService.instance.e('更新统计数据缓存失败: $e');
    }

    return _statsCache;
  }

  /// 检查并解锁"初出茅庐"成就
  Future<void> _checkFirstTradeAchievement(List<TradingTransaction> transactions) async {
    if (_unlockedAchievementNames.contains('初出茅庐')) return;

    try {
      final achievement = _achievements.firstWhereOrNull((a) => a.name == '初出茅庐');
      if (achievement == null || achievement.unlocked) return;

      if (transactions.isNotEmpty) {
        await _unlockAchievement(achievement.id, '初出茅庐');
      }
    } catch (e) {
      LogService.instance.e('检查初出茅庐成就失败: $e');
    }
  }

  /// 检查并解锁"盈利之始"成就
  Future<void> _checkFirstProfitAchievement(List<TradingTransaction> transactions) async {
    if (_unlockedAchievementNames.contains('盈利之始')) return;

    try {
      final achievement = _achievements.firstWhereOrNull((a) => a.name == '盈利之始');
      if (achievement == null || achievement.unlocked) return;

      final stats = await _getStatsCache(transactions);
      final hasProfitableTrade = stats['hasProfitableTrade'] ?? false;
      
      if (hasProfitableTrade) {
        await _unlockAchievement(achievement.id, '盈利之始');
      }
    } catch (e) {
      LogService.instance.e('检查盈利之始成就失败: $e');
    }
  }

  /// 检查并解锁交易数量相关成就
  Future<void> _checkTradeCountAchievements(List<TradingTransaction> transactions) async {
    try {
      final totalTrades = transactions.length;
      
      // 检查交易达人成就（10笔）
      if (!_unlockedAchievementNames.contains('交易达人')) {
        final tradeExpertAchievement = _achievements.firstWhereOrNull((a) => a.name == '交易达人');
        if (tradeExpertAchievement != null && !tradeExpertAchievement.unlocked && totalTrades >= 10) {
          await _unlockAchievement(tradeExpertAchievement.id, '交易达人');
        }
      }

      // 检查百炼成钢成就（100笔）
      if (!_unlockedAchievementNames.contains('百炼成钢')) {
        final masterTraderAchievement = _achievements.firstWhereOrNull((a) => a.name == '百炼成钢');
        if (masterTraderAchievement != null && !masterTraderAchievement.unlocked && totalTrades >= 100) {
          await _unlockAchievement(masterTraderAchievement.id, '百炼成钢');
        }
      }
    } catch (e) {
      LogService.instance.e('检查交易数量成就失败: $e');
    }
  }

  /// 检查并解锁"午夜交易员"隐藏成就
  Future<void> _checkMidnightTraderAchievement(List<TradingTransaction> transactions) async {
    if (_unlockedAchievementNames.contains('午夜交易员')) return;

    try {
      final achievement = _achievements.firstWhereOrNull((a) => a.name == '午夜交易员');
      if (achievement == null || achievement.unlocked) return;

      // 检查是否有在凌晨0-3点的交易
      final hasMidnightTrade = transactions.any((trade) {
        final hour = trade.tradeDate.hour;
        return hour >= 0 && hour < 3;
      });

      if (hasMidnightTrade) {
        await _unlockAchievement(achievement.id, '午夜交易员');
      }
    } catch (e) {
      LogService.instance.e('检查午夜交易员成就失败: $e');
    }
  }

  /// 检查并解锁"光速操作"隐藏成就
  Future<void> _checkLightSpeedTraderAchievement(List<TradingTransaction> transactions) async {
    if (_unlockedAchievementNames.contains('光速操作')) return;

    try {
      final achievement = _achievements.firstWhereOrNull((a) => a.name == '光速操作');
      if (achievement == null || achievement.unlocked) return;

      // 按子持仓分组检查
      final subPositionGroups = <int, List<TradingTransaction>>{};
      for (final trade in transactions) {
        subPositionGroups.putIfAbsent(trade.subPositionId, () => []).add(trade);
      }

      // 检查每个子持仓是否有1分钟内的开仓平仓
      for (final trades in subPositionGroups.values) {
        trades.sort((a, b) => a.tradeDate.compareTo(b.tradeDate));
        
        for (int i = 0; i < trades.length - 1; i++) {
          final currentTrade = trades[i];
          final nextTrade = trades[i + 1];
          
          // 检查是否是开仓后平仓的组合
          final isOpenClose = (currentTrade.operate.index <= 1) && (nextTrade.operate.index >= 2);
          
          if (isOpenClose) {
            final timeDiff = nextTrade.tradeDate.difference(currentTrade.tradeDate);
            if (timeDiff.inMinutes <= 1) {
              await _unlockAchievement(achievement.id, '光速操作');
              return;
            }
          }
        }
      }
    } catch (e) {
      LogService.instance.e('检查光速操作成就失败: $e');
    }
  }

  /// 检查并解锁"风险控制者"成就
  Future<void> _checkRiskControlAchievement(List<TradingTransaction> transactions) async {
    if (_unlockedAchievementNames.contains('风险控制者')) return;

    try {
      final achievement = _achievements.firstWhereOrNull((a) => a.name == '风险控制者');
      if (achievement == null || achievement.unlocked) return;

      // 检查最近5笔交易是否都有止损描述
      final recentTrades = transactions
          .where((t) => t.description != null && t.description!.isNotEmpty)
          .toList()
        ..sort((a, b) => b.tradeDate.compareTo(a.tradeDate));

      if (recentTrades.length >= 5) {
        final last5Trades = recentTrades.take(5);
        final allHaveStopLoss = last5Trades.every((trade) => 
          trade.description!.toLowerCase().contains('止损') ||
          trade.description!.toLowerCase().contains('stop loss')
        );

        if (allHaveStopLoss) {
          await _unlockAchievement(achievement.id, '风险控制者');
        }
      }
    } catch (e) {
      LogService.instance.e('检查风险控制者成就失败: $e');
    }
  }

  /// 检查并解锁"分析大师"成就
  Future<void> _checkAnalysisMasterAchievement(List<TradingTransaction> transactions) async {
    if (_unlockedAchievementNames.contains('分析大师')) return;

    try {
      final achievement = _achievements.firstWhereOrNull((a) => a.name == '分析大师');
      if (achievement == null || achievement.unlocked) return;

      // 检查是否有交易的描述超过5条分析（以换行符或分号分隔）
      final hasDetailedAnalysis = transactions.any((trade) {
        if (trade.description == null || trade.description!.isEmpty) return false;
        
        final analysisCount = trade.description!.split(RegExp(r'[;\n]')).length;
        return analysisCount >= 5;
      });

      if (hasDetailedAnalysis) {
        await _unlockAchievement(achievement.id, '分析大师');
      }
    } catch (e) {
      LogService.instance.e('检查分析大师成就失败: $e');
    }
  }

  /// 检查并解锁"标签爱好者"成就
  Future<void> _checkTagLoverAchievement() async {
    if (_unlockedAchievementNames.contains('标签爱好者')) return;

    try {
      final achievement = _achievements.firstWhereOrNull((a) => a.name == '标签爱好者');
      if (achievement == null || achievement.unlocked) return;

      // 查询标签数量
      final tagCount = await (_database.select(_database.tags)).get();
      
      if (tagCount.length >= 10) {
        await _unlockAchievement(achievement.id, '标签爱好者');
      }
    } catch (e) {
      LogService.instance.e('检查标签爱好者成就失败: $e');
    }
  }

  /// 检查并解锁"持仓能手"成就
  Future<void> _checkPositionHolderAchievement() async {
    if (_unlockedAchievementNames.contains('持仓能手')) return;

    try {
      final achievement = _achievements.firstWhereOrNull((a) => a.name == '持仓能手');
      if (achievement == null || achievement.unlocked) return;

      // 查询活跃持仓数量
      final activePositions = await (_database.select(_database.positions)
        ..where((p) => p.isClosed.equals(false))).get();
      
      if (activePositions.length >= 3) {
        await _unlockAchievement(achievement.id, '持仓能手');
      }
    } catch (e) {
      LogService.instance.e('检查持仓能手成就失败: $e');
    }
  }

  /// 解锁成就
  Future<void> _unlockAchievement(int achievementId, String achievementName) async {
    try {
      final now = DateTime.now();
      
      // 更新数据库
      await _achievementsDao.updateAchievement(
        achievementId,
        AchievementsCompanion(
          unlocked: const Value(true),
          unlockDate: Value(now),
          updateTime: Value(now),
        ),
      );

      // 更新已解锁成就缓存
      _unlockedAchievementNames.add(achievementName);

      // 显示解锁通知
      _showAchievementUnlockedNotification(achievementName);

      LogService.instance.i('成就解锁: $achievementName');
    } catch (e) {
      LogService.instance.e('解锁成就失败: $e');
    }
  }

  /// 显示成就解锁通知
  void _showAchievementUnlockedNotification(String achievementName) {
    SnackbarUtils.achievementUnlocked(achievementName);
  }

  /// 重新加载成就数据
  Future<void> reloadAchievements() async {
    try {
      final achievements = await _achievementsDao.getAllAchievements();
      _achievements.assignAll(achievements);
      _updateUnlockedAchievementsCache();
      
      // 清空缓存
      _statsCache.clear();
      _lastCacheUpdate = null;
      
      LogService.instance.i('成就数据重新加载完成');
    } catch (e) {
      LogService.instance.e('重新加载成就数据失败: $e');
    }
  }

  /// 手动解锁成就（用于测试）
  Future<void> manualUnlockAchievement(String achievementName) async {
    final achievement = _achievements.firstWhereOrNull((a) => a.name == achievementName);
    if (achievement != null && !achievement.unlocked) {
      await _unlockAchievement(achievement.id, achievementName);
    }
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
      final transactions = await _database.select(_database.tradingTransactions).get();
      await _processAchievementChecks(transactions);
      LogService.instance.i('强制触发成就检查完成');
    } catch (e) {
      LogService.instance.e('强制触发成就检查失败: $e');
    }
  }
} 