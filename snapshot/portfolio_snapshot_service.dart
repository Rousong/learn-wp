import 'dart:async';
import 'package:trade_flex/core/repositories/portfolio_snapshot_repository.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/utils/snackbar_utils.dart';
import 'package:trade_flex/core/database/database.dart';

/// 快照更新参数配置
class _SnapshotUpdateParams {
  final bool showSuccessMessage;
  final bool showErrorMessage;
  
  const _SnapshotUpdateParams({
    required this.showSuccessMessage,
    required this.showErrorMessage,
  });
}

/// 投资组合快照服务
/// 
/// 负责处理快照的创建和更新逻辑，使用防抖动机制确保用户停止操作后执行快照更新
class PortfolioSnapshotService {
  /// 单例实例
  static final PortfolioSnapshotService instance = PortfolioSnapshotService._internal();
  
  /// 私有构造函数
  PortfolioSnapshotService._internal();
  
  /// 快照数据仓库
  final PortfolioSnapshotRepository _snapshotRepository = PortfolioSnapshotRepository.instance;
  
  /// 防抖动定时器
  /// Key: portfolioId, Value: Timer
  final Map<int, Timer> _debounceTimers = {};
  
  /// 防抖动延迟时间（秒）
  static const int _debounceDelaySeconds = 3;
  
  /// 当前正在执行的投资组合ID集合
  final Set<int> _executingPortfolios = {};
  
  /// 待执行的快照更新参数
  /// Key: portfolioId, Value: 参数配置
  final Map<int, _SnapshotUpdateParams> _pendingUpdates = {};
  
  /// 创建或更新快照（防抖动版本）
  /// 
  /// 此方法使用防抖动机制：
  /// 1. 每次调用都会重置定时器
  /// 2. 只有在用户停止操作指定时间后才会执行快照更新
  /// 3. 确保最后一次操作的参数会被使用
  /// 
  /// [portfolioId] 投资组合ID
  /// [showSuccessMessage] 是否显示成功提示，默认为false
  /// [showErrorMessage] 是否显示错误提示，默认为true
  /// 
  /// 返回值：
  /// - true: 防抖动定时器已设置
  /// - false: 当前正在执行快照更新，无法设置定时器
  Future<bool> createOrUpdateSnapshot(
    int portfolioId, {
    bool showSuccessMessage = false,
    bool showErrorMessage = true,
  }) async {
    try {
      // 如果正在执行，则不允许设置新的定时器
      if (_executingPortfolios.contains(portfolioId)) {
        LogService.instance.d('投资组合 $portfolioId 正在执行快照更新，跳过本次请求');
        return false;
      }
      
      // 取消之前的定时器（如果存在）
      _cancelDebounceTimer(portfolioId);
      
      // 更新待执行的参数（使用最新的参数）
      _pendingUpdates[portfolioId] = _SnapshotUpdateParams(
        showSuccessMessage: showSuccessMessage,
        showErrorMessage: showErrorMessage,
      );
      
      LogService.instance.d('设置快照更新防抖动定时器: 投资组合ID=$portfolioId, 延迟=$_debounceDelaySeconds秒');
      
      // 设置新的防抖动定时器
      _debounceTimers[portfolioId] = Timer(
        const Duration(seconds: _debounceDelaySeconds),
        () => _executeSnapshotUpdate(portfolioId),
      );
      
      return true;
    } catch (e) {
      LogService.instance.e('设置快照更新定时器失败: $e');
      return false;
    }
  }
  
  /// 取消防抖动定时器
  void _cancelDebounceTimer(int portfolioId) {
    final timer = _debounceTimers[portfolioId];
    if (timer != null && timer.isActive) {
      timer.cancel();
      LogService.instance.d('取消投资组合 $portfolioId 的防抖动定时器');
    }
    _debounceTimers.remove(portfolioId);
  }
  
  /// 执行快照更新的具体逻辑
  Future<void> _executeSnapshotUpdate(int portfolioId) async {
    try {
      // 标记为正在执行
      _executingPortfolios.add(portfolioId);
      
      // 获取待执行的参数
      final params = _pendingUpdates[portfolioId] ?? const _SnapshotUpdateParams(
        showSuccessMessage: false,
        showErrorMessage: true,
      );
      
      LogService.instance.d('开始执行快照更新: 投资组合ID=$portfolioId');
      
      // 检查今日是否已有快照
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todaySnapshot = await _snapshotRepository.getSnapshotByDate(portfolioId, todayStart);
      
      if (todaySnapshot != null) {
        // 今日已有快照，删除后重新创建（相当于更新）
        LogService.instance.d('今日已有快照(ID=${todaySnapshot.id})，删除后重新创建');
        
        final deleteResult = await _snapshotRepository.deleteSnapshot(todaySnapshot.id);
        if (!deleteResult) {
          LogService.instance.e('删除今日现有快照失败');
          if (params.showErrorMessage) {
            SnackbarUtils.error('错误', '无法删除今日现有快照');
          }
          return;
        }
      }
      
      // 创建新的每日快照
      final snapshot = await _snapshotRepository.createDailySnapshot(portfolioId);
      
      LogService.instance.d('成功创建/更新快照: ID=${snapshot.id}, 日期=${snapshot.snapshotDate}');
      
      if (params.showSuccessMessage) {
        SnackbarUtils.success('操作成功', '投资组合快照已更新');
      }
      
    } catch (e) {
      LogService.instance.e('执行快照更新失败: $e');
      
      final params = _pendingUpdates[portfolioId];
      if (params?.showErrorMessage == true) {
        SnackbarUtils.error('错误', '更新投资组合快照时发生错误');
      }
    } finally {
      // 清理状态
      _executingPortfolios.remove(portfolioId);
      _pendingUpdates.remove(portfolioId);
      _debounceTimers.remove(portfolioId);
    }
  }
  
  /// 立即执行快照更新（取消防抖动）
  /// 
  /// 用于需要立即执行快照更新的场景，会取消当前的防抖动定时器并立即执行
  /// 
  /// [portfolioId] 投资组合ID
  /// [showSuccessMessage] 是否显示成功提示，默认为true
  /// [showErrorMessage] 是否显示错误提示，默认为true
  Future<bool> executeImmediately(
    int portfolioId, {
    bool showSuccessMessage = true,
    bool showErrorMessage = true,
  }) async {
    try {
      // 如果正在执行，则等待完成
      if (_executingPortfolios.contains(portfolioId)) {
        LogService.instance.d('投资组合 $portfolioId 正在执行快照更新，等待完成');
        return false;
      }
      
      // 取消防抖动定时器
      _cancelDebounceTimer(portfolioId);
      
      // 设置参数并立即执行
      _pendingUpdates[portfolioId] = _SnapshotUpdateParams(
        showSuccessMessage: showSuccessMessage,
        showErrorMessage: showErrorMessage,
      );
      
      LogService.instance.d('立即执行快照更新: 投资组合ID=$portfolioId');
      
      // 立即执行
      await _executeSnapshotUpdate(portfolioId);
      
      return true;
    } catch (e) {
      LogService.instance.e('立即执行快照更新失败: $e');
      return false;
    }
  }
  
  /// 强制创建快照（忽略所有机制）
  /// 
  /// 用于特殊情况下需要立即创建快照的场景，完全独立于防抖动机制
  /// 
  /// [portfolioId] 投资组合ID
  /// [showSuccessMessage] 是否显示成功提示，默认为true
  /// [showErrorMessage] 是否显示错误提示，默认为true
  Future<PortfolioSnapshot?> forceCreateSnapshot(
    int portfolioId, {
    bool showSuccessMessage = true,
    bool showErrorMessage = true,
  }) async {
    try {
      LogService.instance.d('强制创建快照: 投资组合ID=$portfolioId');
      
      // 检查今日是否已有快照
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todaySnapshot = await _snapshotRepository.getSnapshotByDate(portfolioId, todayStart);
      
      // 如果今天已经有快照，先删除它
      if (todaySnapshot != null) {
        LogService.instance.d('今日已有快照(ID=${todaySnapshot.id})，删除后创建新快照');
        final deleteResult = await _snapshotRepository.deleteSnapshot(todaySnapshot.id);
        if (!deleteResult) {
          LogService.instance.e('删除今日现有快照失败');
          if (showErrorMessage) {
            SnackbarUtils.error('错误', '无法删除今日现有快照');
          }
          return null;
        }
      }
      
      // 创建每日快照
      final snapshot = await _snapshotRepository.createDailySnapshot(portfolioId);
      
      LogService.instance.d('成功强制创建快照: ID=${snapshot.id}, 日期=${snapshot.snapshotDate}');
      
      if (showSuccessMessage) {
        SnackbarUtils.success('操作成功', '已创建新的投资组合快照');
      }
      
      return snapshot;
    } catch (e) {
      LogService.instance.e('强制创建快照失败: $e');
      
      if (showErrorMessage) {
        SnackbarUtils.error('错误', '创建快照时发生错误');
      }
      
      return null;
    }
  }
  
  /// 取消指定投资组合的快照更新
  /// 
  /// 用于取消已设置但尚未执行的快照更新
  void cancelSnapshotUpdate(int portfolioId) {
    _cancelDebounceTimer(portfolioId);
    _pendingUpdates.remove(portfolioId);
    LogService.instance.d('已取消投资组合 $portfolioId 的快照更新');
  }
  
  /// 取消所有待执行的快照更新
  void cancelAllSnapshotUpdates() {
    final portfolioIds = _debounceTimers.keys.toList();
    for (final portfolioId in portfolioIds) {
      _cancelDebounceTimer(portfolioId);
    }
    _pendingUpdates.clear();
    LogService.instance.d('已取消所有待执行的快照更新');
  }
  
  /// 检查指定投资组合是否有待执行的快照更新
  bool hasPendingUpdate(int portfolioId) {
    return _debounceTimers.containsKey(portfolioId) && 
           _debounceTimers[portfolioId]!.isActive;
  }
  
  /// 检查指定投资组合是否正在执行快照更新
  bool isExecuting(int portfolioId) {
    return _executingPortfolios.contains(portfolioId);
  }
  
  /// 获取所有待执行更新的投资组合ID
  List<int> getPendingUpdatePortfolios() {
    return _debounceTimers.keys
        .where((id) => _debounceTimers[id]!.isActive)
        .toList();
  }
  
  /// 获取所有正在执行的投资组合ID
  List<int> getExecutingPortfolios() {
    return _executingPortfolios.toList();
  }
  
  /// 清理服务状态
  /// 
  /// 用于应用关闭时清理所有定时器和状态
  void dispose() {
    LogService.instance.d('清理快照服务状态');
    
    // 取消所有定时器
    for (final timer in _debounceTimers.values) {
      if (timer.isActive) {
        timer.cancel();
      }
    }
    
    // 清理所有状态
    _debounceTimers.clear();
    _pendingUpdates.clear();
    _executingPortfolios.clear();
    
    LogService.instance.d('快照服务状态清理完成');
  }
} 