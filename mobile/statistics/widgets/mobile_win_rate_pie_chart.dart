import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/statistics/win_rate_chart_controller.dart';

/// 移动端胜率饼图组件
/// 
/// 显示交易胜率分布
class MobileWinRatePieChart extends StatelessWidget {
  const MobileWinRatePieChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WinRateChartController>();
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
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
                  Icons.emoji_events,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '交易胜率分布',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                const Tooltip(
                  message: '显示盈利交易与亏损交易的比例',
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
  Widget _buildChartContent(BuildContext context, WinRateChartController controller) {
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
    
    if (!controller.hasData.value || controller.winRateData.value == null) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                '暂无交易数据',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
    
    final data = controller.winRateData.value!;
    
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
                child: data.totalTrades > 0
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
                          '无交易记录',
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
        
        // 详细统计
        _buildDetailedStats(data),
      ],
    );
  }

  /// 构建饼图扇区
  List<PieChartSectionData> _buildPieChartSections(WinRateChartController controller, dynamic data) {
    final isWinSelected = controller.touchedIndex.value == 0;
    final isLossSelected = controller.touchedIndex.value == 1;
    
    return [
      // 盈利扇区
      PieChartSectionData(
        color: Colors.green,
        value: data.winRate,
        title: '${data.winRate.toStringAsFixed(1)}%',
        radius: isWinSelected ? 45 : 40,
        titleStyle: TextStyle(
          fontSize: isWinSelected ? 12 : 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      // 亏损扇区
      PieChartSectionData(
        color: Colors.red,
        value: data.lossRate,
        title: '${data.lossRate.toStringAsFixed(1)}%',
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
          _buildStatItem('盈利交易', '${data.winTrades}笔', Colors.green),
          const SizedBox(height: 8),
          _buildStatItem('亏损交易', '${data.lossTrades}笔', Colors.red),
          const SizedBox(height: 8),
          _buildStatItem('总交易', '${data.totalTrades}笔', Colors.grey[700]!),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: data.winRate >= 50 ? Colors.green.withAlpha(25) : Colors.red.withAlpha(25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  data.winRate >= 50 ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: data.winRate >= 50 ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  '胜率 ${data.winRate.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: data.winRate >= 50 ? Colors.green : Colors.red,
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
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 构建详细统计
  Widget _buildDetailedStats(dynamic data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDetailedStatItem(
            '胜率',
            '${data.winRate.toStringAsFixed(1)}%',
            data.winRate >= 50 ? Colors.green : Colors.red,
          ),
          Container(width: 1, height: 30, color: Colors.grey[300]),
          _buildDetailedStatItem(
            '败率',
            '${data.lossRate.toStringAsFixed(1)}%',
            data.lossRate >= 50 ? Colors.red : Colors.grey[600]!,
          ),
          Container(width: 1, height: 30, color: Colors.grey[300]),
          _buildDetailedStatItem(
            '总计',
            '${data.totalTrades}笔',
            Colors.grey[700]!,
          ),
        ],
      ),
    );
  }

  /// 构建详细统计项
  Widget _buildDetailedStatItem(String label, String value, Color color) {
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