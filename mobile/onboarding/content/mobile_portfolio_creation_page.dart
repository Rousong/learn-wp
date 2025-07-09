import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/mobile/onboarding/controller/mobile_onboarding_controller.dart';
import 'package:trade_flex/mobile/onboarding/mobile_pager_indicator.dart';
import 'package:trade_flex/core/constants/portfolio_enums.dart';
import 'package:trade_flex/core/utils/portfolio_utils.dart';

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
                Obx(() => DropdownButtonFormField<PortfolioCurrency>(
                  value: controller.portfolioCurrency.value,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: PortfolioCurrency.values.map((currency) {
                    return DropdownMenuItem(
                      value: currency,
                      child: Row(
                        children: [
                          Text(PortfolioUtils.getCurrencySymbol(currency)),
                          const SizedBox(width: 8),
                          Text(PortfolioUtils.getCurrencyCode(currency)),
                          const SizedBox(width: 8),
                          Text("(${PortfolioUtils.getCurrencyLabel(currency)})"),
                        ],
                      ),
                    );
                  }).toList(),
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
                Obx(() => DropdownButtonFormField<PortfolioType>(
                  value: controller.portfolioType.value,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: PortfolioType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(PortfolioUtils.getPortfolioTypeLabel(type)),
                    );
                  }).toList(),
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
                Obx(() => DropdownButtonFormField<PortfolioDirection>(
                  value: controller.portfolioDirection.value,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: PortfolioDirection.values.map((direction) {
                    return DropdownMenuItem(
                      value: direction,
                      child: Text(PortfolioUtils.getDirectionLabel(direction)),
                    );
                  }).toList(),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 页面指示器
              Obx(() => MobilePagerIndicator(
                currentPage: controller.currentPage.value,
                pageCount: controller.pageConfigs.length,
                onPageSelected: (index) {
                  controller.goToPage(index);
                },
                activeColor: Colors.purple,
                inactiveColor: Colors.grey.shade300,
              )),
              
              const SizedBox(height: 16),
              
              // 按钮行
              Row(
                children: [
                  // 左侧返回按钮（矩形圆角）
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: onPrevious,
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // 右侧下一步按钮（占据剩余空间）
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('下一步'),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
} 