import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/database/database_provider.dart';
import 'package:trade_flex/core/services/log/log_service.dart';

/// 成就缓存管理器
/// 负责管理成就系统中的各种统计缓存
class AchievementCacheManager {
  static AchievementCacheManager? _instance;
  static AchievementCacheManager get instance => _instance ??= AchievementCacheManager._();
  
  AchievementCacheManager._();

  // ===== 分级缓存系统 =====
  final Map<String, dynamic> _basicStatsCache = {}; // 基础统计缓存
  final Map<String, dynamic> _complexStatsCache = {}; // 复杂统计缓存
  final Map<String, bool> _achievementStatusCache = {}; // 成就状态缓存
  
  // 缓存时间戳
  DateTime? _basicCacheUpdate;
  DateTime? _complexCacheUpdate;

  // 缓存有效期配置
  static const Duration _basicCacheValidDuration = Duration(minutes: 2);
  static const Duration _complexCacheValidDuration = Duration(minutes: 5);

  /// 获取数据库实例
  AppDatabase get _database => DatabaseProvider.instance.database;

  /// 获取基础统计缓存
  Future<Map<String, dynamic>> getBasicStatsCache() async {
    if (_isBasicCacheValid() && _basicStatsCache.isNotEmpty) {
      return _basicStatsCache;
    }

    try {
      LogService.instance.d('更新基础统计缓存...');
      
      // 获取所有交易数据
      final transactions = await _database.select(_database.tradingTransactions).get();
      
      // 基础统计计算
      _basicStatsCache.clear();
      _basicStatsCache['totalTrades'] = transactions.length;
      _basicStatsCache['transactions'] = transactions;
      
      // 盈利相关统计
      final profitableTrades = transactions.where((t) => 
        t.profitOrLoss != null && 
        double.tryParse(t.profitOrLoss!) != null && 
        double.parse(t.profitOrLoss!) > 0
      ).toList();
      
      _basicStatsCache['profitableTrades'] = profitableTrades;
      _basicStatsCache['hasProfitableTrade'] = profitableTrades.isNotEmpty;
      _basicStatsCache['profitableTradeCount'] = profitableTrades.length;
      
      // 时间相关统计
      if (transactions.isNotEmpty) {
        transactions.sort((a, b) => a.tradeDate.compareTo(b.tradeDate));
        _basicStatsCache['firstTradeDate'] = transactions.first.tradeDate;
        _basicStatsCache['lastTradeDate'] = transactions.last.tradeDate;
        
        // 计算交易天数跨度
        final daySpan = transactions.last.tradeDate.difference(transactions.first.tradeDate).inDays;
        _basicStatsCache['tradingDaySpan'] = daySpan;
      }
      
      // 特殊交易统计
      _basicStatsCache['midnightTrades'] = transactions.where((t) => 
        t.tradeDate.hour >= 0 && t.tradeDate.hour < 3
      ).toList();
      
      _basicStatsCache['earlyMorningTrades'] = transactions.where((t) => 
        t.tradeDate.hour < 5
      ).toList();
      
      _basicCacheUpdate = DateTime.now();
      LogService.instance.d('基础统计缓存更新完成');
    } catch (e) {
      LogService.instance.e('更新基础统计缓存失败: $e');
    }

    return _basicStatsCache;
  }

  /// 获取复杂统计缓存
  Future<Map<String, dynamic>> getComplexStatsCache() async {
    if (_isComplexCacheValid() && _complexStatsCache.isNotEmpty) {
      return _complexStatsCache;
    }

    try {
      LogService.instance.d('更新复杂统计缓存...');
      
      // 获取相关数据
      final positions = await _database.select(_database.positions).get();
      final portfolios = await _database.select(_database.portfolios).get();
      final notes = await _database.select(_database.notes).get();
      final tags = await _database.select(_database.tags).get();
      final deposits = await _database.select(_database.depositsAndWithdrawals).get();
      final transactions = await _database.select(_database.tradingTransactions).get();
      
      _complexStatsCache.clear();
      
      // 持仓相关统计
      final activePositions = positions.where((p) => !p.isClosed).toList();
      _complexStatsCache['activePositions'] = activePositions;
      _complexStatsCache['activePositionCount'] = activePositions.length;
      _complexStatsCache['totalPositions'] = positions;
      
      // 投资组合相关统计
      _complexStatsCache['portfolios'] = portfolios;
      _complexStatsCache['portfolioCount'] = portfolios.length;
      _complexStatsCache['transactions'] = transactions; // 添加交易数据，供投资组合成就检查使用
      
      // 分析记录相关统计
      _complexStatsCache['notes'] = notes;
      _complexStatsCache['noteCount'] = notes.length;
      _complexStatsCache['tags'] = tags;
      _complexStatsCache['tagCount'] = tags.length;
      
      // 资金管理相关统计
      _complexStatsCache['deposits'] = deposits;
      
      _complexCacheUpdate = DateTime.now();
      LogService.instance.d('复杂统计缓存更新完成');
    } catch (e) {
      LogService.instance.e('更新复杂统计缓存失败: $e');
    }

    return _complexStatsCache;
  }

  /// 检查基础缓存是否有效
  bool _isBasicCacheValid() {
    if (_basicCacheUpdate == null) return false;
    return DateTime.now().difference(_basicCacheUpdate!) < _basicCacheValidDuration;
  }

  /// 检查复杂缓存是否有效
  bool _isComplexCacheValid() {
    if (_complexCacheUpdate == null) return false;
    return DateTime.now().difference(_complexCacheUpdate!) < _complexCacheValidDuration;
  }

  /// 缓存失效管理
  void invalidateRelatedCaches(String dataType) {
    switch (dataType) {
      case 'trading_transactions':
        // 交易数据变化影响基础统计和复杂统计
        _basicStatsCache.clear();
        _complexStatsCache.clear();
        _basicCacheUpdate = null;
        _complexCacheUpdate = null;
        break;
      case 'positions':
        // 持仓数据变化影响复杂统计
        _complexStatsCache.clear();
        _complexCacheUpdate = null;
        break;
      case 'portfolios':
      case 'portfolio_snapshots':
      case 'notes':
      case 'deposits_withdrawals':
      case 'tags':
        // 其他数据变化影响特定统计
        _complexStatsCache.clear();
        _complexCacheUpdate = null;
        break;
    }
    
    // 所有数据变化都会影响成就状态缓存
    _achievementStatusCache.clear();
  }

  /// 清空所有缓存
  void clearAllCaches() {
    _basicStatsCache.clear();
    _complexStatsCache.clear();
    _achievementStatusCache.clear();
    _basicCacheUpdate = null;
    _complexCacheUpdate = null;
  }

  /// 获取成就状态缓存
  Map<String, bool> get achievementStatusCache => _achievementStatusCache;
} 