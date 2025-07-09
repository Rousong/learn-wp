import 'package:flutter/material.dart';
import 'package:trade_flex/core/database/database.dart';

/// 移动端子持仓卡片组件
class MobileSubPositionCard extends StatelessWidget {
  final SubPosition subPosition;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MobileSubPositionCard({
    super.key,
    required this.subPosition,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 计算持仓天数
    final holdingDays = subPosition.closeDate != null
        ? subPosition.closeDate!.difference(subPosition.openDate).inDays
        : DateTime.now().difference(subPosition.openDate).inDays;
    
    // 计算浮动盈亏（模拟数据，实际应该从控制器获取）
    final floatingPL = subPosition.isClosed ? '0.00' : '${(double.tryParse(subPosition.profitOrLoss) ?? 0) * 0.8}';

    return Container(
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
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
                        overflow: TextOverflow.ellipsis,
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
              Row(
                children: [
                  // 删除按钮
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    tooltip: '删除子持仓',
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
                    tooltip: '编辑子持仓',
                  ),
                ],
              ),
            ],
          ),
                      const SizedBox(height: 6),
          // 第二行：持仓数量、均价、摊薄均价
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
                Expanded(
                  child: _buildInfoItem(
                    '摊薄均价',
                    _formatPrice(subPosition.dilutedAvgPrice),
                    null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          // 第三行：实现盈亏、浮动盈亏、开仓日期
          Row(
            children: [
                Expanded(
                  child: _buildInfoItem(
                  '实现盈亏',
                    _formatPrice(subPosition.profitOrLoss),
                    _getProfitColor(subPosition.profitOrLoss),
                  ),
                ),
              Expanded(
                child: _buildInfoItem(
                  '浮动盈亏',
                  _formatPrice(floatingPL),
                  _getProfitColor(floatingPL),
                ),
            ),
              Expanded(
                child: _buildInfoItem(
                  '开仓日期',
                  _formatDate(subPosition.openDate),
                  null,
                ),
              ),
            ],
          ),
                  const SizedBox(height: 4),
          // 第四行：持仓天数、手续费、股息
                  Row(
                    children: [
              Expanded(
                child: _buildInfoItem(
                  '持仓天数',
                  '$holdingDays天',
                  null,
                ),
              ),
                        Expanded(
                          child: _buildInfoItem(
                            '手续费',
                  _formatPrice(subPosition.fee ?? '0.00'),
                            Colors.orange,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            '股息',
                  _formatPrice(subPosition.dividendAmount ?? '0.00'),
                            Colors.green,
                          ),
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
  
  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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