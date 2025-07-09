import 'package:trade_flex/core/services/snapshot/portfolio_snapshot_service.dart';
import 'package:trade_flex/core/services/log/log_service.dart';

/// 快照服务使用示例（防抖动版本）
/// 
/// 展示如何在不同业务场景中使用 PortfolioSnapshotService 的防抖动机制
class SnapshotUsageExample {
  
  /// 示例1: 在交易完成后更新快照（防抖动）
  /// 
  /// 适用场景：买入、卖出、换股等交易操作完成后
  /// 特点：用户频繁交易时，只有停止操作3秒后才会执行快照更新
  static Future<void> afterTradeCompleted(int portfolioId) async {
    LogService.instance.d('交易完成，设置快照更新防抖动定时器');
    
    // 使用防抖动机制，每次调用都会重置定时器
    final result = await PortfolioSnapshotService.instance.createOrUpdateSnapshot(
      portfolioId,
      showSuccessMessage: false,  // 交易时不显示成功提示
      showErrorMessage: true,     // 但显示错误提示
    );
    
    if (result) {
      LogService.instance.d('防抖动定时器已设置，将在用户停止操作后执行');
    } else {
      LogService.instance.d('当前正在执行快照更新，无法设置新的定时器');
    }
  }
  
  /// 示例2: 在出入金完成后更新快照（防抖动）
  /// 
  /// 适用场景：存款、取款操作完成后
  /// 特点：如果用户连续进行出入金操作，只有停止操作后才会更新快照
  static Future<void> afterDepositWithdrawal(int portfolioId) async {
    LogService.instance.d('出入金完成，设置快照更新防抖动定时器');
    
    // 出入金后可以显示成功提示
    final result = await PortfolioSnapshotService.instance.createOrUpdateSnapshot(
      portfolioId,
      showSuccessMessage: true,   // 显示成功提示
      showErrorMessage: true,     // 显示错误提示
    );
    
    if (!result) {
      LogService.instance.w('当前正在执行快照更新，无法设置新的定时器');
    }
  }
  
  /// 示例3: 用户手动刷新快照
  /// 
  /// 适用场景：用户点击刷新按钮，需要立即更新快照
  static Future<void> manualRefreshSnapshot(int portfolioId) async {
    LogService.instance.d('用户手动刷新快照');
    
    // 使用立即执行，取消防抖动定时器并立即执行
    final result = await PortfolioSnapshotService.instance.executeImmediately(
      portfolioId,
      showSuccessMessage: true,   // 显示成功提示
      showErrorMessage: true,     // 显示错误提示
    );
    
    if (result) {
      LogService.instance.d('手动刷新快照已执行');
    } else {
      LogService.instance.w('无法执行手动刷新，可能正在执行中');
    }
  }
  
  /// 示例4: 批量交易场景（展示防抖动效果）
  /// 
  /// 适用场景：用户快速进行多笔交易
  /// 特点：每笔交易都会重置防抖动定时器，只有最后停止交易3秒后才会执行快照更新
  static Future<void> batchTradeScenario(int portfolioId, List<String> trades) async {
    LogService.instance.d('开始批量交易，共 ${trades.length} 笔');
    
    for (int i = 0; i < trades.length; i++) {
      final trade = trades[i];
      
      // 模拟执行交易
      LogService.instance.d('执行交易 ${i + 1}: $trade');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 每笔交易后都会重置防抖动定时器
      final result = await PortfolioSnapshotService.instance.createOrUpdateSnapshot(
        portfolioId,
        showSuccessMessage: false,  // 批量交易时不显示成功提示
        showErrorMessage: false,    // 也不显示错误提示，避免干扰
      );
      
      LogService.instance.d('交易 ${i + 1} 防抖动定时器: ${result ? "已重置" : "设置失败"}');
    }
    
    LogService.instance.d('批量交易完成，等待防抖动定时器触发快照更新...');
    
    // 注意：这里不需要手动调用，防抖动机制会在3秒后自动执行
    // 如果需要立即执行，可以调用 executeImmediately
  }
  
  /// 示例4.1: 演示防抖动机制的实际效果
  /// 
  /// 模拟用户频繁点击交易按钮的场景
  static Future<void> demonstrateDebounceEffect(int portfolioId) async {
    LogService.instance.d('=== 防抖动机制演示开始 ===');
    
    // 模拟用户快速点击5次交易按钮
    for (int i = 1; i <= 5; i++) {
      LogService.instance.d('用户点击交易按钮第 $i 次');
      
      final result = await PortfolioSnapshotService.instance.createOrUpdateSnapshot(
        portfolioId,
        showSuccessMessage: false,
        showErrorMessage: false,
      );
      
      LogService.instance.d('第 $i 次点击结果: ${result ? "定时器已重置" : "设置失败"}');
      
      // 模拟快速点击，间隔1秒
      await Future.delayed(const Duration(seconds: 1));
    }
    
    LogService.instance.d('用户停止点击，等待3秒后快照将自动更新...');
    LogService.instance.d('=== 防抖动机制演示结束 ===');
  }
  
  /// 示例5: 检查服务状态
  /// 
  /// 适用场景：在执行操作前检查快照服务状态
  static void checkServiceStatus(int portfolioId) {
    final service = PortfolioSnapshotService.instance;
    
    // 检查是否正在执行
    final isExecuting = service.isExecuting(portfolioId);
    LogService.instance.d('投资组合 $portfolioId 快照更新状态: ${isExecuting ? "执行中" : "空闲"}');
    
    // 检查是否有待执行的更新
    final hasPending = service.hasPendingUpdate(portfolioId);
    LogService.instance.d('投资组合 $portfolioId 待执行状态: ${hasPending ? "有待执行的更新" : "无待执行更新"}');
    
    // 获取所有待执行的投资组合
    final pendingPortfolios = service.getPendingUpdatePortfolios();
    LogService.instance.d('所有待执行更新的投资组合: $pendingPortfolios');
  }
  
  /// 示例6: 取消快照更新
  /// 
  /// 适用场景：需要取消已设置的快照更新
  static void cancelSnapshotUpdates(int portfolioId) {
    LogService.instance.d('取消投资组合 $portfolioId 的快照更新');
    PortfolioSnapshotService.instance.cancelSnapshotUpdate(portfolioId);
  }
  
  /// 示例7: 应用关闭时清理
  /// 
  /// 适用场景：应用关闭时清理所有定时器和状态
  static void appShutdown() {
    LogService.instance.d('应用关闭，清理快照服务');
    PortfolioSnapshotService.instance.dispose();
  }
} 