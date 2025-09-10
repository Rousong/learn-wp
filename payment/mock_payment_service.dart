import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/services/payment/payment_service.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/services/premium/premium_service.dart';

/// 模拟支付服务
/// 用于开发测试和不支持的平台
class MockPaymentService extends PaymentService {
  
  @override
  bool get isSupported => true;

  @override
  Future<bool> initialize() async {
    LogService.instance.i('模拟支付服务初始化成功');
    return true;
  }

  @override
  Future<List<PaymentProduct>> getProducts() async {
    return [
      PaymentProduct(
        id: 'mock_monthly',
        title: '月费版（测试）',
        description: '包含所有高级功能',
        price: '¥9.00',
        currencyCode: 'CNY',
        rawPrice: 9.0,
      ),
      PaymentProduct(
        id: 'mock_yearly',
        title: '年费版（测试）',
        description: '包含所有高级功能，年付更优惠',
        price: '¥98.00',
        currencyCode: 'CNY',
        rawPrice: 98.0,
      ),
      PaymentProduct(
        id: 'mock_lifetime',
        title: '终身版（测试）',
        description: '一次付费，终身使用',
        price: '¥198.00',
        currencyCode: 'CNY',
        rawPrice: 198.0,
      ),
    ];
  }

  @override
  Future<PaymentResult> purchaseProduct(String productId) async {
    try {
      // 获取产品信息
      final products = await getProducts();
      final product = products.firstWhere((p) => p.id == productId);
      
      // 显示模拟支付对话框
      bool? confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('模拟支付'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('这是一个模拟支付，仅用于测试'),
              const SizedBox(height: 16),
              Text('产品: ${product.title}'),
              Text('价格: ${product.price}'),
              Text('描述: ${product.description}'),
              const SizedBox(height: 16),
              const Text('点击确认将模拟支付成功'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: const Text('确认支付'),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        // 显示支付处理对话框
        Get.dialog(
          const AlertDialog(
            title: Text('处理支付'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在处理模拟支付...'),
              ],
            ),
          ),
          barrierDismissible: false,
        );
        
        // 模拟支付延迟
        await Future.delayed(const Duration(seconds: 2));
        
        Get.back(); // 关闭处理对话框
        
        // 激活会员权限
        await _activateMembership(productId);
        
        // 模拟支付成功
        LogService.instance.i('模拟购买成功: $productId');
        Get.snackbar('支付成功', '模拟支付完成，会员权限已激活！');
        return PaymentResult.success('mock_transaction_${DateTime.now().millisecondsSinceEpoch}');
      } else {
        return PaymentResult.failure('支付被取消');
      }
    } catch (e) {
      LogService.instance.e('模拟支付异常: $e');
      return PaymentResult.failure('模拟支付异常: $e');
    }
  }

  @override
  Future<PaymentResult> restorePurchases() async {
    try {
      // 显示恢复购买确认对话框
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('恢复购买'),
          content: const Text('是否要恢复之前的购买记录？'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: const Text('确认'),
            ),
          ],
        ),
      );
      
      // 用户取消了操作
      if (result != true) {
        LogService.instance.i('用户取消恢复购买');
        return PaymentResult.failure('用户取消操作');
      }
      
      // 显示处理进度对话框
      Get.dialog(
        const AlertDialog(
          title: Text('恢复购买'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在恢复购买记录...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );
      
      // 模拟恢复购买延迟
      await Future.delayed(const Duration(seconds: 2));
      
      // 关闭进度对话框
      Get.back();
      
      LogService.instance.i('模拟恢复购买成功');
      Get.snackbar(
        '恢复成功', 
        '购买记录已恢复',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return PaymentResult.success('mock_restore_transaction_id');
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      LogService.instance.e('模拟恢复购买异常: $e');
      Get.snackbar(
        '恢复失败',
        '恢复购买过程中出现异常',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return PaymentResult.failure('模拟恢复购买异常: $e');
    }
  }

  @override
  Future<bool> verifyReceipt(String receiptData) async {
    LogService.instance.i('模拟收据验证: $receiptData');
    return true;
  }

  /// 激活会员权限
  Future<void> _activateMembership(String productId) async {
    try {
      final premiumService = Get.find<PremiumService>();
      
      switch (productId) {
        case 'mock_monthly':
          await premiumService.activateMonthlySubscription();
          break;
        case 'mock_yearly':
          await premiumService.activateYearlySubscription();
          break;
        case 'mock_lifetime':
          await premiumService.activateLifetimeSubscription();
          break;
        default:
          LogService.instance.w('未知的产品ID: $productId');
      }
    } catch (e) {
      LogService.instance.e('激活会员权限异常: $e');
    }
  }
} 