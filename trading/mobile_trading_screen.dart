import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/mobile/base/mobile_base_page.dart';
import 'package:trade_flex/mobile/trading/widgets/mobile_portfolio_summary_card.dart';
import 'package:trade_flex/mobile/trading/widgets/mobile_trading_operation_area.dart';
import 'package:trade_flex/mobile/trading/widgets/mobile_trading_records.dart';
import 'package:trade_flex/mobile/trading/controller/mobile_trading_screen_controller.dart';

/// 移动端交易屏幕
/// 
/// 包含三个主要组件：
/// 1. 投资组合概览卡片
/// 2. 交易操作区域
/// 3. 交易记录
/// 
/// 使用MobileTradingScreenController统一管理投资组合切换和数据加载
class MobileTradingScreen extends MobileBasePage {
  const MobileTradingScreen({super.key}) : super(
    title: '交易',
    pageIndex: 0,
    contentBuilder: _buildTradingContent,
  );

  static Widget _buildTradingContent(BuildContext context) {
    // 获取移动端交易屏幕控制器
    final controller = Get.find<MobileTradingScreenController>();
    
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
                  Icons.account_balance_wallet_outlined,
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
                  '请先创建一个投资组合开始交易',
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
        onRefresh: controller.refreshData,
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 投资组合概览卡片
              MobilePortfolioSummaryCard(),
              
              SizedBox(height: 16),
              
              // 交易操作区域
              MobileTradingOperationArea(),
              
              SizedBox(height: 16),
              
              // 交易记录
              MobileTradingRecords(),
              
              // 底部安全区域
              SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }
} 