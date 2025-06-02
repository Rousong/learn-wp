import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/repositories/trading_transaction_repository.dart';
import 'package:trade_flex/core/repositories/position_repository.dart';
import 'package:trade_flex/core/constants/trading_transactions_enums.dart';
import 'package:trade_flex/core/constants/position_enums.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/services/trade/calculation/trade_calculation_service.dart';
import 'package:trade_flex/core/event/trade_events_controller.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;



/// 移动端交易记录控制器
class MobileTradingRecordsController extends GetxController {
  final TradingTransactionRepository _repository = TradingTransactionRepository.instance;
  
  // 交易记录数据
  final RxList<TradingTransaction> _recentTrades = <TradingTransaction>[].obs;
  List<TradingTransaction> get recentTrades => _recentTrades;
  
  // 加载状态
  final RxBool isLoading = false.obs;
  
  // 当前投资组合ID
  final RxInt _portfolioId = 0.obs;
  int get portfolioId => _portfolioId.value;
  
  // 交易事件监听器
  Worker? _tradeEventWorker;
  
  @override
  void onInit() {
    super.onInit();
    
    // 监听交易更新事件
    final tradeEventsController = Get.find<TradeEventsController>();
    _tradeEventWorker = ever(tradeEventsController.tradeUpdated, (_) {
      // 当交易更新事件触发时，重新加载当前投资组合的数据
      if (_portfolioId.value != 0) {
        LogService.instance.d('收到交易更新事件，重新加载交易记录数据');
        loadData(_portfolioId.value);
      }
    });
  }
  
  @override
  void onClose() {
    // 清理监听器
    _tradeEventWorker?.dispose();
    super.onClose();
  }
  
  /// 加载交易记录数据
  Future<void> loadData(int portfolioId) async {
    try {
      isLoading.value = true;
      _portfolioId.value = portfolioId;
      
      // 获取该投资组合的所有交易记录
      final allTrades = await _repository.getTradesByPortfolio(portfolioId.toString());
      
      // 按交易日期和创建时间降序排序，获取最近的交易记录
      allTrades.sort((a, b) {
        final dateCompare = b.tradeDate.compareTo(a.tradeDate);
        if (dateCompare != 0) return dateCompare;
        return b.createTime.compareTo(a.createTime);
      });
      
      // 只取前10条最近的交易记录
      _recentTrades.value = allTrades.take(10).toList();
      
    } catch (e) {
      LogService.instance.e('加载交易记录失败: $e');
      _recentTrades.clear();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 获取交易操作对应的样式
  Map<String, dynamic> getTradeOperationStyle(TradeOperate operate) {
    switch (operate) {
      case TradeOperate.openLong:
        return {'icon': Icons.trending_up, 'color': Colors.green, 'text': '买入开多'};
      case TradeOperate.openShort:
        return {'icon': Icons.trending_down, 'color': Colors.red, 'text': '卖出开空'};
      case TradeOperate.closeLong:
        return {'icon': Icons.call_made, 'color': Colors.blue, 'text': '卖出平多'};
      case TradeOperate.closeShort:
        return {'icon': Icons.call_received, 'color': Colors.orange, 'text': '买入平空'};
      case TradeOperate.swapFrom:
        return {'icon': Icons.swap_horiz, 'color': Colors.purple, 'text': '换出'};
      case TradeOperate.swapTo:
        return {'icon': Icons.swap_horiz, 'color': Colors.purple, 'text': '换入'};
      case TradeOperate.deposit:
        return {'icon': Icons.account_balance_wallet, 'color': Colors.teal, 'text': '入金'};
      case TradeOperate.withdraw:
        return {'icon': Icons.money_off, 'color': Colors.brown, 'text': '出金'};
      case TradeOperate.dividend:
        return {'icon': Icons.attach_money, 'color': Colors.teal, 'text': '股息'};
    }
  }
  
  /// 格式化日期时间
  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tradeDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (tradeDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (tradeDate == yesterday) {
      return '昨天';
    } else {
      return DateFormat('MM-dd').format(dateTime);
    }
  }
  
  /// 安全解析字符串为double
  double parseDouble(String? value) {
    try {
      if (value == null || value.isEmpty) return 0.0;
      return double.parse(value);
    } catch (e) {
      return 0.0;
    }
  }

  /// 删除交易记录
  Future<Map<String, dynamic>> deleteRecord(int tradeId) async {
    try {
      LogService.instance.d('删除交易记录: $tradeId');
      
      // 进行合理性验证
      final validationResult = await TradeCalculationService.instance.validateTradeDelete(tradeId.toString());
      
      // 如果验证不通过，返回验证结果
      if (!validationResult['isValid']) {
        return {
          'success': false,
          'validationResult': validationResult,
          'message': validationResult['message'].toString(),
        };
      }

      // 先获取要删除的交易记录信息，这些信息在删除后将无法获取
      final trade = await _repository.getTradingTransactionById(tradeId.toString());
      if (trade == null) {
        return {
          'success': false,
          'message': '未找到要删除的交易记录',
        };
      }

      // 保存删除前的必要信息
      final subPositionId = trade.subPositionId;
      final positionId = trade.positionId;
      final tradeDate = trade.tradeDate;
      final createTime = trade.createTime;
      
      // 获取持仓方向（多头/空头）
      final position = await PositionRepository.instance.getPositionById(positionId);
      final isLong = position?.positionDirection == PositionDirection.long;
      
      // 执行删除操作
      await _repository.deleteTrade(tradeId.toString());
      
      // 使用 TradeCalculationService 处理删除后的计算
      int updatedCount = 0;
      updatedCount = await TradeCalculationService.instance.handleTradeDelete(
        subPositionId.toString(),
        tradeDate,
        createTime,
        positionId.toString(),
        isLong
      );
      
      LogService.instance.i('删除交易后更新了 $updatedCount 条相关交易记录');
      
      // 从本地列表中移除
      _recentTrades.removeWhere((trade) => trade.id == tradeId);
      
      LogService.instance.d('交易记录删除成功: $tradeId');
      
      return {
        'success': true,
        'updatedCount': updatedCount,
        'message': '交易记录已删除',
      };
    } catch (e) {
      LogService.instance.e('删除交易记录失败: $e');
      return {
        'success': false,
        'message': '删除交易记录失败: $e',
      };
    }
  }

  /// 更新交易记录
  Future<bool> updateRecord(
    int tradeId,
    String symbol,
    String subPosition,
    String price,
    String amount,
    String profitLoss,
    String fees,
    String description,
    DateTime tradeDate,
  ) async {
    try {
      LogService.instance.d('更新交易记录: $tradeId');
      
      // 找到要更新的记录
      final tradeIndex = _recentTrades.indexWhere((trade) => trade.id == tradeId);
      if (tradeIndex == -1) {
        LogService.instance.e('未找到要更新的交易记录: $tradeId');
        return false;
      }
      
      final originalTrade = _recentTrades[tradeIndex];
      
      // 使用 copyWith 方法更新记录，保持所有必需字段
      final updatedTrade = originalTrade.copyWith(
        symbol: symbol,
        subPositionSymbol: subPosition,
        price: price,
        amount: amount,
        profitOrLoss: profitLoss.isEmpty ? const drift.Value.absent() : drift.Value(profitLoss),
        fees: fees.isEmpty ? const drift.Value.absent() : drift.Value(fees),
        description: description.isEmpty ? const drift.Value.absent() : drift.Value(description),
        tradeDate: tradeDate,
        updateTime: DateTime.now(),
      );
      
      // 调用仓库更新记录
      await _repository.updateTradingTransaction(updatedTrade);
      
      // 更新本地列表
      _recentTrades[tradeIndex] = updatedTrade;
      _recentTrades.refresh(); // 触发UI更新
      
      LogService.instance.d('交易记录更新成功: $tradeId');
      return true;
    } catch (e) {
      LogService.instance.e('更新交易记录失败: $e');
      return false;
    }
  }
}