import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/settings/ui_settings_controller.dart';

/// 移动端语言设置卡片
/// 
/// 用于显示和设置应用语言
class MobileLanguageSettingCard extends StatelessWidget {
  final UISettingsController controller;

  const MobileLanguageSettingCard({
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
          Icons.language_outlined,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        title: const Text(
          '语言',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          controller.selectedLanguage.value,
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
        onTap: () => _showLanguageBottomSheet(context),
      )),
    );
  }

  /// 显示语言选择底部弹窗
  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
                  '选择语言',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              
              // 语言列表
              Container(
                constraints: const BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.languageOptions.length,
                  itemBuilder: (context, index) {
                    final language = controller.languageOptions[index];
                    final isSelected = language == controller.selectedLanguage.value;
                    
                    return ListTile(
                      title: Text(
                        language,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                        ),
                      ),
                      trailing: isSelected 
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                      onTap: () {
                        Navigator.of(context).pop();
                        _showLanguageChangeDialog(context, language);
                      },
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示语言更改确认对话框
  void _showLanguageChangeDialog(BuildContext context, String language) {
    if (language == controller.selectedLanguage.value) {
      return; // 如果选择的是当前语言，不需要确认
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认更改语言'),
        content: Text('确定要将语言更改为 "$language" 吗？\n\n更改后需要重新启动应用才能完全生效。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.changeLanguage(language);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
} 