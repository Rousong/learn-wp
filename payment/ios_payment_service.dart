import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/services/payment/payment_service.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/services/premium/premium_service.dart';
import 'package:trade_flex/core/services/api/payment_verification_service.dart';

/// iOS 支付服务实现
class IOSPaymentService extends PaymentService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  
  // 产品ID配置 - 需要在 App Store Connect 中配置
  static const String monthlyProductId = 'app.tradeflex.monthly_subscription';
  static const String yearlyProductId = 'app.tradeflex.yearly_subscription';
  static const String lifetimeProductId = 'app.tradeflex.lifetime_purchase';
  
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
        LogService.instance.e('iOS 应用内购买不可用');
        return false;
      }

      // 设置 StoreKit 代理
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
            _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
                 await iosPlatformAddition.setDelegate(TradeFlexPaymentQueueDelegate());
      }

      // 监听购买更新
      _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onError: (error) {
          LogService.instance.e('购买流监听错误: $error');
        },
      );

      LogService.instance.i('iOS 支付服务初始化成功');
      return true;
    } catch (e) {
      LogService.instance.e('iOS 支付服务初始化失败: $e');
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
      // 调用后端服务验证iOS收据
      final verificationService = PaymentVerificationService.instance;
      final result = await verificationService.verifyReceipt(
        platform: 'ios',
        receiptData: receiptData,
        userId: _getCurrentUserId(), // 可选的用户ID
      );
      
      LogService.instance.i('iOS收据验证结果: ${result.isValid}');
      
      if (result.isValid && result.isActive) {
        // 验证成功且订阅有效，更新本地用户状态
        await _updateLocalUserStatus(result);
        return true;
      } else {
        LogService.instance.w('iOS收据验证失败: ${result.errorMessage}');
        return false;
      }
    } catch (e) {
      LogService.instance.e('iOS收据验证异常: $e');
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
          await premiumService.activateMonthlySubscription();
          break;
        case yearlyProductId:
          await premiumService.activateYearlySubscription();
          break;
        case lifetimeProductId:
          await premiumService.activateLifetimeSubscription();
          break;
        default:
          LogService.instance.w('未知的产品ID: $productId');
      }
    } catch (e) {
      LogService.instance.e('激活会员权限异常: $e');
    }
  }

  /// 获取当前用户ID
  /// 这里可以根据实际需求返回用户的唯一标识
  String? _getCurrentUserId() {
    // TODO: 实现获取用户ID的逻辑
    // 例如从用户服务、设备ID或其他来源获取
    return null; // 暂时返回null，表示匿名用户
  }

  /// 更新本地用户状态
  /// 根据后端验证结果更新本地的用户订阅状态
  Future<void> _updateLocalUserStatus(PaymentVerificationResult result) async {
    try {
      final premiumService = PremiumService.instance;
      
      if (result.isValid && result.isActive) {
        // 根据产品类型激活相应的订阅
        switch (result.productType) {
          case 'monthly':
            await premiumService.activateMonthlySubscription();
            break;
          case 'yearly':
            await premiumService.activateYearlySubscription();
            break;
          case 'lifetime':
            await premiumService.activateLifetimeSubscription();
            break;
          default:
            LogService.instance.w('未知的产品类型: ${result.productType}');
        }
        
        LogService.instance.i('本地用户状态更新成功: ${result.productType}');
      } else {
        // 如果验证失败或订阅无效，可能需要降级用户状态
        LogService.instance.w('验证失败，考虑降级用户状态');
      }
    } catch (e) {
      LogService.instance.e('更新本地用户状态异常: $e');
    }
  }
}

/// iOS 支付队列代理
class TradeFlexPaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
} 