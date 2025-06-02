import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// 移动端主持仓卡片组件
class MobilePositionCard extends StatelessWidget {
  final PlutoRow position;
  final bool isLongPosition;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const MobilePositionCard({
    super.key,
    required this.position,
    required this.isLongPosition,
    required this.isExpanded,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isClosed = position.cells['isClosed']?.value == true;
    final positionSymbol = position.cells['symbol']?.value?.toString() ?? '';
    final totalHoldCnt = position.cells['holdCount']?.value?.toString() ?? '0';
    final totalAvgPrice = position.cells['avgPrice']?.value?.toString() ?? '0.00';
    final totalDilutedAvgPrice = position.cells['dilutedAvgPrice']?.value?.toString() ?? '0.00';
    final totalProfitOrLoss = position.cells['profitOrLoss']?.value?.toString() ?? '0.00';
    final latestPrice = position.cells['latestPrice']?.value?.toString() ?? '0.00';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isClosed ? Colors.grey.withAlpha(50) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一行：标的代码和操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // 持仓方向指示器
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isLongPosition ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 标的代码
                      Expanded(
                        child: Text(
                          positionSymbol,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isClosed ? Colors.grey : null,
                          ),
                        ),
                      ),
                      // 状态标签
                      if (isClosed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.grey.withAlpha(100),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            '已平仓',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // 编辑按钮
                    IconButton(
                      icon: const Icon(Icons.edit, size: 16),
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                    ),
                    // 展开/折叠按钮
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 第二行：持仓数量和最新价格
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    '持仓数量',
                    totalHoldCnt,
                    _getPositionColor(totalHoldCnt),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    '最新价格',
                    _formatPrice(latestPrice),
                    null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // 第三行：均价和摊薄均价
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    '均价',
                    _formatPrice(totalAvgPrice),
                    null,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    '摊薄均价',
                    _formatPrice(totalDilutedAvgPrice),
                    null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // 第四行：盈亏
            _buildInfoItem(
              '盈亏',
              _formatPrice(totalProfitOrLoss),
              _getProfitColor(totalProfitOrLoss),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建信息项
  Widget _buildInfoItem(String label, String value, Color? valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  /// 格式化价格为两位小数
  String _formatPrice(String priceStr) {
    try {
      final value = double.parse(priceStr);
      return value.toStringAsFixed(2);
    } catch (e) {
      return priceStr;
    }
  }

  /// 获取持仓颜色
  Color _getPositionColor(String amount) {
    try {
      final value = double.parse(amount);
      if (value > 0) {
        return Colors.green;
      } else if (value < 0) {
        return Colors.red;
      } else {
        return Colors.grey;
      }
    } catch (e) {
      return Colors.grey;
    }
  }

  /// 获取盈亏颜色
  Color _getProfitColor(String profitStr) {
    try {
      final value = double.parse(profitStr);
      if (value > 0) {
        return Colors.green;
      } else if (value < 0) {
        return Colors.red;
      } else {
        return Colors.grey;
      }
    } catch (e) {
      return Colors.grey;
    }
  }
} 