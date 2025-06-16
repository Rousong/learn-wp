import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/services/achievement/checkers/achievement_checker_base.dart';

/// 资金管理成就检查器
/// 负责检查所有资金管理相关的成就
class FundManagementChecker extends AchievementCheckerBase {

  @override
  Future<void> checkAchievements(
    Map<String, dynamic> basicStats,
    Map<String, dynamic> complexStats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    final tasks = <Future<void>>[];
    
    // 现金流达人 - 添加10笔入金记录
    if (!isAchievementUnlocked(unlockedAchievementIds, 'cash_flow_master')) {
      tasks.add(_checkCashFlowMasterAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 资金管理师 - 添加10笔出金记录
    if (!isAchievementUnlocked(unlockedAchievementIds, 'fund_manager')) {
      tasks.add(_checkFundManagerAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    await Future.wait(tasks);
  }

  /// 检查并解锁"现金流达人"成就 - 添加10笔入金记录
  Future<void> _checkCashFlowMasterAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'cash_flow_master');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final deposits = getSafeListStat<DepositsAndWithdrawal>(stats, 'deposits');
      
      if (deposits.isEmpty) {
        LogService.instance.d('现金流达人成就检查：出入金数据为空');
        return;
      }
      
      // 统计入金记录数量
      final depositCount = deposits.where((deposit) => deposit.isDeposit).length;
      
      if (depositCount >= 10) {
        await unlockAchievement(achievement.id, 'cash_flow_master', unlockedAchievementIds);
      }
    } catch (e) {
      LogService.instance.e('检查现金流达人成就失败: $e');
    }
  }

  /// 检查并解锁"资金管理师"成就 - 添加10笔出金记录
  Future<void> _checkFundManagerAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'fund_manager');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final deposits = getSafeListStat<DepositsAndWithdrawal>(stats, 'deposits');
      
      if (deposits.isEmpty) {
        LogService.instance.d('资金管理师成就检查：出入金数据为空');
        return;
      }
      
      // 统计出金记录数量
      final withdrawalCount = deposits.where((deposit) => !deposit.isDeposit).length;
      
      if (withdrawalCount >= 10) {
        await unlockAchievement(achievement.id, 'fund_manager', unlockedAchievementIds);
      }
    } catch (e) {
      LogService.instance.e('检查资金管理师成就失败: $e');
    }
  }
} 