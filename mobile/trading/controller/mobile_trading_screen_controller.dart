import 'package:get/get.dart';
import 'package:trade_flex/core/event/portfolio_event_controller.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/controllers/trading/portfolio_summary_controller.dart';
import 'package:trade_flex/core/controllers/trading/trading_operator_area_controller.dart';
import 'package:trade_flex/core/controllers/trading/porfolio_current_position_controller.dart';
import 'package:trade_flex/core/controllers/trading/note_card_controller.dart';
import 'package:trade_flex/mobile/trading/controller/mobile_trading_records_controller.dart';

/// 移动端交易屏幕主控制器
/// 
/// 负责协调移动端交易屏幕的各个子控制器，管理共享数据以及组织屏幕的整体状态
/// 参考桌面端TradingScreenController的实现模式
class MobileTradingScreenController extends GetxController {
  // 单例实例
  static MobileTradingScreenController get instance => Get.find<MobileTradingScreenController>();
  
  // 子控制器
  late final PortfolioSummaryController portfolioSummaryController;
  late final TradingOperatorAreaController tradingOperatorAreaController;
  late final MobileTradingRecordsController mobileTradingRecordsController;
  late final PorfolioCurrentPositionController currentPositionController;
  late final NoteCardController noteCardController;

  // 投资组合ID监听器处理函数
  Worker? _portfolioIdWorker;

  // 是否有投资组合
  final hasPortfolios = false.obs;
  
  // 当前选中的投资组合ID
  final selectedPortfolioId = 0.obs;

  @override
  void onInit() {
    super.onInit();

    LogService.instance.d('移动端交易屏幕主控制器初始化');
    
    // 初始化所有子控制器
    portfolioSummaryController = Get.find<PortfolioSummaryController>();
    tradingOperatorAreaController = Get.find<TradingOperatorAreaController>();
    mobileTradingRecordsController = Get.find<MobileTradingRecordsController>();
    currentPositionController = Get.find<PorfolioCurrentPositionController>();
    noteCardController = Get.find<NoteCardController>();
    
    final portfolioController = Get.find<PortfolioEventController>();
    hasPortfolios.value = portfolioController.hasPortfolios.value;
    selectedPortfolioId.value = portfolioController.selectedPortfolioId.value;

    // 初始化时立即加载一次数据
    final initialPortfolioId = portfolioController.selectedPortfolioId.value;
    if (initialPortfolioId != 0) { // 确保有合法的初始ID
       loadData(initialPortfolioId);
    }

    // 监听 portfolioId 的变化，并在变化时加载数据
    _portfolioIdWorker = ever(portfolioController.selectedPortfolioId, (int portfolioId) {
       if (portfolioId != 0) { // 确保ID有效
         selectedPortfolioId.value = portfolioId;
         loadData(portfolioId);
       }
    });
    
    // 监听投资组合是否存在的变化
    ever(portfolioController.hasPortfolios, (bool hasPortfolios) {
      this.hasPortfolios.value = hasPortfolios;
    });
  }
  
  @override
  void onClose() {
    // 清理监听器
    _portfolioIdWorker?.dispose();
    super.onClose();
  }
  
  /// 加载所有数据
  Future<void> loadData(int selectedPortfolioId) async {
    LogService.instance.d('MobileTradingScreenController.loadData - 加载投资组合数据: $selectedPortfolioId');
    
    // 通知所有子控制器加载数据
    portfolioSummaryController.loadData(selectedPortfolioId);
    tradingOperatorAreaController.loadData(selectedPortfolioId);
    mobileTradingRecordsController.loadData(selectedPortfolioId);
    currentPositionController.loadData(selectedPortfolioId);
    noteCardController.loadData(selectedPortfolioId);
  }
  
  /// 刷新所有数据
  Future<void> refreshData() async {
    if (selectedPortfolioId.value != 0) {
      await loadData(selectedPortfolioId.value);
    }
  }
} 