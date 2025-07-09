import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/controllers/settings/achievement_settings_controller.dart';
import 'package:trade_flex/core/utils/achievement_utils.dart';
import 'package:trade_flex/core/utils/keyboard_utils.dart';

/// 移动端成就设置页面
/// 
/// 显示成就网格，一排摆四个成就图标
class MobileAchievementSettingsScreen extends GetView<AchievementSettingsController> {
  const MobileAchievementSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissible(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('成就系统'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: Column(
          children: [
            // 成就进度统计
            _buildProgressHeader(),
            const Divider(height: 1),
            // 成就网格
            Expanded(
              child: GetBuilder<AchievementSettingsController>(
                builder: (controller) {
                  if (!controller.isInitialized) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  if (controller.achievements.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildAchievementGrid(controller.achievements);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建进度头部
  Widget _buildProgressHeader() {
    return GetBuilder<AchievementSettingsController>(
      builder: (controller) {
        final unlockedCount = controller.unlockedCount;
        final totalCount = controller.totalCount;
        final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '成就进度',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(Get.context!).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$unlockedCount / $totalCount 已解锁',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(Get.context!).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(Get.context!).primaryColor,
                ),
                minHeight: 8,
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              '暂无成就数据',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '开始使用应用来解锁各种成就吧！',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建成就网格
  Widget _buildAchievementGrid(List<Achievement> achievements) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 一排四个
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8, // 稍微高一点，适合移动端
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildAchievementCard(achievement);
      },
    );
  }

  /// 构建单个成就卡片
  Widget _buildAchievementCard(Achievement achievement) {
    final bool isUnlocked = achievement.unlocked;
    final bool showAsHidden = achievement.isHidden && !isUnlocked;

    return GestureDetector(
      onTap: () => _showAchievementDetail(achievement),
      child: Column(
        children: [
          // 成就图标容器
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _getCardBackgroundColor(achievement),
                borderRadius: BorderRadius.circular(16),
                border: isUnlocked 
                  ? Border.all(
                      color: Theme.of(Get.context!).primaryColor.withValues(alpha: 0.3),
                      width: 2,
                    )
                  : null,
                boxShadow: isUnlocked 
                  ? [
                      BoxShadow(
                        color: Theme.of(Get.context!).primaryColor.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
              ),
              child: Center(
                child: Opacity(
                  opacity: _getOpacity(achievement),
                  child: Icon(
                    _getIconFromString(achievement.icon, showAsHidden),
                    size: 32,
                    color: _getIconColor(achievement, showAsHidden),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 成就名称
          Text(
            _getDisplayName(achievement, showAsHidden),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getNameColor(achievement, showAsHidden),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 获取成就图标
  IconData _getIconFromString(String iconString, bool showAsHidden) {
    if (showAsHidden) {
      return Icons.question_mark_rounded;
    }

    switch (iconString) {
      // ===== 基础成就图标 =====
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'monetization_on':
        return Icons.monetization_on;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'verified':
        return Icons.verified;
      case 'military_tech':
        return Icons.military_tech;
      case 'auto_awesome':
        return Icons.auto_awesome;
      
      // ===== 盈利相关成就图标 =====
      case 'show_chart':
        return Icons.show_chart;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'phoenix_rising':
        return Icons.restart_alt;
      case 'savings':
        return Icons.savings;
      case 'double_arrow':
        return Icons.double_arrow;
      case 'account_balance':
        return Icons.account_balance;
      
      // ===== 持仓管理成就图标 =====
      case 'dashboard_customize':
        return Icons.dashboard_customize;
      case 'scatter_plot':
        return Icons.scatter_plot;
      case 'hourglass_full':
        return Icons.hourglass_full;
      case 'flash_on':
        return Icons.flash_on;
      case 'waves':
        return Icons.waves;
      case 'diamond':
        return Icons.diamond;
      
      // ===== 投资组合成就图标 =====
      case 'business_center':
        return Icons.business_center;
      case 'language':
        return Icons.language;
      case 'currency_bitcoin':
        return Icons.currency_bitcoin;
      
      // ===== 情绪控制成就图标 =====
      case 'psychology_alt':
        return Icons.psychology_alt;
      case 'trending_up_outlined':
        return Icons.trending_up_outlined;
      case 'content_cut':
        return Icons.content_cut;
      case 'self_improvement':
        return Icons.self_improvement;
      
      // ===== 资金管理成就图标 =====
      case 'trending_up':
        return Icons.trending_up;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      
      // ===== 分析记录成就图标 =====
      case 'analytics':
        return Icons.analytics;
      case 'local_offer':
        return Icons.local_offer;
      case 'calculate':
        return Icons.calculate;
      case 'description':
        return Icons.description;
      case 'sticky_note_2':
        return Icons.sticky_note_2;
      
      // ===== 时间管理成就图标 =====
      case 'filter_3':
        return Icons.filter_3;
      case 'event_available':
        return Icons.event_available;
      case 'all_inclusive':
        return Icons.all_inclusive;
      
      // ===== 交易策略成就图标 =====
      case 'trending_down':
        return Icons.trending_down;
      case 'balance':
        return Icons.balance;
      case 'layers':
        return Icons.layers;
      
      // ===== 特殊时间成就图标（隐藏） =====
      case 'nightlight':
        return Icons.nightlight;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'dark_mode':
        return Icons.dark_mode;
      case 'bolt':
        return Icons.bolt;
      case 'memory':
        return Icons.memory;
      
      // ===== 特殊节日成就图标（隐藏） =====
      case 'celebration':
        return Icons.celebration;
      case 'local_pizza':
        return Icons.local_pizza;
      case 'swap_horizontal_circle':
        return Icons.swap_horizontal_circle;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'volunteer_activism':
        return Icons.volunteer_activism;
      
      default:
        return Icons.help_outline;
    }
  }

  /// 获取卡片背景色
  Color _getCardBackgroundColor(Achievement achievement) {
    final bool isUnlocked = achievement.unlocked;
    final bool showAsHidden = achievement.isHidden && !isUnlocked;

    if (showAsHidden) {
      return Colors.grey[100]!;
    }

    if (isUnlocked) {
      return Theme.of(Get.context!).primaryColor.withValues(alpha: 0.1);
    } else {
      return Colors.grey[50]!;
    }
  }

  /// 获取透明度
  double _getOpacity(Achievement achievement) {
    final bool isUnlocked = achievement.unlocked;
    final bool showAsHidden = achievement.isHidden && !isUnlocked;

    if (showAsHidden) {
      return 0.6;
    }

    return isUnlocked ? 1.0 : 0.5;
  }

  /// 获取图标颜色
  Color _getIconColor(Achievement achievement, bool showAsHidden) {
    if (showAsHidden) {
      return Colors.grey[500]!;
    }

    final bool isUnlocked = achievement.unlocked;
    return isUnlocked
        ? Theme.of(Get.context!).primaryColor
        : Colors.grey[400]!;
  }

  /// 获取显示名称
  String _getDisplayName(Achievement achievement, bool showAsHidden) {
    if (showAsHidden) {
      return '未知成就';
    }

    return AchievementUtils.getAchievementTitle(achievement.achievementId);
  }

  /// 获取名称颜色
  Color _getNameColor(Achievement achievement, bool showAsHidden) {
    if (showAsHidden) {
      return Colors.grey[600]!;
    }

    final bool isUnlocked = achievement.unlocked;
    return isUnlocked
        ? Theme.of(Get.context!).textTheme.bodyMedium?.color ?? Colors.black
        : Colors.grey[500]!;
  }

  /// 显示成就详情
  void _showAchievementDetail(Achievement achievement) {
    final bool showAsHidden = achievement.isHidden && !achievement.unlocked;

    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 拖拽指示器
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                // 成就图标
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _getCardBackgroundColor(achievement),
                    borderRadius: BorderRadius.circular(20),
                    border: achievement.unlocked 
                      ? Border.all(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                          width: 2,
                        )
                      : null,
                  ),
                  child: Icon(
                    _getIconFromString(achievement.icon, showAsHidden),
                    size: 40,
                    color: _getIconColor(achievement, showAsHidden),
                  ),
                ),
                const SizedBox(height: 20),
                // 成就标题
                Text(
                  _getDisplayName(achievement, showAsHidden),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // 成就描述
                Text(
                  showAsHidden 
                    ? '这是一个隐藏成就，完成特定条件后即可解锁查看详情'
                    : AchievementUtils.getAchievementDescription(achievement.achievementId),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // 解锁状态
                if (achievement.unlocked) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                                                 const Icon(
                           Icons.check_circle,
                           color: Colors.green,
                           size: 20,
                         ),
                        const SizedBox(width: 8),
                        Text(
                          achievement.unlockDate != null
                            ? '已于 ${DateFormat('yyyy-MM-dd').format(achievement.unlockDate!)} 解锁'
                            : '已解锁',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '尚未解锁',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // 关闭按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('关闭'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 