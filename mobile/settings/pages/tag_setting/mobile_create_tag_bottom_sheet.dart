import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/repositories/tag_repository.dart';
import 'package:trade_flex/core/utils/snackbar_utils.dart';
import 'package:trade_flex/core/utils/keyboard_utils.dart';

/// 移动端创建标签底部弹出页面
/// 
/// 用于创建新标签
class MobileCreateTagBottomSheet extends StatefulWidget {
  final Function(String tagName)? onTagCreated;

  const MobileCreateTagBottomSheet({
    super.key,
    this.onTagCreated,
  });

  @override
  State<MobileCreateTagBottomSheet> createState() => _MobileCreateTagBottomSheetState();
}

class _MobileCreateTagBottomSheetState extends State<MobileCreateTagBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tagRepository = TagRepository.instance;
  bool _isCreating = false;

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
                        '创建标签',
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
                // 表单
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '标签名称',
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
                          hintText: '请输入标签名称',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.label_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入标签名称';
                          }
                          if (value.trim().length > 50) {
                            return '标签名称不能超过50个字符';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _createTag(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '标签名称应简洁明了，便于分类管理交易记录',
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
                        onPressed: _isCreating ? null : () => Get.back(),
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isCreating ? null : _createTag,
                        child: _isCreating
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                                ),
                              )
                            : const Text('创建'),
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

  /// 创建标签
  Future<void> _createTag() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final tagName = _nameController.text.trim();

    // 检查标签名称是否已存在
    final existingTag = await _tagRepository.getTagByName(tagName);
    if (existingTag != null) {
      SnackbarUtils.error('错误', '标签名称已存在');
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      await _tagRepository.addTag(tagName);
      
      // 回调通知上级页面
      if (widget.onTagCreated != null) {
        widget.onTagCreated!(tagName);
      }

      // 先关闭弹出页面，然后显示成功提示
      Get.back();
      
      // 使用 Future.delayed 确保导航完成后再显示 Snackbar
      Future.delayed(const Duration(milliseconds: 100), () {
        SnackbarUtils.success('成功', '标签创建成功');
      });
    } catch (e) {
      SnackbarUtils.error('错误', '创建标签失败');
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
} 