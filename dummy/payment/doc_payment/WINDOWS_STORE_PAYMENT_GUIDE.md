# Windows Store 官方支付集成指南

## 概述

Windows 平台现在支持 **Microsoft Store 官方支付** 和 **第三方支付** 两种方案，系统会自动检测并选择最合适的支付方式。

## 支付方案对比

| 方案 | 优点 | 缺点 | 适用场景 |
|------|------|------|----------|
| **Microsoft Store 官方** | 用户体验好、安全可靠、无需额外配置 | 需要通过 Store 分发、有平台抽成 | Store 应用 |
| **第三方支付** | 灵活性高、无平台抽成、支持多种支付方式 | 需要额外配置、用户体验相对复杂 | 直接分发的应用 |

## Microsoft Store 官方支付

### 1. 前置条件

#### 应用要求
- 应用必须通过 Microsoft Store 分发
- 应用必须打包为 MSIX 格式
- 应用必须在 Microsoft Partner Center 中注册

#### Windows 版本要求
- Windows 10 版本 1607 (Build 14393) 及以上
- 支持 Windows.Services.Store API

#### 开发环境要求
- Visual Studio 2019/2022
- Windows App SDK 或 UWP 开发工具

### 2. Partner Center 配置

#### 创建应用
1. 登录 [Microsoft Partner Center](https://partner.microsoft.com/)
2. 创建新应用或选择现有应用
3. 获取应用的 Store ID

#### 配置应用内产品
1. 进入应用管理页面
2. 选择"应用内产品" -> "持久性加载项"
3. 创建以下产品：

```
产品ID: tradeflex_monthly_subscription
产品类型: 订阅
价格: $0.99/月
显示名称: TradeFlex 月费版
描述: 包含所有高级功能的月度订阅

产品ID: tradeflex_yearly_subscription  
产品类型: 订阅
价格: $9.99/年
显示名称: TradeFlex 年费版
描述: 包含所有高级功能的年度订阅

产品ID: tradeflex_lifetime_purchase
产品类型: 持久性
价格: $19.99
显示名称: TradeFlex 终身版
描述: 一次购买，终身使用所有高级功能
```

### 3. 应用配置

#### Package.appxmanifest 配置
```xml
<?xml version="1.0" encoding="utf-8"?>
<Package xmlns="http://schemas.microsoft.com/appx/manifest/foundation/windows10">
  <Identity Name="YourCompany.TradeFlex" 
            Publisher="CN=YourCompany" 
            Version="1.0.0.0" />
  
  <Properties>
    <DisplayName>TradeFlex</DisplayName>
    <PublisherDisplayName>Your Company</PublisherDisplayName>
  </Properties>
  
  <Capabilities>
    <!-- 应用内购买权限 -->
    <Capability Name="internetClient" />
  </Capabilities>
  
  <Applications>
    <Application Id="App">
      <!-- 应用配置 -->
    </Application>
  </Applications>
</Package>
```

#### Windows 项目配置
```cmake
# windows/CMakeLists.txt
# 添加 Windows Runtime 支持
target_link_libraries(${BINARY_NAME} PRIVATE windowsapp)
```

### 4. FFI 实现示例

#### Windows Store API 调用
```dart
// lib/core/services/payment/windows_store_ffi.dart
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// Windows Store API 绑定
class WindowsStoreFFI {
  static final DynamicLibrary _lib = Platform.isWindows
      ? DynamicLibrary.open('windowsapp.dll')
      : DynamicLibrary.process();

  // 获取 Store Context
  static final _getStoreContext = _lib.lookupFunction<
      Pointer Function(),
      Pointer Function()>('GetStoreContext');

  // 请求购买
  static final _requestPurchase = _lib.lookupFunction<
      Int32 Function(Pointer, Pointer<Utf16>),
      int Function(Pointer, Pointer<Utf16>)>('RequestPurchase');

  // 获取产品信息
  static final _getProducts = _lib.lookupFunction<
      Pointer Function(Pointer),
      Pointer Function(Pointer)>('GetProducts');

  /// 初始化 Store Context
  static Pointer getStoreContext() {
    return _getStoreContext();
  }

  /// 请求购买产品
  static int requestPurchase(Pointer context, String productId) {
    final productIdPtr = productId.toNativeUtf16();
    try {
      return _requestPurchase(context, productIdPtr);
    } finally {
      malloc.free(productIdPtr);
    }
  }

  /// 获取产品列表
  static Pointer getProducts(Pointer context) {
    return _getProducts(context);
  }
}
```

### 5. 实际集成步骤

#### 步骤 1: 创建 Windows 原生插件
```bash
# 创建 Windows 插件
flutter create --template=plugin --platforms=windows windows_store_plugin
```

#### 步骤 2: 实现 C++ 代码
```cpp
// windows/windows_store_plugin.cpp
#include "windows_store_plugin.h"
#include <winrt/Windows.Services.Store.h>
#include <winrt/Windows.Foundation.h>

using namespace winrt;
using namespace Windows::Foundation;
using namespace Windows::Services::Store;

class WindowsStorePlugin {
private:
    StoreContext storeContext{ nullptr };

public:
    WindowsStorePlugin() {
        // 初始化 Store Context
        storeContext = StoreContext::GetDefault();
    }

    // 获取产品信息
    IAsyncOperation<StoreProductQueryResult> GetProductsAsync() {
        std::vector<hstring> productIds = {
            L"tradeflex_monthly_subscription",
            L"tradeflex_yearly_subscription", 
            L"tradeflex_lifetime_purchase"
        };
        
        return storeContext.GetStoreProductsAsync(productIds);
    }

    // 请求购买
    IAsyncOperation<StorePurchaseResult> RequestPurchaseAsync(hstring productId) {
        return storeContext.RequestPurchaseAsync(productId);
    }
};
```

#### 步骤 3: Flutter 接口实现
```dart
// lib/windows_store_plugin.dart
import 'dart:async';
import 'package:flutter/services.dart';

class WindowsStorePlugin {
  static const MethodChannel _channel = MethodChannel('windows_store_plugin');

  /// 获取产品列表
  static Future<List<Map<String, dynamic>>> getProducts() async {
    final result = await _channel.invokeMethod('getProducts');
    return List<Map<String, dynamic>>.from(result);
  }

  /// 购买产品
  static Future<Map<String, dynamic>> purchaseProduct(String productId) async {
    final result = await _channel.invokeMethod('purchaseProduct', {
      'productId': productId,
    });
    return Map<String, dynamic>.from(result);
  }

  /// 恢复购买
  static Future<List<Map<String, dynamic>>> restorePurchases() async {
    final result = await _channel.invokeMethod('restorePurchases');
    return List<Map<String, dynamic>>.from(result);
  }
}
```

## 第三方支付备选方案

### 支持的支付方式
1. **Stripe** - 国际信用卡支付
2. **PayPal** - 全球支付平台
3. **支付宝** - 中国用户支付
4. **微信支付** - 中国用户支付
5. **银联** - 中国银行卡支付

### 集成示例
```dart
// 第三方支付配置
class ThirdPartyPaymentConfig {
  static const String stripePublishableKey = 'pk_test_...';
  static const String paypalClientId = 'your_paypal_client_id';
  static const String alipayAppId = 'your_alipay_app_id';
}
```

## 自动检测逻辑

系统会按以下顺序检测并选择支付方式：

1. **检查 Microsoft Store API 可用性**
   - 应用是否从 Store 安装
   - 是否有 Store API 权限
   - Windows 版本是否支持

2. **Microsoft Store 官方支付**（优先）
   - 如果检测通过，使用官方支付
   - 提供最佳用户体验

3. **第三方支付**（备选）
   - 如果官方支付不可用
   - 自动切换到第三方支付

## 测试指南

### 开发环境测试
1. 使用 Visual Studio 的 Store 模拟器
2. 配置测试产品和测试账户
3. 验证购买流程

### 生产环境测试
1. 通过 Microsoft Store 分发测试版本
2. 使用真实的支付方式测试
3. 验证收据验证和权限激活

## 收据验证

### Microsoft Store 收据验证
```dart
// 服务端验证示例
Future<bool> verifyMicrosoftStoreReceipt(String receiptData) async {
  final response = await http.post(
    Uri.parse('https://collections.mp.microsoft.com/v6.0/collections/query'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'beneficiary': {'localTicket': receiptData},
      'productId': productId,
    }),
  );
  
  return response.statusCode == 200;
}
```

## 常见问题

### Q: 如何判断应用是否从 Store 安装？
A: 检查应用包身份和 Store 许可证信息。

### Q: 开发阶段如何测试支付功能？
A: 使用 Visual Studio 的 Store 模拟器或配置测试产品。

### Q: 如何处理支付失败？
A: 检查网络连接、用户权限和产品配置。

### Q: 第三方支付如何保证安全？
A: 使用 HTTPS、收据验证和服务端验证。

## 最佳实践

1. **优先使用官方支付** - 提供最佳用户体验
2. **提供备选方案** - 确保所有用户都能正常支付
3. **完善错误处理** - 提供清晰的错误提示
4. **收据验证** - 确保支付安全性
5. **用户体验** - 简化支付流程

## 总结

Windows 平台的支付集成现在支持：
- ✅ Microsoft Store 官方支付（推荐）
- ✅ 第三方支付（备选）
- ✅ 自动检测和切换
- ✅ 完整的错误处理
- ✅ 收据验证机制

这样既保证了最佳的用户体验，又确保了支付功能的可用性和灵活性。 