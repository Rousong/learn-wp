import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/mobile/base/mobile_base_page.dart';
import 'package:trade_flex/core/controllers/history/history_screen_controller.dart';
import 'package:trade_flex/core/controllers/history/history_records_controller.dart';
import 'package:trade_flex/core/event/portfolio_event_controller.dart';
import 'package:trade_flex/mobile/history/widgets/mobile_history_filter.dart';
import 'package:trade_flex/mobile/history/widgets/mobile_history_records.dart';
import 'package:trade_flex/mobile/history/widgets/mobile_history_stats.dart';

/// 移动端历史记录屏幕
/// 
/// 显示已关闭持仓的历史记录和相关交易信息
/// 参考桌面端历史记录功能，针对移动端优化布局
class MobileHistoryScreen extends MobileBasePage {
  const MobileHistoryScreen({super.key}) : super(
    title: '历史',
    pageIndex: 2,
    contentBuilder: _buildHistoryContent,
  );

  static Widget _buildHistoryContent(BuildContext context) {
    // 获取历史记录屏幕控制器
    final controller = Get.find<HistoryScreenController>();
    
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
                  Icons.history_outlined,
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
                  '请先创建一个投资组合查看历史记录',
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 历史记录内容
              _buildHistoryWidgets(context, controller),
              
              // 底部安全区域
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }

  /// 构建历史记录内容组件
  static Widget _buildHistoryWidgets(BuildContext context, HistoryScreenController screenController) {
    // 获取历史记录控制器
    final recordsController = Get.find<HistoryRecordsController>();
    
    return Column(
      children: [
        // 筛选器
        const MobileHistoryFilter(),
        
        const SizedBox(height: 16),
        
        // 统计信息卡片
        const MobileHistoryStats(),
        
        const SizedBox(height: 16),
        
        // 历史记录列表
        Obx(() {
          if (recordsController.isLoadingSubPositions.value) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (recordsController.closedSubPositions.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return const MobileHistoryRecords();
        }),
      ],
    );
  }

  /// 构建空状态
  static Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
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
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.folder_off_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无历史记录',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '当前筛选条件下没有已关闭的持仓记录',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 