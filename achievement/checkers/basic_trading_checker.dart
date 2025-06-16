import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/services/achievement/checkers/achievement_checker_base.dart';

/// 基础交易成就检查器
/// 负责检查所有基础交易相关的成就
class BasicTradingChecker extends AchievementCheckerBase {
  @override
  Future<void> checkAchievements(
    Map<String, dynamic> basicStats,
    Map<String, dynamic> complexStats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    final tasks = <Future<void>>[];
    
    // 初出茅庐 - 完成第一笔交易记录
    if (!isAchievementUnlocked(unlockedAchievementIds, 'first_trade')) {
      tasks.add(_checkFirstTradeAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 盈利之始 - 首次实现单笔盈利
    if (!isAchievementUnlocked(unlockedAchievementIds, 'first_profit')) {
      tasks.add(_checkFirstProfitAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 交易数量相关成就
    tasks.add(_checkTradeCountAchievements(basicStats, achievements, unlockedAchievementIds));
    
    await Future.wait(tasks);
  }

  /// 检查并解锁"初出茅庐"成就
  Future<void> _checkFirstTradeAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'first_trade');
      if (achievement == null || achievement.unlocked) return;

      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      if (transactions.isNotEmpty) {
        await unlockAchievement(achievement.id, 'first_trade', unlockedAchievementIds);
      }
    } catch (e) {
      LogService.instance.e('检查初出茅庐成就失败: $e');
    }
  }

  /// 检查并解锁"盈利之始"成就
  Future<void> _checkFirstProfitAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'first_profit');
      if (achievement == null || achievement.unlocked) return;

      final hasProfitableTrade = stats['hasProfitableTrade'] as bool? ?? false;
      
      if (hasProfitableTrade) {
        await unlockAchievement(achievement.id, 'first_profit', unlockedAchievementIds);
      }
    } catch (e) {
      LogService.instance.e('检查盈利之始成就失败: $e');
    }
  }

  /// 检查并解锁交易数量相关成就
  Future<void> _checkTradeCountAchievements(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      final totalTrades = transactions.length;
      
      // 检查交易达人成就（10笔）
      if (!isAchievementUnlocked(unlockedAchievementIds, 'trade_expert')) {
        final tradeExpertAchievement = getAchievement(achievements, 'trade_expert');
        if (tradeExpertAchievement != null && !tradeExpertAchievement.unlocked && totalTrades >= 10) {
          await unlockAchievement(tradeExpertAchievement.id, 'trade_expert', unlockedAchievementIds);
        }
      }

      // 检查百炼成钢成就（100笔）
      if (!isAchievementUnlocked(unlockedAchievementIds, 'hundred_trades')) {
        final masterTraderAchievement = getAchievement(achievements, 'hundred_trades');
        if (masterTraderAchievement != null && !masterTraderAchievement.unlocked && totalTrades >= 100) {
          await unlockAchievement(masterTraderAchievement.id, 'hundred_trades', unlockedAchievementIds);
        }
      }

      // 检查千军万马成就（1000笔）
      if (!isAchievementUnlocked(unlockedAchievementIds, 'thousand_trades')) {
        final thousandTradesAchievement = getAchievement(achievements, 'thousand_trades');
        if (thousandTradesAchievement != null && !thousandTradesAchievement.unlocked && totalTrades >= 1000) {
          await unlockAchievement(thousandTradesAchievement.id, 'thousand_trades', unlockedAchievementIds);
        }
      }
    } catch (e) {
      LogService.instance.e('检查交易数量成就失败: $e');
    }
  }
} 