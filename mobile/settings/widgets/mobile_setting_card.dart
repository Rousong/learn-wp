import 'package:flutter/material.dart';

/// 移动端设置卡片组件
/// 
/// 用于显示设置项的统一卡片样式
class MobileSettingCard extends StatelessWidget {
  /// 图标
  final IconData icon;
  
  /// 激活状态图标
  final IconData? activeIcon;
  
  /// 标题
  final String title;
  
  /// 副标题
  final String subtitle;
  
  /// 点击回调
  final VoidCallback onTap;
  
  /// 是否显示箭头
  final bool showArrow;
  
  /// 自定义尾部组件
  final Widget? trailing;

  const MobileSettingCard({
    super.key,
    required this.icon,
    this.activeIcon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showArrow = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 图标容器
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 文本信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 尾部组件
              if (trailing != null)
                trailing!
              else if (showArrow)
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
} 