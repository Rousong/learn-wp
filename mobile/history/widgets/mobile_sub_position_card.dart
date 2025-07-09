import 'package:flutter/material.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/constants/position_enums.dart';
import 'package:intl/intl.dart';

/// 移动端历史记录子持仓卡片组件
/// 
/// 显示已关闭子持仓的详细信息
class MobileSubPositionCard extends StatelessWidget {
  final SubPosition subPosition;
  final Position parentPosition;
  final bool isSelected;
  final VoidCallback onTap;

  const MobileSubPositionCard({
    super.key,
    required this.subPosition,
    required this.parentPosition,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLong = parentPosition.positionDirection == PositionDirection.long;
    final profitLoss = double.tryParse(subPosition.profitOrLoss) ?? 0;
    final isProfit = profitLoss >= 0;
    
    // 计算持仓天数
    final holdingDays = subPosition.closeDate?.difference(subPosition.openDate).inDays ?? 0;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withAlpha(20)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor.withAlpha(100)
                : Colors.grey.withAlpha(30),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一行：标的代码和方向
            Row(
              children: [
                // 方向指示器
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isLong ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // 子持仓代码
                Expanded(
                  child: Text(
                    subPosition.subPositionSymbol,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected 
                          ? Theme.of(context).primaryColor
                          : null,
                    ),
                  ),
                ),
                
                // 方向标签
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isLong ? Colors.green : Colors.red).withAlpha(20),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isLong ? '多头' : '空头',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isLong ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // 第二行：父持仓代码
            Row(
              children: [
                Icon(
                  Icons.account_tree_outlined,
                  size: 12,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '父持仓: ${parentPosition.positionSymbol}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // 第三行：均价、摊薄均价、盈亏
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    '均价',
                    _formatPrice(subPosition.avgPrice),
                    Icons.price_check,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    '摊薄均价',
                    _formatPrice(subPosition.dilutedAvgPrice),
                    Icons.price_change,
                  ),
                ),
                Expanded(
                  child: _buildProfitLossItem(
                    '盈亏',
                    subPosition.profitOrLoss,
                    isProfit,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 6),
            
            // 第四行：开仓日期、平仓日期、持仓天数
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    '开仓日期',
                    _formatDate(subPosition.openDate),
                    Icons.login,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    '平仓日期',
                    _formatDate(subPosition.closeDate),
                    Icons.logout,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    '持仓天数',
                    '$holdingDays天',
                    Icons.schedule,
                  ),
                ),
              ],
            ),
            
            // 第五行：手续费、股息（如果有）
            if (subPosition.fee != null || subPosition.dividendAmount != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    if (subPosition.fee != null)
                      Expanded(
                        child: _buildInfoItem(
                          '手续费',
                          _formatPrice(subPosition.fee!),
                          Icons.account_balance_wallet,
                          Colors.orange,
                        ),
                      ),
                    if (subPosition.dividendAmount != null)
                      Expanded(
                        child: _buildInfoItem(
                          '股息',
                          _formatPrice(subPosition.dividendAmount!),
                          Icons.attach_money,
                          Colors.green,
                        ),
                      ),
                    // 如果只有一个项目，添加空的Expanded来保持对齐
                    if ((subPosition.fee != null) != (subPosition.dividendAmount != null))
                      const Expanded(child: SizedBox()),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建信息项
  Widget _buildInfoItem(String label, String value, IconData icon, [Color? valueColor]) {
    return Row(
      children: [
        Icon(
          icon,
          size: 10,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建盈亏信息项
  Widget _buildProfitLossItem(String label, String value, bool isProfit) {
    return Row(
      children: [
        Icon(
          isProfit ? Icons.trending_up : Icons.trending_down,
          size: 10,
          color: isProfit ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                '${isProfit ? '+' : ''}${_formatPrice(value)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isProfit ? Colors.green : Colors.red,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 格式化价格
  String _formatPrice(String priceStr) {
    try {
      final value = double.parse(priceStr);
      return value.toStringAsFixed(2);
    } catch (e) {
      return priceStr;
    }
  }

  /// 格式化日期
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MM-dd').format(date);
  }
} 