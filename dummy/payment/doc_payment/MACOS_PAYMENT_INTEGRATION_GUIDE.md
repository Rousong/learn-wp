# macOS 支付集成指南

## 概述

TradeFlex 现已支持 macOS 平台的应用内购买功能，使用与 iOS 相同的 App Store 支付系统。

## 架构说明

### 支付服务实现
- `MacOSPaymentService` - macOS 平台专用支付服务
- 使用 `in_app_purchase` 包的 StoreKit 集成
- 与 iOS 共享相同的 App Store Connect 产品配置

### 产品配置
macOS 使用与 iOS 相同的产品ID：
- `com.tradeflex.monthly_subscription` - 月费版订阅
- `com.tradeflex.yearly_subscription` - 年费版订阅  
- `com.tradeflex.lifetime_purchase` - 终身版购买

## 配置步骤

### 1. App Store Connect 配置

macOS 应用内购买与 iOS 共享相同的 App Store Connect 配置：

1. 在 App Store Connect 中创建 macOS 应用
2. 配置应用内购买产品（与 iOS 使用相同的产品ID）
3. 确保产品状态为 "Ready to Submit"

### 2. 应用配置

#### Bundle ID 配置
确保 macOS 应用的 Bundle ID 与 iOS 应用一致，或者使用相同的开发者账号下的不同 Bundle ID。

#### 权限配置
在 `macos/Runner/DebugProfile.entitlements` 和 `macos/Runner/Release.entitlements` 中添加：

```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.network.client</key>
<true/>
```

### 3. 代码集成

#### 自动平台检测
支付服务会自动检测 macOS 平台并使用 `MacOSPaymentService`：

```dart
// 在 PaymentService.getInstance() 中自动选择
if (defaultTargetPlatform == TargetPlatform.macOS) {
  return Get.put(MacOSPaymentService());
}
```

#### 使用方式
```dart
// 获取支付服务实例
final paymentService = Get.find<PaymentService>();

// 获取可用产品
final products = await paymentService.getProducts();

// 购买产品
final result = await paymentService.purchaseProduct('com.tradeflex.monthly_subscription');

// 恢复购买
await paymentService.restorePurchases();
```

## 测试指南

### 1. 沙盒测试
- 使用与 iOS 相同的沙盒测试账号
- 在 macOS 系统偏好设置中配置沙盒账号

### 2. StoreKit 测试
- 可以使用 Xcode 的 StoreKit 配置文件进行本地测试
- 创建 `Configuration.storekit` 文件并在 Xcode scheme 中配置

### 3. TestFlight 测试
- 通过 TestFlight 分发 macOS 版本进行测试
- 测试购买不会产生实际费用

## 特性支持

### 支持的功能
- ✅ 产品查询
- ✅ 购买流程
- ✅ 恢复购买
- ✅ 收据验证
- ✅ 自动权限激活
- ✅ 订阅管理
- ✅ 错误处理

### 平台特性
- 使用原生 macOS 支付界面
- 支持 Touch ID / Face ID 验证
- 与 iOS 购买记录同步（使用相同 Apple ID）
- 支持家庭共享

## 注意事项

### 1. 产品配置
- macOS 和 iOS 可以共享相同的产品ID
- 确保在 App Store Connect 中为 macOS 应用启用相应产品

### 2. 测试环境
- 优先使用真机测试，模拟器可能存在限制
- 确保测试设备已登录沙盒测试账号

### 3. 收据验证
- 收据验证逻辑与 iOS 相同
- 建议在服务端进行收据验证

### 4. 错误处理
- 处理网络连接问题
- 处理用户取消购买
- 处理产品不可用情况

## 常见问题

### Q: macOS 是否需要单独的支付服务？
A: 是的，虽然 macOS 使用与 iOS 相同的 App Store 系统，但需要单独的服务类来处理平台特定的逻辑。

### Q: 产品ID 是否需要不同？
A: 不需要，macOS 和 iOS 可以使用相同的产品ID，但需要在 App Store Connect 中为两个平台分别配置。

### Q: 如何处理跨平台购买同步？
A: 使用相同的 Apple ID 登录的设备会自动同步购买记录，可以通过恢复购买功能实现。

### Q: 测试时遇到产品不可用怎么办？
A: 检查以下几点：
- App Store Connect 中产品状态是否正确
- Bundle ID 是否匹配
- 测试账号是否正确配置
- 网络连接是否正常

## 部署注意事项

### 1. 证书配置
- 确保使用正确的开发者证书
- 配置正确的 Bundle ID

### 2. 权限配置
- 确保应用具有网络访问权限
- 配置正确的沙盒权限

### 3. 分发方式
- 通过 Mac App Store 分发
- 或通过 TestFlight 进行测试分发

## 扩展功能

### 未来可能的增强
- 支持 macOS 特有的支付界面定制
- 集成 macOS 系统通知
- 支持 macOS 快捷键操作
- 优化大屏幕显示效果

---

## 技术支持

如果在集成过程中遇到问题，请检查：
1. 日志输出中的错误信息
2. App Store Connect 中的产品配置
3. 测试账号和设备配置
4. 网络连接状态

更多技术细节请参考 Apple 官方文档：
- [In-App Purchase Programming Guide](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/StoreKitGuide/Introduction.html)
- [StoreKit Framework Reference](https://developer.apple.com/documentation/storekit) 