import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/mobile/onboarding/controller/mobile_onboarding_controller.dart';

/// 移动端投资组合创建页面
/// 
/// 允许用户创建新的投资组合
class MobilePortfolioCreationPage extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const MobilePortfolioCreationPage({
    Key? key,
    required this.onNext,
    required this.onPrevious,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MobileOnboardingController>();
    
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 页面标题
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.add_chart,
                        size: 64,
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '创建投资组合',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '设置您的第一个投资组合',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 投资组合名称
                const Text(
                  '投资组合名称 *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => TextField(
                  onChanged: controller.setPortfolioName,
                  decoration: InputDecoration(
                    hintText: '例如：我的股票投资',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText: controller.errorMessage.value.isNotEmpty ? controller.errorMessage.value : null,
                  ),
                )),
                
                const SizedBox(height: 24),
                
                // 币种选择
                const Text(
                  '币种',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.portfolioCurrency.value,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'CNY', child: Text('人民币 (CNY)')),
                    DropdownMenuItem(value: 'USD', child: Text('美元 (USD)')),
                    DropdownMenuItem(value: 'EUR', child: Text('欧元 (EUR)')),
                    DropdownMenuItem(value: 'JPY', child: Text('日元 (JPY)')),
                    DropdownMenuItem(value: 'HKD', child: Text('港币 (HKD)')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.setCurrency(value);
                    }
                  },
                )),
                
                const SizedBox(height: 24),
                
                // 投资组合类型
                const Text(
                  '投资类型',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.portfolioType.value.toString().split('.').last,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'stock', child: Text('股票')),
                    DropdownMenuItem(value: 'crypto', child: Text('加密货币')),
                    DropdownMenuItem(value: 'forex', child: Text('外汇')),
                    DropdownMenuItem(value: 'futures', child: Text('期货')),
                    DropdownMenuItem(value: 'options', child: Text('期权')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.setPortfolioType(value);
                    }
                  },
                )),
                
                const SizedBox(height: 24),
                
                // 交易方向
                const Text(
                  '交易方向',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.portfolioDirection.value.toString().split('.').last,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'long', child: Text('做多')),
                    DropdownMenuItem(value: 'short', child: Text('做空')),
                    DropdownMenuItem(value: 'both', child: Text('双向')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.setDirection(value);
                    }
                  },
                )),
              ],
            ),
          ),
        ),
        
        // 底部按钮
        Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: onPrevious,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  minimumSize: const Size(80, 44),
                  foregroundColor: Theme.of(context).primaryColor,
                ),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                ),
                label: const Text('上一步'),
              ),
              ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  minimumSize: const Size(120, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('下一步'),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 