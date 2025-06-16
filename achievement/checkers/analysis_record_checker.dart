import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/services/achievement/checkers/achievement_checker_base.dart';

/// 分析记录成就检查器
/// 负责检查所有分析记录相关的成就
class AnalysisRecordChecker extends AchievementCheckerBase {


  @override
  Future<void> checkAchievements(
    Map<String, dynamic> basicStats,
    Map<String, dynamic> complexStats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    final tasks = <Future<void>>[];
    
    // 分析大师 - 在投资组合中添加了10条以上的笔记
    if (!isAchievementUnlocked(unlockedAchievementIds, 'analysis_master')) {
      tasks.add(_checkAnalysisMasterAchievement(complexStats, achievements, unlockedAchievementIds));
    }
    
    // 标签爱好者 - 创建并使用10个不同的标签
    if (!isAchievementUnlocked(unlockedAchievementIds, 'tag_lover')) {
      tasks.add(_checkTagLoverAchievement(complexStats, achievements, unlockedAchievementIds));
    }
    
    // 数字洁癖者 - 连续10笔交易的数量和价格都是整数
    if (!isAchievementUnlocked(unlockedAchievementIds, 'number_perfectionist')) {
      tasks.add(_checkNumberPerfectionistAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 详细记录者 - 单笔交易备注信息超过50字
    if (!isAchievementUnlocked(unlockedAchievementIds, 'detail_recorder')) {
      tasks.add(_checkDetailRecorderAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    // 备注达人 - 有10笔交易以上都添加了备注信息
    if (!isAchievementUnlocked(unlockedAchievementIds, 'note_master')) {
      tasks.add(_checkNoteMasterAchievement(basicStats, achievements, unlockedAchievementIds));
    }
    
    await Future.wait(tasks);
  }

  /// 检查并解锁"分析大师"成就 - 在投资组合中添加了10条以上的笔记
  Future<void> _checkAnalysisMasterAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'analysis_master');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final notes = getSafeListStat<Note>(stats, 'notes');
      
      if (notes.isEmpty) {
        LogService.instance.d('分析大师成就检查：笔记数据为空');
        return;
      }
      
      if (notes.length >= 10) {
        await unlockAchievement(achievement.id, 'analysis_master', unlockedAchievementIds);
      }
    } catch (e) {
      LogService.instance.e('检查分析大师成就失败: $e');
    }
  }

  /// 检查并解锁"标签爱好者"成就 - 创建并使用10个不同的标签
  Future<void> _checkTagLoverAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'tag_lover');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final tags = getSafeListStat<Tag>(stats, 'tags');
      
      if (tags.isEmpty) {
        LogService.instance.d('标签爱好者成就检查：标签数据为空');
        return;
      }
      
      if (tags.length >= 10) {
        await unlockAchievement(achievement.id, 'tag_lover', unlockedAchievementIds);
      }
    } catch (e) {
      LogService.instance.e('检查标签爱好者成就失败: $e');
    }
  }

  /// 检查并解锁"数字洁癖者"成就 - 连续10笔交易的数量和价格都是整数
  Future<void> _checkNumberPerfectionistAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'number_perfectionist');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (transactions.isEmpty) {
        LogService.instance.d('数字洁癖者成就检查：交易数据为空');
        return;
      }
      
      // 需要至少10笔交易才能检查
      if (transactions.length < 10) {
        LogService.instance.d('数字洁癖者成就检查：交易数量不足10笔');
        return;
      }
      
      // 按交易日期排序，确保检查的是连续的交易
      final sortedTransactions = List<TradingTransaction>.from(transactions);
      sortedTransactions.sort((a, b) => a.tradeDate.compareTo(b.tradeDate));
      
      // 检查是否存在连续10笔交易的数量和价格都是整数
      int consecutiveCount = 0;
      
      for (final transaction in sortedTransactions) {
        // 检查价格和数量是否都为整数
        if (_isWholeNumber(transaction.price) && _isWholeNumber(transaction.amount)) {
          consecutiveCount++;
          // 如果连续10笔都是整数，解锁成就
          if (consecutiveCount >= 10) {
            await unlockAchievement(achievement.id, 'number_perfectionist', unlockedAchievementIds);
            return;
          }
        } else {
          // 重置连续计数
          consecutiveCount = 0;
        }
      }
    } catch (e) {
      LogService.instance.e('检查数字洁癖者成就失败: $e');
    }
  }

  /// 检查字符串是否表示整数
  bool _isWholeNumber(String value) {
    final number = double.tryParse(value);
    if (number == null) return false;
    return number == number.toInt();
  }

  /// 检查并解锁"详细记录者"成就 - 单笔交易备注信息超过50字
  Future<void> _checkDetailRecorderAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'detail_recorder');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (transactions.isEmpty) {
        LogService.instance.d('详细记录者成就检查：交易数据为空');
        return;
      }
      
      // 检查是否有备注信息超过50字的交易
      for (final transaction in transactions) {
        if (transaction.description != null && 
            transaction.description!.trim().length > 50) {
          await unlockAchievement(achievement.id, 'detail_recorder', unlockedAchievementIds);
          return;
        }
      }
    } catch (e) {
      LogService.instance.e('检查详细记录者成就失败: $e');
    }
  }

  /// 检查并解锁"备注达人"成就 - 有10笔交易以上都添加了备注信息
  Future<void> _checkNoteMasterAchievement(
    Map<String, dynamic> stats,
    List<Achievement> achievements,
    Set<String> unlockedAchievementIds,
  ) async {
    try {
      final achievement = getAchievement(achievements, 'note_master');
      if (achievement == null || achievement.unlocked) return;

      // 安全获取数据，添加空值检查
      final transactions = getSafeListStat<TradingTransaction>(stats, 'transactions');
      
      if (transactions.isEmpty) {
        LogService.instance.d('备注达人成就检查：交易数据为空');
        return;
      }
      
      int transactionsWithNotes = 0;
      
      // 统计有备注信息的交易数量
      for (final transaction in transactions) {
        if (transaction.description != null && 
            transaction.description!.trim().isNotEmpty) {
          transactionsWithNotes++;
        }
      }
      
      if (transactionsWithNotes >= 10) {
        await unlockAchievement(achievement.id, 'note_master', unlockedAchievementIds);
      }
    } catch (e) {
      LogService.instance.e('检查备注达人成就失败: $e');
    }
  }
} 