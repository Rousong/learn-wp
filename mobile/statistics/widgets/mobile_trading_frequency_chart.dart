import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/statistics/trading_frequency_chart_controller.dart';

/// 移动端交易频率柱状图组件
/// 
/// 显示不同时间段的交易频率
class MobileTradingFrequencyChart extends StatelessWidget {
  const MobileTradingFrequencyChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TradingFrequencyChartController>();
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '交易频率分析',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                const Tooltip(
                  message: '显示不同时间段的交易频率分布',
                  child: Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          
          // 图表内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() => _buildChartContent(context, controller)),
          ),
        ],
      ),
    );
  }

  /// 构建图表内容
  Widget _buildChartContent(BuildContext context, TradingFrequencyChartController controller) {
    if (controller.isLoading.value) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (controller.hasError.value) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                '加载失败',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => controller.refreshData(),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (!controller.hasData.value || controller.frequencyData.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                '暂无交易频率数据',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
    
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: controller.maxTradeCount.value.toDouble(),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.blueGrey.withValues(alpha: 0.8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final data = controller.frequencyData[groupIndex];
                return BarTooltipItem(
                  '${data.label}\n买入: ${data.buyCount}\n卖出: ${data.sellCount}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => _buildBottomTitle(controller, value.toInt()),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: controller.maxTradeCount.value / 5,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => _buildLeftTitle(value),
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey[300]!),
          ),
          barGroups: controller.getBarGroups(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: controller.maxTradeCount.value / 5,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey[300]!,
              strokeWidth: 1,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建底部标题
  Widget _buildBottomTitle(TradingFrequencyChartController controller, int index) {
    return Text(
      controller.getBottomTitle(index.toDouble()),
      style: const TextStyle(fontSize: 10, color: Colors.grey),
    );
  }

  /// 构建左侧标题
  Widget _buildLeftTitle(double value) {
    return Text(
      value.toInt().toString(),
      style: const TextStyle(fontSize: 10, color: Colors.grey),
    );
  }
} 