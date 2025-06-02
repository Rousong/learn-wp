import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/routes/mobile_pages.dart';
import 'package:trade_flex/core/routes/mobile_routes.dart';
import 'package:trade_flex/core/repositories/user_settings_repository.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/repositories/portfolio_repository.dart';
import 'package:trade_flex/core/themes/app_theme.dart';
import 'package:trade_flex/mobile/onboarding/onboarding_screen.dart';
import 'package:trade_flex/core/translations/app_translations.dart';
import 'package:trade_flex/core/bindings/globle_controllers_binding.dart';

/// 移动端应用程序入口
class MobileApp extends StatelessWidget {
  const MobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      // 同时加载投资组合、主题模式设置和引导完成状态
      future: Future.wait([
        UserSettingsRepository.instance.loadSetting('selected_portfolio_id'),
        UserSettingsRepository.instance.loadSetting('dark_mode'),
        UserSettingsRepository.instance.loadSetting('onboarding_completed'),
        UserSettingsRepository.instance.loadSetting('primary_color'), // 加载主题颜色
        UserSettingsRepository.instance.loadSetting('language'), // 加载语言设置
      ]).then((results) async {
        // 解析投资组合ID
        String? portfolioIdStr = results[0];
        int? portfolioId;
        
        if (portfolioIdStr != null && portfolioIdStr.isNotEmpty) {
          try {
            portfolioId = int.parse(portfolioIdStr);
            
            // 验证投资组合是否存在
            final portfolio = await PortfolioRepository.instance.getPortfolioById(portfolioId);
            if (portfolio == null) {
              // 如果保存的投资组合ID不存在，重置为null
              portfolioId = null;
            }
          } catch (e) {
            LogService.instance.e('无法解析投资组合ID: $e');
            portfolioId = null;
          }
        }
        
        // 解析并应用主题颜色
        String? primaryColorStr = results[3];
        if (primaryColorStr != null && primaryColorStr.isNotEmpty) {
          try {
            // 解析颜色
            Color? primaryColor;
            if (primaryColorStr.startsWith('0x')) {
              primaryColor = Color(int.parse(primaryColorStr));
            } else {
              primaryColor = Color(int.parse('0x$primaryColorStr'));
            }
            
            // 应用到全局主题
            AppThemes.setPrimaryColor(primaryColor);
          } catch (e) {
            LogService.instance.e('无法解析主题颜色: $e');
          }
        }
        
        // 解析并应用语言设置
        String? languageStr = results[4];
        Locale? userLocale;
        
        if (languageStr != null && languageStr.isNotEmpty) {
          // 语言代码映射
          final Map<String, Locale> languageLocales = {
            '简体中文': const Locale('zh', 'CN'),
            '繁体中文': const Locale('zh', 'TW'),
            'English': const Locale('en', 'US'),
            'Español': const Locale('es', 'ES'),
            'Français': const Locale('fr', 'FR'),
            'Deutsch': const Locale('de', 'DE'),
            '日本語': const Locale('ja', 'JP'),
            '한국어': const Locale('ko', 'KR'),
            'Русский': const Locale('ru', 'RU'),
            'हिन्दी': const Locale('hi', 'IN'),
            'Tiếng Việt': const Locale('vi', 'VN'),
            'ไทย': const Locale('th', 'TH'),
          };
          
          userLocale = languageLocales[languageStr];
          if (userLocale != null) {
            LogService.instance.i('应用已保存的语言设置: $languageStr (${userLocale.languageCode}_${userLocale.countryCode})');
          }
        }
        
        return {
          'portfolioId': portfolioId,
          'darkMode': results[1],
          'onboardingCompleted': results[2],
          'userLocale': userLocale,
        };
      }),
      builder: (context, snapshot) {
        // 如果正在加载，显示加载指示器
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            theme: AppThemes.loadingLight,
            darkTheme: AppThemes.loadingDark,
            home: const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        
        // 获取保存的设置
        final data = snapshot.data!;
        final selectedPortfolioId = data['portfolioId'];
        final isDarkMode = data['darkMode'] == 'true';
        final isOnboardingCompleted = data['onboardingCompleted'] == 'true';
        final Locale? userLocale = data['userLocale'];
        
        // 如果未完成引导，显示引导界面
        if (!isOnboardingCompleted) {
          // 注册移动端引导控制器
          // Get.put(MobileOnboardingController()); // 根据你的绑定逻辑决定是否需要

          
          return GetMaterialApp(
            title: 'Trade Flex',
            debugShowCheckedModeBanner: false,
            theme: AppThemes.light,
            darkTheme: AppThemes.dark,
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            getPages: MobilePages.pages, // <--- 确保 getPages 已设置
            initialBinding: GlobalControllersBinding(), // 添加全局控制器绑定
            home: OnboardingScreen(
              onComplete: () {
                LogService.instance.d('引导完成，准备导航到主页');
                // 完成引导后，导航到主应用界面
                // 使用 MobileRoutes.trading 作为主页路由
                Get.offAllNamed(MobileRoutes.trading); // <--- 使用正确的路由常量
                LogService.instance.d('已调用 Get.offAllNamed 至 MobileRoutes.trading');
              },
            ),
          );
        }
        
        // 返回GetMaterialApp并注册控制器
        return GetMaterialApp(
          title: 'Trade Flex',
          debugShowCheckedModeBanner: false,
          theme: AppThemes.light,
          darkTheme: AppThemes.dark,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialBinding: GlobalControllersBinding(), // 添加全局控制器绑定
          translations: AppTranslations(), // 翻译
          locale: userLocale ?? Get.deviceLocale, // 使用保存的语言设置或设备语言
          fallbackLocale: const Locale('en', 'US'), // 默认语言
          initialRoute: selectedPortfolioId == null ? MobileRoutes.emptyState : MobileRoutes.trading, // 根据是否有投资组合ID决定初始路由
          getPages: MobilePages.pages, // 全局路由
          defaultTransition: Transition.fadeIn, // 默认转场效果
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh', 'CN'), // 支持中文
            Locale('en', 'US'), // 支持英文
            Locale('zh', 'TW'), // 支持繁体中文
            Locale('es', 'ES'), // 支持西班牙语
            Locale('fr', 'FR'), // 支持法语
            Locale('de', 'DE'), // 支持德语
            Locale('ja', 'JP'), // 支持日语
            Locale('ko', 'KR'), // 支持韩语
            Locale('ru', 'RU'), // 支持俄语
            Locale('hi', 'IN'), // 支持印地语
          ],
        );
      },
    );
  }
}

/// 移动端Demo界面
class MobileDemoScreen extends StatelessWidget {
  const MobileDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 直接使用新的移动主屏幕
    return const Scaffold(
      body: Center(
        child: Text('移动端Demo界面'),
      ),
    );
  }
} 