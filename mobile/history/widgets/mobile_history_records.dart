import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/history/history_records_controller.dart';
import 'package:trade_flex/core/controllers/history/history_filter_card_controller.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/constants/position_enums.dart';
import 'package:trade_flex/core/constants/trading_transactions_enums.dart';
import 'package:trade_flex/core/utils/formatting_utils.dart';
import 'package:trade_flex/mobile/history/widgets/mobile_sub_position_card.dart';
import 'package:trade_flex/mobile/history/widgets/mobile_trade_detail_sheet.dart';

/// 移动端历史记录列表组件
/// 
/// 显示已关闭的子持仓列表，支持展开查看相关交易记录
class MobileHistoryRecords extends GetView<HistoryRecordsController> {
  const MobileHistoryRecords({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 记录标题栏
          _buildRecordsHeader(context),
          
          // 记录列表
          _buildRecordsList(context),
        ],
      ),
    );
  }

  /// 构建记录标题栏
  Widget _buildRecordsHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(10),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.history,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '历史记录',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const Spacer(),
          Obx(() => Text(
            '${controller.closedSubPositions.length}条记录',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          )),
        ],
      ),
    );
  }

  /// 构建记录列表
  Widget _buildRecordsList(BuildContext context) {
    return Obx(() {
      if (controller.closedSubPositions.isEmpty) {
        return const SizedBox.shrink();
      }
      
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        itemCount: controller.closedSubPositions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final subPosition = controller.closedSubPositions[index];
          return _buildSubPositionItem(context, subPosition, index);
        },
      );
    });
  }

  /// 构建子持仓项目
  Widget _buildSubPositionItem(BuildContext context, SubPosition subPosition, int index) {
    final filterController = Get.find<HistoryFilterCardController>();
    
    // 获取父持仓信息
    final parentPosition = filterController.positions.firstWhere(
      (p) => p.id == subPosition.parentPositionId,
      orElse: () => Position(
        id: 0,
        portfolioId: 0,
        positionSymbol: '未知',
        positionDirection: PositionDirection.long,
        totalHoldCnt: '0',
        totalAvgPrice: '0',
        totalDilutedAvgPrice: '0',
        totalProfitOrLoss: '0',
        isClosed: true,
        openDate: DateTime.now(),
        latestPrice: '0',
        autoUpdatePrice: false,
        createTime: DateTime.now(),
        updateTime: DateTime.now(),
      ),
    );
    
    return Obx(() {
      final isSelected = controller.selectedSubPosition.value?.id == subPosition.id;
      
      return Column(
        children: [
          // 子持仓卡片
          MobileSubPositionCard(
            subPosition: subPosition,
            parentPosition: parentPosition,
            isSelected: isSelected,
            onTap: () => _handleSubPositionTap(subPosition),
          ),
          
          // 相关交易记录
          if (isSelected) _buildRelatedTrades(context, subPosition),
        ],
      );
    });
  }

  /// 构建相关交易记录
  Widget _buildRelatedTrades(BuildContext context, SubPosition subPosition) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).cardColor.withAlpha(120)
            : Colors.grey.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.withAlpha(50)
              : Colors.grey.withAlpha(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 交易记录标题
          Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                '相关交易记录',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const Spacer(),
              Obx(() {
                if (controller.isLoadingTransactions.value) {
                  return SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                }
                return Text(
                  '${controller.relatedTransactions.length}笔',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                );
              }),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 交易记录列表
          Obx(() {
            if (controller.isLoadingTransactions.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (controller.relatedTransactions.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '暂无相关交易记录',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }
            
            return Column(
              children: controller.relatedTransactions.map((trade) {
                return _buildTradeItem(context, trade);
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  /// 构建交易项目 - 参考移动端交易记录设计
  Widget _buildTradeItem(BuildContext context, TradingTransaction trade) {
    final operationStyle = controller.getTradeOperationStyle(trade.operate);
    final operationIcon = operationStyle['icon'] as IconData;
    final operationColor = operationStyle['color'] as Color;
    final operationText = operationStyle['text'] as String;
    
    // 解析各种数值 - 直接实现解析逻辑
    final profitLoss = _parseDouble(trade.profitOrLoss);
    final profitPercent = _parseDouble(trade.percentOfPl);
    final price = _parseDouble(trade.price);
    final amount = _parseDouble(trade.amount);
    final nowAvgPrice = _parseDouble(trade.nowAvgPrice);
    final nowDilutedAvgPrice = _parseDouble(trade.nowDilutedAvgPrice);
    
    final isProfit = profitLoss >= 0;
    final profitColor = isProfit ? Colors.green : Colors.red;
    
    // 获取交易状态信息
    final statusInfo = _getTradeStatusInfo(trade.status);
    
    return InkWell(
      onTap: () => _showTradeDetail(context, trade),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).cardColor
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: operationColor.withAlpha(38),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // 主要信息行
              Row(
                children: [
                  // 交易类型图标
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: operationColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: operationColor.withAlpha(51),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      operationIcon,
                      color: operationColor,
                      size: 16,
                    ),
                  ),
                  
                  const SizedBox(width: 10),
                  
                  // 股票信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getDisplaySymbol(trade),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: operationColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                operationText,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: operationColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              controller.formatDate(trade.tradeDate),
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[500],
                              ),
                            ),
                            const Spacer(),
                            // 备注图标指示器
                            _buildIndicators(trade),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 右侧信息区域
                  SizedBox(
                    width: 100,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 盈亏信息区域
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (trade.profitOrLoss != null && trade.profitOrLoss!.isNotEmpty) ...[
                                Text(
                                  FormattingUtils.formatCurrency(profitLoss),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: profitColor,
                                  ),
                                  textAlign: TextAlign.right,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (trade.percentOfPl != null && trade.percentOfPl!.isNotEmpty)
                                  Text(
                                    '${profitPercent >= 0 ? '+' : ''}${profitPercent.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: profitColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        // 交易状态标签
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusInfo['color'].withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: statusInfo['color'].withAlpha(51),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            statusInfo['text'],
                            style: TextStyle(
                              fontSize: 8,
                              color: statusInfo['color'],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 详细数据行
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).cardColor.withAlpha(179)
                      : Theme.of(context).colorScheme.surface.withAlpha(179),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: operationColor.withAlpha(51),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildCompactInfoItem(
                        '数量',
                        '${amount.toStringAsFixed(0)}股',
                        Icons.numbers,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildCompactInfoItem(
                        '成交价',
                        FormattingUtils.formatCurrency(price),
                        Icons.attach_money,
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildCompactInfoItem(
                        '均价',
                        nowAvgPrice > 0 ? FormattingUtils.formatCurrency(nowAvgPrice) : '-',
                        Icons.trending_up,
                        Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: _buildCompactInfoItem(
                        '摊薄',
                        nowDilutedAvgPrice > 0 ? FormattingUtils.formatCurrency(nowDilutedAvgPrice) : '-',
                        Icons.show_chart,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建备注图标指示器
  Widget _buildIndicators(TradingTransaction trade) {
    final hasDescription = trade.description != null && trade.description!.isNotEmpty;
    
    if (!hasDescription) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.purple.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.notes_outlined,
        size: 10,
        color: Colors.purple.withAlpha(180),
      ),
    );
  }

  /// 安全解析字符串为double
  double _parseDouble(String? value) {
    try {
      if (value == null || value.isEmpty) return 0.0;
      return double.parse(value);
    } catch (e) {
      return 0.0;
    }
  }

  /// 获取显示的股票符号
  String _getDisplaySymbol(TradingTransaction trade) {
    // 如果symbol为空，直接返回subPositionSymbol
    if (trade.symbol.isEmpty) {
      return trade.subPositionSymbol;
    }
    
    // 如果subPositionSymbol为空或与symbol相同，只显示symbol
    if (trade.subPositionSymbol.isEmpty || trade.subPositionSymbol == trade.symbol) {
      return trade.symbol;
    }
    
    // 如果两者不同，显示为：symbol（subPositionSymbol）
    return '${trade.symbol}（${trade.subPositionSymbol}）';
  }

  /// 构建紧凑信息项
  Widget _buildCompactInfoItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 10,
          color: color,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 获取交易状态信息
  Map<String, dynamic> _getTradeStatusInfo(TradeStatus status) {
    switch (status) {
      case TradeStatus.newPosition:
        return {'text': '新建仓', 'color': Colors.blue};
      case TradeStatus.raiseAvgPrice:
        return {'text': '提高均价', 'color': Colors.orange};
      case TradeStatus.lowerAvgPrice:
        return {'text': '降低均价', 'color': Colors.purple};
      case TradeStatus.takeProfit:
        return {'text': '止盈', 'color': Colors.green};
      case TradeStatus.stopLoss:
        return {'text': '止损', 'color': Colors.red};
      case TradeStatus.costPrice:
        return {'text': '成本价', 'color': Colors.grey};
      case TradeStatus.swapFrom:
        return {'text': '换出', 'color': Colors.teal};
      case TradeStatus.swapTo:
        return {'text': '换入', 'color': Colors.cyan};
      case TradeStatus.close:
        return {'text': '平仓', 'color': Colors.indigo};
      case TradeStatus.dividend:
        return {'text': '股息', 'color': Colors.teal};
    }
  }

  /// 处理子持仓点击
  void _handleSubPositionTap(SubPosition subPosition) {
    controller.selectSubPosition(subPosition);
  }

  /// 显示交易详情
  void _showTradeDetail(BuildContext context, TradingTransaction trade) {
    MobileTradeDetailSheet.show(context, trade);
  }
} 