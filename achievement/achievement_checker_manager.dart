import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/services/achievement/checkers/achievement_checker_base.dart';
import 'package:trade_flex/core/services/achievement/checkers/basic_trading_checker.dart';
import 'package:trade_flex/core/services/achievement/checkers/profit_related_checker.dart';
import 'package:trade_flex/core/services/achievement/checkers/position_management_checker.dart';
import 'package:trade_flex/core/services/achievement/checkers/portfolio_checker.dart';
import 'package:trade_flex/core/services/achievement/checkers/emotion_control_checker.dart';
import 'package:trade_flex/core/services/achievement/checkers/analysis_record_checker.dart';
import 'package:trade_flex/core/services/achievement/checkers/trading_strategy_checker.dart';
import 'package:trade_flex/core/services/achievement/checkers/fund_management_checker.dart';
import 'package:trade_flex/core/services/achievement/checkers/time_management_checker.dart';
import 'package:trade_flex/core/services/achievement/checkers/special_hidden_checker.dart';

/// 成就检查器管理器
/// 统一管理所有成就检查器，协调成就检查流程
class AchievementCheckerManager {
  static AchievementCheckerManager? _instance;
  static AchievementCheckerManager get instance => _instance ??= AchievementCheckerManager._();
  
  AchievementCheckerManager._();

  // 所有成就检查器
  late final List<AchievementCheckerBase> _checkers;

  /// 初始化所有检查器
  void initializeCheckers() {
    _checkers = [
      BasicTradingChecker(),
      ProfitRelatedChecker(),
      PositionManagementChecker(),
      PortfolioChecker(),
      EmotionControlChecker(),
      AnalysisRecordChecker(),
      TradingStrategyChecker(),
      FundManagementChecker(),
      TimeManagementChecker(),
      SpecialHiddenChecker(),
    ];
    
    LogService.instance.i('成就检查器管理器初始化完成，共加载 ${_checkers.length} 个检查器');
  }

  /// 执行优化的成就检查
  Future<void> processOptimizedAchievementChecks(
    Set<String> changedDataTypes,
    Map<String, dynamic> basicStats,
    Map<String, dynamic> complexStats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      LogService.instance.d('开始优化成就检查，变化数据类型: $changedDataTypes');
      
      final checkTasks = <Future<void>>[];
      
      // 根据数据变化类型，选择性执行成就检查
      
      // 交易相关成就检查
      if (changedDataTypes.contains('trading_transactions')) {
        checkTasks.add(_checkers[0].checkAchievements(basicStats, complexStats, achievements, unlockedAchievementIds)); // BasicTradingChecker
        checkTasks.add(_checkers[1].checkAchievements(basicStats, complexStats, achievements, unlockedAchievementIds)); // ProfitRelatedChecker
        checkTasks.add(_checkers[4].checkAchievements(basicStats, complexStats, achievements, unlockedAchievementIds)); // EmotionControlChecker
        checkTasks.add(_checkers[5].checkAchievements(basicStats, complexStats, achievements, unlockedAchievementIds)); // AnalysisRecordChecker
        checkTasks.add(_checkers[6].checkAchievements(basicStats, complexStats, achievements, unlockedAchievementIds)); // TradingStrategyChecker
        checkTasks.add(_checkers[7].checkAchievements(basicStats, complexStats, achievements, unlockedAchievementIds)); // FundManagementChecker
        checkTasks.add(_checkers[8].checkAchievements(basicStats, complexStats, achievements, unlockedAchievementIds)); // TimeManagementChecker
        checkTasks.add(_checkers[9].checkAchievements(basicStats, complexStats, achievements, unlockedAchievementIds)); // SpecialHiddenChecker
      }
      
      // 持仓相关成就检查
      if (changedDataTypes.contains('positions')) {
        checkTasks.add(_checkers[2].checkAchievements(basicStats, complexStats, achievements, unlockedAchievementIds)); // PositionManagementChecker
      }
      
      // 投资组合相关成就检查
      if (changedDataTypes.contains('portfolios') || changedDataTypes.contains('portfolio_snapshots')) {
        checkTasks.add(_checkers[3].checkAchievements(basicStats, complexStats, achievements, unlockedAchievementIds)); // PortfolioChecker
        checkTasks.add(_checkers[5].checkAchievements(basicStats, complexStats, achievements, unlockedAchievementIds)); // AnalysisRecordChecker (快照相关)
      }
      
      // 资金管理相关成就检查
      if (changedDataTypes.contains('deposits_withdrawals')) {
        checkTasks.add(_checkers[7].checkAchievements(basicStats, complexStats, achievements, unlockedAchievementIds)); // FundManagementChecker
      }
      
      // 并行执行所有相关的成就检查
      if (checkTasks.isNotEmpty) {
        await Future.wait(checkTasks);
      }
      
      LogService.instance.d('优化成就检查处理完成');
    } catch (e) {
      LogService.instance.e('处理优化成就检查失败: $e');
    }
  }

  /// 执行全量成就检查（用于初始化或强制检查）
  Future<void> processFullAchievementCheck(
    Map<String, dynamic> basicStats,
    Map<String, dynamic> complexStats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      LogService.instance.d('开始全量成就检查...');
      
      final checkTasks = <Future<void>>[];
      
      // 执行所有检查器
      for (final checker in _checkers) {
        checkTasks.add(checker.checkAchievements(basicStats, complexStats, achievements, unlockedAchievementIds));
      }
      
      // 并行执行所有成就检查
      await Future.wait(checkTasks);
      
      LogService.instance.d('全量成就检查处理完成');
    } catch (e) {
      LogService.instance.e('处理全量成就检查失败: $e');
    }
  }
} 