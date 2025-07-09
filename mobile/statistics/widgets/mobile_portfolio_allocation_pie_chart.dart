import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/statistics/portfolio_allocation_chart_controller.dart';

/// 移动端持仓占比饼图组件
/// 
/// 显示投资组合中各资产的占比分布
class MobilePortfolioAllocationPieChart extends StatelessWidget {
  const MobilePortfolioAllocationPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PortfolioAllocationChartController>();
    
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
                  Icons.pie_chart,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '持仓占比分布',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                const Tooltip(
                  message: '显示投资组合中各资产的占比分布',
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
  Widget _buildChartContent(BuildContext context, PortfolioAllocationChartController controller) {
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
    
    if (!controller.hasData.value || !controller.hasAllocationData.value) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                '暂无持仓数据',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      children: [
        SizedBox(
          height: 160, // 给左右布局一个固定的高度
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 饼图
              Expanded(
                flex: 1, // 均分空间
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
              
              const SizedBox(width: 16),
              
              // 图例
              Expanded(
                flex: 1, // 均分空间
                child: _buildLegend(controller),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 总市值信息
        _buildTotalValueInfo(controller),
      ],
    );
  }

  /// 构建饼图扇区
  List<PieChartSectionData> _buildPieChartSections(PortfolioAllocationChartController controller) {
    return controller.allocationItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = controller.selectedSectionIndex.value == index;
      
      return PieChartSectionData(
        color: item.color,
        value: item.percentage,
        title: '${item.percentage.toStringAsFixed(1)}%',
        radius: isSelected ? 45 : 40, // 调整半径
        titleStyle: TextStyle(
          fontSize: isSelected ? 12 : 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  /// 构建图例
  Widget _buildLegend(PortfolioAllocationChartController controller) {
    // 使用SingleChildScrollView确保图例在项目过多时可以滚动
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: controller.allocationItems.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle, // 使用圆形图例标记
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${item.percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建总市值信息
  Widget _buildTotalValueInfo(PortfolioAllocationChartController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '总市值',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            '¥${controller.totalMarketValue.value.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 