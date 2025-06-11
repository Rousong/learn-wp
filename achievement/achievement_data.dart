import 'package:drift/drift.dart';
import 'package:trade_flex/core/database/database.dart';

/// 成就数据定义
/// 
/// 包含所有成就的初始化数据和相关配置
/// 现在使用achievementId进行国际化映射，而不是硬编码的name和description
class AchievementData {
  /// 获取所有默认成就列表
  static List<AchievementsCompanion> getDefaultAchievements() {
    final now = DateTime.now();
    
    return [
      // ===== 基础成就 =====
      AchievementsCompanion.insert(
        achievementId: 'first_trade', // 初出茅庐
        icon: 'flag_outlined',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'first_profit', // 盈利之始
        icon: 'trending_up',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'trade_expert', // 交易达人
        icon: 'checklist',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'hundred_trades', // 百炼成钢
        icon: 'star_border',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'thousand_trades', // 千炼成钢
        icon: 'military_tech',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'tradeflex',
        icon: 'favorite_border',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),

      // ===== 盈利相关成就 =====
      AchievementsCompanion.insert(
        achievementId: 'continuous_profit', // 连续盈利
        icon: 'trending_up',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'profit_king', // 盈利之王
        icon: 'emoji_events',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'comeback', // 绝地反击
        icon: 'restart_alt',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'small_gain', // 小有斩获
        icon: 'attach_money',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'double_profit', // 双倍盈利
        icon: 'trending_up',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'steady_investor', // 稳健投资者
        icon: 'balance',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),

      // ===== 持仓管理成就 =====
      AchievementsCompanion.insert(
        achievementId: 'position_master', // 持仓能手
        icon: 'inventory_2_outlined',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'diversified_investor', // 多元化投资者
        icon: 'scatter_plot',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'long_term_holder',
        icon: 'schedule',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'short_term_hunter', // 短线猎手
        icon: 'speed',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'swing_trader', // 波段交易者
        icon: 'waves',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'diamond_hands', // 钻石之手
        icon: 'diamond',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),

      // ===== 投资组合管理成就 =====
      AchievementsCompanion.insert(
        achievementId: 'portfolio_manager', // 投资组合管理
        icon: 'folder_copy',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'multi_market', // 多市场征服者
        icon: 'public',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'crypto_newbie',//币圈新人类
        icon: 'currency_bitcoin',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),

      // ===== 风险控制成就 =====
      AchievementsCompanion.insert(
        achievementId: 'risk_controller', // 风险控制者
        icon: 'shield_outlined',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'stop_loss_master', // 止损大师
        icon: 'content_cut',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'emotion_stable',
        icon: 'psychology',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),

      // ===== 资金管理成就 =====
      AchievementsCompanion.insert(
        achievementId: 'heavy_position', // 重仓玩家
        icon: 'rocket_launch',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'big_gambler', // 大赌徒
        icon: 'casino',
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: now,
        updateTime: now,
      ),

      // ===== 分析记录成就 =====
      AchievementsCompanion.insert(
        achievementId: 'analysis_master',
        icon: 'analytics_outlined',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'tag_lover', // 标签爱好者
        icon: 'label_important_outline',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'number_perfectionist', // 数字完美主义者
        icon: 'filter_9_plus',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'data_maniac', // 数据狂人
        icon: 'data_usage',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'perfectionist', // 完美主义者
        icon: 'verified',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),

      // ===== 时间相关成就 =====
      AchievementsCompanion.insert(
        achievementId: 'triple_strike', // 三连击
        icon: 'calendar_today',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'daily_checkin',
        icon: 'event_available',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'never_stop',
        icon: 'all_inclusive',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),

      // ===== 交易策略成就 =====
      AchievementsCompanion.insert(
        achievementId: 'short_commander',
        icon: 'trending_down',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'arbitrage_expert',
        icon: 'swap_horiz',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'grid_warrior',
        icon: 'grid_on',
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),

      // ===== 特殊时间成就（隐藏） =====
      AchievementsCompanion.insert(
        achievementId: 'midnight_trader',
        icon: 'nightlight_round',
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'early_bird',
        icon: 'wb_sunny',
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'night_owl',
        icon: 'bedtime',
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'lightning_speed',
        icon: 'flash_on',
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'system_overload',
        icon: 'memory',
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: now,
        updateTime: now,
      ),

      // ===== 特殊节日成就（隐藏） =====
      AchievementsCompanion.insert(
        achievementId: 'new_year',
        icon: 'celebration',
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'valentine',
        icon: 'favorite',
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'mid_autumn',
        icon: 'brightness_2',
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'national_day',
        icon: 'flag',
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'christmas',
        icon: 'card_giftcard',
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: now,
        updateTime: now,
      ),
      AchievementsCompanion.insert(
        achievementId: 'thanksgiving',
        icon: 'volunteer_activism',
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: now,
        updateTime: now,
      ),
    ];
  }

  /// 获取成就类别映射
  static Map<String, List<String>> getAchievementCategories() {
    return {
      '基础成就': ['first_trade', 'first_profit', 'trade_expert', 'hundred_trades', 'thousand_trades', 'tradeflex'],
      '盈利大师': ['continuous_profit', 'profit_king', 'comeback', 'small_gain', 'double_profit', 'steady_investor'],
      '持仓管理': ['position_master', 'diversified_investor', 'long_term_holder', 'short_term_hunter', 'swing_trader', 'diamond_hands'],
      '投资组合': ['portfolio_manager', 'multi_market', 'crypto_newbie'],
      '风险控制': ['risk_controller', 'stop_loss_master', 'emotion_stable'],
      '资金管理': ['heavy_position', 'big_gambler'],
      '分析记录': ['analysis_master', 'tag_lover', 'number_perfectionist', 'data_maniac', 'perfectionist'],
      '时间管理': ['triple_strike', 'daily_checkin', 'never_stop'],
      '交易策略': ['short_commander', 'arbitrage_expert', 'grid_warrior'],
      '隐藏成就': ['midnight_trader', 'early_bird', 'night_owl', 'lightning_speed', 'system_overload', 'big_gambler', 'new_year', 'valentine', 'mid_autumn', 'national_day', 'christmas', 'thanksgiving'],
    };
  }

  /// 获取成就难度等级
  static Map<String, String> getAchievementDifficulty() {
    return {
      // 简单
      'first_trade': '简单',
      'first_profit': '简单',
      'crypto_newbie': '简单',
      'short_commander': '简单',
      'tradeflex': '简单',
      
      // 普通
      'trade_expert': '普通',
      'position_master': '普通',
      'risk_controller': '普通',
      'analysis_master': '普通',
      'tag_lover': '普通',
      'continuous_profit': '普通',
      'triple_strike': '普通',
      'short_term_hunter': '普通',
      'number_perfectionist': '普通',
      'small_gain': '普通',
      
      // 困难
      'hundred_trades': '困难',
      'diversified_investor': '困难',
      'portfolio_manager': '困难',
      'long_term_holder': '困难',
      'swing_trader': '困难',
      'multi_market': '困难',
      'stop_loss_master': '困难',
      'daily_checkin': '困难',
      'arbitrage_expert': '困难',
      'grid_warrior': '困难',
      'perfectionist': '困难',
      'steady_investor': '困难',
      
      // 极难
      'thousand_trades': '极难',
      'profit_king': '极难',
      'comeback': '极难',
      'heavy_position': '极难',
      'emotion_stable': '极难',
      'never_stop': '极难',
      'double_profit': '极难',
      'diamond_hands': '极难',
      
      // 隐藏成就
      'midnight_trader': '隐藏',
      'early_bird': '隐藏',
      'night_owl': '隐藏',
      'lightning_speed': '隐藏',
      'system_overload': '隐藏',
      'big_gambler': '隐藏',
      'data_maniac': '隐藏',
      'new_year': '隐藏',
      'valentine': '隐藏',
      'mid_autumn': '隐藏',
      'national_day': '隐藏',
      'christmas': '隐藏',
      'thanksgiving': '隐藏',
    };
  }
} 