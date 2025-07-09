import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/mobile/base/mobile_base_page.dart';
import 'package:trade_flex/core/controllers/withdrew_deposit/withdraw_deposit_controller.dart';
import 'package:trade_flex/core/event/portfolio_event_controller.dart';
import 'package:trade_flex/mobile/withdraw_deposit/widgets/mobile_summary_widget.dart';
import 'package:trade_flex/mobile/withdraw_deposit/widgets/mobile_deposit_withdraw_form.dart';
import 'package:trade_flex/mobile/withdraw_deposit/widgets/mobile_transaction_history.dart';

/// 移动端出入金屏幕
/// 
/// 显示投资组合的出入金操作和历史记录
/// 复用桌面端控制器，针对移动端优化布局
class MobileWithdrawDepositScreen extends MobileBasePage {
  const MobileWithdrawDepositScreen({super.key}) : super(
    title: '入出金',
    pageIndex: 4,
    contentBuilder: _buildWithdrawDepositContent,
  );

  static Widget _buildWithdrawDepositContent(BuildContext context) {
    // 获取出入金控制器
    final controller = Get.find<WithdrawDepositController>();
    
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
                  '请先创建一个投资组合进行资金操作',
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
          // 重新检查投资组合状态
          final portfolioController = Get.find<PortfolioEventController>();
          await portfolioController.checkPortfolioState();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 出入金内容
              _buildWithdrawDepositWidgets(context, controller),
              
              // 底部安全区域
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }

  /// 构建出入金内容组件
  static Widget _buildWithdrawDepositWidgets(BuildContext context, WithdrawDepositController controller) {
    return const Column(
      children: [
        // 1. 摘要区域 - 显示投资组合信息和现金比例
        MobileSummaryWidget(),
        
        SizedBox(height: 16),
        
        // 2. 出入金表单区域
        MobileDepositWithdrawForm(),
        
        SizedBox(height: 16),
        
        // 3. 交易历史记录区域
        MobileTransactionHistory(),
      ],
    );
  }
} 