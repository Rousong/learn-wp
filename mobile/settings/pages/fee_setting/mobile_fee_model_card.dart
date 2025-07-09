import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/controllers/settings/fee_model_controller.dart';
import 'package:trade_flex/mobile/settings/pages/fee_setting/mobile_edit_fee_model_bottom_sheet.dart';
import 'package:trade_flex/mobile/settings/pages/fee_setting/mobile_fee_rule_list_bottom_sheet.dart';

/// 移动端收费模式卡片组件
/// 
/// 显示收费模式信息，支持展开查看规则详情
class MobileFeeModelCard extends StatefulWidget {
  final FeeModel model;
  final FeeModelController controller;

  const MobileFeeModelCard({
    super.key,
    required this.model,
    required this.controller,
  });

  @override
  State<MobileFeeModelCard> createState() => _MobileFeeModelCardState();
}

class _MobileFeeModelCardState extends State<MobileFeeModelCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = widget.controller.selectedModel.value?.id == widget.model.id;
    
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected 
          ? BorderSide(color: theme.primaryColor, width: 2)
          : BorderSide.none,
      ),
      child: Column(
        children: [
          // 主要信息区域
          InkWell(
            onTap: () {
              widget.controller.selectModel(widget.model);
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 收费模式图标
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.attach_money,
                      color: theme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // 收费模式信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.model.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.model.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // 展开/收起图标
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
          
          // 展开的操作区域
          if (_isExpanded) ...[
            Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.2)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 规则数量信息
                  Obx(() {
                    final rules = widget.controller.currentRules;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.rule,
                            size: 16,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${rules.length} 条规则',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  
                  // 操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showRulesList(context),
                          icon: const Icon(Icons.list, size: 18),
                          label: const Text('查看规则'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showEditBottomSheet(context),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('编辑'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => _showDeleteDialog(context),
                        icon: const Icon(Icons.delete_outline),
                        color: colorScheme.error,
                        tooltip: '删除',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 显示规则列表底部弹出页面
  void _showRulesList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MobileFeeRuleListBottomSheet(
        model: widget.model,
        controller: widget.controller,
      ),
    );
  }

  /// 显示编辑收费模式底部弹出页面
  void _showEditBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MobileEditFeeModelBottomSheet(
        model: widget.model,
        onFeeModelUpdated: (updatedModel) async {
          await widget.controller.updateFeeModel(updatedModel);
        },
      ),
    );
  }

  /// 显示删除确认对话框
  void _showDeleteDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    Get.dialog(
      AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除收费模式 "${widget.model.name}" 吗？\n\n这将同时删除所有关联的规则，此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await widget.controller.deleteFeeModel(widget.model.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
} 