import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/event/portfolio_event_controller.dart';
import 'package:trade_flex/core/repositories/user_settings_repository.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/constants/portfolio_enums.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/utils/portfolio_utils.dart';
import 'package:trade_flex/core/repositories/portfolio_repository.dart';
import 'package:trade_flex/core/repositories/fee_model_repository.dart';
import 'package:trade_flex/core/utils/snackbar_utils.dart';
import 'package:trade_flex/mobile/onboarding/onboarding_screen.dart';

/// 移动端欢迎引导流程的控制器
/// 
/// 使用GetX管理移动端引导流程的状态和业务逻辑
class MobileOnboardingController extends GetxController {
  // 单例访问方式
  static MobileOnboardingController get to => Get.find<MobileOnboardingController>();
  
  // 页面控制器
  final pageController = PageController();
  
  // 可观察变量
  final RxInt currentPage = 0.obs;
  final RxBool isLoading = false.obs;
  
  // 投资组合相关
  final RxString portfolioName = ''.obs;
  final RxString portfolioDescription = ''.obs;
  final RxString portfolioCurrency = 'CNY'.obs;
  final RxString errorMessage = ''.obs;
  
  // 添加缺失的属性
  final Rx<PortfolioType> portfolioType = PortfolioType.stock.obs;
  final Rx<PortfolioDirection> portfolioDirection = PortfolioDirection.long.obs;
  final Rx<dynamic> portfolioFeeMode = Rx<dynamic>(null);
  
  // 费率相关
  final RxList<dynamic> feeModes = <dynamic>[].obs;
  final RxInt selectedFeeModeId = 0.obs;
  
  // 选中的费率模式
  final Rx<FeeModel?> selectedFeeMode = Rx<FeeModel?>(null);
  
  // 仓库实例
  final _feeModelRepository = FeeModelRepository.instance;
  final _portfolioRepository = PortfolioRepository.instance;
  final _userSettingsRepository = UserSettingsRepository.instance;
  
  // 回调函数
  VoidCallback? onCompleteCallback;
  
  // 移动端页面配置列表
  final List<Map<String, dynamic>> pageConfigs = [
    {
      'pageType': MobileOnboardingPageType.eula.name,
      'title': '用户许可协议',
      'icon': Icons.policy_outlined,
      'color': Colors.grey,
    },
    {
      'pageType': MobileOnboardingPageType.welcome.name,
      'icon': Icons.waving_hand,
      'color': Colors.blue,
      'title': '欢迎使用交易日记',
      'description': '开始记录和分析您的交易。',
    },
    {
      'pageType': 'trackTrades',
      'icon': Icons.timeline,
      'color': Colors.green,
      'title': '跟踪您的交易',
      'description': '轻松记录每一笔交易详情。',
    },
    {
      'pageType': 'analyzePerformance',
      'icon': Icons.analytics,
      'color': Colors.orange,
      'title': '分析交易表现',
      'description': '深入了解您的交易策略。',
    },
    {
      'pageType': MobileOnboardingPageType.portfolioCreation.name,
      'icon': Icons.add_chart,
      'color': Colors.purple,
      'title': '创建投资组合',
      'description': '设置您的第一个投资组合。',
    },
    {
      'pageType': MobileOnboardingPageType.confirmation.name,
      'icon': Icons.check_circle_outline,
      'color': Colors.teal,
      'title': '确认您的投资组合',
      'description': '检查所有设置。',
    },
  ];
  
  // 初始化回调设置方法
  void setOnCompleteCallback(VoidCallback callback) {
    onCompleteCallback = callback;
  }
  
  @override
  void onInit() {
    super.onInit();
    loadFeeModes();
    initPortfolioData();

    // 监听 selectedFeeModeId 的变化，并在变化时加载对应的 FeeModel
    ever(selectedFeeModeId, (_) => _loadSelectedFeeMode());

    // 首次加载，以防 onInit 时 selectedFeeModeId 就有值
    _loadSelectedFeeMode();
  }
  
  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
  
  /// 加载费率模式
  void loadFeeModes() async {
    try {
      // 加载所有可用的费率模式
      final modes = await _feeModelRepository.getAllFeeModels();
      feeModes.value = modes;
    } catch (e) {
      LogService.instance.e('加载费率模式失败', e);
    }
  }
  
  /// 初始化投资组合数据
  void initPortfolioData() {
    portfolioName.value = '';
    portfolioDescription.value = '';
    portfolioCurrency.value = 'CNY';
    portfolioType.value = PortfolioType.stock;
    portfolioDirection.value = PortfolioDirection.long;
    portfolioFeeMode.value = null;
    selectedFeeModeId.value = 0;
    selectedFeeMode.value = null;
  }
  
  /// 根据 selectedFeeModeId 加载对应的费率模式对象
  Future<void> _loadSelectedFeeMode() async {
    final id = selectedFeeModeId.value;
    if (id > 0) {
      try {
        final feeModel = await _feeModelRepository.getFeeModelById(id);
        selectedFeeMode.value = feeModel;
      } catch (e) {
        LogService.instance.e('加载选中费率模式失败 (ID: $id)', e);
        selectedFeeMode.value = null; // 加载失败则设为 null
      }
    } else {
      // 如果 ID 无效或为 0，则表示不记录手续费
      selectedFeeMode.value = null;
    }
  }
  
  /// 设置错误信息
  void setErrorMessage(String message) {
    errorMessage.value = message;
  }
  
  /// 根据页面类型查找对应的页面索引
  /// 
  /// @param type 页面类型枚举
  /// @return 找到的页面索引，未找到返回-1
  int findPageIndexByType(MobileOnboardingPageType type) {
    return pageConfigs.indexWhere((config) => config['pageType'] == type.name);
  }
  
  /// 检查并导航到确认页面
  /// 
  /// 验证必要信息后，检查是否可以跳转到确认页面
  bool validateAndNavigateToConfirmationPage() {
    // 检查投资组合名称是否为空
    if (portfolioName.value.trim().isEmpty) {
      // 设置错误信息
      setErrorMessage('请输入投资组合名称');
      
      // 跳转到创建投资组合页面
      int portfolioPageIndex = findPageIndexByType(MobileOnboardingPageType.portfolioCreation);
      if (portfolioPageIndex != -1) {
        goToPage(portfolioPageIndex);
      }
      
      return false;
    }
    
    return true;
  }
  
  /// 处理页面切换时的验证
  /// 
  /// @param newPage 新的页面索引
  /// @param oldPage 当前页面索引
  /// @return 是否允许切换
  bool handlePageChange(int newPage, int oldPage) {
    bool goingForward = newPage > oldPage;
    
    // 查找确认页和创建页的索引
    final confirmationPageIndex = pageConfigs.indexWhere((config) => config['pageType'] == MobileOnboardingPageType.confirmation.name);
    final portfolioPageIndex = pageConfigs.indexWhere((config) => config['pageType'] == MobileOnboardingPageType.portfolioCreation.name);

    if (confirmationPageIndex != -1 && 
        newPage == confirmationPageIndex && 
        portfolioName.value.trim().isEmpty && 
        goingForward) {
      // 设置错误信息
      setErrorMessage('请输入投资组合名称');
      
      // 返回到创建页面
      if (portfolioPageIndex != -1) {
        goToPage(portfolioPageIndex);
      }
      return false;
    }
    
    return true;
  }
  
  /// 完成引导流程
  /// 
  /// 验证必要的信息，创建投资组合，保存设置，然后调用完成回调
  Future<void> completeOnboarding() async {
    // 检查投资组合名称是否为空
    if (portfolioName.value.trim().isEmpty) {
      // 设置错误信息
      setErrorMessage('请输入投资组合名称');
      
      // 跳转到创建投资组合页面
      int portfolioPageIndex = findPageIndexByType(MobileOnboardingPageType.portfolioCreation);
      if (portfolioPageIndex != -1) {
        goToPage(portfolioPageIndex);
      }
      
      return;
    }
    
    isLoading.value = true;
    
    try {
      // 创建投资组合
      final portfolio = await createPortfolio();
      
      if (portfolio != null) {
        // 设置首选项，标记引导已完成
        await _userSettingsRepository.saveSetting('onboarding_completed', 'true');
        
        // 通知投资组合状态控制器
        Get.find<PortfolioEventController>().setSelectedPortfolio(portfolio.id);

        // 调用完成回调
        if (onCompleteCallback != null) {
          onCompleteCallback!();
        }
      } else {
        // 如果创建失败，显示错误信息并重置加载状态
        isLoading.value = false;
      }
    } catch (e) {
      LogService.instance.e('创建投资组合错误', e);
      isLoading.value = false;
    }
  }
  
  /// 导航到模板设置页面
  void navigateToTemplatePage() {
    // 检查投资组合名称
    if (portfolioName.value.trim().isEmpty) {
      // 投资组合名称为空，跳转到创建页面
      int portfolioPageIndex = findPageIndexByType(MobileOnboardingPageType.portfolioCreation);
      if (portfolioPageIndex != -1) {
        goToPage(portfolioPageIndex);
        SnackbarUtils.warn('提示', '请先设置投资组合名称');
      }
    }
  }
  
  /// 创建投资组合
  Future<Portfolio?> createPortfolio() async {
    try {
      // 检查投资组合名称是否为空
      if (portfolioName.value.trim().isEmpty) {
        setErrorMessage('请输入投资组合名称');
        return null;
      }
      
      // 如果选择了费率模式，加载完整的费率模式数据
      if (selectedFeeModeId.value > 0 && selectedFeeMode.value == null) {
        try {
          final feeMode = await _feeModelRepository.getFeeModelById(selectedFeeModeId.value);
          if (feeMode != null) {
            selectedFeeMode.value = feeMode;
          }
        } catch (e) {
          LogService.instance.e('加载费率模式失败', e);
        }
      }
      
      // 创建新的投资组合对象
      final now = DateTime.now();
      final portfolio = Portfolio(
        id: 0, // 新创建的投资组合ID为0，由数据库自动生成
        portfolioName: portfolioName.value.trim(),
        currency: PortfolioUtils.getCurrencyFromString(portfolioCurrency.value),
        portfolioType: portfolioType.value,
        direction: portfolioDirection.value,
        feeModeId: selectedFeeModeId.value > 0 ? selectedFeeModeId.value : null,
        isClosed: false,
        createTime: now,
        updateTime: now,
      );
      
      // 调用数据库服务创建投资组合
      final createdPortfolio = await _portfolioRepository.insertPortfolio(portfolio);
      
      // 返回创建的投资组合
      return createdPortfolio;
    } catch (e) {
      LogService.instance.e('创建投资组合错误', e);
      return null;
    }
  }
  
  /// 导航到下一页
  void nextPage() {
    if (currentPage.value < pageConfigs.length - 1) {
      // 检查是否可以进入下一页
      if (handlePageChange(currentPage.value + 1, currentPage.value)) {
        pageController.animateToPage(
          currentPage.value + 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }
  
  /// 导航到上一页
  void previousPage() {
    if (currentPage.value > 0) {
      pageController.animateToPage(
        currentPage.value - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  /// 设置当前页
  void setPage(int page) {
    currentPage.value = page;
  }
  
  /// 导航到指定页面索引
  void goToPage(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  /// 设置投资组合名称
  void setPortfolioName(String name) {
    portfolioName.value = name;
    // 清除错误信息
    if (name.trim().isNotEmpty) {
      errorMessage.value = '';
    }
  }
  
  /// 设置币种
  void setCurrency(String currency) {
    portfolioCurrency.value = currency;
  }
  
  /// 设置投资组合类型
  void setPortfolioType(String type) {
    portfolioType.value = PortfolioType.values[PortfolioType.values.indexWhere((e) => e.toString() == 'PortfolioType.$type')];
  }
  
  /// 设置交易方向
  void setDirection(String direction) {
    portfolioDirection.value = PortfolioDirection.values[PortfolioDirection.values.indexWhere((e) => e.toString() == 'PortfolioDirection.$direction')];
  }
  
  /// 设置费率模式
  void setFeeMode(FeeModel? mode) {
    selectedFeeMode.value = mode;
    selectedFeeModeId.value = mode?.id ?? 0;
  }
  
  /// 获取所有的数据
  Map<String, dynamic> getOnboardingData() {
    return {
      'portfolioName': portfolioName.value,
      'portfolioCurrency': portfolioCurrency.value,
      'portfolioType': portfolioType.value.toString().split('.').last,
      'portfolioDirection': portfolioDirection.value.toString().split('.').last,
      'feeModeId': selectedFeeModeId.value,
    };
  }
  
  /// 重置所有数据
  void resetData() {
    portfolioName.value = '';
    portfolioCurrency.value = 'CNY';
    portfolioType.value = PortfolioType.stock;
    portfolioDirection.value = PortfolioDirection.long;
    selectedFeeModeId.value = 0;
    selectedFeeMode.value = null;
    errorMessage.value = '';
  }
  
  /// 获取币种显示名称
  String getCurrencyLabel(String currency) {
    return PortfolioUtils.getCurrencyFullLabel(currency);
  }
  
  /// 获取投资组合类型显示名称
  String getPortfolioTypeLabel(String type) {
    return PortfolioUtils.getPortfolioTypeLabelFromString(type);
  }
  
  /// 获取交易方向显示名称
  String getDirectionLabel(String direction) {
    return PortfolioUtils.getDirectionLabelFromString(direction);
  }
} 