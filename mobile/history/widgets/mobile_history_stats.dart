import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/history/history_profit_loss_chart_controller.dart';
import 'package:trade_flex/core/controllers/history/history_win_rate_chart_controller.dart';

/// 移动端历史记录统计组件
/// 
/// 显示盈亏比例和胜率统计信息
class MobileHistoryStats extends StatelessWidget {
  const MobileHistoryStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 统计标题栏
          _buildStatsHeader(context),
          
          // 统计内容
          _buildStatsContent(context),
        ],
      ),
    );
  }

  /// 构建统计标题栏
  Widget _buildStatsHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(10),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.bar_chart,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '统计概览',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计内容
  Widget _buildStatsContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 盈亏统计
          Expanded(
            child: _buildProfitLossStats(context),
          ),
          
          const SizedBox(width: 16),
          
          // 胜率统计
          Expanded(
            child: _buildWinRateStats(context),
          ),
        ],
      ),
    );
  }

  /// 构建盈亏统计
  Widget _buildProfitLossStats(BuildContext context) {
    final controller = Get.find<HistoryProfitLossChartController>();
    
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }
      
      if (controller.hasError.value) {
        return _buildErrorWidget('盈亏数据加载失败');
      }
      
      if (!controller.hasData.value || controller.profitLossData.value == null) {
        return _buildNoDataWidget('暂无盈亏数据');
      }
      
      final data = controller.profitLossData.value!;
      final netProfit = controller.getNetProfit();
      final isProfit = netProfit >= 0;
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isProfit ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '净盈亏',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            controller.formatAmount(netProfit),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isProfit ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatsItem(
                '盈利',
                controller.formatAmount(data.profitAmount),
                Colors.green,
              ),
              _buildStatsItem(
                '亏损',
                controller.formatAmount(data.lossAmount),
                Colors.red,
              ),
            ],
          ),
        ],
      );
    });
  }

  /// 构建胜率统计
  Widget _buildWinRateStats(BuildContext context) {
    final controller = Get.find<HistoryWinRateChartController>();
    
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }
      
      if (controller.hasError.value) {
        return _buildErrorWidget('胜率数据加载失败');
      }
      
      if (!controller.hasData.value || controller.winRateData.value == null) {
        return _buildNoDataWidget('暂无胜率数据');
      }
      
      final data = controller.winRateData.value!;
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '胜率',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${data.winRate.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatsItem(
                '盈利',
                '${data.winTrades}笔',
                Colors.green,
              ),
              _buildStatsItem(
                '亏损',
                '${data.lossTrades}笔',
                Colors.red,
              ),
            ],
          ),
        ],
      );
    });
  }

  /// 构建统计项
  Widget _buildStatsItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
          ),
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
    );
  }

  /// 构建错误组件
  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 24,
            color: Colors.red[300],
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              fontSize: 10,
              color: Colors.red[300],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建无数据组件
  Widget _buildNoDataWidget(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.data_usage_outlined,
            size: 24,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 