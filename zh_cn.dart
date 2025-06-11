import 'package:trade_flex/core/constants/trade_flex_strings.dart';

/// 中文（简体）翻译映射
const Map<String, String> zhCN = {
  // --- UI 标签 --- 
  TradeFlexStrings.assetType: '资产类型',
  TradeFlexStrings.market: '市场',
  
  // --- 资产类型翻译 (对应 AssetTypes.toKey) ---
  TradeFlexStrings.assetTypeAll: '全部',
  TradeFlexStrings.assetTypeStock: '股票',
  TradeFlexStrings.assetTypeEtf: 'ETF',
  TradeFlexStrings.assetTypeFuture: '期货',
  TradeFlexStrings.assetTypeForex: '外汇',
  TradeFlexStrings.assetTypeCrypto: '加密货币',
  TradeFlexStrings.assetTypeOption: '期权',
  TradeFlexStrings.assetTypeBond: '债券',
  TradeFlexStrings.assetTypeFund: '基金',
  TradeFlexStrings.assetTypeIndex: '指数',

  // --- 市场翻译 (对应 Markets.toKey) ---
  TradeFlexStrings.marketGlobal: '全球',
  TradeFlexStrings.marketUSStocks: '美股',
  TradeFlexStrings.marketLondonExchange: '伦敦证券交易所',
  TradeFlexStrings.marketTorontoExchange: '多伦多证券交易所',
  TradeFlexStrings.marketBerlinExchange: '泛欧布鲁塞尔证券交易所',
  TradeFlexStrings.marketEuronextParis: '泛欧巴黎证券交易所',
  TradeFlexStrings.marketEuronextBrussels: '泛欧布鲁塞尔证券交易所',
  TradeFlexStrings.marketEuronextLisbon: '泛欧里斯本',
  TradeFlexStrings.marketSwissExchange: '瑞士证券交易所',
  TradeFlexStrings.marketEuronextAmsterdam: '泛欧阿姆斯特丹',
  TradeFlexStrings.marketHongKongExchange: '香港证券交易所',
  TradeFlexStrings.marketSingaporeExchange: '新加坡证券交易所',
  TradeFlexStrings.marketShanghaiExchange: '上海证券交易所',
  TradeFlexStrings.marketShenzhenExchange: '深圳证券交易所',
  TradeFlexStrings.marketKoreaExchange: '韩国证券交易所',
  TradeFlexStrings.marketBombayExchange: '孟买证券交易所',
  TradeFlexStrings.marketThailandExchange: '泰国证券交易所',
  TradeFlexStrings.marketNSEIndia: '印度国家证券交易所',
  TradeFlexStrings.marketAustralia: '澳大利亚证券交易所',
  TradeFlexStrings.marketCrypto: '加密货币',
  TradeFlexStrings.marketForex: '外汇', 
  
  // === 成就系统翻译 ===
  // 页面标题和通用文本
  TradeFlexStrings.achievementSystem: '成就系统',
  TradeFlexStrings.achievementUnlocked: '成就解锁！',
  TradeFlexStrings.achievementProgress: '完成特定目标，解锁您的交易成就！',
  TradeFlexStrings.achievementCount: '({unlocked}/{total})',
  TradeFlexStrings.hiddenAchievement: '隐藏成就',
  TradeFlexStrings.unknownAchievement: '？？？',
  TradeFlexStrings.unlockedOn: '解锁于: {date}',
  TradeFlexStrings.dateUnknown: '(日期未知)',
  
  // 成就难度等级
  TradeFlexStrings.difficultyEasy: '简单',
  TradeFlexStrings.difficultyNormal: '普通', 
  TradeFlexStrings.difficultyHard: '困难',
  TradeFlexStrings.difficultyExtreme: '极难',
  TradeFlexStrings.difficultyHidden: '隐藏',
  
  // 成就类别
  TradeFlexStrings.categoryBasic: '基础成就',
  TradeFlexStrings.categoryProfit: '盈利大师',
  TradeFlexStrings.categoryPosition: '持仓管理',
  TradeFlexStrings.categoryPortfolio: '投资组合',
  TradeFlexStrings.categoryRisk: '风险控制',
  TradeFlexStrings.categoryFund: '资金管理',
  TradeFlexStrings.categoryAnalysis: '分析记录',
  TradeFlexStrings.categoryTime: '时间管理',
  TradeFlexStrings.categoryStrategy: '交易策略',
  TradeFlexStrings.categoryHidden: '隐藏成就',
  
  // 基础成就
  TradeFlexStrings.achievementFirstTradeTitle: '初出茅庐',
  TradeFlexStrings.achievementFirstTradeDesc: '完成您的第一笔交易记录',
  TradeFlexStrings.achievementFirstProfitTitle: '盈利之始',
  TradeFlexStrings.achievementFirstProfitDesc: '首次实现单笔盈利',
  TradeFlexStrings.achievementTradeExpertTitle: '交易达人',
  TradeFlexStrings.achievementTradeExpertDesc: '累计完成 10 笔交易记录',
  TradeFlexStrings.achievementHundredTradesTitle: '百炼成钢',
  TradeFlexStrings.achievementHundredTradesDesc: '累计完成 100 笔交易记录',
  TradeFlexStrings.achievementThousandTradesTitle: '千军万马',
  TradeFlexStrings.achievementThousandTradesDesc: '累计完成 1000 笔交易记录',
  TradeFlexStrings.achievementTradeflexTitle: 'TradeFlex',
  TradeFlexStrings.achievementTradeflexDesc: '买入资产时填写 "TradeFlex"',
  
  // 盈利相关成就
  TradeFlexStrings.achievementContinuousProfitTitle: '持续盈利',
  TradeFlexStrings.achievementContinuousProfitDesc: '连续 3 笔交易盈利',
  TradeFlexStrings.achievementProfitKingTitle: '连续盈利王',
  TradeFlexStrings.achievementProfitKingDesc: '连续 10 笔交易全部盈利',
  TradeFlexStrings.achievementComebackTitle: '破而后立',
  TradeFlexStrings.achievementComebackDesc: '遭遇 5 连亏后实现连续盈利',
  TradeFlexStrings.achievementSmallGainTitle: '小有收获',
  TradeFlexStrings.achievementSmallGainDesc: '单笔交易盈利超过 10%',
  TradeFlexStrings.achievementDoubleProfitTitle: '翻倍达人',
  TradeFlexStrings.achievementDoubleProfitDesc: '单笔交易盈利超过 100%',
  TradeFlexStrings.achievementSteadyInvestorTitle: '稳健投资者',
  TradeFlexStrings.achievementSteadyInvestorDesc: '月度收益率保持在 5%-15% 之间',
  
  // 持仓管理成就
  TradeFlexStrings.achievementPositionMasterTitle: '持仓能手',
  TradeFlexStrings.achievementPositionMasterDesc: '同时持有 3 个不同的活跃仓位',
  TradeFlexStrings.achievementDiversifiedInvestorTitle: '分散投资者',
  TradeFlexStrings.achievementDiversifiedInvestorDesc: '同一时间持有 8 个以上标的',
  TradeFlexStrings.achievementLongTermHolderTitle: '长期持有',
  TradeFlexStrings.achievementLongTermHolderDesc: '持有一个仓位超过 30 天',
  TradeFlexStrings.achievementShortTermHunterTitle: '短线猎手',
  TradeFlexStrings.achievementShortTermHunterDesc: '持仓时间小于 10 分钟',
  TradeFlexStrings.achievementSwingTraderTitle: '波段之舞',
  TradeFlexStrings.achievementSwingTraderDesc: '持仓时间介于 3 天至 10 天',
  TradeFlexStrings.achievementDiamondHandsTitle: '钻石之手',
  TradeFlexStrings.achievementDiamondHandsDesc: '持有一个仓位超过 365 天',
  
  // 投资组合成就
  TradeFlexStrings.achievementPortfolioManagerTitle: '组合管理者',
  TradeFlexStrings.achievementPortfolioManagerDesc: '创建并管理 3 个投资组合',
  TradeFlexStrings.achievementMultiMarketTitle: '多市场征服者',
  TradeFlexStrings.achievementMultiMarketDesc: '记录交易涉及 5 个以上市场',
  TradeFlexStrings.achievementCryptoNewbieTitle: '币圈新人类',
  TradeFlexStrings.achievementCryptoNewbieDesc: '首次记录加密资产交易',
  
  // 风险控制成就
  TradeFlexStrings.achievementRiskControllerTitle: '风险控制者',
  TradeFlexStrings.achievementRiskControllerDesc: '连续 5 笔交易设置止损',
  TradeFlexStrings.achievementStopLossMasterTitle: '斩亏高手',
  TradeFlexStrings.achievementStopLossMasterDesc: '一次交易亏损少于 1%，成功止损',
  TradeFlexStrings.achievementEmotionStableTitle: '情绪稳定者',
  TradeFlexStrings.achievementEmotionStableDesc: '连续 5 笔交易无情绪波动记录',
  
  // 资金管理成就
  TradeFlexStrings.achievementHeavyPositionTitle: '重仓突击',
  TradeFlexStrings.achievementHeavyPositionDesc: '开仓即用满全部剩余可用资金',
  TradeFlexStrings.achievementBigGamblerTitle: '大仓位赌徒',
  TradeFlexStrings.achievementBigGamblerDesc: '单笔交易仓位超过账户资金的 50%',
  
  // 分析记录成就
  TradeFlexStrings.achievementAnalysisMasterTitle: '分析大师',
  TradeFlexStrings.achievementAnalysisMasterDesc: '为一笔交易添加 5 条以上分析笔记',
  TradeFlexStrings.achievementTagLoverTitle: '标签爱好者',
  TradeFlexStrings.achievementTagLoverDesc: '创建并使用 10 个不同的标签',
  TradeFlexStrings.achievementNumberPerfectionistTitle: '数字洁癖者',
  TradeFlexStrings.achievementNumberPerfectionistDesc: '开仓价、止损价、止盈价都是整数',
  TradeFlexStrings.achievementDataManiacTitle: '数据狂魔',
  TradeFlexStrings.achievementDataManiacDesc: '单笔交易记录包含超过 20 个字段信息',
  TradeFlexStrings.achievementPerfectionistTitle: '完美主义者',
  TradeFlexStrings.achievementPerfectionistDesc: '连续 10 笔交易都填写了完整的交易信息',
  
  // 时间管理成就
  TradeFlexStrings.achievementTripleStrikeTitle: '三连击',
  TradeFlexStrings.achievementTripleStrikeDesc: '连续三天都有交易记录',
  TradeFlexStrings.achievementDailyCheckinTitle: '每日签到',
  TradeFlexStrings.achievementDailyCheckinDesc: '连续 30 天打开 App',
  TradeFlexStrings.achievementNeverStopTitle: '永不止步',
  TradeFlexStrings.achievementNeverStopDesc: '记录交易超过 365 天',
  
  // 交易策略成就
  TradeFlexStrings.achievementShortCommanderTitle: '空军司令',
  TradeFlexStrings.achievementShortCommanderDesc: '首次做空并成功盈利',
  TradeFlexStrings.achievementArbitrageExpertTitle: '套利专家',
  TradeFlexStrings.achievementArbitrageExpertDesc: '同时在不同市场进行对冲交易',
  TradeFlexStrings.achievementGridWarriorTitle: '网格战士',
  TradeFlexStrings.achievementGridWarriorDesc: '在同一标的上进行 5 次以上分批建仓',
  
  // 隐藏成就
  TradeFlexStrings.achievementMidnightTraderTitle: '午夜交易员',
  TradeFlexStrings.achievementMidnightTraderDesc: '在凌晨 0 点到 3 点之间添加了一笔交易',
  TradeFlexStrings.achievementEarlyBirdTitle: '起得真早',
  TradeFlexStrings.achievementEarlyBirdDesc: '凌晨 5 点之前记录一笔交易',
  TradeFlexStrings.achievementNightOwlTitle: '深夜选手',
  TradeFlexStrings.achievementNightOwlDesc: '凌晨 1 点还在修改交易笔记',
  TradeFlexStrings.achievementLightningSpeedTitle: '光速操作',
  TradeFlexStrings.achievementLightningSpeedDesc: '在 1 分钟内完成开仓和平仓',
  TradeFlexStrings.achievementSystemOverloadTitle: '系统超载',
  TradeFlexStrings.achievementSystemOverloadDesc: '一天内添加了 50 条交易记录',
  
  // 特殊节日成就
  TradeFlexStrings.achievementNewYearTitle: '新年开门红',
  TradeFlexStrings.achievementNewYearDesc: '在新年第一天记录盈利交易',
  TradeFlexStrings.achievementValentineTitle: '情人节惊喜',
  TradeFlexStrings.achievementValentineDesc: '在情人节当天实现意外盈利',
  TradeFlexStrings.achievementMidAutumnTitle: '中秋团圆',
  TradeFlexStrings.achievementMidAutumnDesc: '在中秋节当天完成一笔完美交易',
  TradeFlexStrings.achievementNationalDayTitle: '国庆献礼',
  TradeFlexStrings.achievementNationalDayDesc: '在国庆节期间实现周收益率超过 5%',
  TradeFlexStrings.achievementChristmasTitle: '圣诞奇迹',
  TradeFlexStrings.achievementChristmasDesc: '在圣诞节当天记录年度最佳单笔收益',
  TradeFlexStrings.achievementThanksgivingTitle: '感恩收获',
  TradeFlexStrings.achievementThanksgivingDesc: '在感恩节当天回顾并总结全年交易心得',
  
  // --- 其他通用或特定页面的翻译可以继续添加在这里 ---
  // 'save': '保存',
  // 'cancel': '取消',
}; 