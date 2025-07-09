import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/base/mobile_base_page_controller.dart';
import 'package:trade_flex/core/utils/keyboard_utils.dart';
import 'package:trade_flex/mobile/base/widgets/mobile_app_header.dart';
import 'package:trade_flex/mobile/base/widgets/mobile_portfolio_selector.dart';

/// 移动端基础页面
/// 
/// 移动端应用的主要界面，包含顶部导航和底部导航栏
/// 参考桌面端的BasePage结构，但针对移动端优化
class MobileBasePage extends GetView<MobileBasePageController> {
  /// 页面标题
  final String title;
  
  /// 当前选中的导航索引
  final int pageIndex;
  
  /// 页面内容构建器
  final Widget Function(BuildContext) contentBuilder;
  
  /// 投资组合选择器组件
  final Widget? portfolioSelector;
  
  /// 是否显示投资组合选择器
  final bool showPortfolioSelector;

  const MobileBasePage({
    super.key,
    required this.title,
    required this.pageIndex,
    required this.contentBuilder,
    this.portfolioSelector,
    this.showPortfolioSelector = true,
  });

  @override
  Widget build(BuildContext context) {
    // 获取 PortfolioEventController
    // final portfolioController = Get.find<PortfolioEventController>();
    // 检查投资组合状态
    // portfolioController.checkPortfolioState();

    return KeyboardDismissible(
      child: Scaffold(
        body: Column(
          children: [
            // 顶部区域
            MobileAppHeader(
              title: title,
              portfolioSelector: showPortfolioSelector 
                  ? (portfolioSelector ?? const MobilePortfolioSelector())
                  : null,
            ),
            
            // 主体内容区域
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: contentBuilder(context),
              ),
            ),
          ],
        ),
        
        // 底部导航栏
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  /// 构建底部导航栏
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: pageIndex,
      onTap: (index) {
        // 添加触觉反馈
        HapticFeedback.lightImpact();
        controller.handleNavigationItemSelected(index);
      },
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey[600],
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.swap_horiz),
          activeIcon: Icon(Icons.swap_horiz),
          label: '交易',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance),
          activeIcon: Icon(Icons.account_balance),
          label: '持仓',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          activeIcon: Icon(Icons.history),
          label: '历史',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.insert_chart),
          activeIcon: Icon(Icons.insert_chart_outlined),
          label: '统计',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          activeIcon: Icon(Icons.account_balance_wallet),
          label: '入出金',
        ),
      ],
    );
  }
}

