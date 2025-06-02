import 'package:flutter/material.dart';
import 'package:trade_flex/core/database/database.dart';

/// 移动端子持仓卡片组件
class MobileSubPositionCard extends StatelessWidget {
  final SubPosition subPosition;
  final VoidCallback onEdit;

  const MobileSubPositionCard({
    super.key,
    required this.subPosition,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: subPosition.isClosed 
          ? Colors.grey.withAlpha(30) 
          : Colors.blue.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: subPosition.isClosed 
            ? Colors.grey.withAlpha(50) 
            : Colors.blue.withAlpha(50),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 第一行：子持仓代码和操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    // 子持仓指示器
                    Container(
                      width: 3,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 子持仓代码
                    Expanded(
                      child: Text(
                        subPosition.subPositionSymbol,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: subPosition.isClosed ? Colors.grey : Colors.blue[800],
                        ),
                      ),
                    ),
                    // 状态标签
                    if (subPosition.isClosed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
            ],
          ),
                      const SizedBox(height: 6),
            // 第二行：持仓数量和均价
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    '数量',
                    subPosition.holdCnt,
                    _getPositionColor(subPosition.holdCnt),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    '均价',
                    _formatPrice(subPosition.avgPrice),
                    null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // 第三行：摊薄均价和盈亏
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    '摊薄均价',
                    _formatPrice(subPosition.dilutedAvgPrice),
                    null,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    '盈亏',
                    _formatPrice(subPosition.profitOrLoss),
                    _getProfitColor(subPosition.profitOrLoss),
                  ),
                ),
              ],
            ),
                      // 手续费和股息（如果有）
            if (subPosition.fee != null || subPosition.dividendAmount != null)
              Column(
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (subPosition.fee != null)
                        Expanded(
                          child: _buildInfoItem(
                            '手续费',
                            _formatPrice(subPosition.fee!),
                            Colors.orange,
                          ),
                        ),
                      if (subPosition.dividendAmount != null)
                        Expanded(
                          child: _buildInfoItem(
                            '股息',
                            _formatPrice(subPosition.dividendAmount!),
                            Colors.green,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
        ],
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
            fontSize: 9,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
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