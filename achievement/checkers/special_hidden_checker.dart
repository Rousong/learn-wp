import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/services/achievement/checkers/achievement_checker_base.dart';

/// 特殊隐藏成就检查器
/// 负责检查所有特殊隐藏成就
class SpecialHiddenChecker extends AchievementCheckerBase {

  @override
  Future<void> checkAchievements(
    Map<String, dynamic> basicStats,
    Map<String, dynamic> complexStats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    final tasks = <Future<void>>[];
    
    // TradeFlex彩蛋 - 交易描述包含"TradeFlex"
    if (!isAchievementUnlocked(unlockedAchievementIds, 'tradeflex')) {
      tasks.add(_checkTradeFlexAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 午夜交易员 - 在凌晨0点到3点之间添加了一笔交易
    if (!isAchievementUnlocked(unlockedAchievementIds, 'midnight_trader')) {
      tasks.add(_checkMidnightTraderAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 起得真早 - 凌晨5点之前记录一笔交易
    if (!isAchievementUnlocked(unlockedAchievementIds, 'early_bird')) {
      tasks.add(_checkEarlyBirdAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 深夜选手 - 凌晨1点还在修改交易笔记
    if (!isAchievementUnlocked(unlockedAchievementIds, 'night_owl')) {
      tasks.add(_checkNightOwlAchievement(complexStats, achievements, unlockedAchievementIds));
    }
    
    // 光速操作 - 在1分钟内完成开仓和平仓
    if (!isAchievementUnlocked(unlockedAchievementIds, 'lightning_speed')) {
      tasks.add(_checkLightningSpeedAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 系统超载 - 一天内添加了50条交易记录
    if (!isAchievementUnlocked(unlockedAchievementIds, 'system_overload')) {
      tasks.add(_checkSystemOverloadAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 新年开门红 - 在新年第一天记录盈利交易
    if (!isAchievementUnlocked(unlockedAchievementIds, 'new_year')) {
      tasks.add(_checkNewYearAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 披萨节纪念 - 在比特币披萨节当天买入BTC
    if (!isAchievementUnlocked(unlockedAchievementIds, 'pizza_day')) {
      tasks.add(_checkPizzaDayAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 圣诞奇迹 - 在圣诞节当天记录交易
    if (!isAchievementUnlocked(unlockedAchievementIds, 'christmas')) {
      tasks.add(_checkChristmasAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 感恩收获 - 在感恩节当天回顾并总结全年交易心得
    if (!isAchievementUnlocked(unlockedAchievementIds, 'thanksgiving')) {
      tasks.add(_checkThanksgivingAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 兑换初体验 - 首次使用兑换交易功能
    if (!isAchievementUnlocked(unlockedAchievementIds, 'first_exchange')) {
      tasks.add(_checkFirstExchangeAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    await Future.wait(tasks);
  }

  /// 检查并解锁"TradeFlex"彩蛋成就
  Future<void> _checkTradeFlexAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'tradeflex');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (transactions.isEmpty) {
        LogService.instance.d('TradeFlex彩蛋成就检查：交易数据为空');
        return;
      }
      
      // 检查是否有交易描述包含"TradeFlex"
      for (final transaction in transactions) {
        if (transaction.description != null &&
            transaction.description!.toLowerCase().contains('tradeflex')) {
          await unlockAchievement(achievement.id, 'tradeflex', unlockedAchievementIds);
          return;
        }
      }
    } catch (e) {
      LogService.instance.e('检查TradeFlex彩蛋成就失败: $e');
    }
  }

  /// 检查并解锁"午夜交易员"成就
  Future<void> _checkMidnightTraderAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'midnight_trader');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (transactions.isEmpty) {
        LogService.instance.d('午夜交易员成就检查：交易数据为空');
        return;
      }
      
      // 检查是否有在凌晨0-3点的交易
      for (final transaction in transactions) {
        final hour = transaction.tradeDate.hour;
        if (hour >= 0 && hour < 3) {
          await unlockAchievement(achievement.id, 'midnight_trader', unlockedAchievementIds);
          return;
        }
      }
    } catch (e) {
      LogService.instance.e('检查午夜交易员成就失败: $e');
    }
  }

  /// 检查并解锁"起得真早"成就
  Future<void> _checkEarlyBirdAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'early_bird');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (transactions.isEmpty) {
        LogService.instance.d('起得真早成就检查：交易数据为空');
        return;
      }
      
      // 检查是否有在凌晨5点前的交易
      for (final transaction in transactions) {
        final hour = transaction.tradeDate.hour;
        if (hour < 5) {
          await unlockAchievement(achievement.id, 'early_bird', unlockedAchievementIds);
          return;
        }
      }
    } catch (e) {
      LogService.instance.e('检查起得真早成就失败: $e');
    }
  }

  /// 检查并解锁"深夜选手"成就
  Future<void> _checkNightOwlAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'night_owl');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final notes = getSafeListStat<Note>(stats, 'notes');
      
      if (notes.isEmpty) {
        LogService.instance.d('深夜选手成就检查：笔记数据为空');
        return;
      }
      
      // 检查是否有在凌晨1点创建或修改的笔记
      for (final note in notes) {
        final hour = note.createTime.hour;
        if (hour == 1) { // 凌晨1点
          await unlockAchievement(achievement.id, 'night_owl', unlockedAchievementIds);
          return;
        }
      }
    } catch (e) {
      LogService.instance.e('检查深夜选手成就失败: $e');
    }
  }

  /// 检查并解锁"光速操作"成就
  Future<void> _checkLightningSpeedAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'lightning_speed');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (transactions.isEmpty) {
        LogService.instance.d('光速操作成就检查：交易数据为空');
        return;
      }
      
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
          final isOpenClose = (currentTrade.operate.name == 'openLong' || currentTrade.operate.name == 'openShort') && 
                             (nextTrade.operate.name == 'closeLong' || nextTrade.operate.name == 'closeShort');
          
          if (isOpenClose) {
            final timeDiff = nextTrade.tradeDate.difference(currentTrade.tradeDate);
            if (timeDiff.inMinutes <= 1) {
              await unlockAchievement(achievement.id, 'lightning_speed', unlockedAchievementIds);
              return;
            }
          }
        }
      }
    } catch (e) {
      LogService.instance.e('检查光速操作成就失败: $e');
    }
  }

  /// 检查并解锁"系统超载"成就
  Future<void> _checkSystemOverloadAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'system_overload');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (transactions.isEmpty) {
        LogService.instance.d('系统超载成就检查：交易数据为空');
        return;
      }
      
      // 按日期分组交易
      final Map<String, int> transactionCountByDate = {};
      for (final transaction in transactions) {
        final dateKey = '${transaction.tradeDate.year}-${transaction.tradeDate.month}-${transaction.tradeDate.day}';
        transactionCountByDate[dateKey] = (transactionCountByDate[dateKey] ?? 0) + 1;
      }

      // 检查是否有单日50条以上的交易记录
      for (final count in transactionCountByDate.values) {
        if (count >= 50) {
          await unlockAchievement(achievement.id, 'system_overload', unlockedAchievementIds);
          return;
        }
      }
    } catch (e) {
      LogService.instance.e('检查系统超载成就失败: $e');
    }
  }

  /// 检查并解锁"新年开门红"成就
  Future<void> _checkNewYearAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'new_year');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (transactions.isEmpty) {
        LogService.instance.d('新年开门红成就检查：交易数据为空');
        return;
      }
      
      // 检查是否有在新年第一天(1月1日)的盈利交易
      for (final transaction in transactions) {
        if (transaction.tradeDate.month == 1 && transaction.tradeDate.day == 1) {
          // 检查是否为盈利交易
          if (transaction.profitOrLoss != null) {
            final profit = double.tryParse(transaction.profitOrLoss!) ?? 0;
            if (profit > 0) {
              await unlockAchievement(achievement.id, 'new_year', unlockedAchievementIds);
              return;
            }
          }
        }
      }
    } catch (e) {
      LogService.instance.e('检查新年开门红成就失败: $e');
    }
  }

  /// 检查并解锁"披萨节纪念"成就
  Future<void> _checkPizzaDayAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'pizza_day');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (transactions.isEmpty) {
        LogService.instance.d('披萨节纪念成就检查：交易数据为空');
        return;
      }
      
      // 检查是否有在5月22日买入BTC的交易
      for (final transaction in transactions) {
        if (transaction.tradeDate.month == 5 && transaction.tradeDate.day == 22) {
          // 检查是否为买入BTC的交易
          if ((transaction.operate.name == 'openLong' || transaction.operate.name == 'openShort') &&
              transaction.symbol.toUpperCase().contains('BTC')) {
            await unlockAchievement(achievement.id, 'pizza_day', unlockedAchievementIds);
            return;
          }
        }
      }
    } catch (e) {
      LogService.instance.e('检查披萨节纪念成就失败: $e');
    }
  }

  /// 检查并解锁"圣诞奇迹"成就
  Future<void> _checkChristmasAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'christmas');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (transactions.isEmpty) {
        LogService.instance.d('圣诞奇迹成就检查：交易数据为空');
        return;
      }
      
      // 检查是否有在12月25日的交易记录
      for (final transaction in transactions) {
        if (transaction.tradeDate.month == 12 && transaction.tradeDate.day == 25) {
          await unlockAchievement(achievement.id, 'christmas', unlockedAchievementIds);
          return;
        }
      }
    } catch (e) {
      LogService.instance.e('检查圣诞奇迹成就失败: $e');
    }
  }

  /// 检查并解锁"感恩收获"成就
  Future<void> _checkThanksgivingAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'thanksgiving');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (transactions.isEmpty) {
        LogService.instance.d('感恩收获成就检查：交易数据为空');
        return;
      }
      
      // 检查是否有在感恩节(11月28日)的交易记录
      for (final transaction in transactions) {
        if (transaction.tradeDate.month == 11 && transaction.tradeDate.day == 28) {
          // 检查是否有详细的交易描述(表示回顾总结)
          if (transaction.description != null && transaction.description!.length >= 20) {
            await unlockAchievement(achievement.id, 'thanksgiving', unlockedAchievementIds);
            return;
          }
        }
      }
    } catch (e) {
      LogService.instance.e('检查感恩收获成就失败: $e');
    }
  }

  /// 检查并解锁"兑换初体验"成就
  Future<void> _checkFirstExchangeAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'first_exchange');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (transactions.isEmpty) {
        LogService.instance.d('兑换初体验成就检查：交易数据为空');
        return;
      }
      
      // 检查是否有兑换交易
      for (final transaction in transactions) {
        if (transaction.operate.name == 'swapFrom') {
          await unlockAchievement(achievement.id, 'first_exchange', unlockedAchievementIds);
          return;
        }
      }
    } catch (e) {
      LogService.instance.e('检查兑换初体验成就失败: $e');
    }
  }
} 