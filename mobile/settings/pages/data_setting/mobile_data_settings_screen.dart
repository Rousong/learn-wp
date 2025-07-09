import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/settings/data_settings_controller.dart';
import 'package:trade_flex/core/constants/premium_features.dart';
import 'package:trade_flex/core/widgets/premium_feature_widget.dart';

/// 移动端数据设置页面
/// 
/// 提供数据备份、恢复、导出等数据管理功能
class MobileDataSettingsScreen extends GetView<DataSettingsController> {
  const MobileDataSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据管理'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDataOperationsSection(context),
          const SizedBox(height: 20),
          _buildBackupManagementSection(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 构建数据操作区域
  Widget _buildDataOperationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '数据操作', Icons.data_usage),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Obx(() => _buildActionTile(
                context,
                icon: Icons.backup_outlined,
                title: '数据备份',
                subtitle: '将您的交易数据备份到安全位置',
                isLoading: controller.isLoadingBackup.value,
                onTap: controller.isLoadingBackup.value ? null : controller.backupData,
                isFirst: true,
              )),
              _buildDivider(),
              Obx(() => _buildActionTile(
                context,
                icon: Icons.restore_page_outlined,
                title: '数据恢复',
                subtitle: '从之前的备份文件中恢复数据',
                isLoading: controller.isLoadingRestore.value,
                onTap: controller.isLoadingRestore.value ? null : controller.restoreData,
              )),
              _buildDivider(),
              _buildExportTile(context),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建备份管理区域
  Widget _buildBackupManagementSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(context, '备份历史', Icons.backup),
            TextButton.icon(
              onPressed: controller.loadBackupList,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('刷新'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              if (controller.isLoadingBackupList.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (controller.backupList.isEmpty) {
                return _buildEmptyBackupState(context);
              }

              return Column(
                children: [
                  // 显示最近的3个备份
                  ...controller.backupList.take(3).map((backup) =>
                    _buildBackupItem(context, backup)
                  ),
                  if (controller.backupList.length > 3) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => _showAllBackupsBottomSheet(context),
                        child: Text('查看全部 ${controller.backupList.length} 个备份'),
                      ),
                    ),
                  ],
                ],
              );
            }),
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
    required bool isLoading,
    required VoidCallback? onTap,
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
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
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
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // 箭头图标
              if (!isLoading)
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建导出功能项
  Widget _buildExportTile(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          // 图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(() => controller.isLoadingExport.value
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    Icons.file_download_outlined,
                    size: 20,
                    color: theme.primaryColor,
                  )),
          ),
          const SizedBox(width: 16),
          // 文本内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '导出备份文件',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '将数据库备份文件保存到您选择的位置 (付费功能)',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // 付费按钮
          Obx(() => controller.isLoadingExport.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : PremiumButton(
                  feature: PremiumFeature.dataExport,
                  text: '导出',
                  onPressed: controller.exportBackup,
                )),
        ],
      ),
    );
  }

  /// 构建分割线
  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 72,
      endIndent: 16,
      color: Theme.of(Get.context!).colorScheme.outline.withValues(alpha: 0.2),
    );
  }

  /// 构建空备份状态
  Widget _buildEmptyBackupState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.backup_outlined,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              '暂无备份文件',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '点击上方"数据备份"按钮创建第一个备份\n定期备份可以保护您的交易数据安全',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建备份项
  Widget _buildBackupItem(BuildContext context, dynamic backup) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.backup,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  backup.fileName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${backup.formattedCreatedAt} • ${backup.formattedFileSize}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
                      PopupMenuButton(
              icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), size: 20),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'restore',
                child: Row(
                  children: [
                    Icon(Icons.restore, size: 16),
                    SizedBox(width: 8),
                    Text('恢复'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 8),
                    Text('删除', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'restore':
                  controller.restoreFromBackup(backup.filePath);
                  break;
                case 'delete':
                  controller.deleteBackup(backup);
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  /// 显示所有备份的底部弹窗
  void _showAllBackupsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // 顶部拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题栏
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '所有备份文件',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 备份列表
            Expanded(
              child: Obx(() => ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: controller.backupList.length,
                itemBuilder: (context, index) {
                  final backup = controller.backupList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        Icons.backup,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(backup.fileName),
                      subtitle: Text(
                        '创建时间: ${backup.formattedCreatedAt}\n'
                        '文件大小: ${backup.formattedFileSize}',
                      ),
                      trailing: PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'restore',
                            child: Row(
                              children: [
                                Icon(Icons.restore, size: 16),
                                SizedBox(width: 8),
                                Text('恢复'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 16, color: Theme.of(context).colorScheme.error),
                                const SizedBox(width: 8),
                                Text('删除', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          Get.back(); // 关闭底部弹窗
                          switch (value) {
                            case 'restore':
                              controller.restoreFromBackup(backup.filePath);
                              break;
                            case 'delete':
                              controller.deleteBackup(backup);
                              break;
                          }
                        },
                      ),
                      onTap: () {
                        Get.back(); // 关闭底部弹窗
                        controller.restoreFromBackup(backup.filePath);
                      },
                    ),
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }
} 