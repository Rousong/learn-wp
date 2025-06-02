import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/event/portfolio_event_controller.dart';
import 'package:trade_flex/core/controllers/base/mobile_base_page_controller.dart';
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
    final portfolioController = Get.find<PortfolioEventController>();
    // 检查投资组合状态
    portfolioController.checkPortfolioState();

    return Scaffold(
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
    );
  }

  /// 构建底部导航栏
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: pageIndex,
      onTap: (index) => controller.handleNavigationItemSelected(index),
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



/// 移动端历史页面
class MobileHistoryPage extends MobileBasePage {
  const MobileHistoryPage({super.key}) : super(
    title: '历史',
    pageIndex: 2,
    contentBuilder: _buildHistoryContent,
  );
  
  static Widget _buildHistoryContent(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Color(0xFF16425B)),
          SizedBox(height: 16),
          Text(
            '历史页面',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('这里将显示交易历史'),
        ],
      ),
    );
  }
}

/// 移动端统计页面
class MobileStatisticsPage extends MobileBasePage {
  const MobileStatisticsPage({super.key}) : super(
    title: '统计',
    pageIndex: 3,
    contentBuilder: _buildStatisticsContent,
  );
  
  static Widget _buildStatisticsContent(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_chart, size: 64, color: Color(0xFF81C3D7)),
          SizedBox(height: 16),
          Text(
            '统计页面',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('这里将显示统计分析'),
        ],
      ),
    );
  }
}

/// 移动端入出金页面
class MobileWithdrawDepositPage extends MobileBasePage {
  const MobileWithdrawDepositPage({super.key}) : super(
    title: '入出金',
    pageIndex: 4,
    contentBuilder: _buildWithdrawDepositContent,
  );
  
  static Widget _buildWithdrawDepositContent(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet, size: 64, color: Color(0xFF2E86AB)),
          SizedBox(height: 16),
          Text(
            '入出金页面',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('这里将显示入出金记录'),
        ],
      ),
    );
  }
}

/// 移动端设置页面
class MobileSettingsPage extends StatelessWidget {
  const MobileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.settings, size: 64, color: Color(0xFF3A7CA5)),
              SizedBox(height: 16),
              Text(
                '设置页面',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('这里将显示应用设置选项'),
            ],
          ),
        ),
      ),
    );
  }
} 