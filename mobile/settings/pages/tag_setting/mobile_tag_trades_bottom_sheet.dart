import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/settings/tag_settings_controller.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/constants/trading_transactions_enums.dart';

/// 移动端标签相关交易底部弹出页面
/// 
/// 显示使用该标签的交易记录列表
class MobileTagTradesBottomSheet extends StatefulWidget {
  final Tag tag;
  final TagSettingsController controller;

  const MobileTagTradesBottomSheet({
    super.key,
    required this.tag,
    required this.controller,
  });

  @override
  State<MobileTagTradesBottomSheet> createState() => _MobileTagTradesBottomSheetState();
}

class _MobileTagTradesBottomSheetState extends State<MobileTagTradesBottomSheet> {
  @override
  void initState() {
    super.initState();
    // 加载相关交易记录
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadRelatedTrades(widget.tag.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${widget.tag.tagName}" 相关交易',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                        '${widget.controller.relatedTrades.length} 条交易记录',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      )),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.2)),
          // 交易列表
          Expanded(
            child: Obx(() {
              if (widget.controller.isLoadingTrades.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final trades = widget.controller.relatedTrades;
              
              if (trades.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: trades.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final trade = trades[index];
                  return _buildTradeCard(trade);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              '没有相关交易记录',
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '该标签尚未被用于任何交易记录',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建交易卡片
  Widget _buildTradeCard(TradingTransaction trade) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final operationStyle = _getTradeOperationStyle(trade.operate);
    final icon = operationStyle['icon'] as IconData;
    final color = operationStyle['color'] as Color;
    final text = operationStyle['text'] as String;

    // 计算总金额
    final totalAmount = (double.tryParse(trade.price) ?? 0) * (double.tryParse(trade.amount) ?? 0);
    
    // 盈亏信息
    final profitLoss = double.tryParse(trade.profitOrLoss ?? '0') ?? 0;
    final hasProfit = trade.profitOrLoss != null && trade.profitOrLoss!.isNotEmpty;

    return Card(
      elevation: 2,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部：交易日期和操作类型
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(trade.tradeDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 主要信息：资产名称
            Text(
              trade.symbol,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            // 交易详情
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('价格', trade.price, Icons.attach_money),
                ),
                Expanded(
                  child: _buildInfoItem('数量', trade.amount, Icons.format_list_numbered),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('总额', totalAmount.toStringAsFixed(2), Icons.account_balance_wallet),
                ),
                if (trade.fees != null && trade.fees!.isNotEmpty)
                  Expanded(
                    child: _buildInfoItem('手续费', trade.fees!, Icons.receipt),
                  ),
              ],
            ),
            // 盈亏信息（如果有）
            if (hasProfit) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: profitLoss >= 0 ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      profitLoss >= 0 ? Icons.trending_up : Icons.trending_down,
                      color: profitLoss >= 0 ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '盈亏: ${profitLoss >= 0 ? '+' : ''}${trade.profitOrLoss}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: profitLoss >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // 备注信息（如果有）
            if (trade.description != null && trade.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 16, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      trade.description!,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建信息项
  Widget _buildInfoItem(String label, String value, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurface.withValues(alpha: 0.6)),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 获取交易操作样式
  Map<String, dynamic> _getTradeOperationStyle(TradeOperate operate) {
    switch (operate) {
      case TradeOperate.openLong:
        return {'icon': Icons.trending_up, 'color': Colors.green, 'text': '买入'};
      case TradeOperate.openShort:
        return {'icon': Icons.trending_down, 'color': Colors.red, 'text': '卖出'};
      case TradeOperate.closeLong:
        return {'icon': Icons.call_made, 'color': Colors.blue, 'text': '平多'};
      case TradeOperate.closeShort:
        return {'icon': Icons.call_received, 'color': Colors.orange, 'text': '平空'};
      case TradeOperate.swapFrom:
        return {'icon': Icons.trending_up, 'color': Colors.green, 'text': '换仓'};
      case TradeOperate.swapTo:
        return {'icon': Icons.trending_down, 'color': Colors.red, 'text': '换仓'};
      default:
        return {'icon': Icons.swap_horiz, 'color': Colors.grey, 'text': '其他'};
    }
  }
} 