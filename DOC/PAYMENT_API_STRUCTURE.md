# API应用结构说明

本项目现在包含四个API应用，分别用于不同的环境和功能：

## API应用概览

### 生产环境应用
- `payment_verification` - 支付验证API (生产环境)
- `price_api` - 价格查询API (生产环境)

### 测试环境应用
- `test_payment_verification` - 支付验证API (测试环境)
- `test_price_api` - 价格查询API (测试环境)

## 1. payment_verification - 生产环境应用

**URL前缀**: `api/v1/`

**特点**:
- 仅包含生产环境的真实API调用逻辑
- iOS: 直接调用Apple App Store生产环境API
- Android: 需要配置Google Play Developer API凭据
- Windows: 需要配置Microsoft Store API凭据
- macOS: 使用与iOS相同的App Store API
- 删除了所有沙盒和mock逻辑

**主要端点**:
- `GET /api/v1/health/` - 健康检查
- `POST /api/v1/verify/` - 支付验证
- `GET /api/v1/subscription/status/<user_id>/` - 用户订阅状态
- `GET /api/v1/subscription/detail/<user_id>/` - 用户订阅详情
- `GET /api/v1/records/` - 支付记录列表

## 2. price_api - 生产环境价格API

**URL前缀**: `api/v1/`

**特点**:
- 支持真实的第三方API调用（EODHD等）
- 包含生产环境API凭据配置
- 支持多种资产类型：股票、加密货币、外汇、商品
- 支持多个市场：美国、中国、香港、日本等
- 删除了mock逻辑，仅保留真实API调用

**主要端点**:
- `GET /api/v1/search/` - 资产搜索
- `GET /api/v1/price/` - 单个资产实时价格
- `GET /api/v1/prices/` - 批量资产实时价格

## 3. test_payment_verification - 测试环境支付验证

**URL前缀**: `api-test/v1/`

**特点**:
- 仅包含mock/模拟验证逻辑
- 所有平台都使用模拟验证，不调用真实API
- 支持模拟不同的验证结果（成功/失败）
- 所有返回数据都带有 `test_mode: true` 标识
- 数据库表名都带有 `test_` 前缀

**主要端点**:
- `GET /api-test/v1/health/` - 健康检查（返回test_mode: true）
- `POST /api-test/v1/verify/` - 模拟支付验证
- `GET /api-test/v1/subscription/status/<user_id>/` - 模拟用户订阅状态
- `GET /api-test/v1/subscription/detail/<user_id>/` - 模拟用户订阅详情
- `GET /api-test/v1/records/` - 模拟支付记录列表

## 4. test_price_api - 测试环境价格API

**URL前缀**: `api-test/v1/`

**特点**:
- 仅包含mock/模拟数据逻辑
- 不调用任何真实的第三方API
- 支持模拟所有资产类型和市场
- 所有返回数据都带有 `test_mode: true` 标识
- 数据库表名都带有 `test_` 前缀

**主要端点**:
- `GET /api-test/v1/search/` - 模拟资产搜索
- `GET /api-test/v1/price/` - 模拟单个资产实时价格
- `GET /api-test/v1/prices/` - 模拟批量资产实时价格

## 测试环境特殊功能

### 模拟不同验证结果

测试环境支持通过收据内容模拟不同的验证结果：

1. **成功验证**: 使用正常的收据数据
2. **失败验证**: 收据数据中包含 `invalid` 关键字

#### 模拟价格数据

测试价格API包含丰富的模拟数据：

1. **美国股票**: AAPL, MSFT, GOOG, AMZN, TSLA, META, NVDA等
2. **香港股票**: 0700.HK (腾讯), 9988.HK (阿里巴巴), 3690.HK (美团)等
3. **中国A股**: 600519.SHG (茅台), 601318.SHG (平安)等
4. **加密货币**: BTC.CC, ETH.CC, SOL.CC等
5. **外汇**: EURUSD.FOREX, USDJPY.FOREX等

## 示例

### 支付验证API示例

#### iOS成功验证
```bash
curl -X POST http://localhost:8000/api-test/v1/verify/ \
  -H "Content-Type: application/json" \
  -d '{
    "platform": "ios",
    "receipt_data": "test_receipt_data_123",
    "user_id": "test_user_001",
    "product_id": "test_ios_monthly_subscription"
  }'
```

#### iOS失败验证
```bash
curl -X POST http://localhost:8000/api-test/v1/verify/ \
  -H "Content-Type: application/json" \
  -d '{
    "platform": "ios",
    "receipt_data": "invalid_receipt_data",
    "user_id": "test_user_002"
  }'
```

#### Android验证
```bash
curl -X POST http://localhost:8000/api-test/v1/verify/ \
  -H "Content-Type: application/json" \
  -d '{
    "platform": "android",
    "receipt_data": "{\"purchaseToken\":\"test_token_123\",\"productId\":\"test_android_monthly\",\"purchaseTime\":1725984000000,\"orderId\":\"test_order_001\"}",
    "user_id": "test_user_003"
  }'
```

### 价格API示例

#### 资产搜索
```bash
curl -X GET "http://localhost:8000/api-test/v1/search/?keyword=apple&asset_type=stock&market=us"
```

#### 单个资产实时价格
```bash
curl -X GET "http://localhost:8000/api-test/v1/price/?symbol=AAPL&exchange=US"
```

#### 批量资产实时价格
```bash
curl -X GET "http://localhost:8000/api-test/v1/prices/?symbols=AAPL.US,MSFT.US,BTC.CC"
```

#### POST方式批量查询
```bash
curl -X POST http://localhost:8000/api-test/v1/prices/ \
  -H "Content-Type: application/json" \
  -d '{
    "symbols": ["AAPL.US", "MSFT.US", "0700.HK", "BTC.CC"]
  }'
```

## 数据库

四个应用使用独立的数据库表：

**支付验证应用**:
- 生产环境: `payment_verification_*` 表
- 测试环境: `test_payment_verification_*` 表

**价格API应用**:
- 生产环境: `price_api_*` 表
- 测试环境: `test_price_api_*` 表

这确保了测试数据和生产数据完全隔离。

## 使用建议

1. **开发阶段**: 
   - 支付验证：使用 `api-test/v1/` 进行功能测试和开发
   - 价格查询：使用 `api-test/v1/` 进行功能测试和开发

2. **生产环境**: 
   - 支付验证：配置好各平台的API凭据后，使用 `api/v1/` 进行真实验证
   - 价格查询：配置好EODHD等API凭据后，使用 `api/v1/` 进行真实数据查询

3. **CI/CD**: 可以在测试环境中使用测试API进行自动化测试

4. **API切换**: 生产环境和测试环境的API接口完全一致，只需要改变URL前缀即可切换
