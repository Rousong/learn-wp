import 'package:flutter/material.dart';

/// 移动端空投资组合状态组件
/// 
/// 当没有投资组合时显示的空状态界面
/// 适配移动端的布局和交互
class MobileEmptyPortfolioState extends StatelessWidget {
  /// 显示的图标
  final IconData icon;
  
  /// 标题文本
  final String title;
  
  /// 描述文本
  final String description;
  
  /// 可选的操作按钮文本
  final String? actionText;
  
  /// 操作按钮回调
  final VoidCallback? onAction;

  const MobileEmptyPortfolioState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                icon,
                size: 40,
                color: colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 标题
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // 描述
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            // 操作按钮（如果提供）
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 20),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 