import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/mobile/onboarding/controller/mobile_onboarding_controller.dart';
import 'package:trade_flex/mobile/onboarding/content/mobile_portfolio_confirmation_page.dart';
import 'package:trade_flex/mobile/onboarding/content/mobile_portfolio_creation_page.dart';
import 'package:trade_flex/mobile/onboarding/mobile_pager_indicator.dart';
import 'package:trade_flex/mobile/onboarding/content/mobile_welcome_page_content.dart';
import 'package:trade_flex/mobile/onboarding/content/mobile_track_trades_page_content.dart';
import 'package:trade_flex/mobile/onboarding/content/mobile_analyze_performance_page_content.dart';
import 'package:trade_flex/mobile/onboarding/content/mobile_eula_page.dart';

// --- 枚举定义 ---

enum MobileOnboardingPageType {
  eula,
  welcome,
  trackTrades,
  analyzePerformance,
  portfolioCreation,
  confirmation,
  unknown
}

/// 移动端自定义页面滑动物理效果
/// 
/// 针对移动端触摸操作优化的滑动体验
class MobilePageViewScrollPhysics extends ScrollPhysics {
  const MobilePageViewScrollPhysics({super.parent});

  @override
  MobilePageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return MobilePageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 60,
        stiffness: 120,
        damping: 0.8,
      );
}

/// 移动端欢迎引导屏幕组件
/// 
/// 专为移动端设计的引导流程，具有触摸友好的界面
class OnboardingScreen extends StatelessWidget {
  /// 引导完成后的回调函数
  final VoidCallback onComplete;
  
  /// 构造函数
  const OnboardingScreen({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  /// 构建引导页面
  Widget _buildOnboardingPage(BuildContext context, MobileOnboardingController controller, int index) {
    final config = controller.pageConfigs[index];
    final pageTypeString = config['pageType'] as String?;
    final pageType = MobileOnboardingPageType.values.firstWhere(
        (e) => e.toString() == 'MobileOnboardingPageType.${pageTypeString ?? 'unknown'}',
        orElse: () => MobileOnboardingPageType.unknown);

    switch (pageType) {
      case MobileOnboardingPageType.eula:
        return MobileEulaPageContent(
          onAgreed: controller.nextPage,
        );
      case MobileOnboardingPageType.welcome:
        return _buildStandardPage(context, controller, config, content: const MobileWelcomePageContent());
      case MobileOnboardingPageType.trackTrades:
         return _buildStandardPage(context, controller, config, content: const MobileTrackTradesPageContent());
      case MobileOnboardingPageType.analyzePerformance:
         return _buildStandardPage(context, controller, config, content: const MobileAnalyzePerformancePageContent());
      case MobileOnboardingPageType.portfolioCreation:
        return MobilePortfolioCreationPage(
          onNext: controller.nextPage,
          onPrevious: controller.previousPage,
        );
      case MobileOnboardingPageType.confirmation:
        return Obx(() => MobilePortfolioConfirmationPage(
              onComplete: controller.completeOnboarding,
              onPrevious: controller.previousPage,
              isLoading: controller.isLoading.value,
              onNavigateToTemplate: controller.navigateToTemplatePage,
            ));
      case MobileOnboardingPageType.unknown:
        LogService.instance.w('警告: Mobile Onboarding page $index 没有找到匹配的 pageType 或配置不完整，将显示默认内容。 Config: $config');
        return _buildStandardPage(context, controller, config, content: const Center(child: Text('未知页面类型或配置错误')));
    }
  }

  /// 构建移动端标准页面布局
  Widget _buildStandardPage(BuildContext context, MobileOnboardingController controller, Map<String, dynamic> config, {required Widget content}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    return Column(
      children: [
        // 内容区域 (包含标题和正文)
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 24, 
                vertical: isSmallScreen ? 16 : 24
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: isSmallScreen ? 20 : 40),
                  Icon(
                    config['icon'] ?? Icons.help_outline,
                    size: isSmallScreen ? 48 : 64,
                    color: config['color'] ?? Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 24),
                  Text(
                    config['title'] ?? '无标题',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  Text(
                    config['description'] ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 24 : 32),
                  content,
                  SizedBox(height: isSmallScreen ? 24 : 40),
                ],
              ),
            ),
          ),
        ),
        
        // 移动端底部导航栏
        Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => TextButton.icon(
                onPressed: controller.currentPage.value > 0 ? controller.previousPage : null,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  minimumSize: const Size(80, 44),
                  foregroundColor: controller.currentPage.value > 0 ? Theme.of(context).primaryColor : Colors.grey,
                ),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                ),
                label: const Text('上一步'),
              )),
              Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: config['color'] ?? Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  minimumSize: const Size(120, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('下一步'),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 在 build 方法中获取 Controller
    final MobileOnboardingController controller = Get.find<MobileOnboardingController>();
    // 设置完成回调
    controller.setOnCompleteCallback(onComplete);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // 页面内容
            PageView.builder(
              controller: controller.pageController,
              itemCount: controller.pageConfigs.length,
              physics: const MobilePageViewScrollPhysics(),
              onPageChanged: (page) {
                controller.setPage(page);
              },
              itemBuilder: (context, index) {
                return _buildOnboardingPage(context, controller, index);
              },
            ),
            
            // 移动端底部指示器
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Obx(() => controller.isLoading.value
                ? const SizedBox.shrink()
                : MobilePagerIndicator(
                    currentPage: controller.currentPage.value,
                    pageCount: controller.pageConfigs.length,
                    onPageSelected: (index) {
                      controller.goToPage(index);
                    },
                    activeColor: (controller.currentPage.value < controller.pageConfigs.length ? 
                                  controller.pageConfigs[controller.currentPage.value]['color'] : null) 
                                  ?? Theme.of(context).primaryColor, 
                    inactiveColor: Colors.grey.shade300,
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 