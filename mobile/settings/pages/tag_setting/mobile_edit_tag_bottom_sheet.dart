import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/repositories/tag_repository.dart';
import 'package:trade_flex/core/utils/snackbar_utils.dart';
import 'package:trade_flex/core/utils/keyboard_utils.dart';

/// 移动端编辑标签底部弹出页面
/// 
/// 用于编辑现有标签
class MobileEditTagBottomSheet extends StatefulWidget {
  final Tag tag;
  final Function(Tag updatedTag)? onTagUpdated;

  const MobileEditTagBottomSheet({
    super.key,
    required this.tag,
    this.onTagUpdated,
  });

  @override
  State<MobileEditTagBottomSheet> createState() => _MobileEditTagBottomSheetState();
}

class _MobileEditTagBottomSheetState extends State<MobileEditTagBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _tagRepository = TagRepository.instance;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tag.tagName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return KeyboardDismissible(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题栏
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '编辑标签',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
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
                const SizedBox(height: 24),
                // 标签信息
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.label_outline,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(width: 12),
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
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // 表单
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '新标签名称',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: '请输入新的标签名称',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.edit_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入标签名称';
                          }
                          if (value.trim().length > 50) {
                            return '标签名称不能超过50个字符';
                          }
                          if (value.trim() == widget.tag.tagName) {
                            return '新名称与原名称相同';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _updateTag(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '更改标签名称不会影响已关联的交易记录',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // 操作按钮
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isUpdating ? null : () => Get.back(),
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isUpdating ? null : _updateTag,
                        child: _isUpdating
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                                ),
                              )
                            : const Text('保存'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 更新标签
  Future<void> _updateTag() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newTagName = _nameController.text.trim();

    // 检查新标签名称是否已存在（排除自身）
    final existingTag = await _tagRepository.getTagByName(newTagName);
    if (existingTag != null && existingTag.id != widget.tag.id) {
      SnackbarUtils.error('错误', '标签名称已存在');
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      // 创建更新后的标签对象
      final updatedTag = Tag(
        id: widget.tag.id,
        tagName: newTagName,
        usageCount: widget.tag.usageCount,
        createTime: widget.tag.createTime,
        updateTime: DateTime.now(),
      );

      await _tagRepository.updateTag(widget.tag.id, updatedTag);
      
      // 回调通知上级页面
      if (widget.onTagUpdated != null) {
        widget.onTagUpdated!(updatedTag);
      }

      // 先关闭弹出页面，然后显示成功提示
      Get.back();
      
      // 使用 Future.delayed 确保导航完成后再显示 Snackbar
      Future.delayed(const Duration(milliseconds: 100), () {
        SnackbarUtils.success('成功', '标签更新成功');
      });
    } catch (e) {
      SnackbarUtils.error('错误', '更新标签失败');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }
} 