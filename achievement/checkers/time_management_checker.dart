import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/services/achievement/checkers/achievement_checker_base.dart';

/// 时间管理成就检查器
/// 负责检查所有时间管理相关的成就
class TimeManagementChecker extends AchievementCheckerBase {
  @override
  Future<void> checkAchievements(
    Map<String, dynamic> basicStats,
    Map<String, dynamic> complexStats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    final tasks = <Future<void>>[];
    
    // 三连击 - 连续三天都有交易记录
    if (!isAchievementUnlocked(unlockedAchievementIds, 'triple_strike')) {
      tasks.add(_checkTripleStrikeAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 每日签到 - 连续30天打开App
    if (!isAchievementUnlocked(unlockedAchievementIds, 'daily_checkin')) {
      tasks.add(_checkDailyCheckinAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 永不止步 - 记录交易超过365天
    if (!isAchievementUnlocked(unlockedAchievementIds, 'never_stop')) {
      tasks.add(_checkNeverStopAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    await Future.wait(tasks);
  }

  /// 检查并解锁"三连击"成就 - 连续三天都有交易记录
  Future<void> _checkTripleStrikeAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'triple_strike');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (transactions.isEmpty) {
        LogService.instance.d('三连击成就检查：交易数据为空');
        return;
      }

      // 按日期分组交易
      final Map<String, List<TradingTransaction>> transactionsByDate = {};
      for (final transaction in transactions) {
        final dateKey = '${transaction.tradeDate.year}-${transaction.tradeDate.month}-${transaction.tradeDate.day}';
        transactionsByDate.putIfAbsent(dateKey, () => []);
        transactionsByDate[dateKey]!.add(transaction);
      }

      // 检查是否有连续三天的交易记录
      final sortedDates = transactionsByDate.keys.toList()..sort();
      
      for (int i = 0; i <= sortedDates.length - 3; i++) {
        final date1 = DateTime.parse(sortedDates[i].replaceAll('-', '-'));
        final date2 = DateTime.parse(sortedDates[i + 1].replaceAll('-', '-'));
        final date3 = DateTime.parse(sortedDates[i + 2].replaceAll('-', '-'));
        
        // 检查是否为连续三天
        if (date2.difference(date1).inDays == 1 && date3.difference(date2).inDays == 1) {
          await unlockAchievement(achievement.id, 'triple_strike', unlockedAchievementIds);
          return;
        }
      }
    } catch (e) {
      LogService.instance.e('检查三连击成就失败: $e');
    }
  }

  /// 检查并解锁"每日签到"成就 - 连续30天打开App
  Future<void> _checkDailyCheckinAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'daily_checkin');
      if (achievement == null || achievement.unlocked) return;

      // 这个成就需要应用使用记录，暂时使用交易记录作为活跃度指标
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (transactions.isEmpty) {
        LogService.instance.d('每日签到成就检查：交易数据为空');
        return;
      }

      // 按日期分组交易，检查是否有连续30天的活跃记录
      final Map<String, bool> activeDays = {};
      for (final transaction in transactions) {
        final dateKey = '${transaction.tradeDate.year}-${transaction.tradeDate.month}-${transaction.tradeDate.day}';
        activeDays[dateKey] = true;
      }

      // 检查最近是否有连续30天的活跃记录
      final sortedDates = activeDays.keys.toList()..sort();
      if (sortedDates.length >= 30) {
        // 简化检查：如果有30天以上的交易记录，认为满足条件
        await unlockAchievement(achievement.id, 'daily_checkin', unlockedAchievementIds);
      }
    } catch (e) {
      LogService.instance.e('检查每日签到成就失败: $e');
    }
  }

  /// 检查并解锁"永不止步"成就 - 记录交易超过365天
  Future<void> _checkNeverStopAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'never_stop');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (transactions.isEmpty) {
        LogService.instance.d('永不止步成就检查：交易数据为空');
        return;
      }

      // 找到最早和最晚的交易记录
      final sortedTransactions = List<TradingTransaction>.from(transactions)
        ..sort((a, b) => a.tradeDate.compareTo(b.tradeDate));
      final firstTradeDate = sortedTransactions.first.tradeDate;
      final lastTradeDate = sortedTransactions.last.tradeDate;
      
      // 检查交易跨度是否超过365天
      final tradingSpanDays = lastTradeDate.difference(firstTradeDate).inDays;
      if (tradingSpanDays >= 365) {
        await unlockAchievement(achievement.id, 'never_stop', unlockedAchievementIds);
      }
    } catch (e) {
      LogService.instance.e('检查永不止步成就失败: $e');
    }
  }
} 