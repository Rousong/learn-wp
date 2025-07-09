import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/mobile/base/mobile_base_page.dart';
import 'package:trade_flex/core/controllers/statistics/statistics_screen_controller.dart';
import 'package:trade_flex/core/event/portfolio_event_controller.dart';
import 'package:trade_flex/mobile/statistics/widgets/mobile_time_range_filter.dart';
import 'package:trade_flex/mobile/statistics/widgets/mobile_snapshot_heatmap.dart';
import 'package:trade_flex/mobile/statistics/widgets/mobile_portfolio_allocation_pie_chart.dart';
import 'package:trade_flex/mobile/statistics/widgets/mobile_win_rate_pie_chart.dart';
import 'package:trade_flex/mobile/statistics/widgets/mobile_profit_loss_pie_chart.dart';
import 'package:trade_flex/mobile/statistics/widgets/mobile_asset_trend_line_chart.dart';
import 'package:trade_flex/mobile/statistics/widgets/mobile_trading_frequency_chart.dart';
import 'package:trade_flex/mobile/statistics/widgets/mobile_fear_greed_profit_chart.dart';

/// 移动端统计页面
/// 
/// 显示各种交易统计图表和分析数据
/// 复用桌面端控制器，针对移动端优化布局
class MobileStatisticsScreen extends MobileBasePage {
  const MobileStatisticsScreen({super.key}) : super(
    title: '数据统计',
    pageIndex: 3,
    contentBuilder: _buildStatisticsContent,
  );

  static Widget _buildStatisticsContent(BuildContext context) {
    final controller = Get.find<StatisticsScreenController>();
    
    return Obx(() {
      // 如果没有投资组合，显示空状态
      if (!controller.hasPortfolios.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.insert_chart_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  '暂无投资组合',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '请先创建一个投资组合查看统计分析',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      
      // 有投资组合时显示正常内容
      return RefreshIndicator(
        onRefresh: () async {
          // 简单的刷新逻辑 - 重新检查投资组合状态
          final portfolioController = Get.find<PortfolioEventController>();
          await portfolioController.checkPortfolioState();
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 时间范围选择器
                  const MobileTimeRangeFilter(),
                  
                  const SizedBox(height: 16),
                  
                  // 快照历史热力图
                  const MobileSnapshotHeatmap(),
                  
                  const SizedBox(height: 16),
                  
                  // 持仓占比饼图
                  const MobilePortfolioAllocationPieChart(),
                  
                  const SizedBox(height: 16),
                  
                  // 盈亏胜率饼图
                  const MobileWinRatePieChart(),
                  
                  const SizedBox(height: 16),
                  
                  // 盈亏金额饼图
                  const MobileProfitLossPieChart(),
                  
                  const SizedBox(height: 16),
                  
                  // 资产趋势折线图
                  const MobileAssetTrendLineChart(),
                  
                  const SizedBox(height: 16),
                  
                  // 交易频率柱状图
                  const MobileTradingFrequencyChart(),
                  
                  const SizedBox(height: 16),
                  
                  // 恐惧贪婪分布饼图
                  const MobileFearGreedProfitChart(),
                  
                  // 底部安全间距
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      );
    });
  }
} 