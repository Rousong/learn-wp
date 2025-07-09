import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/settings/tag_settings_controller.dart';
import 'package:trade_flex/core/utils/keyboard_utils.dart';
import 'package:trade_flex/mobile/settings/pages/tag_setting/mobile_tag_card.dart';
import 'package:trade_flex/mobile/settings/pages/tag_setting/mobile_empty_tag_state.dart';
import 'package:trade_flex/mobile/settings/pages/tag_setting/mobile_create_tag_bottom_sheet.dart';

/// 移动端标签管理页面
/// 
/// 显示标签列表，复用桌面端的TagSettingsController
class MobileTagSettingsScreen extends GetView<TagSettingsController> {
  const MobileTagSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissible(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('标签管理'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          actions: [
            // 排序按钮
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort),
              tooltip: '排序方式',
              onSelected: controller.changeSortMethod,
              itemBuilder: (context) => [
                _buildSortMenuItem(context, 'usage', '使用次数', Icons.numbers),
                _buildSortMenuItem(context, 'name', '名称', Icons.sort_by_alpha),
                _buildSortMenuItem(context, 'date', '创建日期', Icons.calendar_today_outlined),
              ],
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final tags = controller.tags;
          
          if (tags.isEmpty) {
            return const MobileEmptyTagState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await controller.loadTags();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tags.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tag = tags[index];
                return MobileTagCard(
                  tag: tag,
                  controller: controller,
                );
              },
            ),
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateTagBottomSheet(context),
          tooltip: '添加标签',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  /// 构建排序菜单项
  PopupMenuItem<String> _buildSortMenuItem(BuildContext context, String value, String text, IconData icon) {
    final theme = Theme.of(context);
    
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 12),
          Text(text),
          const Spacer(),
          Obx(() {
            final isSelected = controller.sortBy.value == value;
            final isAscending = controller.ascending.value;
            if (isSelected) {
              return Icon(
                isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: theme.primaryColor,
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  /// 显示创建标签底部弹出页面
  void _showCreateTagBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MobileCreateTagBottomSheet(
        onTagCreated: (tagName) async {
          await controller.loadTags(); // 重新加载标签列表
        },
      ),
    );
  }
} 