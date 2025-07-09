import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/trading/porfolio_current_position_controller.dart';

/// 移动端当前持仓卡片
class MobileCurrentPositionCard extends GetView<PorfolioCurrentPositionController> {
  const MobileCurrentPositionCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        gradient: _buildGradient(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // 表头
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      '当前持仓',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '数量',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '均价',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '摊薄价',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '盈亏',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),

            // 持仓列表
            Expanded(
              child: Obx(() {
                final currentPositions = controller.currentPositions;
                if (currentPositions.isEmpty) {
                  return _buildEmptyPositions();
                } else {
                  return _buildPositionsList(currentPositions);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  // 空状态显示
  Widget _buildEmptyPositions() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 36,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            '暂无持仓数据',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // 构建持仓列表
  Widget _buildPositionsList(List<Map<String, dynamic>> positions) {
    return ListView.builder(
      itemCount: positions.length,
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final position = positions[index];
        final amount = position['amount']?.toString() ?? '0';
        final avgPrice = position['avgPrice']?.toString() ?? 'N/A';
        final dilutedAvgPrice = position['dilutedAvgPrice']?.toString() ?? 'N/A';
        final profitOrLoss = position['profitOrLoss']?.toString() ?? '0';
        final hasAccumulatedDividend = position['dividendAmount'] != null && 
                                    position['dividendAmount'].toString() != '0' && 
                                    position['dividendAmount'].toString().isNotEmpty;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 30,
                decoration: BoxDecoration(
                  color: _getPositionColor(amount),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${position['symbol'] ?? 'N/A'}${position['subPosition'] != null && position['subPosition'].isNotEmpty ? ' (${position['subPosition']})' : ''}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasAccumulatedDividend)
                      Text(
                        '股息: ${position['dividendAmount']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.teal.shade200,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  amount,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getPositionColor(amount),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                child: Text(
                  _formatPrice(avgPrice),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                child: Text(
                  _formatPrice(dilutedAvgPrice),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                child: Text(
                  _formatPrice(profitOrLoss),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getProfitColor(profitOrLoss),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 格式化价格为两位小数
  String _formatPrice(String priceStr) {
    try {
      final value = double.parse(priceStr);
      return value.toStringAsFixed(2);
    } catch (e) {
      return priceStr; // 如果无法解析，保留原始值
    }
  }

  // 获取持仓颜色
  Color _getPositionColor(String amount) {
    try {
      final value = double.parse(amount);
      if (value > 0) {
        return Colors.green.shade300; // 多头仓位为绿色
      } else if (value < 0) {
        return Colors.red.shade300; // 空头仓位为红色
      } else {
        return Colors.grey.shade300; // 零仓位为灰色
      }
    } catch (e) {
      return Colors.grey.shade300; // 解析失败，返回默认颜色
    }
  }
  
  // 获取盈亏颜色
  Color _getProfitColor(String profitStr) {
    try {
      final value = double.parse(profitStr);
      if (value > 0) {
        return Colors.green.shade300; // 盈利为绿色
      } else if (value < 0) {
        return Colors.red.shade300; // 亏损为红色
      } else {
        return Colors.grey.shade300; // 盈亏平为灰色
      }
    } catch (e) {
      return Colors.grey.shade300; // 解析失败，返回默认颜色
    }
  }

  /// 构建渐变色背景
  LinearGradient _buildGradient(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor,
        primaryColor.withValues(alpha: 0.75),
        primaryColor.withValues(alpha: 0.5),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
  }
} 