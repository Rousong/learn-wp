import 'package:drift/drift.dart';
import 'package:trade_flex/core/database/database.dart';

/// 成就数据定义
/// 
/// 包含所有成就的初始化数据和相关配置
/// 现在使用achievementId进行国际化映射，而不是硬编码的name和description
/// 每个成就都有独特的图标设计，避免重复
class AchievementData {
  /// 获取所有默认成就列表
  static List<AchievementsCompanion> getDefaultAchievements() {
    final now = DateTime.now();
    
    return [
      // ===== 基础成就 =====
      // 初出茅庐 - 完成您的第一笔交易记录
      AchievementsCompanion.insert(
        achievementId: 'first_trade',
        icon: 'rocket_launch', // 火箭发射 - 象征开始交易之旅
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 盈利之始 - 首次实现单笔盈利
      AchievementsCompanion.insert(
        achievementId: 'first_profit',
        icon: 'monetization_on', // 金币 - 象征首次盈利
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 交易达人 - 累计完成 10 笔交易记录
      AchievementsCompanion.insert(
        achievementId: 'trade_expert',
        icon: 'workspace_premium', // 专业徽章 - 象征达人级别
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 百炼成钢 - 累计完成 100 笔交易记录
      AchievementsCompanion.insert(
        achievementId: 'hundred_trades',
        icon: 'verified', // 认证徽章 - 象征经验丰富
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 千军万马 - 累计完成 1000 笔交易记录
      AchievementsCompanion.insert(
        achievementId: 'thousand_trades',
        icon: 'military_tech', // 军功章 - 象征千军万马
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // TradeFlex - 买入资产时填写 "TradeFlex"（彩蛋成就） 
      AchievementsCompanion.insert(
        achievementId: 'tradeflex',
        icon: 'auto_awesome', // 魔法星星 - 象征彩蛋惊喜
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: now,
        updateTime: now,
      ),

      // ===== 盈利相关成就 =====
      // 持续盈利 - 连续 3 笔交易盈利
      AchievementsCompanion.insert(
        achievementId: 'continuous_profit',
        icon: 'show_chart', // 上升图表 - 象征持续盈利
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 连续盈利王 - 连续 10 笔交易全部盈利
      AchievementsCompanion.insert(
        achievementId: 'profit_king',
        icon: 'emoji_events', // 奖杯 - 象征盈利之王
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 破而后立 - 遭遇 5 连亏后实现连续盈利
      AchievementsCompanion.insert(
        achievementId: 'comeback',
        icon: 'phoenix_rising', // 凤凰涅槃 - 象征破而后立
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 小有收获 - 单笔交易盈利超过 10%
      AchievementsCompanion.insert(
        achievementId: 'small_gain',
        icon: 'savings', // 储蓄罐 - 象征小有收获
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 翻倍达人 - 单笔交易盈利超过 100%
      AchievementsCompanion.insert(
        achievementId: 'double_profit',
        icon: 'double_arrow', // 双箭头 - 象征翻倍
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 财富倍增者 - 整个投资组合的利润实现翻倍，检查PortfolioSnapshots来得知
      AchievementsCompanion.insert(
        achievementId: 'wealth_doubler',
        icon: 'account_balance', // 银行 - 象征财富倍增
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),

      // ===== 持仓管理成就 =====
      // 持仓能手 - 同时持有 3 个不同的活跃仓位，检查Positions表来得知
      AchievementsCompanion.insert(
        achievementId: 'position_master',
        icon: 'dashboard_customize', // 仪表盘 - 象征持仓管理
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 分散投资者 - 同一时间持有 8 个以上标的，检查Positions表来得知
      AchievementsCompanion.insert(
        achievementId: 'diversified_investor',
        icon: 'scatter_plot', // 散点图 - 象征分散投资
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 长期持有 - 持有一个仓位超过 30 天，检查Positions表来得知
      AchievementsCompanion.insert(
        achievementId: 'long_term_holder',
        icon: 'hourglass_full', // 沙漏 - 象征长期持有
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 短线猎手 - 持仓时间小于 10 分钟
      AchievementsCompanion.insert(
        achievementId: 'short_term_hunter',
        icon: 'flash_on', // 闪电 - 象征快速交易
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 波段之舞 - 持仓时间介于 3 天至 10 天
      AchievementsCompanion.insert(
        achievementId: 'swing_trader',
        icon: 'waves', // 波浪 - 象征波段交易
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 钻石之手 - 持有一个仓位超过 365 天
      AchievementsCompanion.insert(
        achievementId: 'diamond_hands',
        icon: 'diamond', // 钻石 - 象征钻石之手
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),

      // ===== 投资组合管理成就 =====
      // 组合管理者 - 创建并管理 3 个投资组合，检查Portfolio表来得知
      AchievementsCompanion.insert(
        achievementId: 'portfolio_manager',
        icon: 'business_center', // 公文包 - 象征专业管理
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 多市场征服者 - 记录交易涉及 5 个以上市场，检查Portfolio表来得知
      AchievementsCompanion.insert(
        achievementId: 'multi_market',
        icon: 'language', // 地球 - 象征全球市场
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 币圈新人类 - 首次记录加密资产交易，在Portfolio的属性为crypto，并添加交易
      AchievementsCompanion.insert(
        achievementId: 'crypto_newbie',
        icon: 'currency_bitcoin', // 比特币 - 象征加密货币
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),

      // ===== 情绪控制成就 =====
      // 恐惧买入者 - 在极度恐惧情绪下记录买入交易，检查TradingTransactions的fearGreedIndex来得知
      AchievementsCompanion.insert(
        achievementId: 'fear_buyer',
        icon: 'psychology_alt', // 心理学 - 象征情绪控制
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 贪婪追涨者 - 在极度贪婪情绪下追加交易记录，检查TradingTransactions的fearGreedIndex来得知
      AchievementsCompanion.insert(
        achievementId: 'greed_chaser',
        icon: 'trending_up_outlined', // 上涨趋势 - 象征追涨
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 斩亏高手 - 一次交易亏损少于 1%，成功止损
      AchievementsCompanion.insert(
        achievementId: 'stop_loss_master',
        icon: 'content_cut', // 剪刀 - 象征止损
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 情绪稳定者 - 连续 5 笔交易无情绪波动记录
      AchievementsCompanion.insert(
        achievementId: 'emotion_stable',
        icon: 'self_improvement', // 冥想 - 象征情绪稳定
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),

      // ===== 资金管理成就 =====
      // 现金流达人 - 添加10笔入金记录，检查DepositsAndWithdrawals表来得知
      AchievementsCompanion.insert(
        achievementId: 'cash_flow_master',
        icon: 'trending_up', // 上升趋势 - 象征现金流入
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 资金管理师 - 添加10笔出金记录，检查DepositsAndWithdrawals表来得知
      AchievementsCompanion.insert(
        achievementId: 'fund_manager',
        icon: 'account_balance_wallet', // 钱包 - 象征资金管理
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),

      // ===== 分析记录成就 =====
      // 分析大师 - 在投资组合中添加了 10 条以上的笔记，检查notes表来得知
      AchievementsCompanion.insert(
        achievementId: 'analysis_master',
        icon: 'analytics', // 分析图表 - 象征分析能力
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 标签爱好者 - 创建并使用 10 个不同的标签，检查tags表来得知
      AchievementsCompanion.insert(
        achievementId: 'tag_lover',
        icon: 'local_offer', // 标签 - 象征标签管理
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 数字洁癖者 - 连续10笔交易的数量和价格都是整数
      AchievementsCompanion.insert(
        achievementId: 'number_perfectionist',
        icon: 'calculate', // 计算器 - 象征数字精确
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 详细记录者 - 单笔交易备注信息超过 50 字，检查TradingTransactions的description来得知
      AchievementsCompanion.insert(
        achievementId: 'detail_recorder',
        icon: 'description', // 文档 - 象征详细记录
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 备注达人 - 有 10 笔交易以上都添加了备注信息
      AchievementsCompanion.insert(
        achievementId: 'note_master',
        icon: 'sticky_note_2', // 便签 - 象征备注习惯
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),

      // ===== 时间相关成就 =====
      // 三连击 - 连续三天都有交易记录，检查TradingTransactions，如果连续三天都有，则解锁
      AchievementsCompanion.insert(
        achievementId: 'triple_strike',
        icon: 'filter_3', // 数字3 - 象征三连击
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 每日签到 - 连续 30 天打开 App，检查PortfolioSnapshots，如果连续30天都有记录，则解锁
      AchievementsCompanion.insert(
        achievementId: 'daily_checkin',
        icon: 'event_available', // 日历勾选 - 象征每日签到
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 永不止步 - 记录交易超过 365 天，检查TradingTransactions，如果最新的交易和最旧的交易时间差超过365天，则解锁
      AchievementsCompanion.insert(
        achievementId: 'never_stop',
        icon: 'all_inclusive', // 无穷符号 - 象征永不止步
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),

      // ===== 交易策略成就 =====
      // 空军司令 - 首次做空并成功盈利
      AchievementsCompanion.insert(
        achievementId: 'short_commander',
        icon: 'trending_down', // 下降趋势 - 象征做空
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 对冲大师 - 在同一持仓中同时做多和做空
      AchievementsCompanion.insert(
        achievementId: 'hedge_master',
        icon: 'balance', // 天平 - 象征对冲平衡
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),
      // 分批建仓者 - 在同一持仓中进行了 5 次以上的分批操作，有五个Subposition
      AchievementsCompanion.insert(
        achievementId: 'batch_builder',
        icon: 'layers', // 图层 - 象征分批建仓
        unlocked: const Value(false),
        isHidden: const Value(false),
        createTime: now,
        updateTime: now,
      ),

      // ===== 特殊时间成就（隐藏） =====
      // 午夜交易员 - 在凌晨 0 点到 3 点之间添加了一笔交易（隐藏成就）
      AchievementsCompanion.insert(
        achievementId: 'midnight_trader',
        icon: 'nightlight', // 夜灯 - 象征午夜
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: now,
        updateTime: now,
      ),
      // 起得真早 - 凌晨 5 点之前记录一笔交易（隐藏成就）
      AchievementsCompanion.insert(
        achievementId: 'early_bird',
        icon: 'wb_sunny', // 太阳 - 象征早起
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: now,
        updateTime: now,
      ),
      // 深夜选手 - 凌晨 1 点还在修改交易笔记（隐藏成就）
      AchievementsCompanion.insert(
        achievementId: 'night_owl',
        icon: 'dark_mode', // 夜间模式 - 象征深夜
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: now,
        updateTime: now,
      ),
      // 光速操作 - 在 1 分钟内完成开仓和平仓（隐藏成就）
      AchievementsCompanion.insert(
        achievementId: 'lightning_speed',
        icon: 'bolt', // 闪电 - 象征光速
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: now,
        updateTime: now,
      ),
      // 系统超载 - 一天内添加了 50 条交易记录（隐藏成就）
      AchievementsCompanion.insert(
        achievementId: 'system_overload',
        icon: 'memory', // 内存芯片 - 象征系统超载
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: now,
        updateTime: now,
      ),

      // ===== 特殊节日成就（隐藏） =====
      // 新年开门红 - 在新年第一天记录盈利交易（隐藏成就）
      AchievementsCompanion.insert(
        achievementId: 'new_year',
        icon: 'celebration', // 庆祝 - 象征新年
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: now,
        updateTime: now,
      ),
      // 披萨节纪念 - 在比特币披萨节当天买入 BTC（隐藏成就），检查TradingTransactions，如果交易时间在2010年5月22日，而且买入的是BTC，则解锁
      AchievementsCompanion.insert(
        achievementId: 'pizza_day',
        icon: 'local_pizza', // 披萨 - 象征披萨节
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: now,
        updateTime: now,
      ),
      // 兑换初体验 - 首次使用兑换交易功能（隐藏成就），检查TradingTransactions，如果TradeOperate是swapFrom，则解锁
      AchievementsCompanion.insert(
        achievementId: 'first_exchange',
        icon: 'swap_horizontal_circle', // 交换圆圈 - 象征兑换
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: now,
        updateTime: now,
      ),
      // 圣诞奇迹 - 在圣诞节当天记录交易（隐藏成就），检查TradingTransactions，如果交易时间在2024年12月25日，而且交易状态是takeProfit，则解锁
      AchievementsCompanion.insert(
        achievementId: 'christmas',
        icon: 'card_giftcard', // 礼品卡 - 象征圣诞礼物
        unlocked: const Value(false),
        isHidden: const Value(true),
        createTime: now,
        updateTime: now,
      ),
      // 感恩收获 - 在感恩节当天回顾并总结全年交易心得（隐藏成就），检查TradingTransactions，如果交易时间在2024年11月28日，而且交易状态是takeProfit，则解锁
      AchievementsCompanion.insert(
        achievementId: 'thanksgiving',
        icon: 'volunteer_activism', // 志愿服务 - 象征感恩
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
      '基础成就': ['first_trade', 'first_profit', 'trade_expert', 'hundred_trades', 'thousand_trades'],
      '盈利大师': ['continuous_profit', 'profit_king', 'comeback', 'small_gain', 'double_profit', 'wealth_doubler'],
      '持仓管理': ['position_master', 'diversified_investor', 'long_term_holder', 'short_term_hunter', 'swing_trader', 'diamond_hands'],
      '投资组合': ['portfolio_manager', 'multi_market', 'crypto_newbie'],
      '情绪控制': ['fear_buyer', 'greed_chaser', 'stop_loss_master', 'emotion_stable'],
      '资金管理': ['cash_flow_master', 'fund_manager'],
      '分析记录': ['analysis_master', 'tag_lover', 'number_perfectionist', 'detail_recorder', 'note_master'],
      '时间管理': ['triple_strike', 'daily_checkin', 'never_stop'],
      '交易策略': ['short_commander', 'hedge_master', 'batch_builder'],
      '隐藏成就': ['tradeflex', 'midnight_trader', 'early_bird', 'night_owl', 'lightning_speed', 'system_overload', 'new_year', 'pizza_day', 'christmas', 'thanksgiving', 'first_exchange'],
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
      'fear_buyer': '简单',
      'greed_chaser': '简单',
      
      // 普通
      'trade_expert': '普通',
      'position_master': '普通',
      'analysis_master': '普通',
      'tag_lover': '普通',
      'continuous_profit': '普通',
      'triple_strike': '普通',
      'short_term_hunter': '普通',
      'number_perfectionist': '普通',
      'small_gain': '普通',
      'note_master': '普通',
      
      // 困难
      'hundred_trades': '困难',
      'diversified_investor': '困难',
      'portfolio_manager': '困难',
      'long_term_holder': '困难',
      'swing_trader': '困难',
      'multi_market': '困难',
      'stop_loss_master': '困难',
      'daily_checkin': '困难',
      'hedge_master': '困难',
      'batch_builder': '困难',
      'detail_recorder': '困难',
      'wealth_doubler': '困难',
      
      // 极难
      'thousand_trades': '极难',
      'profit_king': '极难',
      'comeback': '极难',
      'cash_flow_master': '普通',
      'emotion_stable': '极难',
      'never_stop': '极难',
      'double_profit': '极难',
      'diamond_hands': '极难',
      
      // 隐藏成就
      'tradeflex': '隐藏',
      'midnight_trader': '隐藏',
      'early_bird': '隐藏',
      'night_owl': '隐藏',
      'lightning_speed': '隐藏',
      'system_overload': '隐藏',
      'fund_manager': '普通',
      'new_year': '隐藏',
      'pizza_day': '隐藏',
      'christmas': '隐藏',
      'thanksgiving': '隐藏',
      'first_exchange': '隐藏',
    };
  }
} 