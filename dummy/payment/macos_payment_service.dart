import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/services/payment/payment_service.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/services/premium/premium_service.dart';

/// macOS 支付服务实现
/// 使用与 iOS 相同的 App Store 支付系统
class MacOSPaymentService extends PaymentService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  
  // 产品ID配置 - 需要在 App Store Connect 中配置
  static const String monthlyProductId = 'com.tradeflex.monthly_subscription';
  static const String yearlyProductId = 'com.tradeflex.yearly_subscription';
  static const String lifetimeProductId = 'com.tradeflex.lifetime_purchase';
  
  static const Set<String> _productIds = {
    monthlyProductId,
    yearlyProductId,
    lifetimeProductId,
  };

  @override
  bool get isSupported => true;

  @override
  Future<bool> initialize() async {
    try {
      // 检查是否支持应用内购买
      final available = await _inAppPurchase.isAvailable();
      if (!available) {
        LogService.instance.e('macOS 应用内购买不可用');
        return false;
      }

      // 设置 StoreKit 代理
      if (defaultTargetPlatform == TargetPlatform.macOS) {
        final InAppPurchaseStoreKitPlatformAddition macOSPlatformAddition =
            _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await macOSPlatformAddition.setDelegate(TradeFlexPaymentQueueDelegate());
      }

      // 监听购买更新
      _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onError: (error) {
          LogService.instance.e('购买流监听错误: $error');
        },
      );

      LogService.instance.i('macOS 支付服务初始化成功');
      return true;
    } catch (e) {
      LogService.instance.e('macOS 支付服务初始化失败: $e');
      return false;
    }
  }

  @override
  Future<List<PaymentProduct>> getProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds);
      
      if (response.error != null) {
        LogService.instance.e('获取产品信息失败: ${response.error}');
        return [];
      }

      return response.productDetails.map((product) {
        return PaymentProduct(
          id: product.id,
          title: product.title,
          description: product.description,
          price: product.price,
          currencyCode: product.currencyCode,
          rawPrice: product.rawPrice,
        );
      }).toList();
    } catch (e) {
      LogService.instance.e('获取产品信息异常: $e');
      return [];
    }
  }

  @override
  Future<PaymentResult> purchaseProduct(String productId) async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails({productId});
      
      if (response.error != null || response.productDetails.isEmpty) {
        return PaymentResult.failure('产品不存在: $productId');
      }

      final productDetails = response.productDetails.first;
      
      // 创建购买参数
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: null, // 可以设置用户标识
      );

      // 执行购买
      late bool success;
      
      if (productId == lifetimeProductId) {
        // 一次性购买
        success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        // 订阅购买
        success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }
      
      if (success) {
        LogService.instance.i('购买请求发送成功: $productId');
        return PaymentResult.success('购买请求已发送');
      } else {
        return PaymentResult.failure('购买请求失败');
      }
    } catch (e) {
      LogService.instance.e('购买产品异常: $e');
      return PaymentResult.failure('购买异常: $e');
    }
  }

  @override
  Future<PaymentResult> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      LogService.instance.i('恢复购买请求发送成功');
      return PaymentResult.success('恢复购买请求已发送');
    } catch (e) {
      LogService.instance.e('恢复购买异常: $e');
      return PaymentResult.failure('恢复购买失败: $e');
    }
  }

  @override
  Future<bool> verifyReceipt(String receiptData) async {
    try {
      // macOS 收据验证需要发送到 Apple 服务器或你的后端服务
      // 这里应该调用你的后端服务验证收据
      LogService.instance.i('验证 macOS 收据: $receiptData');
      return true;
    } catch (e) {
      LogService.instance.e('验证收据异常: $e');
      return false;
    }
  }

  /// 处理购买更新
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  /// 处理单个购买
  void _handlePurchase(PurchaseDetails purchaseDetails) async {
    LogService.instance.i('处理购买: ${purchaseDetails.productID}, 状态: ${purchaseDetails.status}');
    
    if (purchaseDetails.status == PurchaseStatus.purchased) {
      await _processPurchase(purchaseDetails);
    } else if (purchaseDetails.status == PurchaseStatus.error) {
      LogService.instance.e('购买失败: ${purchaseDetails.error}');
      Get.snackbar('购买失败', '支付过程中出现问题: ${purchaseDetails.error?.message}');
    } else if (purchaseDetails.status == PurchaseStatus.restored) {
      await _processRestore(purchaseDetails);
    }

    // 完成购买流程
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  /// 处理购买成功
  Future<void> _processPurchase(PurchaseDetails purchaseDetails) async {
    try {
      final isValid = await verifyReceipt(purchaseDetails.verificationData.serverVerificationData);
      
      if (isValid) {
        await _activateMembership(purchaseDetails.productID);
        LogService.instance.i('购买处理成功: ${purchaseDetails.productID}');
        Get.snackbar('购买成功', '会员权限已激活！');
      } else {
        LogService.instance.e('收据验证失败: ${purchaseDetails.productID}');
        Get.snackbar('购买失败', '收据验证失败，请联系客服');
      }
    } catch (e) {
      LogService.instance.e('处理购买异常: $e');
      Get.snackbar('购买失败', '处理购买时出现异常');
    }
  }

  /// 处理恢复购买
  Future<void> _processRestore(PurchaseDetails purchaseDetails) async {
    try {
      final isValid = await verifyReceipt(purchaseDetails.verificationData.serverVerificationData);
      
      if (isValid) {
        await _activateMembership(purchaseDetails.productID);
        LogService.instance.i('恢复购买成功: ${purchaseDetails.productID}');
        Get.snackbar('恢复成功', '会员权限已恢复！');
      } else {
        LogService.instance.e('恢复购买收据验证失败: ${purchaseDetails.productID}');
        Get.snackbar('恢复失败', '收据验证失败，请联系客服');
      }
    } catch (e) {
      LogService.instance.e('处理恢复购买异常: $e');
      Get.snackbar('恢复失败', '处理恢复购买时出现异常');
    }
  }

  /// 激活会员权限
  Future<void> _activateMembership(String productId) async {
    try {
      final premiumService = Get.find<PremiumService>();
      
      switch (productId) {
        case monthlyProductId:
          await premiumService.simulateMonthlyActivation();
          break;
        case yearlyProductId:
          await premiumService.simulateYearlyActivation();
          break;
        case lifetimeProductId:
          await premiumService.simulateLifetimeActivation();
          break;
      }
      
      LogService.instance.i('会员权限激活成功: $productId');
    } catch (e) {
      LogService.instance.e('激活会员权限失败: $e');
    }
  }
}

/// 自定义支付队列代理
class TradeFlexPaymentQueueDelegate extends SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
} 