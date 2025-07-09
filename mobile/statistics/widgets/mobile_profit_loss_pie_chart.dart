import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/statistics/profit_loss_chart_controller.dart';

/// 移动端盈亏金额饼图组件
/// 
/// 显示盈利和亏损金额的分布
class MobileProfitLossPieChart extends StatelessWidget {
  const MobileProfitLossPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfitLossChartController>();
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // 0.05
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
                  Icons.account_balance,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '盈亏金额分布',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                const Tooltip(
                  message: '显示盈利金额与亏损金额的分布',
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
  Widget _buildChartContent(BuildContext context, ProfitLossChartController controller) {
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
    
    if (!controller.hasData.value || controller.profitLossData.value == null) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                '暂无盈亏数据',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
    
    final data = controller.profitLossData.value!;
    
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 饼图
              Expanded(
                flex: 1,
                child: (data.profitAmount + data.lossAmount) > 0
                    ? PieChart(
                        PieChartData(
                          sections: _buildPieChartSections(controller, data),
                          centerSpaceRadius: 30,
                          sectionsSpace: 2,
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              if (event is FlTapUpEvent && pieTouchResponse?.touchedSection != null) {
                                final index = pieTouchResponse!.touchedSection!.touchedSectionIndex;
                                controller.touchedIndex.value =
                                    controller.touchedIndex.value == index ? -1 : index;
                              }
                            },
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          '无盈亏记录',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
              ),
              
              const SizedBox(width: 16),
              
              // 统计信息
              Expanded(
                flex: 1,
                child: _buildStatistics(data),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 净盈亏信息
        _buildNetProfitInfo(data),
      ],
    );
  }

  /// 构建饼图扇区
  List<PieChartSectionData> _buildPieChartSections(ProfitLossChartController controller, dynamic data) {
    final isProfitSelected = controller.touchedIndex.value == 0;
    final isLossSelected = controller.touchedIndex.value == 1;
    
    return [
      // 盈利扇区
      PieChartSectionData(
        color: Colors.green,
        value: data.profitPercentage,
        title: '${data.profitPercentage.toStringAsFixed(1)}%',
        radius: isProfitSelected ? 45 : 40,
        titleStyle: TextStyle(
          fontSize: isProfitSelected ? 12 : 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      // 亏损扇区
      PieChartSectionData(
        color: Colors.red,
        value: data.lossPercentage,
        title: '${data.lossPercentage.toStringAsFixed(1)}%',
        radius: isLossSelected ? 45 : 40,
        titleStyle: TextStyle(
          fontSize: isLossSelected ? 12 : 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  /// 构建统计信息
  Widget _buildStatistics(dynamic data) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatItem('盈利金额', '¥${data.profitAmount.toStringAsFixed(2)}', Colors.green),
          const SizedBox(height: 8),
          _buildStatItem('亏损金额', '¥${data.lossAmount.toStringAsFixed(2)}', Colors.red),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: data.netProfit >= 0 ? Colors.green.withAlpha(25) : Colors.red.withAlpha(25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  data.netProfit >= 0 ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: data.netProfit >= 0 ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '净${data.netProfit >= 0 ? "盈利" : "亏损"}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: data.netProfit >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建净盈亏信息
  Widget _buildNetProfitInfo(dynamic data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            data.netProfit >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
            color: data.netProfit >= 0 ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '净盈亏: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            '¥${data.netProfit.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: data.netProfit >= 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
} 