import 'dart:math' as math;
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/database/database_provider.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/services/achievement/checkers/achievement_checker_base.dart';

/// 盈利相关成就检查器
/// 负责检查所有盈利相关的成就
class ProfitRelatedChecker extends AchievementCheckerBase {
  /// 获取数据库实例
  AppDatabase get _database => DatabaseProvider.instance.database;

  @override
  Future<void> checkAchievements(
    Map<String, dynamic> basicStats,
    Map<String, dynamic> complexStats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    final tasks = <Future<void>>[];
    
    // 持续盈利 - 连续3笔交易盈利
    if (!isAchievementUnlocked(unlockedAchievementIds, 'continuous_profit')) {
      tasks.add(_checkContinuousProfitAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 连续盈利王 - 连续10笔交易盈利
    if (!isAchievementUnlocked(unlockedAchievementIds, 'profit_king')) {
      tasks.add(_checkProfitKingAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 破而后立 - 5连亏后连续盈利
    if (!isAchievementUnlocked(unlockedAchievementIds, 'comeback')) {
      tasks.add(_checkComebackAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 小有收获 - 单笔盈利>10%
    if (!isAchievementUnlocked(unlockedAchievementIds, 'small_gain')) {
      tasks.add(_checkSmallGainAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 翻倍达人 - 单笔盈利>100%
    if (!isAchievementUnlocked(unlockedAchievementIds, 'double_profit')) {
      tasks.add(_checkDoubleProfitAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 财富倍增者 - 组合利润翻倍
    if (!isAchievementUnlocked(unlockedAchievementIds, 'wealth_doubler')) {
      tasks.add(_checkWealthDoublerAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    await Future.wait(tasks);
  }

  /// 检查并解锁"持续盈利"成就 - 连续3笔交易盈利
  Future<void> _checkContinuousProfitAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'continuous_profit');
      if (achievement == null || achievement.unlocked) return;

      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      if (transactions.length < 3) return;

      // 按时间排序
      final sortedTransactions = List<TradingTransaction>.from(transactions)
        ..sort((a, b) => a.tradeDate.compareTo(b.tradeDate));

      // 检查连续盈利
      int consecutiveProfits = 0;
      int maxConsecutiveProfits = 0;

      for (final transaction in sortedTransactions) {
        if (transaction.profitOrLoss != null && 
            double.tryParse(transaction.profitOrLoss!) != null &&
            double.parse(transaction.profitOrLoss!) > 0) {
          consecutiveProfits++;
          maxConsecutiveProfits = math.max(maxConsecutiveProfits, consecutiveProfits);
        } else {
          consecutiveProfits = 0;
        }
      }

      if (maxConsecutiveProfits >= 3) {
        await unlockAchievement(achievement.id, 'continuous_profit', unlockedAchievementIds);
      }
    } catch (e) {
      LogService.instance.e('检查持续盈利成就失败: $e');
    }
  }

  /// 检查并解锁"连续盈利王"成就 - 连续10笔交易盈利
  Future<void> _checkProfitKingAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'profit_king');
      if (achievement == null || achievement.unlocked) return;

      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      if (transactions.length < 10) return;

      // 按时间排序
      final sortedTransactions = List<TradingTransaction>.from(transactions)
        ..sort((a, b) => a.tradeDate.compareTo(b.tradeDate));

      // 检查连续盈利
      int consecutiveProfits = 0;
      int maxConsecutiveProfits = 0;

      for (final transaction in sortedTransactions) {
        if (transaction.profitOrLoss != null && 
            double.tryParse(transaction.profitOrLoss!) != null &&
            double.parse(transaction.profitOrLoss!) > 0) {
          consecutiveProfits++;
          maxConsecutiveProfits = math.max(maxConsecutiveProfits, consecutiveProfits);
        } else {
          consecutiveProfits = 0;
        }
      }

      if (maxConsecutiveProfits >= 10) {
        await unlockAchievement(achievement.id, 'profit_king', unlockedAchievementIds);
      }
    } catch (e) {
      LogService.instance.e('检查连续盈利王成就失败: $e');
    }
  }

  /// 检查并解锁"破而后立"成就 - 5连亏后实现连续盈利
  Future<void> _checkComebackAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'comeback');
      if (achievement == null || achievement.unlocked) return;

      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      if (transactions.length < 7) return; // 至少需要5亏+2盈

      // 按时间排序
      final sortedTransactions = List<TradingTransaction>.from(transactions)
        ..sort((a, b) => a.tradeDate.compareTo(b.tradeDate));

      // 检查5连亏后连续盈利的模式
      for (int i = 0; i <= sortedTransactions.length - 7; i++) {
        // 检查5连亏
        bool hasFiveLosses = true;
        for (int j = i; j < i + 5; j++) {
          final transaction = sortedTransactions[j];
          if (transaction.profitOrLoss == null || 
              double.tryParse(transaction.profitOrLoss!) == null ||
              double.parse(transaction.profitOrLoss!) >= 0) {
            hasFiveLosses = false;
            break;
          }
        }

        if (hasFiveLosses) {
          // 检查后续是否有连续盈利
          int consecutiveProfits = 0;
          for (int j = i + 5; j < sortedTransactions.length; j++) {
            final transaction = sortedTransactions[j];
            if (transaction.profitOrLoss != null && 
                double.tryParse(transaction.profitOrLoss!) != null &&
                double.parse(transaction.profitOrLoss!) > 0) {
              consecutiveProfits++;
              if (consecutiveProfits >= 2) {
                await unlockAchievement(achievement.id, 'comeback', unlockedAchievementIds);
                return;
              }
            } else {
              break;
            }
          }
        }
      }
    } catch (e) {
      LogService.instance.e('检查破而后立成就失败: $e');
    }
  }

  /// 检查并解锁"小有收获"成就 - 单笔交易盈利超过10%
  Future<void> _checkSmallGainAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'small_gain');
      if (achievement == null || achievement.unlocked) return;

      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      for (final transaction in transactions) {
        if (transaction.percentOfPl != null && 
            double.tryParse(transaction.percentOfPl!) != null) {
          final profitPercent = double.parse(transaction.percentOfPl!);
          if (profitPercent > 10.0) {
            await unlockAchievement(achievement.id, 'small_gain', unlockedAchievementIds);
            return;
          }
        }
      }
    } catch (e) {
      LogService.instance.e('检查小有收获成就失败: $e');
    }
  }

  /// 检查并解锁"翻倍达人"成就 - 单笔交易盈利超过100%
  Future<void> _checkDoubleProfitAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'double_profit');
      if (achievement == null || achievement.unlocked) return;

      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      for (final transaction in transactions) {
        if (transaction.percentOfPl != null && 
            double.tryParse(transaction.percentOfPl!) != null) {
          final profitPercent = double.parse(transaction.percentOfPl!);
          if (profitPercent > 100.0) {
            await unlockAchievement(achievement.id, 'double_profit', unlockedAchievementIds);
            return;
          }
        }
      }
    } catch (e) {
      LogService.instance.e('检查翻倍达人成就失败: $e');
    }
  }

  /// 检查并解锁"财富倍增者"成就 - 整个投资组合的利润实现翻倍
  Future<void> _checkWealthDoublerAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'wealth_doubler');
      if (achievement == null || achievement.unlocked) return;

      // 获取投资组合快照数据
      final snapshots = await _database.select(_database.portfolioSnapshots).get();
      if (snapshots.isEmpty) return;

      // 按时间排序
      snapshots.sort((a, b) => a.snapshotDate.compareTo(b.snapshotDate));

      for (final snapshot in snapshots) {
        if (double.tryParse(snapshot.netDeposits) != null &&
            double.tryParse(snapshot.totalProfitLoss) != null) {
          
          final netDeposits = double.parse(snapshot.netDeposits);
          final totalProfitLoss = double.parse(snapshot.totalProfitLoss);
          
          // 检查利润是否超过净入金（即翻倍）
          if (netDeposits > 0 && totalProfitLoss >= netDeposits) {
            await unlockAchievement(achievement.id, 'wealth_doubler', unlockedAchievementIds);
            return;
          }
        }
      }
    } catch (e) {
      LogService.instance.e('检查财富倍增者成就失败: $e');
    }
  }
} 