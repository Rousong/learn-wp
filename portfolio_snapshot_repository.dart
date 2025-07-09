import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Value;
import 'package:trade_flex/core/constants/trading_transactions_enums.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/database/DAO/portfolio_snapshot_dao.dart';
import 'package:trade_flex/core/repositories/deposit_withdrawal_repository.dart';
import 'package:trade_flex/core/repositories/position_repository.dart';
import 'package:trade_flex/core/repositories/trading_transaction_repository.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/utils/decimal_utils.dart';
import 'dart:convert';

/// 投资组合快照类型枚举
enum SnapshotType {
  /// 每日快照
  daily(0),
  
  /// 每周快照
  weekly(1),
  
  /// 每月快照
  monthly(2),
  
  /// 每季度快照
  quarterly(3),
  
  /// 每年快照
  yearly(4),
  
  /// 手动快照
  manual(5);
  
  final int value;
  const SnapshotType(this.value);
}

/// 投资组合快照仓库
/// 
/// 负责管理投资组合快照数据
class PortfolioSnapshotRepository {
  /// 单例实例
  static final PortfolioSnapshotRepository instance = PortfolioSnapshotRepository._init();
  
  /// 私有构造函数
  PortfolioSnapshotRepository._init();
  
  /// 投资组合快照Dao
  final PortfolioSnapshotDAO _dao = PortfolioSnapshotDAO.instance;
  
  /// 获取所有快照
  Future<List<PortfolioSnapshot>> getAllSnapshots() async {
    return await _dao.getAllSnapshots();
  }
  
  /// 根据投资组合ID获取所有快照
  Future<List<PortfolioSnapshot>> getSnapshotsByPortfolioId(int portfolioId) async {
    return await _dao.getSnapshotsByPortfolioId(portfolioId);
  }
  
  /// 根据投资组合ID获取所有快照日期（性能优化版本）
  /// 只返回有快照的日期，不返回完整快照数据
  Future<List<DateTime>> getSnapshotDatesByPortfolioId(int portfolioId) async {
    try {
      LogService.instance.d('获取投资组合 $portfolioId 的所有快照日期（轻量版）');
      // 调用仓库层获取日期数据
      final dates = await _dao.getSnapshotDatesByPortfolioId(portfolioId);
      LogService.instance.d('获取到 ${dates.length} 个快照日期');
      return dates;
    } catch (e) {
      LogService.instance.e('获取快照日期失败: $e');
      return [];
    }
  }
  
  /// 获取指定投资组合的最近快照
  Future<PortfolioSnapshot?> getLatestSnapshot(int portfolioId) async {
    return await _dao.getLatestSnapshot(portfolioId);
  }
  
  /// 获取特定日期范围内的快照
  Future<List<PortfolioSnapshot>> getSnapshotsByDateRange(
    int portfolioId, DateTime startDate, DateTime endDate) async {
    return await _dao.getSnapshotsByDateRange(portfolioId, startDate, endDate);
  }
  
  /// 获取特定日期的快照
  Future<PortfolioSnapshot?> getSnapshotByDate(int portfolioId, DateTime date) async {
    return await _dao.getSnapshotByDate(portfolioId, date);
  }
  
  /// 生成快照
  /// 
  /// [portfolioId] 投资组合ID
  /// [snapshotType] 快照类型
  /// [date] 快照日期，默认为当前时间
  Future<PortfolioSnapshot> createSnapshot(
    int portfolioId, 
    SnapshotType snapshotType, 
    {DateTime? date}
  ) async {
    final now = DateTime.now();
    final snapshotDate = date ?? now;
    
    try {
      LogService.instance.d('开始创建投资组合 $portfolioId 的快照，类型: ${snapshotType.name}');
      
      // 计算快照数据
      final snapshotData = await _calculatePortfolioSnapshot(portfolioId, snapshotDate);
      
      // 创建快照记录
      final companion = PortfolioSnapshotsCompanion.insert(
        portfolioId: portfolioId,
        snapshotDate: snapshotDate,
        snapshotType: Value(snapshotType.value),
        totalDeposits: snapshotData['totalDeposits']!,
        totalWithdrawals: snapshotData['totalWithdrawals']!,
        netDeposits: snapshotData['netDeposits']!,
        totalCost: snapshotData['totalCost']!,
        totalMarketValue: snapshotData['totalMarketValue']!,
        unrealizedProfitLoss: snapshotData['unrealizedProfitLoss']!,
        realizedProfitLoss: snapshotData['realizedProfitLoss']!,
        totalProfitLoss: snapshotData['totalProfitLoss']!,
        cashBalance: snapshotData['cashBalance']!,
        totalAssets: snapshotData['totalAssets']!,
        returnRate: snapshotData['returnRate']!,
        assetAllocation: Value(snapshotData['assetAllocation'] ?? '{}'),
        profitAmount: Value(snapshotData['profitAmount'] ?? '0'),
        lossAmount: Value(snapshotData['lossAmount'] ?? '0'),
        winCount: Value(int.tryParse(snapshotData['winCount'] ?? '0') ?? 0),
        lossCount: Value(int.tryParse(snapshotData['lossCount'] ?? '0') ?? 0),
        buyCount: Value(int.tryParse(snapshotData['buyCount'] ?? '0') ?? 0),
        sellCount: Value(int.tryParse(snapshotData['sellCount'] ?? '0') ?? 0),
        extremeFearTradeCount: Value(int.tryParse(snapshotData['extremeFearTradeCount'] ?? '0') ?? 0),
        fearTradeCount: Value(int.tryParse(snapshotData['fearTradeCount'] ?? '0') ?? 0),
        neutralTradeCount: Value(int.tryParse(snapshotData['neutralTradeCount'] ?? '0') ?? 0),
        greedTradeCount: Value(int.tryParse(snapshotData['greedTradeCount'] ?? '0') ?? 0),
        extremeGreedTradeCount: Value(int.tryParse(snapshotData['extremeGreedTradeCount'] ?? '0') ?? 0),
        extremeFearProfitLoss: Value(snapshotData['extremeFearProfitLoss'] ?? '0'),
        fearProfitLoss: Value(snapshotData['fearProfitLoss'] ?? '0'),
        neutralProfitLoss: Value(snapshotData['neutralProfitLoss'] ?? '0'),
        greedProfitLoss: Value(snapshotData['greedProfitLoss'] ?? '0'),
        extremeGreedProfitLoss: Value(snapshotData['extremeGreedProfitLoss'] ?? '0'),
        createTime: now,
        updateTime: now,
      );
      
      // 插入快照
      final result = await _dao.insertSnapshot(companion);
      LogService.instance.d('成功创建投资组合快照，ID: ${result.id}');
      
      return result;
    } catch (e) {
      LogService.instance.e('创建投资组合快照失败: $e');
      rethrow;
    }
  }
  
  /// 更新快照数据
  /// 
  /// 允许直接修改指定快照的字段值
  /// 
  /// [snapshotId] 快照ID
  /// [updates] 需要更新的字段，可选
  Future<bool> updateSnapshot(
    int snapshotId, {
    String? totalDeposits,
    String? totalWithdrawals,
    String? netDeposits,
    String? totalCost,
    String? totalMarketValue,
    String? unrealizedProfitLoss,
    String? realizedProfitLoss,
    String? totalProfitLoss,
    String? cashBalance,
    String? totalAssets,
    String? returnRate,
    String? assetAllocation,
    String? profitAmount,
    String? lossAmount,
    int? winCount,
    int? lossCount,
    int? buyCount,
    int? sellCount,
    int? extremeFearTradeCount,
    int? fearTradeCount,
    int? neutralTradeCount,
    int? greedTradeCount,
    int? extremeGreedTradeCount,
    String? extremeFearProfitLoss,
    String? fearProfitLoss,
    String? neutralProfitLoss,
    String? greedProfitLoss,
    String? extremeGreedProfitLoss,
  }) async {
    try {
      LogService.instance.d('更新快照数据: 快照ID=$snapshotId');
      
      // 首先获取当前快照
      final snapshot = await _dao.getSnapshotById(snapshotId);
      if (snapshot == null) {
        LogService.instance.e('未找到快照: ID=$snapshotId');
        return false;
      }
      
      // 创建更新对象
      final now = DateTime.now();
      final companion = PortfolioSnapshotsCompanion(
        updateTime: Value(now),
        // 只更新有值的字段
        totalDeposits: totalDeposits != null ? Value(totalDeposits) : const Value.absent(),
        totalWithdrawals: totalWithdrawals != null ? Value(totalWithdrawals) : const Value.absent(),
        netDeposits: netDeposits != null ? Value(netDeposits) : const Value.absent(),
        totalCost: totalCost != null ? Value(totalCost) : const Value.absent(),
        totalMarketValue: totalMarketValue != null ? Value(totalMarketValue) : const Value.absent(),
        unrealizedProfitLoss: unrealizedProfitLoss != null ? Value(unrealizedProfitLoss) : const Value.absent(),
        realizedProfitLoss: realizedProfitLoss != null ? Value(realizedProfitLoss) : const Value.absent(),
        totalProfitLoss: totalProfitLoss != null ? Value(totalProfitLoss) : const Value.absent(),
        cashBalance: cashBalance != null ? Value(cashBalance) : const Value.absent(),
        totalAssets: totalAssets != null ? Value(totalAssets) : const Value.absent(),
        returnRate: returnRate != null ? Value(returnRate) : const Value.absent(),
        assetAllocation: assetAllocation != null ? Value(assetAllocation) : const Value.absent(),
        profitAmount: profitAmount != null ? Value(profitAmount) : const Value.absent(),
        lossAmount: lossAmount != null ? Value(lossAmount) : const Value.absent(),
        winCount: winCount != null ? Value(winCount) : const Value.absent(),
        lossCount: lossCount != null ? Value(lossCount) : const Value.absent(),
        buyCount: buyCount != null ? Value(buyCount) : const Value.absent(),
        sellCount: sellCount != null ? Value(sellCount) : const Value.absent(),
        extremeFearTradeCount: extremeFearTradeCount != null ? Value(extremeFearTradeCount) : const Value.absent(),
        fearTradeCount: fearTradeCount != null ? Value(fearTradeCount) : const Value.absent(),
        neutralTradeCount: neutralTradeCount != null ? Value(neutralTradeCount) : const Value.absent(),
        greedTradeCount: greedTradeCount != null ? Value(greedTradeCount) : const Value.absent(),
        extremeGreedTradeCount: extremeGreedTradeCount != null ? Value(extremeGreedTradeCount) : const Value.absent(),
        extremeFearProfitLoss: extremeFearProfitLoss != null ? Value(extremeFearProfitLoss) : const Value.absent(),
        fearProfitLoss: fearProfitLoss != null ? Value(fearProfitLoss) : const Value.absent(),
        neutralProfitLoss: neutralProfitLoss != null ? Value(neutralProfitLoss) : const Value.absent(),
        greedProfitLoss: greedProfitLoss != null ? Value(greedProfitLoss) : const Value.absent(),
        extremeGreedProfitLoss: extremeGreedProfitLoss != null ? Value(extremeGreedProfitLoss) : const Value.absent(),
      );
      
      // 更新快照
      final rowsAffected = await _dao.updateSnapshot(snapshotId, companion);
      final success = rowsAffected > 0;
      
      if (success) {
        LogService.instance.d('成功更新快照数据: ID=$snapshotId');
      } else {
        LogService.instance.e('更新快照数据失败: ID=$snapshotId, 没有行被更新');
      }
      
      return success;
    } catch (e) {
      LogService.instance.e('更新快照数据失败: $e');
      return false;
    }
  }
  
  /// 创建每日快照
  Future<PortfolioSnapshot> createDailySnapshot(int portfolioId) async {
    return await createSnapshot(portfolioId, SnapshotType.daily);
  }
  
  /// 创建每周快照
  Future<PortfolioSnapshot> createWeeklySnapshot(int portfolioId) async {
    return await createSnapshot(portfolioId, SnapshotType.weekly);
  }
  
  /// 创建每月快照
  Future<PortfolioSnapshot> createMonthlySnapshot(int portfolioId) async {
    return await createSnapshot(portfolioId, SnapshotType.monthly);
  }
  
  /// 创建季度快照
  Future<PortfolioSnapshot> createQuarterlySnapshot(int portfolioId) async {
    return await createSnapshot(portfolioId, SnapshotType.quarterly);
  }
  
  /// 创建年度快照
  Future<PortfolioSnapshot> createYearlySnapshot(int portfolioId) async {
    return await createSnapshot(portfolioId, SnapshotType.yearly);
  }
  
  /// 创建手动快照
  Future<PortfolioSnapshot> createManualSnapshot(int portfolioId) async {
    return await createSnapshot(portfolioId, SnapshotType.manual);
  }
  
  /// 计算投资组合的快照数据
  /// 
  /// [portfolioId] 投资组合ID
  /// [date] 快照日期
  /// 
  /// 返回快照数据映射表
  Future<Map<String, String>> _calculatePortfolioSnapshot(int portfolioId, DateTime date) async {
    try {
      final depositWithdrawalRepository = DepositWithdrawalRepository.instance;
      final positionRepository = PositionRepository.instance;
      final transactionRepository = TradingTransactionRepository.instance;
      
      // 1. 获取所有入金和出金记录
      final depositWithdrawals = await depositWithdrawalRepository.getDepositWithdrawalsByPortfolioId(portfolioId);
      
      // 2. 分离入金和出金
      final deposits = depositWithdrawals.where((dw) => dw.isDeposit).toList();
      final withdrawals = depositWithdrawals.where((dw) => !dw.isDeposit).toList();
      
      // 3. 计算总入金和出金
      Decimal totalDeposits = Decimal.zero;
      for (final deposit in deposits) {
        totalDeposits += DecimalUtils.parseDecimal(deposit.amount);
      }
      
      Decimal totalWithdrawals = Decimal.zero;
      for (final withdrawal in withdrawals) {
        totalWithdrawals += DecimalUtils.parseDecimal(withdrawal.amount);
      }
      
      // 4. 计算净入金
      final netDeposits = totalDeposits - totalWithdrawals;
      
      // 5. 获取所有持仓
      final positions = await positionRepository.getPositions(true, portfolioId) + 
                        await positionRepository.getPositions(false, portfolioId);
      
      // 6. 计算持仓总成本和市值
      Decimal totalCost = Decimal.zero;
      Decimal totalMarketValue = Decimal.zero;
      
      // 用于计算资产分配比例
      Map<String, Decimal> assetMarketValues = {};
      
      for (final position in positions) {
        // 跳过持仓数量为0的持仓
        if (position.totalHoldCnt == "0") continue;
        
        // 获取持仓成本和市值
        final avgPrice = DecimalUtils.parseDecimal(position.totalAvgPrice);
        final holdCount = DecimalUtils.parseDecimal(position.totalHoldCnt);
        final marketPrice = DecimalUtils.parseDecimal(position.latestPrice);
        
        // 计算成本和市值
        final cost = avgPrice * holdCount;
        final marketValue = marketPrice * holdCount;
        
        // 记录各资产的市值(使用symbol作为key)
        assetMarketValues[position.positionSymbol] = marketValue;
        
        totalCost += cost;
        totalMarketValue += marketValue;
      }

      // 将资产分配比例转换为JSON字符串
      Map<String, String> assetAllocation = {};
      for (final entry in assetMarketValues.entries) {
        assetAllocation[entry.key] = entry.value.toString();
      }
      
      final assetAllocationJson = jsonEncode(assetAllocation);
      LogService.instance.d('资产分配比例: $assetAllocationJson');
      
      // 7. 计算未实现盈亏
      final unrealizedProfitLoss = totalMarketValue - totalCost;
      
      // 8. 计算已实现盈亏（平仓盈亏总和）
      Decimal realizedProfitLoss = Decimal.zero;
      
      // 计算盈利和亏损金额
      Decimal profitAmount = Decimal.zero;  
      Decimal lossAmount = Decimal.zero;
      
      // 遍历所有子持仓，分别统计盈利和亏损金额
      for (final p in positions) {
        final pl = DecimalUtils.parseDecimal(p.totalProfitOrLoss);
        if (pl > Decimal.zero) {
          profitAmount += pl;
        } else if (pl < Decimal.zero) {
          // 亏损金额存储为正数，便于计算和显示
          lossAmount += pl.abs();
        }
        // 不管盈利还是亏损，都要加到总的已实现盈亏中
        realizedProfitLoss += pl;
      }
      
      // 9. 计算总盈亏
      final totalProfitLoss = unrealizedProfitLoss + realizedProfitLoss;
      
      // 10. 计算现金余额
      final cashBalance = netDeposits - totalCost;
      
      // 11. 计算总资产
      final totalAssets = totalMarketValue + cashBalance;
      
      // 12. 计算收益率（直接存储百分比值）
      String returnRateStr;
      if (netDeposits == Decimal.zero) {
        returnRateStr = '0';
      } else {
        // 使用安全除法计算收益率，避免精度问题
        final returnRateDecimal = DecimalUtils.safeDivide(
          totalProfitLoss, 
          netDeposits, 
          scale: DecimalUtils.percentScale
        ) * Decimal.fromInt(100);
        
        // 格式化为保留2位小数的字符串
        returnRateStr = DecimalUtils.formatDecimal(returnRateDecimal, 2);
      }
      
      // 13. 计算交易次数统计
      final transactions = await transactionRepository.getTradesByPortfolio(portfolioId.toString());
      
      int winCount = 0;
      int lossCount = 0;
      int buyCount = 0;
      int sellCount = 0;
      
      for (final transaction in transactions) {
        // 统计买入卖出次数
        if (transaction.operate == TradeOperate.openLong || transaction.operate == TradeOperate.openShort) { // 买入
          buyCount++;
        } else if (transaction.operate == TradeOperate.closeLong || transaction.operate == TradeOperate.closeShort) { // 卖出
          sellCount++;
        }
        
        // 统计盈亏次数
        if (transaction.profitOrLoss != null) {
          final pl = double.tryParse(transaction.profitOrLoss!) ?? 0;
          if (pl > 0) {
            winCount++;
          } else if (pl < 0) {
            lossCount++;
          }
        }
      }
      
      // 14. 恐惧贪婪指数与盈亏关系统计
      Map<String, String> fearGreedStats = {
        'extremeFearTradeCount': '0',
        'fearTradeCount': '0',
        'neutralTradeCount': '0',
        'greedTradeCount': '0',
        'extremeGreedTradeCount': '0',
        'extremeFearProfitLoss': '0',
        'fearProfitLoss': '0',
        'neutralProfitLoss': '0',
        'greedProfitLoss': '0',
        'extremeGreedProfitLoss': '0',
      };
      
      // 计算不同情绪状态下的盈亏情况
      final profitByFearGreed = {
        'extremeFear': Decimal.zero,  // 极度恐惧
        'fear': Decimal.zero,         // 恐惧
        'neutral': Decimal.zero,      // 中性
        'greed': Decimal.zero,        // 贪婪
        'extremeGreed': Decimal.zero, // 极度贪婪
      };
      
      final countByFearGreed = {
        'extremeFear': 0,
        'fear': 0,
        'neutral': 0,
        'greed': 0,
        'extremeGreed': 0,
      };
      
      //遍历所有平仓交易
      for (final transaction in transactions.where((t) => 
          t.operate == TradeOperate.closeLong || 
          t.operate == TradeOperate.closeShort)) {
        
        
          final profitLoss = DecimalUtils.parseDecimal(transaction.profitOrLoss!);
          final fearGreedValue = transaction.fearGreedIndex;
          
          // 根据恐惧贪婪值确定类别
          String category;
          if (fearGreedValue <= 25) {
            category = 'extremeFear';
          } else if (fearGreedValue <= 45) {
            category = 'fear';
          } else if (fearGreedValue <= 55) {
            category = 'neutral';
          } else if (fearGreedValue <= 75) {
            category = 'greed';
          } else {
            category = 'extremeGreed';
          }
          
          // 累加盈亏和计数
          profitByFearGreed[category] = profitByFearGreed[category]! + profitLoss;
          countByFearGreed[category] = countByFearGreed[category]! + 1;
        
      }
      
      // 更新统计结果
      fearGreedStats = {
        'extremeFearTradeCount': countByFearGreed['extremeFear'].toString(),
        'fearTradeCount': countByFearGreed['fear'].toString(),
        'neutralTradeCount': countByFearGreed['neutral'].toString(),
        'greedTradeCount': countByFearGreed['greed'].toString(),
        'extremeGreedTradeCount': countByFearGreed['extremeGreed'].toString(),
        'extremeFearProfitLoss': profitByFearGreed['extremeFear'].toString(),
        'fearProfitLoss': profitByFearGreed['fear'].toString(),
        'neutralProfitLoss': profitByFearGreed['neutral'].toString(),
        'greedProfitLoss': profitByFearGreed['greed'].toString(),
        'extremeGreedProfitLoss': profitByFearGreed['extremeGreed'].toString(),
      };
      
      // 15. 返回计算结果，添加资产分配比例
      return {
        'totalDeposits': totalDeposits.toString(),
        'totalWithdrawals': totalWithdrawals.toString(),
        'netDeposits': netDeposits.toString(),
        'totalCost': totalCost.toString(),
        'totalMarketValue': totalMarketValue.toString(),
        'unrealizedProfitLoss': unrealizedProfitLoss.toString(),
        'realizedProfitLoss': realizedProfitLoss.toString(),
        'totalProfitLoss': totalProfitLoss.toString(),
        'cashBalance': cashBalance.toString(),
        'totalAssets': totalAssets.toString(),
        'returnRate': returnRateStr,
        'assetAllocation': assetAllocationJson,
        'profitAmount': profitAmount.toString(),
        'lossAmount': lossAmount.toString(),
        'winCount': winCount.toString(),
        'lossCount': lossCount.toString(),
        'buyCount': buyCount.toString(),
        'sellCount': sellCount.toString(),
        ...fearGreedStats,
      };
    } catch (e) {
      LogService.instance.e('计算投资组合快照数据失败: $e');
      // 返回默认值
      return {
        'totalDeposits': '0',
        'totalWithdrawals': '0',
        'netDeposits': '0',
        'totalCost': '0',
        'totalMarketValue': '0',
        'unrealizedProfitLoss': '0',
        'realizedProfitLoss': '0',
        'totalProfitLoss': '0',
        'cashBalance': '0',
        'totalAssets': '0',
        'returnRate': '0',
        'assetAllocation': '{}',
        'profitAmount': '0',
        'lossAmount': '0',
        'winCount': '0',
        'lossCount': '0',
        'buyCount': '0',
        'sellCount': '0',
        'extremeFearTradeCount': '0',
        'fearTradeCount': '0',
        'neutralTradeCount': '0',
        'greedTradeCount': '0',
        'extremeGreedTradeCount': '0',
        'extremeFearProfitLoss': '0',
        'fearProfitLoss': '0',
        'neutralProfitLoss': '0',
        'greedProfitLoss': '0',
        'extremeGreedProfitLoss': '0',
      };
    }
  }
  
  /// 检查是否需要创建新快照
  /// 
  /// [portfolioId] 投资组合ID
  /// [snapshotType] 快照类型
  Future<bool> shouldCreateNewSnapshot(int portfolioId, SnapshotType snapshotType) async {
    try {
      // 获取最近的特定类型快照
      final latestSnapshot = await _dao.getLatestSnapshotByType(portfolioId, snapshotType.value);
      
      // 如果没有快照，则需要创建
      if (latestSnapshot == null) {
        return true;
      }
      
      // 获取当前日期
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // 获取最近快照的日期
      final latestDate = latestSnapshot.snapshotDate;
      final latestDay = DateTime(latestDate.year, latestDate.month, latestDate.day);
      
      // 根据快照类型确定是否需要创建新快照
      switch (snapshotType) {
        case SnapshotType.daily:
          // 检查是否是今天的快照
          return latestDay.isBefore(today);
          
        case SnapshotType.weekly:
          // 检查是否是本周的快照
          final weekStart = today.subtract(Duration(days: today.weekday - 1));
          return latestDate.isBefore(weekStart);
          
        case SnapshotType.monthly:
          // 检查是否是本月的快照
          final monthStart = DateTime(today.year, today.month, 1);
          return latestDate.isBefore(monthStart);
          
        case SnapshotType.quarterly:
          // 检查是否是本季度的快照
          final quarter = (today.month - 1) ~/ 3;
          final quarterStart = DateTime(today.year, quarter * 3 + 1, 1);
          return latestDate.isBefore(quarterStart);
          
        case SnapshotType.yearly:
          // 检查是否是本年的快照
          final yearStart = DateTime(today.year, 1, 1);
          return latestDate.isBefore(yearStart);
          
        case SnapshotType.manual:
          // 手动快照总是需要创建新的
          return true;
      }
    } catch (e) {
      LogService.instance.e('检查是否需要创建新快照失败: $e');
      // 默认创建新快照
      return true;
    }
  }
  
  /// 清理旧快照数据
  /// 
  /// [portfolioId] 投资组合ID
  /// [keepDuration] 保留时长，默认值如下:
  /// - 每日快照: 90天
  /// - 每周快照: 365天
  /// - 每月快照: 0 (永久保留)
  /// - 季度快照: 0 (永久保留)
  /// - 年度快照: 0 (永久保留)
  Future<void> cleanupOldSnapshots(int portfolioId, {
    int keepDailyDays = 90,
    int keepWeeklyDays = 365,
    int keepMonthlyDays = 0, // 0表示永久保留
    int keepQuarterlyDays = 0,
    int keepYearlyDays = 0,
  }) async {
    try {
      final now = DateTime.now();
      
      // 清理每日快照
      if (keepDailyDays > 0) {
        final cutoffDate = now.subtract(Duration(days: keepDailyDays));
        await _dao.deleteSnapshotsBeforeDate(
          portfolioId, cutoffDate, SnapshotType.daily.value);
      }
      
      // 清理每周快照
      if (keepWeeklyDays > 0) {
        final cutoffDate = now.subtract(Duration(days: keepWeeklyDays));
        await _dao.deleteSnapshotsBeforeDate(
          portfolioId, cutoffDate, SnapshotType.weekly.value);
      }
      
      // 清理每月快照
      if (keepMonthlyDays > 0) {
        final cutoffDate = now.subtract(Duration(days: keepMonthlyDays));
        await _dao.deleteSnapshotsBeforeDate(
          portfolioId, cutoffDate, SnapshotType.monthly.value);
      }
      
      // 清理季度快照
      if (keepQuarterlyDays > 0) {
        final cutoffDate = now.subtract(Duration(days: keepQuarterlyDays));
        await _dao.deleteSnapshotsBeforeDate(
          portfolioId, cutoffDate, SnapshotType.quarterly.value);
      }
      
      // 清理年度快照
      if (keepYearlyDays > 0) {
        final cutoffDate = now.subtract(Duration(days: keepYearlyDays));
        await _dao.deleteSnapshotsBeforeDate(
          portfolioId, cutoffDate, SnapshotType.yearly.value);
      }
      
      LogService.instance.d('成功清理投资组合 $portfolioId 的旧快照数据');
    } catch (e) {
      LogService.instance.e('清理旧快照数据失败: $e');
    }
  }
  
  /// 删除快照
  Future<bool> deleteSnapshot(int id) async {
    try {
      final rowsAffected = await _dao.deleteSnapshot(id);
      return rowsAffected > 0;
    } catch (e) {
      LogService.instance.e('删除快照失败: $e');
      return false;
    }
  }
} 