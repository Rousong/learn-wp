# TradeFlex 跨平台支付集成指南

## 概述

TradeFlex 现已集成完整的跨平台支付解决方案，支持 Android、iOS 和 Windows 平台的应用内购买功能。

## 架构设计

### 统一接口设计
- `PaymentService` - 统一的支付服务抽象接口
- `PaymentResult` - 统一的支付结果模型
- `PaymentProduct` - 统一的产品信息模型

### 平台特定实现
- `AndroidPaymentService` - Android 平台实现（Google Play）
- `IOSPaymentService` - iOS 平台实现（App Store）
- `WindowsPaymentService` - Windows 平台实现（第三方支付）
- `MockPaymentService` - 模拟支付服务（测试用）

## 功能特性

### 核心功能
- ✅ 跨平台统一API
- ✅ 产品信息查询
- ✅ 购买功能
- ✅ 恢复购买
- ✅ 收据验证
- ✅ 自动权限激活

### 支付方式
- **Android**: Google Play 应用内购买
- **iOS**: App Store 应用内购买
- **Windows**: 第三方支付（可扩展 Microsoft Store）
- **其他平台**: 模拟支付（开发测试）

## 使用方法

### 1. 基本使用

```dart
// 获取支付服务实例
final paymentService = Get.find<PaymentService>();

// 获取可用产品
final products = await paymentService.getProducts();

// 购买产品
final result = await paymentService.purchaseProduct('product_id');

// 恢复购买
final restoreResult = await paymentService.restorePurchases();
```

### 2. 集成到现有UI

```dart
// 在 PremiumService 中已经集成了支付功能
final premiumService = Get.find<PremiumService>();

// 获取可用产品
final products = await premiumService.getAvailableProducts();

// 恢复购买
await premiumService.restorePurchases();
```

### 3. 测试支付功能

```dart
// 导航到测试页面
Get.to(() => const PaymentTestPage());
```

## 配置说明

### Android 配置

1. **Google Play Console 配置**
   - 创建应用内产品
   - 配置产品ID：
     - `tradeflex_monthly_subscription` - 月费版
     - `tradeflex_yearly_subscription` - 年费版
     - `tradeflex_lifetime_purchase` - 终身版

2. **代码配置**
   ```dart
   // 在 AndroidPaymentService 中已配置
   static const String monthlyProductId = 'tradeflex_monthly_subscription';
   static const String yearlyProductId = 'tradeflex_yearly_subscription';
   static const String lifetimeProductId = 'tradeflex_lifetime_purchase';
   ```

### iOS 配置

1. **App Store Connect 配置**
   - 创建应用内购买项目
   - 配置产品ID：
     - `com.tradeflex.monthly_subscription` - 月费版
     - `com.tradeflex.yearly_subscription` - 年费版
     - `com.tradeflex.lifetime_purchase` - 终身版

2. **代码配置**
   ```dart
   // 在 IOSPaymentService 中已配置
   static const String monthlyProductId = 'com.tradeflex.monthly_subscription';
   static const String yearlyProductId = 'com.tradeflex.yearly_subscription';
   static const String lifetimeProductId = 'com.tradeflex.lifetime_purchase';
   ```

### Windows 配置

Windows 平台支持两种支付方案：

#### 1. Microsoft Store 官方支付（推荐）

**Partner Center 配置**
- 在 Microsoft Partner Center 中创建应用
- 配置应用内产品：
  - `tradeflex_monthly_subscription` - 月费版
  - `tradeflex_yearly_subscription` - 年费版  
  - `tradeflex_lifetime_purchase` - 终身版

**应用要求**
- 必须通过 Microsoft Store 分发
- 打包为 MSIX 格式
- Windows 10 版本 1607 及以上

#### 2. 第三方支付（备选）

**支持的支付方式**
- Stripe - 国际信用卡支付
- PayPal - 全球支付平台
- 支付宝/微信支付 - 中国用户支付

**代码配置**
```dart
// 系统会自动检测并选择最合适的支付方式
// 优先使用 Microsoft Store 官方支付
// 如果不可用则自动切换到第三方支付
```

详细配置请参考：[Windows Store 官方支付集成指南](WINDOWS_STORE_PAYMENT_GUIDE.md)

## 收据验证

### 安全考虑
- 所有收据验证都应该在服务端完成
- 客户端仅做基本验证
- 建议实现以下验证流程：

```dart
// 客户端发送收据到服务端
final response = await http.post(
  Uri.parse('https://your-backend.com/verify-receipt'),
  body: {
    'receipt_data': receiptData,
    'platform': platform, // 'android', 'ios', 'windows'
  },
);

// 服务端验证收据并返回结果
return response.statusCode == 200;
```

## 错误处理

### 常见错误
- 产品不存在
- 支付被取消
- 网络连接问题
- 收据验证失败

### 错误处理示例
```dart
try {
  final result = await paymentService.purchaseProduct(productId);
  if (result.success) {
    // 处理成功
  } else {
    // 处理失败
    Get.snackbar('购买失败', result.error ?? '未知错误');
  }
} catch (e) {
  // 处理异常
  Get.snackbar('错误', '购买异常: $e');
}
```

## 测试指南

### 开发测试
1. 使用 `MockPaymentService` 进行本地测试
2. 使用 `PaymentTestPage` 进行功能测试
3. 测试各种错误场景

### 真机测试
1. **Android**: 使用 Google Play 测试轨道
2. **iOS**: 使用 TestFlight 或沙盒环境
3. **Windows**: 使用实际的第三方支付

### 测试检查清单
- [ ] 产品列表加载
- [ ] 购买流程完整性
- [ ] 支付成功后权限激活
- [ ] 恢复购买功能
- [ ] 错误处理和用户提示
- [ ] 收据验证
- [ ] 跨平台兼容性

## 部署注意事项

### 发布前检查
1. 确保所有产品ID配置正确
2. 实现服务端收据验证
3. 测试所有支付流程
4. 检查错误处理逻辑
5. 验证用户权限管理

### 监控和日志
- 使用 `LogService` 记录支付相关日志
- 监控支付成功率
- 跟踪收据验证失败率
- 分析用户支付行为

## 扩展功能

### 未来可扩展的功能
- 支付宝/微信支付集成
- 优惠券系统
- 分期付款
- 退款处理
- 订阅管理

### 自定义支付方式
```dart
// 创建自定义支付服务
class CustomPaymentService extends PaymentService {
  // 实现自定义支付逻辑
}

// 在工厂方法中添加
static PaymentService getInstance() {
  // 根据需要返回自定义服务
  return CustomPaymentService();
}
```

## 常见问题

### Q: 如何添加新的产品？
A: 在相应平台的开发者控制台添加产品，然后在对应的 PaymentService 中配置产品ID。

### Q: 如何处理支付失败？
A: 检查错误信息，可能是网络问题、用户取消或产品配置错误。

### Q: 如何测试支付功能？
A: 使用 `PaymentTestPage` 进行基本测试，或使用各平台的测试环境。

### Q: 收据验证失败怎么办？
A: 检查服务端验证逻辑，确保收据数据完整且验证URL正确。

## 支持

如有问题或建议，请联系开发团队或查看相关文档。 