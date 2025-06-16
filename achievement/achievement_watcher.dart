import 'dart:async';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/database/database_provider.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/services/achievement/achievement_cache_manager.dart';

/// 成就数据库监控管理器
/// 负责监控数据库变化并触发成就检查
class AchievementWatcher {
  static AchievementWatcher? _instance;
  static AchievementWatcher get instance => _instance ??= AchievementWatcher._();
  
  AchievementWatcher._();

  // 多表数据库监控流订阅
  StreamSubscription<List<TradingTransaction>>? _tradingTransactionsSubscription;
  StreamSubscription<List<Position>>? _positionsSubscription;
  StreamSubscription<List<Portfolio>>? _portfoliosSubscription;
  StreamSubscription<List<PortfolioSnapshot>>? _portfolioSnapshotsSubscription;
  StreamSubscription<List<Note>>? _notesSubscription;
  StreamSubscription<List<DepositsAndWithdrawal>>? _depositsWithdrawalsSubscription;
  StreamSubscription<List<Tag>>? _tagsSubscription;
  StreamSubscription<List<Achievement>>? _achievementsSubscription;

  // 防抖处理
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(seconds: 1);

  // 数据变化标记系统
  final Set<String> _changedDataTypes = {};

  // 数据变化回调
  Function(Set<String>)? _onDataChangedCallback;

  /// 获取数据库实例
  AppDatabase get _database => DatabaseProvider.instance.database;

  /// 设置数据变化回调
  void setOnDataChangedCallback(Function(Set<String>) callback) {
    _onDataChangedCallback = callback;
  }

  /// 设置扩展的数据库监控系统
  void setupDatabaseWatchers() {
    LogService.instance.d('设置扩展数据库监控系统...');
    
    // 监控交易数据变化
    _tradingTransactionsSubscription = _database.select(_database.tradingTransactions).watch().listen(
      (transactions) => _onDataChanged('trading_transactions', transactions),
      onError: (error) => LogService.instance.e('监控交易数据失败: $error'),
    );

    // 监控持仓数据变化
    _positionsSubscription = _database.select(_database.positions).watch().listen(
      (positions) => _onDataChanged('positions', positions),
      onError: (error) => LogService.instance.e('监控持仓数据失败: $error'),
    );

    // 监控投资组合数据变化
    _portfoliosSubscription = _database.select(_database.portfolios).watch().listen(
      (portfolios) => _onDataChanged('portfolios', portfolios),
      onError: (error) => LogService.instance.e('监控投资组合数据失败: $error'),
    );

    // 监控投资组合快照数据变化
    _portfolioSnapshotsSubscription = _database.select(_database.portfolioSnapshots).watch().listen(
      (snapshots) => _onDataChanged('portfolio_snapshots', snapshots),
      onError: (error) => LogService.instance.e('监控投资组合快照数据失败: $error'),
    );

    // 监控笔记数据变化
    _notesSubscription = _database.select(_database.notes).watch().listen(
      (notes) => _onDataChanged('notes', notes),
      onError: (error) => LogService.instance.e('监控笔记数据失败: $error'),
    );

    // 监控出入金数据变化
    _depositsWithdrawalsSubscription = _database.select(_database.depositsAndWithdrawals).watch().listen(
      (deposits) => _onDataChanged('deposits_withdrawals', deposits),
      onError: (error) => LogService.instance.e('监控出入金数据失败: $error'),
    );

    // 监控标签数据变化
    _tagsSubscription = _database.select(_database.tags).watch().listen(
      (tags) => _onDataChanged('tags', tags),
      onError: (error) => LogService.instance.e('监控标签数据失败: $error'),
    );

    LogService.instance.d('扩展数据库监控系统设置完成');
  }

  /// 设置成就数据监控
  void setupAchievementWatcher(Function(List<Achievement>) onAchievementsChanged) {
    // 监控成就数据变化
    _achievementsSubscription = _database.select(_database.achievements).watch().listen(
      onAchievementsChanged,
      onError: (error) => LogService.instance.e('监控成就数据失败: $error'),
    );
  }

  /// 统一数据变化处理
  void _onDataChanged(String dataType, List<dynamic> data) {
    // 标记数据类型变化
    _changedDataTypes.add(dataType);
    
    // 清除相关缓存
    AchievementCacheManager.instance.invalidateRelatedCaches(dataType);
    
    // 使用防抖处理，避免频繁触发
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      _processDataChanges();
    });
  }

  /// 处理数据变化
  void _processDataChanges() {
    if (_onDataChangedCallback != null && _changedDataTypes.isNotEmpty) {
      final changedTypes = Set<String>.from(_changedDataTypes);
      _changedDataTypes.clear();
      _onDataChangedCallback!(changedTypes);
    }
  }

  /// 取消所有监控订阅
  void dispose() {
    _tradingTransactionsSubscription?.cancel();
    _positionsSubscription?.cancel();
    _portfoliosSubscription?.cancel();
    _portfolioSnapshotsSubscription?.cancel();
    _notesSubscription?.cancel();
    _depositsWithdrawalsSubscription?.cancel();
    _tagsSubscription?.cancel();
    _achievementsSubscription?.cancel();
    _debounceTimer?.cancel();
  }
} 