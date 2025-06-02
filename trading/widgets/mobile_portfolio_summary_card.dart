import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/trading/portfolio_summary_controller.dart';
import 'package:trade_flex/core/utils/formatting_utils.dart';

/// 移动端投资组合概览卡片
/// 
/// 显示投资组合的关键信息，包括总资产、盈亏、收益率等
class MobilePortfolioSummaryCard extends GetView<PortfolioSummaryController> {
  const MobilePortfolioSummaryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 数据加载由MobileTradingScreenController统一管理，这里不需要手动加载
    
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
            // 标题行 - 显示投资组合名称
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => Text(
                    '投资组合: ${controller.portfolioName}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )),
                ),
                Icon(
                  Icons.trending_up,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 18,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 总盈亏和胜率行
            Obx(() {
              final totalProfitLoss = controller.tradeStats['totalProfitLoss'] ?? '0.00';
              final profitLossValue = _parseDouble(totalProfitLoss);
              final winRate = controller.tradeStats['winRate'] ?? 0.0;
              
              return Row(
                children: [
                  // 总盈亏
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '总盈亏',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          FormattingUtils.formatCurrency(profitLossValue),
                          style: TextStyle(
                            color: _getProfitLossColor(totalProfitLoss),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // 胜率
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '胜率',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(winRate * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
            
            const SizedBox(height: 16),
            
            // 四个指标行
            Obx(() {
              final totalProfit = controller.tradeStats['totalProfit'] ?? '0.00';
              final totalProfitValue = _parseDouble(totalProfit);
              final totalLoss = controller.tradeStats['totalLoss'] ?? '0.00';
              final totalLossValue = _parseDouble(totalLoss);
              final profitCount = controller.tradeStats['profitCount'] ?? 0;
              final lossCount = controller.tradeStats['lossCount'] ?? 0;
              
              return Column(
                children: [
                  // 第一行：盈利金额和亏损金额
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          context,
                          '盈利金额',
                          FormattingUtils.formatCurrency(totalProfitValue),
                          Colors.green.shade300,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricItem(
                          context,
                          '亏损金额',
                          FormattingUtils.formatCurrency(totalLossValue.abs()),
                          Colors.red.shade300,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 第二行：盈利次数和亏损次数
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          context,
                          '盈利次数',
                          '$profitCount',
                          Colors.green.shade300,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricItem(
                          context,
                          '亏损次数',
                          '$lossCount',
                          Colors.red.shade300,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 构建指标项
  Widget _buildMetricItem(BuildContext context, String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 获取盈亏颜色
  Color _getProfitLossColor(String totalProfitLoss) {
    try {
      if (totalProfitLoss.isEmpty) {
        return Colors.white.withValues(alpha: 0.9); // 空值显示为白色
      }
      final value = double.parse(totalProfitLoss);
      if (value >= 0) {
        return Colors.green.shade300;
      } else {
        return Colors.red.shade300;
      }
    } catch (e) {
      // 解析失败，返回默认颜色
      return Colors.white.withValues(alpha: 0.9);
    }
  }

  /// 安全解析字符串为double
  double _parseDouble(String value) {
    try {
      if (value.isEmpty) return 0.0;
      return double.parse(value);
    } catch (e) {
      return 0.0;
    }
  }

  /// 构建渐变色背景
  /// 提供多种渐变效果，可根据需要选择
  LinearGradient _buildGradient(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    // final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // 方案1: 经典商务渐变（当前使用）
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
    
    // 方案2: 深度渐变（取消注释使用）
    // return LinearGradient(
    //   begin: Alignment.topCenter,
    //   end: Alignment.bottomCenter,
    //   colors: [
    //     primaryColor,
    //     primaryColor.withValues(alpha: 0.9),
    //     primaryColor.withValues(alpha: 0.6),
    //   ],
    //   stops: const [0.0, 0.5, 1.0],
    // );
    
    // 方案3: 对角线渐变（取消注释使用）
    // return LinearGradient(
    //   begin: Alignment(-1.0, -1.0),
    //   end: Alignment(1.0, 1.0),
    //   colors: [
    //     primaryColor,
    //     primaryColor.withValues(alpha: 0.8),
    //     primaryColor.withValues(alpha: 0.6),
    //     primaryColor.withValues(alpha: 0.8),
    //   ],
    //   stops: const [0.0, 0.3, 0.7, 1.0],
    // );
    
    // 方案4: 动态渐变（根据盈亏状态调整）
    // final totalProfitLoss = controller.tradeStats['totalProfitLoss'] ?? '0.00';
    // final profitLossValue = _parseDouble(totalProfitLoss);
    // 
    // if (profitLossValue >= 0) {
    //   // 盈利时使用绿色调渐变
    //   return LinearGradient(
    //     begin: Alignment.topLeft,
    //     end: Alignment.bottomRight,
    //     colors: [
    //       Colors.green.shade600,
    //       Colors.green.shade500,
    //       Colors.green.shade400,
    //     ],
    //     stops: const [0.0, 0.5, 1.0],
    //   );
    // } else {
    //   // 亏损时使用红色调渐变
    //   return LinearGradient(
    //     begin: Alignment.topLeft,
    //     end: Alignment.bottomRight,
    //     colors: [
    //       Colors.red.shade600,
    //       Colors.red.shade500,
    //       Colors.red.shade400,
    //     ],
    //     stops: const [0.0, 0.5, 1.0],
    //   );
    // }
  }
} 