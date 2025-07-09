import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/utils/keyboard_utils.dart';
import 'package:trade_flex/core/routes/mobile_routes.dart';
import 'package:trade_flex/mobile/settings/widgets/mobile_setting_card.dart';
import 'package:trade_flex/core/controllers/settings/settings_controller.dart';

/// 移动端设置屏幕
/// 
/// 显示各种设置选项的菜单列表，复用桌面端的SettingsController
class MobileSettingsScreen extends StatelessWidget {
  const MobileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissible(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('设置'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: const MobileSettingsContent(),
      ),
    );
  }
}

/// 设置页面内容组件
class MobileSettingsContent extends GetView<SettingsController> {
  const MobileSettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.settingItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = controller.settingItems[index];
        return MobileSettingCard(
          icon: item.icon,
          activeIcon: item.activeIcon,
          title: item.title,
          subtitle: _getSubtitleForItem(item.title),
          onTap: () => _handleSettingItemTap(item.title),
        );
      },
    );
  }

  /// 根据设置项标题获取副标题描述
  String _getSubtitleForItem(String title) {
    switch (title) {
      case '账户管理':
        return '登录状态、个人信息、会员计划';
      case '投资组合':
        return '投资组合管理、默认设置';
      case '收费模式':
        return '交易费用设置、佣金计算';
      case '标签管理':
        return '自定义标签、分类管理';
      case '成就系统':
        return '成就徽章、进度跟踪';
      case '界面设置':
        return '主题、颜色、语言设置';
      case '数据管理':
        return '备份恢复、数据导入导出';
      case '测试页面':
        return '开发测试功能';
      case '关于':
        return '版本信息、开发团队';
      default:
        return '设置选项';
    }
  }

  /// 处理设置项点击事件
  void _handleSettingItemTap(String title) {
    switch (title) {
      case '账户管理':
        _navigateToAccountSettings();
        break;
      case '投资组合':
        _navigateToPortfolioSettings();
        break;
      case '收费模式':
        _navigateToFeeSettings();
        break;
      case '标签管理':
        _navigateToTagSettings();
        break;
      case '成就系统':
        _navigateToAchievementSettings();
        break;
      case '界面设置':
        _navigateToUISettings();
        break;
      case '数据管理':
        _navigateToDataSettings();
        break;
      case '测试页面':
        _navigateToTestPage();
        break;
      case '关于':
        _navigateToAbout();
        break;
      default:
        Get.snackbar('提示', '$title功能即将推出');
    }
  }

  /// 导航到账户设置页面
  void _navigateToAccountSettings() {
    // TODO: 实现账户设置页面导航
    Get.snackbar('提示', '账户管理功能即将推出');
  }
  
  /// 导航到投资组合设置页面
  void _navigateToPortfolioSettings() {
    Get.toNamed(MobileRoutes.portfolioSettings);
  }
  
  /// 导航到收费模式设置页面
  void _navigateToFeeSettings() {
    Get.toNamed(MobileRoutes.feeSettings);
  }
  
  /// 导航到标签管理页面
  void _navigateToTagSettings() {
    Get.toNamed(MobileRoutes.tagSettings);
  }
  
  /// 导航到成就系统页面
  void _navigateToAchievementSettings() {
    Get.toNamed(MobileRoutes.achievementSettings);
  }
  
  /// 导航到界面设置页面
  void _navigateToUISettings() {
    Get.toNamed(MobileRoutes.uiSettings);
  }
  
  /// 导航到数据管理页面
  void _navigateToDataSettings() {
    Get.toNamed(MobileRoutes.dataSettings);
  }
  
  /// 导航到测试页面
  void _navigateToTestPage() {
    Get.snackbar('提示', '测试页面功能即将推出');
  }
  
  /// 导航到关于页面
  void _navigateToAbout() {
    Get.toNamed(MobileRoutes.about);
  }
} 