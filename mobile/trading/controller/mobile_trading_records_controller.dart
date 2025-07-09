import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/repositories/trading_transaction_repository.dart';
import 'package:trade_flex/core/repositories/position_repository.dart';
import 'package:trade_flex/core/repositories/tag_repository.dart';
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
  final TagRepository _tagRepository = TagRepository.instance;
  
  // 交易记录数据
  final RxList<TradingTransaction> _recentTrades = <TradingTransaction>[].obs;
  List<TradingTransaction> get recentTrades => _recentTrades;
  
  // 加载状态
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  
  // 当前投资组合ID
  final RxInt _portfolioId = 0.obs;
  int get portfolioId => _portfolioId.value;
  
  // 分页参数
  static const int _pageSize = 10;
  int _currentPage = 0;
  List<TradingTransaction> _allTrades = [];
  
  // 标签数据
  final Map<int, bool> _tradeHasTag = {};
  
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
      _currentPage = 0;
      hasMoreData.value = true;
      
      // 获取该投资组合的所有交易记录
      _allTrades = await _repository.getTradesByPortfolio(portfolioId.toString());
      
      // 按交易日期和创建时间降序排序
      _allTrades.sort((a, b) {
        final dateCompare = b.tradeDate.compareTo(a.tradeDate);
        if (dateCompare != 0) return dateCompare;
        return b.createTime.compareTo(a.createTime);
      });
      
      // 加载第一页数据
      _loadPage();
      
      // 加载标签数据
      await _loadTagsData();
      
    } catch (e) {
      LogService.instance.e('加载交易记录失败: $e');
      _recentTrades.clear();
      hasMoreData.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载更多数据
  Future<void> loadMoreData() async {
    if (isLoadingMore.value || !hasMoreData.value) return;
    
    try {
      isLoadingMore.value = true;
      _currentPage++;
      _loadPage();
      
      // 加载新加载交易的标签数据
      await _loadTagsData();
    } catch (e) {
      LogService.instance.e('加载更多交易记录失败: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 加载指定页面的数据
  void _loadPage() {
    final startIndex = _currentPage * _pageSize;
    final endIndex = startIndex + _pageSize;
    
    if (startIndex >= _allTrades.length) {
      hasMoreData.value = false;
      return;
    }
    
    final pageData = _allTrades.skip(startIndex).take(_pageSize).toList();
    
    if (_currentPage == 0) {
      // 第一页，直接替换
      _recentTrades.value = pageData;
    } else {
      // 后续页面，追加数据
      _recentTrades.addAll(pageData);
    }
    
    // 检查是否还有更多数据
    hasMoreData.value = endIndex < _allTrades.length;
  }
  
  /// 加载标签数据
  Future<void> _loadTagsData() async {
    try {
      // 获取所有标签交易关联
      final tagAssociations = await _tagRepository.getAllTagTradingAssociations();
      
      // 更新标签映射
      for (var trade in _recentTrades) {
        final hasTag = tagAssociations.any((assoc) => assoc.tradeTransactionId == trade.id);
        _tradeHasTag[trade.id] = hasTag;
      }
      
      LogService.instance.d('成功加载交易标签数据');
    } catch (e) {
      LogService.instance.e('加载交易标签数据失败: $e');
    }
  }
  
  /// 检查交易是否有标签
  bool hasTags(int tradeId) {
    return _tradeHasTag[tradeId] ?? false;
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
    // 根据系统语言环境自动选择日期格式
    final locale = Get.locale?.languageCode ?? 'en';
    
    // 中文环境使用 yyyy-MM-dd 格式
    if (locale == 'zh') {
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }
    // 英文环境使用 MM/dd/yyyy 格式
    else if (locale == 'en') {
      return DateFormat('MM/dd/yyyy').format(dateTime);
    }
    // 其他语言环境使用标准 ISO 格式
    else {
      return DateFormat('yyyy-MM-dd').format(dateTime);
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
      _allTrades.removeWhere((trade) => trade.id == tradeId);
      
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