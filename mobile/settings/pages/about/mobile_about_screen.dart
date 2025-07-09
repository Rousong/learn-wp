import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/settings/about_page_controller.dart';

/// 移动端关于页面
/// 
/// 显示应用信息、版本详情、支持文档、分享评价等功能
class MobileAboutScreen extends GetView<AboutPageController> {
  const MobileAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildAppInfoCard(context),
          const SizedBox(height: 20),
          _buildSupportSection(context),
          const SizedBox(height: 20),
          _buildShareSection(context),
          const SizedBox(height: 20),
          _buildCopyrightSection(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 构建应用信息卡片
  Widget _buildAppInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 应用图标
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.primaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.analytics,
                size: 40,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            // 应用名称
            Obx(() => Text(
              controller.appName.value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            )),
            const SizedBox(height: 8),
            // 版本信息
            Obx(() => Text(
              '版本 ${controller.appVersion.value} (Build ${controller.buildNumber.value})',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            )),
            const SizedBox(height: 20),
            // 检查更新按钮
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton.icon(
                icon: controller.isLoadingUpdateCheck.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.system_update_alt, size: 18),
                label: Text(
                  controller.isLoadingUpdateCheck.value ? '正在检查...' : '检查更新',
                ),
                onPressed: controller.isLoadingUpdateCheck.value
                    ? null
                    : controller.checkForUpdates,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建支持与文档区域
  Widget _buildSupportSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '支持与文档', Icons.library_books_outlined),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              _buildActionTile(
                context,
                icon: Icons.history_outlined,
                title: '更新历史',
                subtitle: '查看应用的版本更新记录',
                onTap: controller.viewUpdateHistory,
                isFirst: true,
              ),
              _buildDivider(),
              _buildActionTile(
                context,
                icon: Icons.privacy_tip_outlined,
                title: '隐私协议',
                subtitle: '了解我们如何处理您的数据',
                onTap: controller.viewPrivacyPolicy,
              ),
              _buildDivider(),
              _buildActionTile(
                context,
                icon: Icons.gavel_outlined,
                title: '服务条款与版权',
                subtitle: '阅读服务条款和版权信息',
                onTap: controller.viewTerms,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建分享与评价区域
  Widget _buildShareSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '分享与评价', Icons.thumb_up_alt_outlined),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              _buildActionTile(
                context,
                icon: Icons.share_outlined,
                title: '分享应用',
                subtitle: '将 Trade Flex 分享给朋友',
                onTap: controller.shareApp,
                isFirst: true,
              ),
              _buildDivider(),
              _buildActionTile(
                context,
                icon: Icons.star_outline,
                title: '评价我们',
                subtitle: '去应用商店给我们评分',
                onTap: controller.rateApp,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建区域标题
  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  /// 构建操作项
  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              // 图标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              // 文本内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // 箭头图标
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建分割线
  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 72,
      endIndent: 16,
      color: Colors.grey[200],
    );
  }

  /// 构建版权信息
  Widget _buildCopyrightSection(BuildContext context) {
    return Obx(() => Text(
      '© ${DateTime.now().year} ${controller.appName.value}. All Rights Reserved.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Colors.grey[500],
      ),
    ));
  }
} 