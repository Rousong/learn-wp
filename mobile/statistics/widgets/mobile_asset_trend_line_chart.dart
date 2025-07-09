import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/statistics/asset_trend_line_chart_controller.dart';
import 'package:intl/intl.dart';

/// 移动端资产趋势折线图组件
/// 
/// 显示资产变化趋势
class MobileAssetTrendLineChart extends StatelessWidget {
  const MobileAssetTrendLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AssetTrendLineChartController>();
    
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
                  Icons.trending_up,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '资产趋势图',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                const Tooltip(
                  message: '显示资产随时间的变化趋势',
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
  Widget _buildChartContent(BuildContext context, AssetTrendLineChartController controller) {
    if (controller.isLoading.value) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (controller.hasError.value) {
      return SizedBox(
        height: 250,
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
    
    if (!controller.hasData.value || controller.assetDataPoints.isEmpty) {
      return SizedBox(
        height: 250,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_up_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                '暂无趋势数据',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      children: [
        // 图例
        _buildLegend(),
        
        const SizedBox(height: 16),
        
        // 折线图
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: (controller.maxAssetValue.value - controller.minAssetValue.value) / 5,
                verticalInterval: (controller.maxX.value - controller.minX.value) / 5,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey[300]!,
                  strokeWidth: 1,
                ),
                getDrawingVerticalLine: (value) => FlLine(
                  color: Colors.grey[300]!,
                  strokeWidth: 1,
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
                    interval: (controller.maxX.value - controller.minX.value) / 4,
                    getTitlesWidget: (value, meta) => _buildBottomTitle(controller, value),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: (controller.maxAssetValue.value - controller.minAssetValue.value) / 4,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) => _buildLeftTitle(value),
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey[300]!),
              ),
              minX: controller.minX.value,
              maxX: controller.maxX.value,
              minY: controller.minAssetValue.value,
              maxY: controller.maxAssetValue.value,
              lineBarsData: [
                // 总资产线
                LineChartBarData(
                  spots: controller.totalAssetsSpots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withValues(alpha: 0.1),
                  ),
                ),
                // 持仓成本线
                LineChartBarData(
                  spots: controller.totalCostSpots,
                  isCurved: true,
                  color: Colors.orange,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                ),
                // 市值线
                LineChartBarData(
                  spots: controller.totalMarketValueSpots,
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                ),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => Colors.blueGrey.withValues(alpha: 0.8),
                  getTooltipItems: (touchedSpots) => _buildTooltipItems(controller, touchedSpots),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建图例
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('总资产', Colors.blue),
        _buildLegendItem('持仓成本', Colors.orange),
        _buildLegendItem('当前市值', Colors.green),
      ],
    );
  }

  /// 构建图例项
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 2,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  /// 构建底部标题
  Widget _buildBottomTitle(AssetTrendLineChartController controller, double value) {
    final date = controller.getDateFromX(value);
    
    return Text(
      DateFormat('MM/dd').format(date),
      style: const TextStyle(fontSize: 10, color: Colors.grey),
    );
  }

  /// 构建左侧标题
  Widget _buildLeftTitle(double value) {
    return Text(
      '¥${_formatCurrency(value)}',
      style: const TextStyle(fontSize: 10, color: Colors.grey),
    );
  }

  /// 格式化货币
  String _formatCurrency(double value) {
    if (value >= 10000) {
      return '${(value / 10000).toStringAsFixed(1)}万';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  /// 构建工具提示项
  List<LineTooltipItem> _buildTooltipItems(AssetTrendLineChartController controller, List<LineBarSpot> touchedSpots) {
    return touchedSpots.map((spot) {
      final date = controller.getDateFromX(spot.x);
      // ignore: unnecessary_null_comparison
      final dateStr = date != null ? DateFormat('MM-dd').format(date) : '';
      
      String label;
      Color color;
      switch (spot.barIndex) {
        case 0:
          label = '总资产';
          color = Colors.blue;
          break;
        case 1:
          label = '持仓成本';
          color = Colors.orange;
          break;
        case 2:
          label = '当前市值';
          color = Colors.green;
          break;
        default:
          label = '';
          color = Colors.grey;
      }
      
      return LineTooltipItem(
        '$dateStr\n$label: ¥${spot.y.toStringAsFixed(2)}',
        TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }).toList();
  }
} 