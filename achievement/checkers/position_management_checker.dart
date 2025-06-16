import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/services/achievement/checkers/achievement_checker_base.dart';

/// 持仓管理成就检查器
/// 负责检查所有持仓管理相关的成就
class PositionManagementChecker extends AchievementCheckerBase {
  @override
  Future<void> checkAchievements(
    Map<String, dynamic> basicStats,
    Map<String, dynamic> complexStats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    final tasks = <Future<void>>[];
    
    // 持仓能手 - 同时持有3个活跃仓位
    if (!isAchievementUnlocked(unlockedAchievementIds, 'position_master')) {
      tasks.add(_checkPositionMasterAchievement(complexStats, achievements, unlockedAchievementIds));
    }
    
    // 分散投资者 - 同时持有8个以上标的
    if (!isAchievementUnlocked(unlockedAchievementIds, 'diversified_investor')) {
      tasks.add(_checkDiversifiedInvestorAchievement(complexStats, achievements, unlockedAchievementIds));
    }
    
    // 长期持有 - 持有一个仓位超过30天
    if (!isAchievementUnlocked(unlockedAchievementIds, 'long_term_holder')) {
      tasks.add(_checkLongTermHolderAchievement(complexStats, achievements, unlockedAchievementIds));
    }
    
    // 短线猎手 - 持仓时间小于10分钟
    if (!isAchievementUnlocked(unlockedAchievementIds, 'short_term_hunter')) {
      tasks.add(_checkShortTermHunterAchievement(complexStats, achievements, unlockedAchievementIds));
    }
    
    // 波段之舞 - 持仓时间3-10天
    if (!isAchievementUnlocked(unlockedAchievementIds, 'swing_trader')) {
      tasks.add(_checkSwingTraderAchievement(complexStats, achievements, unlockedAchievementIds));
    }
    
    // 钻石之手 - 持有一个仓位超过365天
    if (!isAchievementUnlocked(unlockedAchievementIds, 'diamond_hands')) {
      tasks.add(_checkDiamondHandsAchievement(complexStats, achievements, unlockedAchievementIds));
    }
    
    await Future.wait(tasks);
  }

  /// 检查并解锁"持仓能手"成就 - 同时持有3个活跃仓位
  Future<void> _checkPositionMasterAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'position_master');
      if (achievement == null || achievement.unlocked) return;

      // 检查活跃持仓数量
      final activePositionCount = getSafeStat<int>(stats, 'activePositionCount') ?? 0;
      
      if (activePositionCount >= 3) {
        await unlockAchievement(achievement.id, 'position_master', unlockedAchievementIds);
      }
    } catch (e) {
      LogService.instance.e('检查持仓能手成就失败: $e');
    }
  }

  /// 检查并解锁"分散投资者"成就 - 同时持有8个以上标的
  Future<void> _checkDiversifiedInvestorAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'diversified_investor');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final activePositions = getSafeListStat<Position>(stats, 'activePositions');
      
      if (activePositions.isEmpty) {
        LogService.instance.d('分散投资者成就检查：活跃持仓数据为空');
        return;
      }
      
      // 统计不同标的数量
      final uniqueSymbols = activePositions.map((p) => p.positionSymbol).toSet();
      
      if (uniqueSymbols.length >= 8) {
        await unlockAchievement(achievement.id, 'diversified_investor', unlockedAchievementIds);
      }
    } catch (e) {
      LogService.instance.e('检查分散投资者成就失败: $e');
    }
  }

  /// 检查并解锁"长期持有"成就 - 持有一个仓位超过30天
  Future<void> _checkLongTermHolderAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'long_term_holder');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final positions = getSafeListStat<Position>(stats, 'totalPositions');
      
      if (positions.isEmpty) {
        LogService.instance.d('长期持有成就检查：持仓数据为空');
        return;
      }
      
      final now = DateTime.now();
      
      for (final position in positions) {
        final holdingDays = now.difference(position.openDate).inDays;
        if (holdingDays >= 30) {
          await unlockAchievement(achievement.id, 'long_term_holder', unlockedAchievementIds);
          return;
        }
      }
    } catch (e) {
      LogService.instance.e('检查长期持有成就失败: $e');
    }
  }

  /// 检查并解锁"短线猎手"成就 - 持仓时间小于10分钟
  Future<void> _checkShortTermHunterAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'short_term_hunter');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final positions = getSafeListStat<Position>(stats, 'totalPositions');
      
      if (positions.isEmpty) {
        LogService.instance.d('短线猎手成就检查：持仓数据为空');
        return;
      }
      
      for (final position in positions) {
        if (position.closeDate != null) {
          final holdingMinutes = position.closeDate!.difference(position.openDate).inMinutes;
          if (holdingMinutes < 10) {
            await unlockAchievement(achievement.id, 'short_term_hunter', unlockedAchievementIds);
            return;
          }
        }
      }
    } catch (e) {
      LogService.instance.e('检查短线猎手成就失败: $e');
    }
  }

  /// 检查并解锁"波段之舞"成就 - 持仓时间介于3天至10天
  Future<void> _checkSwingTraderAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'swing_trader');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final positions = getSafeListStat<Position>(stats, 'totalPositions');
      
      if (positions.isEmpty) {
        LogService.instance.d('波段之舞成就检查：持仓数据为空');
        return;
      }
      
      for (final position in positions) {
        final endDate = position.closeDate ?? DateTime.now();
        final holdingDays = endDate.difference(position.openDate).inDays;
        
        if (holdingDays >= 3 && holdingDays <= 10) {
          await unlockAchievement(achievement.id, 'swing_trader', unlockedAchievementIds);
          return;
        }
      }
    } catch (e) {
      LogService.instance.e('检查波段之舞成就失败: $e');
    }
  }

  /// 检查并解锁"钻石之手"成就 - 持有一个仓位超过365天
  Future<void> _checkDiamondHandsAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'diamond_hands');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final positions = getSafeListStat<Position>(stats, 'totalPositions');
      
      if (positions.isEmpty) {
        LogService.instance.d('钻石之手成就检查：持仓数据为空');
        return;
      }
      
      final now = DateTime.now();
      
      for (final position in positions) {
        final holdingDays = now.difference(position.openDate).inDays;
        if (holdingDays >= 365) {
          await unlockAchievement(achievement.id, 'diamond_hands', unlockedAchievementIds);
          return;
        }
      }
    } catch (e) {
      LogService.instance.e('检查钻石之手成就失败: $e');
    }
  }
} 