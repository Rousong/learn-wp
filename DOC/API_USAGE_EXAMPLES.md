# 批量获取实时价格API使用指南

## 概述

新增的批量获取实时价格功能允许您一次请求多个股票代码的实时价格数据，提高了API调用效率。

## API端点

### 批量获取实时价格
- **URL**: `/api/prices/`
- **方法**: `GET` 或 `POST`
- **权限**: 无需认证

## 使用方式

### 方式1: POST请求（推荐）

**请求URL**: `POST /api/prices/`

**请求头**:
```
Content-Type: application/json
```

**请求体**:
```json
{
    "symbols": ["AAPL.US", "VTI.US", "EUR.FOREX"]
}
```

**响应示例**:
```json
{
    "results": [
        {
            "symbol": "AAPL.US",
            "price": 198.50,
            "open": 199.37,
            "high": 201.96,
            "low": 196.78,
            "volume": 70100478,
            "timestamp": 1748636940,
            "previous_close": 199.95,
            "change": 0.9,
            "change_percent": 0.4501,
            "source": "Mock API"
        },
        {
            "symbol": "VTI.US",
            "price": 289.88,
            "open": 289.47,
            "high": 290.745,
            "low": 286.855,
            "volume": 3174072,
            "timestamp": 1748635920,
            "previous_close": 290.12,
            "change": -0.24,
            "change_percent": -0.0827,
            "source": "Mock API"
        },
        {
            "symbol": "EUR.FOREX",
            "price": 0.881,
            "open": 0.8793,
            "high": 0.8836,
            "low": 0.8778,
            "volume": 0,
            "timestamp": 1748640540,
            "previous_close": 0.8794,
            "change": 0.0016,
            "change_percent": 0.1819,
            "source": "Mock API"
        }
    ],
    "count": 3
}
```

### 方式2: GET请求

**请求URL**: `GET /api/prices/?symbols=AAPL.US,VTI.US,EUR.FOREX`

**响应格式**: 与POST请求相同

## 支持的代码格式

### 1. 完整格式（推荐）
- `AAPL.US` - 美国市场苹果公司
- `0700.HK` - 香港市场腾讯控股
- `EUR.FOREX` - 外汇市场欧元
- `BTC.CC` - 加密货币比特币

### 2. 简化格式（仅美国市场）
- `AAPL` - 等同于 `AAPL.US`
- `MSFT` - 等同于 `MSFT.US`

## 错误处理

如果某些代码无法获取数据，API会在响应中包含错误信息：

```json
{
    "results": [
        {
            "symbol": "AAPL.US",
            "price": 198.50,
            // ... 其他字段
        }
    ],
    "count": 1,
    "errors": [
        {
            "error": "Stock or symbol not found",
            "detail": "No data available for INVALID.CODE"
        }
    ]
}
```

## 限制

- 单次请求最多支持50个代码
- 代码列表不能为空
- 无效的代码会返回错误信息，但不会影响其他有效代码的处理

## 代码示例

### Python示例

```python
import requests
import json

# POST请求示例
url = "http://localhost:8000/api/prices/"
data = {
    "symbols": ["AAPL.US", "VTI.US", "EUR.FOREX"]
}

response = requests.post(url, json=data)
result = response.json()

print(f"获取到 {result['count']} 个价格数据")
for item in result['results']:
    print(f"{item['symbol']}: ${item['price']}")

# GET请求示例
url = "http://localhost:8000/api/prices/?symbols=AAPL.US,VTI.US,EUR.FOREX"
response = requests.get(url)
result = response.json()

print(f"获取到 {result['count']} 个价格数据")
```

### JavaScript示例

```javascript
// POST请求示例
const fetchPrices = async () => {
    const response = await fetch('/api/prices/', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            symbols: ['AAPL.US', 'VTI.US', 'EUR.FOREX']
        })
    });
    
    const data = await response.json();
    console.log(`获取到 ${data.count} 个价格数据`);
    
    data.results.forEach(item => {
        console.log(`${item.symbol}: $${item.price}`);
    });
};

// GET请求示例
const fetchPricesGet = async () => {
    const symbols = ['AAPL.US', 'VTI.US', 'EUR.FOREX'];
    const url = `/api/prices/?symbols=${symbols.join(',')}`;
    
    const response = await fetch(url);
    const data = await response.json();
    
    console.log(`获取到 ${data.count} 个价格数据`);
};
```

### cURL示例

```bash
# POST请求
curl -X POST http://localhost:8000/api/prices/ \
  -H "Content-Type: application/json" \
  -d '{"symbols": ["AAPL.US", "VTI.US", "EUR.FOREX"]}'

# GET请求
curl "http://localhost:8000/api/prices/?symbols=AAPL.US,VTI.US,EUR.FOREX"
```

## 与EODHD API的对应关系

本API的设计参考了EODHD官方API的格式：

**EODHD官方格式**:
```
https://eodhd.com/api/real-time/AAPL.US?s=VTI,EUR.FOREX&api_token=xxx&fmt=json
```

**本API格式**:
```
POST /api/prices/
{
    "symbols": ["AAPL.US", "VTI.US", "EUR.FOREX"]
}
```

两者返回的数据格式基本一致，便于迁移和集成。

## 性能优势

- **减少HTTP请求数量**: 一次请求获取多个代码的数据
- **降低延迟**: 批量处理减少了网络往返时间
- **提高效率**: 特别适合需要同时监控多个资产的场景

## 注意事项

1. 建议使用POST请求，特别是当代码列表较长时
2. GET请求的URL长度有限制，代码过多时可能会被截断
3. 错误的代码不会影响其他代码的正常处理
4. 响应时间取决于请求的代码数量和数据源的响应速度 