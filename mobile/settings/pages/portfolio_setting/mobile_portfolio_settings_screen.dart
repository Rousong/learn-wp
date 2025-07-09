import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/utils/keyboard_utils.dart';
import 'package:trade_flex/core/controllers/settings/portfolio_settings_controller.dart';
import 'package:trade_flex/mobile/settings/pages/portfolio_setting/mobile_empty_portfolio_state.dart';
import 'package:trade_flex/mobile/settings/pages/portfolio_setting/mobile_portfolio_card.dart';

/// 移动端投资组合设置屏幕
/// 
/// 参考桌面端投资组合设置页面，适配移动端布局和交互
/// 使用相同的PortfolioSettingsController进行状态管理
class MobilePortfolioSettingsScreen extends GetView<PortfolioSettingsController> {
  const MobilePortfolioSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissible(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('投资组合管理'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          actions: [
            // 添加投资组合按钮
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: controller.showMobileAddPortfolioBottomSheet,
              tooltip: '添加组合',
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: controller.loadPortfolios,
            child: Obx(() {
              if (controller.portfolios.isEmpty) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: 500,
                    child: MobileEmptyPortfolioState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: '没有找到投资组合',
                      description: '点击右上角的 "+" 来创建您的第一个投资组合吧！',
                      actionText: '创建投资组合',
                      onAction: controller.showMobileAddPortfolioBottomSheet,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.portfolios.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final portfolio = controller.portfolios[index];
                  return MobilePortfolioCard(
                    portfolio: portfolio,
                    controller: controller,
                  );
                },
              );
            }),
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: controller.showMobileAddPortfolioBottomSheet,
          tooltip: '添加投资组合',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
} 