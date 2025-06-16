import 'package:get/get.dart' hide Value;
import 'package:drift/drift.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/database/DAO/achievements_dao.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/utils/snackbar_utils.dart';
import 'package:trade_flex/core/utils/achievement_utils.dart';

/// 成就检查器基类
/// 定义成就检查的通用接口和方法
abstract class AchievementCheckerBase {
  final _achievementsDao = AchievementsDAO.instance;

  /// 检查成就的抽象方法，由子类实现
  Future<void> checkAchievements(
    Map<String, dynamic> basicStats,
    Map<String, dynamic> complexStats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  );

  /// 解锁成就的通用方法
  Future<void> unlockAchievement(
    int achievementId, 
    String achievementIdString,
    Set<String> unlockedAchievementIds,
  ) async {
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
      unlockedAchievementIds.add(achievementIdString);

      // 显示解锁通知
      _showAchievementUnlockedNotification(achievementIdString);

      LogService.instance.i('成就解锁: $achievementIdString');
    } catch (e) {
      LogService.instance.e('解锁成就失败: $e');
    }
  }

  /// 显示成就解锁通知
  void _showAchievementUnlockedNotification(String achievementId) {
    final achievementTitle = AchievementUtils.getAchievementTitle(achievementId);
    SnackbarUtils.achievementUnlocked(achievementTitle);
  }

  /// 安全获取成就对象
  Achievement? getAchievement(List<Achievement> achievements, String achievementId) {
    return achievements.firstWhereOrNull((a) => a.achievementId == achievementId);
  }

  /// 检查成就是否已解锁
  bool isAchievementUnlocked(Set<String> unlockedAchievementIds, String achievementId) {
    return unlockedAchievementIds.contains(achievementId);
  }

  /// 安全获取统计数据
  T? getSafeStat<T>(Map<String, dynamic> stats, String key) {
    try {
      return stats[key] as T?;
    } catch (e) {
      LogService.instance.w('获取统计数据失败: key=$key, error=$e');
      return null;
    }
  }

  /// 安全获取列表统计数据
  List<T> getSafeListStat<T>(Map<String, dynamic> stats, String key) {
    try {
      return (stats[key] as List?)?.cast<T>() ?? <T>[];
    } catch (e) {
      LogService.instance.w('获取列表统计数据失败: key=$key, error=$e');
      return <T>[];
    }
  }

  /// 检查字符串是否精确到小数点后2位
  bool isExactlyTwoDecimals(String value) {
    if (double.tryParse(value) == null) return false;
    
    // 检查是否包含小数点
    if (!value.contains('.')) return false;
    
    // 检查小数点后是否恰好有2位数字
    final parts = value.split('.');
    return parts.length == 2 && parts[1].length == 2;
  }
} 