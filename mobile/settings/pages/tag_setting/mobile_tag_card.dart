import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/settings/tag_settings_controller.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/mobile/settings/pages/tag_setting/mobile_edit_tag_bottom_sheet.dart';
import 'package:trade_flex/mobile/settings/pages/tag_setting/mobile_tag_trades_bottom_sheet.dart';

/// 移动端标签卡片组件
/// 
/// 显示标签信息，支持展开收起查看详细信息和操作
class MobileTagCard extends StatefulWidget {
  final Tag tag;
  final TagSettingsController controller;

  const MobileTagCard({
    super.key,
    required this.tag,
    required this.controller,
  });

  @override
  State<MobileTagCard> createState() => _MobileTagCardState();
}

class _MobileTagCardState extends State<MobileTagCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 2,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 主要信息区域
          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 标签图标
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.label_outline,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 标签信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tag.tagName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '已使用 ${widget.tag.usageCount} 次',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 展开/收起图标
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
          // 展开的详细信息
          if (isExpanded)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Column(
                children: [
                  Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.2)),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 详细信息
                        _buildDetailRow(
                          '创建时间',
                          _formatDate(widget.tag.createTime),
                          Icons.calendar_today_outlined,
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          '更新时间',
                          _formatDate(widget.tag.updateTime),
                          Icons.update,
                        ),
                        const SizedBox(height: 16),
                        // 操作按钮
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showTagTrades(),
                                icon: const Icon(Icons.list_alt, size: 18),
                                label: const Text('查看交易'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showEditTag(),
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text('编辑'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () => _showMoreActions(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              child: const Icon(Icons.more_horiz, size: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 构建详细信息行
  Widget _buildDetailRow(String label, String value, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurface.withValues(alpha: 0.6)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 显示标签相关交易
  void _showTagTrades() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MobileTagTradesBottomSheet(
        tag: widget.tag,
        controller: widget.controller,
      ),
    );
  }

  /// 显示编辑标签页面
  void _showEditTag() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MobileEditTagBottomSheet(
        tag: widget.tag,
        onTagUpdated: (updatedTag) async {
          await widget.controller.loadTags();
        },
      ),
    );
  }

  /// 显示更多操作菜单
  void _showMoreActions() {
    final colorScheme = Theme.of(context).colorScheme;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.merge_type),
              title: const Text('合并到其他标签'),
              enabled: widget.controller.tags.length > 1,
              onTap: () {
                Get.back();
                widget.controller.mergeTags(widget.tag);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: colorScheme.error),
              title: Text('删除标签', style: TextStyle(color: colorScheme.error)),
              onTap: () {
                Get.back();
                widget.controller.deleteTag(widget.tag);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
} 