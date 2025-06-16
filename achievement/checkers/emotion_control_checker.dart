import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/services/achievement/checkers/achievement_checker_base.dart';

/// 情绪控制成就检查器
/// 负责检查所有情绪控制相关的成就
class EmotionControlChecker extends AchievementCheckerBase {
  @override
  Future<void> checkAchievements(
    Map<String, dynamic> basicStats,
    Map<String, dynamic> complexStats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    final tasks = <Future<void>>[];
    
    // 恐惧买入者 - 在极度恐惧情绪下记录买入交易
    if (!isAchievementUnlocked(unlockedAchievementIds, 'fear_buyer')) {
      tasks.add(_checkFearBuyerAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 贪婪追涨者 - 在极度贪婪情绪下追加交易记录
    if (!isAchievementUnlocked(unlockedAchievementIds, 'greed_chaser')) {
      tasks.add(_checkGreedChaserAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 斩亏高手 - 一次交易亏损少于1%，成功止损
    if (!isAchievementUnlocked(unlockedAchievementIds, 'stop_loss_master')) {
      tasks.add(_checkStopLossMasterAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 情绪稳定者 - 连续5笔交易无情绪波动记录
    if (!isAchievementUnlocked(unlockedAchievementIds, 'emotion_stable')) {
      tasks.add(_checkEmotionStableAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    await Future.wait(tasks);
  }

  /// 检查并解锁"恐惧买入者"成就 - 在极度恐惧情绪下记录买入交易
  Future<void> _checkFearBuyerAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'fear_buyer');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (transactions.isEmpty) {
        LogService.instance.d('恐惧买入者成就检查：交易数据为空');
        return;
      }

      // 检查是否有在极度恐惧情绪下(≤25)的买入交易
      final fearBuyTrades = transactions.where((t) => 
        (t.operate.name == 'openLong' || t.operate.name == 'openShort') &&
        t.fearGreedIndex <= 25
      ).toList();

      if (fearBuyTrades.isNotEmpty) {
        await unlockAchievement(achievement.id, 'fear_buyer', unlockedAchievementIds);
      }
    } catch (e) {
      LogService.instance.e('检查恐惧买入者成就失败: $e');
    }
  }

  /// 检查并解锁"贪婪追涨者"成就 - 在极度贪婪情绪下追加交易记录
  Future<void> _checkGreedChaserAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'greed_chaser');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (transactions.isEmpty) {
        LogService.instance.d('贪婪追涨者成就检查：交易数据为空');
        return;
      }

      // 检查是否有在极度贪婪情绪下(≥75)的开仓交易（追加仓位）
      final greedTrades = transactions.where((t) => 
        (t.operate.name == 'openLong' || t.operate.name == 'openShort') &&
        t.fearGreedIndex >= 75
      ).toList();

      if (greedTrades.isNotEmpty) {
        await unlockAchievement(achievement.id, 'greed_chaser', unlockedAchievementIds);
      }
    } catch (e) {
      LogService.instance.e('检查贪婪追涨者成就失败: $e');
    }
  }

  /// 检查并解锁"斩亏高手"成就 - 一次交易亏损少于1%，成功止损
  Future<void> _checkStopLossMasterAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'stop_loss_master');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (transactions.isEmpty) {
        LogService.instance.d('斩亏高手成就检查：交易数据为空');
        return;
      }

      // 检查平仓交易中是否有亏损少于1%的成功止损
      for (final transaction in transactions) {
        if ((transaction.operate.name == 'closeLong' || transaction.operate.name == 'closeShort') &&
            transaction.percentOfPl != null && 
            double.tryParse(transaction.percentOfPl!) != null) {
          
          final profitPercent = double.parse(transaction.percentOfPl!);
          // 亏损少于1%（即-1% < 盈亏百分比 < 0%）
          if (profitPercent < 0 && profitPercent > -1.0) {
            await unlockAchievement(achievement.id, 'stop_loss_master', unlockedAchievementIds);
            return;
          }
        }
      }
    } catch (e) {
      LogService.instance.e('检查斩亏高手成就失败: $e');
    }
  }

  /// 检查并解锁"情绪稳定者"成就 - 连续5笔交易无情绪波动记录
  Future<void> _checkEmotionStableAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'emotion_stable');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (transactions.isEmpty || transactions.length < 5) {
        LogService.instance.d('情绪稳定者成就检查：交易数据不足5笔');
        return;
      }

      // 按时间排序
      final sortedTransactions = List<TradingTransaction>.from(transactions)
        ..sort((a, b) => a.tradeDate.compareTo(b.tradeDate));

      // 检查连续5笔交易的恐惧贪婪指数是否都在中性范围内(45-55)
      for (int i = 0; i <= sortedTransactions.length - 5; i++) {
        bool isStable = true;
        
        for (int j = i; j < i + 5; j++) {
          final fearGreedIndex = sortedTransactions[j].fearGreedIndex;
          if (fearGreedIndex < 45 || fearGreedIndex > 55) {
            isStable = false;
            break;
          }
        }
        
        if (isStable) {
          await unlockAchievement(achievement.id, 'emotion_stable', unlockedAchievementIds);
          return;
        }
      }
    } catch (e) {
      LogService.instance.e('检查情绪稳定者成就失败: $e');
    }
  }
} 