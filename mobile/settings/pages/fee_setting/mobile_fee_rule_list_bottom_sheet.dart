import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/controllers/settings/fee_model_controller.dart';
import 'package:trade_flex/mobile/settings/pages/fee_setting/mobile_create_fee_rule_bottom_sheet.dart';
import 'package:trade_flex/mobile/settings/pages/fee_setting/mobile_edit_fee_rule_bottom_sheet.dart';

/// 移动端收费规则列表底部弹出页面
/// 
/// 显示指定收费模式的所有规则
class MobileFeeRuleListBottomSheet extends StatelessWidget {
  final FeeModel model;
  final FeeModelController controller;

  const MobileFeeRuleListBottomSheet({
    super.key,
    required this.model,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部拖拽指示器和标题
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(
                      Icons.rule,
                      color: theme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '费率规则',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            model.name,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 规则列表
          Expanded(
            child: Obx(() {
              final rules = controller.currentRules;
              
              if (rules.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.rule_folder_outlined,
                          size: 64,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '暂无费率规则',
                          style: TextStyle(
                            fontSize: 18,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '为此收费模式添加具体的费率计算规则',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: rules.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final rule = rules[index];
                  return _buildRuleCard(context, rule);
                },
              );
            }),
          ),
          
          // 底部添加按钮
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showCreateRuleBottomSheet(context),
                icon: const Icon(Icons.add),
                label: const Text('添加规则'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建规则卡片
  Widget _buildRuleCard(BuildContext context, FeeRule rule) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 规则类型图标
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _getRuleTypeColor(rule.ruleType).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _getRuleTypeIcon(rule.ruleType),
                    size: 16,
                    color: _getRuleTypeColor(rule.ruleType),
                  ),
                ),
                const SizedBox(width: 12),
                
                // 规则名称和类型
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rule.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getRuleTypeLabel(rule.ruleType),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getRuleTypeColor(rule.ruleType),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 操作按钮
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert, 
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('编辑'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: colorScheme.error),
                          const SizedBox(width: 8),
                          Text('删除', style: TextStyle(color: colorScheme.error)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditRuleBottomSheet(context, rule);
                    } else if (value == 'delete') {
                      _showDeleteRuleDialog(context, rule);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 规则详情
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildDetailRow(context, '费率', '${rule.value}%'),
                  const SizedBox(height: 8),
                  _buildDetailRow(context, '最低费用', rule.minFee),
                  const SizedBox(height: 8),
                  _buildDetailRow(context, '最高费用', rule.maxFee == '0' ? '无限制' : rule.maxFee),
                  const SizedBox(height: 8),
                  _buildDetailRow(context, '适用范围', 
                    '${rule.startRange} - ${rule.endRange == '0' ? '无限制' : rule.endRange}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建详情行
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  /// 获取规则类型图标
  IconData _getRuleTypeIcon(String ruleType) {
    switch (ruleType) {
      case 'buy':
        return Icons.arrow_circle_down;
      case 'sell':
        return Icons.arrow_circle_up;
      case 'universal':
      default:
        return Icons.swap_horiz;
    }
  }

  /// 获取规则类型颜色
  Color _getRuleTypeColor(String ruleType) {
    switch (ruleType) {
      case 'buy':
        return Colors.green.shade700;
      case 'sell':
        return Colors.red.shade700;
      case 'universal':
      default:
        return Colors.blue.shade700;
    }
  }

  /// 获取规则类型标签
  String _getRuleTypeLabel(String ruleType) {
    switch (ruleType) {
      case 'buy':
        return '买入';
      case 'sell':
        return '卖出';
      case 'universal':
      default:
        return '通用';
    }
  }

  /// 显示创建规则底部弹出页面
  void _showCreateRuleBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MobileCreateFeeRuleBottomSheet(
        modelId: model.id,
        onFeeRuleCreated: (rule) async {
          await controller.addRule(rule);
        },
      ),
    );
  }

  /// 显示编辑规则底部弹出页面
  void _showEditRuleBottomSheet(BuildContext context, FeeRule rule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MobileEditFeeRuleBottomSheet(
        rule: rule,
        onFeeRuleUpdated: (updatedRule) async {
          await controller.updateRule(updatedRule);
        },
      ),
    );
  }

  /// 显示删除规则确认对话框
  void _showDeleteRuleDialog(BuildContext context, FeeRule rule) {
    final colorScheme = Theme.of(context).colorScheme;
    
    Get.dialog(
      AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除规则 "${rule.name}" 吗？\n\n此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.deleteRule(rule.id);
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