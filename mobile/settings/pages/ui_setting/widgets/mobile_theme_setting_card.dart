import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/settings/ui_settings_controller.dart';

/// 移动端主题设置卡片
/// 
/// 用于显示和设置主题模式（浅色/深色/跟随系统）
class MobileThemeSettingCard extends StatelessWidget {
  final UISettingsController controller;

  const MobileThemeSettingCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(() => ListTile(
        leading: Icon(
          _getThemeModeIcon(controller.themeMode.value),
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        title: const Text(
          '主题模式',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          _getThemeModeText(controller.themeMode.value),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => _showThemeModeBottomSheet(context),
      )),
    );
  }

  /// 获取主题模式图标
  IconData _getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
    }
  }

  /// 获取主题模式文本
  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
      case ThemeMode.system:
        return '跟随系统';
    }
  }

  /// 显示主题模式选择底部弹窗
  void _showThemeModeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖拽指示器
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // 标题
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '选择主题模式',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              
              // 主题选项
              _buildThemeOption(
                context,
                ThemeMode.light,
                Icons.light_mode_outlined,
                '浅色模式',
                '明亮的界面主题',
              ),
              _buildThemeOption(
                context,
                ThemeMode.dark,
                Icons.dark_mode_outlined,
                '深色模式',
                '暗色的界面主题',
              ),
              _buildThemeOption(
                context,
                ThemeMode.system,
                Icons.brightness_auto_outlined,
                '跟随系统',
                '根据系统设置自动切换',
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建主题选项
  Widget _buildThemeOption(
    BuildContext context,
    ThemeMode mode,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = controller.themeMode.value == mode;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
        ),
      ),
      trailing: isSelected 
        ? Icon(
            Icons.check_circle,
            color: Theme.of(context).primaryColor,
          )
        : null,
      onTap: () {
        controller.setThemeMode(mode);
        Navigator.of(context).pop();
      },
    );
  }
} 