import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/services/achievement/checkers/achievement_checker_base.dart';

/// 交易策略成就检查器
/// 负责检查所有交易策略相关的成就
class TradingStrategyChecker extends AchievementCheckerBase {
  @override
  Future<void> checkAchievements(
    Map<String, dynamic> basicStats,
    Map<String, dynamic> complexStats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    final tasks = <Future<void>>[];
    
    // 空军司令 - 首次做空并成功盈利
    if (!isAchievementUnlocked(unlockedAchievementIds, 'short_commander')) {
      tasks.add(_checkShortCommanderAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 对冲大师 - 同时持有多空仓位进行对冲
    if (!isAchievementUnlocked(unlockedAchievementIds, 'hedge_master')) {
      tasks.add(_checkHedgeMasterAchievement(complexStats, achievements, unlockedAchievementIds));
    }
    
    // 批量建仓者 - 单日内对同一标的进行3次以上建仓
    if (!isAchievementUnlocked(unlockedAchievementIds, 'batch_builder')) {
      tasks.add(_checkBatchBuilderAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    await Future.wait(tasks);
  }

  /// 检查并解锁"空军司令"成就 - 首次做空并成功盈利
  Future<void> _checkShortCommanderAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'short_commander');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (transactions.isEmpty) {
        LogService.instance.d('空军司令成就检查：交易数据为空');
        return;
      }

      // 检查是否有做空并盈利的交易
      final profitableShortTrades = transactions.where((t) => 
        t.operate.name == 'closeShort' &&
        t.profitOrLoss != null && 
        double.tryParse(t.profitOrLoss!) != null && 
        double.parse(t.profitOrLoss!) > 0
      ).toList();

      if (profitableShortTrades.isNotEmpty) {
        await unlockAchievement(achievement.id, 'short_commander', unlockedAchievementIds);
      }
    } catch (e) {
      LogService.instance.e('检查空军司令成就失败: $e');
    }
  }

  /// 检查并解锁"对冲大师"成就 - 同时持有多空仓位进行对冲
  Future<void> _checkHedgeMasterAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'hedge_master');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final activePositions = getSafeListStat<Position>(stats, 'activePositions');
      
      if (activePositions.isEmpty) {
        LogService.instance.d('对冲大师成就检查：活跃持仓数据为空');
        return;
      }

      // 按标的分组检查是否有同时持有多空仓位的情况
      final positionsBySymbol = <String, List<Position>>{};
      for (final position in activePositions) {
        positionsBySymbol.putIfAbsent(position.positionSymbol, () => []).add(position);
      }

      // 检查每个标的是否同时有多空仓位
      for (final positions in positionsBySymbol.values) {
        bool hasLong = false;
        bool hasShort = false;
        
        for (final position in positions) {
          if (position.positionDirection.name == 'long') {
            hasLong = true;
          } else if (position.positionDirection.name == 'short') {
            hasShort = true;
          }
        }
        
        // 如果同时有多空仓位，则解锁成就
        if (hasLong && hasShort) {
          await unlockAchievement(achievement.id, 'hedge_master', unlockedAchievementIds);
          return;
        }
      }
    } catch (e) {
      LogService.instance.e('检查对冲大师成就失败: $e');
    }
  }

  /// 检查并解锁"批量建仓者"成就 - 单日内对同一标的进行3次以上建仓
  Future<void> _checkBatchBuilderAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'batch_builder');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (transactions.isEmpty) {
        LogService.instance.d('批量建仓者成就检查：交易数据为空');
        return;
      }

      // 筛选开仓交易
      final openTrades = transactions.where((t) => 
        t.operate.name == 'openLong' || t.operate.name == 'openShort'
      ).toList();

      // 按日期和标的分组
      final tradesByDateAndSymbol = <String, Map<String, List<TradingTransaction>>>{};
      
      for (final trade in openTrades) {
        final dateKey = '${trade.tradeDate.year}-${trade.tradeDate.month}-${trade.tradeDate.day}';
        final symbol = trade.symbol;
        
        tradesByDateAndSymbol.putIfAbsent(dateKey, () => {});
        tradesByDateAndSymbol[dateKey]!.putIfAbsent(symbol, () => []).add(trade);
      }

      // 检查是否有单日内对同一标的进行3次以上建仓
      for (final dateGroup in tradesByDateAndSymbol.values) {
        for (final symbolTrades in dateGroup.values) {
          if (symbolTrades.length >= 3) {
            await unlockAchievement(achievement.id, 'batch_builder', unlockedAchievementIds);
            return;
          }
        }
      }
    } catch (e) {
      LogService.instance.e('检查批量建仓者成就失败: $e');
    }
  }
} 