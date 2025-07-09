import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:trade_flex/core/repositories/sub_position_repository.dart';

/// 移动端主持仓卡片组件
class MobilePositionCard extends StatelessWidget {
  final PlutoRow position;
  final bool isLongPosition;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MobilePositionCard({
    super.key,
    required this.position,
    required this.isLongPosition,
    required this.isExpanded,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
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
    final floatingPL = position.cells['floatingPL']?.value?.toString() ?? '0.00';
    final openDate = position.cells['openDate']?.value?.toString() ?? '';
    final holdingDays = position.cells['holdingDays']?.value?.toString() ?? '0';
    final dividend = position.cells['dividend']?.value?.toString() ?? '0.00';
    final fee = position.cells['fee']?.value?.toString() ?? '0.00';
    
    // 获取子持仓数量
    final positionId = position.cells['id']?.value as int?;
    
    return FutureBuilder<int>(
      future: _getSubPositionsCount(positionId),
      builder: (context, snapshot) {
        final subPositionsCount = snapshot.data ?? 0;

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
                // 第一行：标的代码、最新价格和操作按钮
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
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // 最新价格
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.withAlpha(30),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _formatPrice(latestPrice),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _getPriceChangeColor(latestPrice, totalAvgPrice),
                              ),
                            ),
                          ),
                          // 子持仓数量标签
                          if (subPositionsCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withAlpha(50),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$subPositionsCount个子持仓',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
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
                        // 删除按钮
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 16),
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          tooltip: '删除持仓',
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
                          tooltip: '编辑持仓',
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
                // 第二行：持仓数量、均价、摊薄均价
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
                // 第三行：实现盈亏、浮动盈亏、开仓日期
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        '实现盈亏',
              _formatPrice(totalProfitOrLoss),
              _getProfitColor(totalProfitOrLoss),
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
                        openDate,
                        null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // 第四行：持仓天数、股息、手续费
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
                        '股息',
                        _formatPrice(dividend),
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        '手续费',
                        _formatPrice(fee),
                        Colors.orange,
                      ),
                    ),
                  ],
            ),
          ],
        ),
      ),
        );
      }
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
  
  /// 获取价格变化颜色（相对于均价）
  Color _getPriceChangeColor(String latestPriceStr, String avgPriceStr) {
    try {
      final latestPrice = double.parse(latestPriceStr);
      final avgPrice = double.parse(avgPriceStr);
      
      if (latestPrice > avgPrice) {
        return Colors.green;
      } else if (latestPrice < avgPrice) {
        return Colors.red;
      } else {
        return Colors.grey;
      }
    } catch (e) {
      return Colors.grey;
    }
  }
  
  /// 获取子持仓数量
  Future<int> _getSubPositionsCount(int? positionId) async {
    if (positionId == null) return 0;
    
    try {
      final subPositionRepository = SubPositionRepository.instance;
      final subPositions = await subPositionRepository.getSubPositionsByParentId(positionId);
      return subPositions.length;
    } catch (e) {
      return 0;
    }
  }
} 