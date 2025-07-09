import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/settings/ui_settings_controller.dart';
import 'package:trade_flex/core/utils/keyboard_utils.dart';
import 'package:trade_flex/mobile/settings/pages/ui_setting/widgets/mobile_color_setting_card.dart';
import 'package:trade_flex/mobile/settings/pages/ui_setting/widgets/mobile_theme_setting_card.dart';
import 'package:trade_flex/mobile/settings/pages/ui_setting/widgets/mobile_language_setting_card.dart';

/// 移动端界面设置页面
/// 
/// 提供主题、颜色、语言等界面相关设置
class MobileUISettingsScreen extends GetView<UISettingsController> {
  const MobileUISettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissible(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('界面设置'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => controller.showResetConfirmDialog(),
              tooltip: '恢复默认设置',
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 外观设置区域
            _buildSectionHeader('外观设置', Icons.palette_outlined),
            const SizedBox(height: 12),
            
            // 主题模式设置
            MobileThemeSettingCard(controller: controller),
            
            const SizedBox(height: 12),
            
            // 主题颜色设置
            Obx(() => MobileColorSettingCard(
              title: '主题颜色',
              icon: Icons.color_lens_outlined,
              color: controller.primaryColor.value,
              onTap: () => controller.showColorPicker(
                '主题颜色',
                UISettingsController.primaryColorKey,
                controller.primaryColor.value,
              ),
            )),
            
            const SizedBox(height: 12),
            
            // 语言设置
            MobileLanguageSettingCard(controller: controller),
            
            const SizedBox(height: 32),
            
            // 交易颜色设置区域
            _buildSectionHeader('交易颜色', Icons.show_chart_outlined),
            const SizedBox(height: 12),
            
            // 盈利颜色
            Obx(() => MobileColorSettingCard(
              title: '盈利颜色',
              icon: Icons.trending_up,
              color: controller.profitColor.value,
              onTap: () => controller.showColorPicker(
                '盈利颜色',
                UISettingsController.profitColorKey,
                controller.profitColor.value,
              ),
            )),
            
            const SizedBox(height: 12),
            
            // 亏损颜色
            Obx(() => MobileColorSettingCard(
              title: '亏损颜色',
              icon: Icons.trending_down,
              color: controller.lossColor.value,
              onTap: () => controller.showColorPicker(
                '亏损颜色',
                UISettingsController.lossColorKey,
                controller.lossColor.value,
              ),
            )),
            
            const SizedBox(height: 12),
            
            // 兑换颜色
            Obx(() => MobileColorSettingCard(
              title: '兑换颜色',
              icon: Icons.currency_exchange_outlined,
              color: controller.exchangeColor.value,
              onTap: () => controller.showColorPicker(
                '兑换颜色',
                UISettingsController.exchangeColorKey,
                controller.exchangeColor.value,
              ),
            )),
            
            const SizedBox(height: 12),
            
            // 股息颜色
            Obx(() => MobileColorSettingCard(
              title: '股息颜色',
              icon: Icons.currency_exchange_outlined,
              color: controller.dividentColor.value,
              onTap: () => controller.showColorPicker(
                '股息颜色',
                UISettingsController.dividentColorKey,
                controller.dividentColor.value,
              ),
            )),
            
            const SizedBox(height: 32),
            
            // 恢复默认设置按钮
            _buildResetButton(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 构建区域标题
  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(Get.context!).primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(Get.context!).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建重置按钮
  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => controller.showResetConfirmDialog(),
        icon: const Icon(Icons.refresh, size: 20),
        label: const Text('恢复默认设置'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red[600],
          side: BorderSide(color: Colors.red[300]!),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
} 