import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/routes/mobile_routes.dart';

/// 移动端应用头部组件
/// 
/// 显示应用logo、名称、投资组合选择器和设置按钮
class MobileAppHeader extends StatelessWidget {
  final String title; // 保留参数以兼容现有代码，但不再使用
  final Widget? portfolioSelector;

  const MobileAppHeader({
    Key? key,
    required this.title,
    this.portfolioSelector,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo和应用名
          Row(
            children: [
              // Logo
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // 如果logo图片不存在，显示默认图标
                      return const Icon(
                        Icons.trending_up,
                        color: Colors.white,
                        size: 20,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 应用名
              Text(
                'Trade Flex',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          
          // 投资组合选择器
          if (portfolioSelector != null) ...[
            const SizedBox(width: 16),
            Expanded(
              child: portfolioSelector!,
            ),
          ] else ...[
            const Spacer(),
          ],
          
          // 设置按钮
          IconButton(
            onPressed: () {
              // 导航到设置页面
              Get.toNamed(MobileRoutes.settings);
            },
            icon: Icon(
              Icons.settings_outlined,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            tooltip: '设置',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
        ],
      ),
    );
  }
} 