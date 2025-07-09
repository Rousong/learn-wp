import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/statistics/fear_greed_profit_chart_controller.dart';

/// 移动端恐惧贪婪分布饼图组件
/// 
/// 显示恐惧贪婪指数与盈亏关系
class MobileFearGreedProfitChart extends StatelessWidget {
  const MobileFearGreedProfitChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FearGreedProfitChartController>();
    
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
                  Icons.psychology,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '恐惧贪婪指数分布',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                const Tooltip(
                  message: '显示不同恐惧贪婪指数下的交易盈亏分布',
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
  Widget _buildChartContent(BuildContext context, FearGreedProfitChartController controller) {
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
    
    if (!controller.hasData.value || controller.fearGreedData.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                '暂无恐惧贪婪数据',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      children: [
        // 饼图和图例
        Row(
          children: [
            // 饼图
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 150,
                child: PieChart(
                  PieChartData(
                    sections: _buildPieChartSections(controller),
                    centerSpaceRadius: 30,
                    sectionsSpace: 2,
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        if (event is FlTapUpEvent && pieTouchResponse?.touchedSection != null) {
                          final index = pieTouchResponse!.touchedSection!.touchedSectionIndex;
                          controller.selectedSectionIndex.value = 
                              controller.selectedSectionIndex.value == index ? -1 : index;
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // 图例
            Expanded(
              flex: 3,
              child: _buildLegend(controller),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 统计信息
        _buildStatistics(controller),
      ],
    );
  }

  /// 构建饼图扇区
  List<PieChartSectionData> _buildPieChartSections(FearGreedProfitChartController controller) {
    return controller.fearGreedData.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = controller.selectedSectionIndex.value == index;
      
      return PieChartSectionData(
        color: item.color,
        value: item.totalTrades.toDouble(),
        title: '${item.totalTrades}笔',
        radius: isSelected ? 55 : 50,
        titleStyle: TextStyle(
          fontSize: isSelected ? 12 : 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  /// 构建图例
  Widget _buildLegend(FearGreedProfitChartController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: controller.fearGreedData.map((item) => 
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${item.totalTrades}笔',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ).toList(),
    );
  }

  /// 构建统计信息
  Widget _buildStatistics(FearGreedProfitChartController controller) {
    final totalTrades = controller.fearGreedData.fold<int>(0, (sum, item) => sum + item.totalTrades);
    final totalProfitLoss = controller.fearGreedData.fold<double>(0, (sum, item) => sum + item.netProfitLoss);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            '总交易',
            '$totalTrades笔',
            Colors.grey[700]!,
          ),
          Container(width: 1, height: 30, color: Colors.grey[300]),
          _buildStatItem(
            '净盈亏',
            '¥${totalProfitLoss.toStringAsFixed(2)}',
            totalProfitLoss >= 0 ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
} 