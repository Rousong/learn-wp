import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/services/payment/android_payment_service.dart';
import 'package:trade_flex/core/services/payment/ios_payment_service.dart';
import 'package:trade_flex/core/services/payment/macos_payment_service.dart';
import 'package:trade_flex/core/services/payment/windows_store_service.dart';
import 'package:trade_flex/core/services/payment/mock_payment_service.dart';

/// 支付结果
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? error;
  final Map<String, dynamic>? metadata;

  PaymentResult({
    required this.success,
    this.transactionId,
    this.error,
    this.metadata,
  });

  factory PaymentResult.success(String transactionId, {Map<String, dynamic>? metadata}) {
    return PaymentResult(
      success: true,
      transactionId: transactionId,
      metadata: metadata,
    );
  }

  factory PaymentResult.failure(String error) {
    return PaymentResult(
      success: false,
      error: error,
    );
  }
}

/// 产品信息
class PaymentProduct {
  final String id;
  final String title;
  final String description;
  final String price;
  final String currencyCode;
  final double rawPrice;

  PaymentProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currencyCode,
    required this.rawPrice,
  });
}

/// 统一支付服务接口
abstract class PaymentService extends GetxService {
  /// 初始化支付服务
  Future<bool> initialize();

  /// 获取可用产品列表
  Future<List<PaymentProduct>> getProducts();

  /// 购买产品
  Future<PaymentResult> purchaseProduct(String productId);

  /// 恢复购买
  Future<PaymentResult> restorePurchases();

  /// 验证收据
  Future<bool> verifyReceipt(String receiptData);

  /// 是否支持应用内购买
  bool get isSupported;

  /// 获取平台特定的支付服务实例
  static PaymentService getInstance() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Get.put(AndroidPaymentService());
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Get.put(IOSPaymentService());
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      return Get.put(MacOSPaymentService());
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      // 优先使用 Microsoft Store 官方支付服务
      return Get.put(WindowsStoreService());
    } else {
      return Get.put(MockPaymentService()); // 用于其他平台或测试
    }
  }
}

 