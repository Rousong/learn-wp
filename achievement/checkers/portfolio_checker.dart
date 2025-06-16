import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/constants/portfolio_enums.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/services/achievement/checkers/achievement_checker_base.dart';

/// 投资组合成就检查器
/// 负责检查所有投资组合相关的成就
class PortfolioChecker extends AchievementCheckerBase {
  @override
  Future<void> checkAchievements(
    Map<String, dynamic> basicStats,
    Map<String, dynamic> complexStats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    final tasks = <Future<void>>[];
    
    // 组合管理者 - 创建并管理3个投资组合
    if (!isAchievementUnlocked(unlockedAchievementIds, 'portfolio_manager')) {
      tasks.add(_checkPortfolioManagerAchievement(complexStats, achievements, unlockedAchievementIds));
    }
    
    // 多市场征服者 - 涉及5个以上市场
    if (!isAchievementUnlocked(unlockedAchievementIds, 'multi_market')) {
      tasks.add(_checkMultiMarketAchievement(complexStats, achievements, unlockedAchievementIds));
    }
    
    // 币圈新人类 - 首次加密货币交易
    if (!isAchievementUnlocked(unlockedAchievementIds, 'crypto_newbie')) {
      tasks.add(_checkCryptoNewbieAchievement(complexStats, achievements, unlockedAchievementIds));
    }
    
    await Future.wait(tasks);
  }

  /// 检查并解锁"组合管理者"成就 - 创建并管理3个投资组合
  Future<void> _checkPortfolioManagerAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'portfolio_manager');
      if (achievement == null || achievement.unlocked) return;

      final portfolioCount = getSafeStat<int>(stats, 'portfolioCount') ?? 0;
      
      if (portfolioCount >= 3) {
        await unlockAchievement(achievement.id, 'portfolio_manager', unlockedAchievementIds);
      }
    } catch (e) {
      LogService.instance.e('检查组合管理者成就失败: $e');
    }
  }

  /// 检查并解锁"多市场征服者"成就 - 记录交易涉及5个以上市场
  Future<void> _checkMultiMarketAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'multi_market');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final portfolios = getSafeListStat<Portfolio>(stats, 'portfolios');
      
      if (portfolios.isEmpty) {
        LogService.instance.d('多市场征服者成就检查：投资组合数据为空');
        return;
      }
      
      // 统计不同的投资组合类型（代表不同市场）
      final uniqueMarkets = portfolios.map((p) => p.portfolioType).toSet();
      
      if (uniqueMarkets.length >= 5) {
        await unlockAchievement(achievement.id, 'multi_market', unlockedAchievementIds);
      }
    } catch (e) {
      LogService.instance.e('检查多市场征服者成就失败: $e');
    }
  }

  /// 检查并解锁"币圈新人类"成就 - 首次记录加密资产交易
  Future<void> _checkCryptoNewbieAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'crypto_newbie');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final portfolios = getSafeListStat<Portfolio>(stats, 'portfolios');
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (portfolios.isEmpty || transactions.isEmpty) {
        LogService.instance.d('币圈新人类成就检查：投资组合或交易数据为空');
        return;
      }
      
      // 检查是否有加密货币类型的投资组合且有交易记录
      for (final portfolio in portfolios) {
        if (portfolio.portfolioType == PortfolioType.crypto) { // 加密货币类型
          // 检查该投资组合是否有交易记录
          final hasTransactions = transactions.any((t) => t.portfolioId == portfolio.id);
          if (hasTransactions) {
            await unlockAchievement(achievement.id, 'crypto_newbie', unlockedAchievementIds);
            return;
          }
        }
      }
    } catch (e) {
      LogService.instance.e('检查币圈新人类成就失败: $e');
    }
  }
} 