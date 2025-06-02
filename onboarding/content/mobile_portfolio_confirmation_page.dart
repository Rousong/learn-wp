import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/mobile/onboarding/controller/mobile_onboarding_controller.dart';

/// 移动端投资组合确认页面
/// 
/// 显示投资组合信息并允许用户确认创建
class MobilePortfolioConfirmationPage extends StatelessWidget {
  final VoidCallback onComplete;
  final VoidCallback onPrevious;
  final bool isLoading;
  final VoidCallback onNavigateToTemplate;

  const MobilePortfolioConfirmationPage({
    Key? key,
    required this.onComplete,
    required this.onPrevious,
    required this.isLoading,
    required this.onNavigateToTemplate,
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
              children: [
                // 页面标题
                const Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.teal,
                ),
                const SizedBox(height: 16),
                const Text(
                  '确认投资组合',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '请确认您的投资组合设置',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 投资组合信息卡片
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha:0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.teal.withValues(alpha:0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.folder_outlined,
                            color: Colors.teal,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '投资组合信息',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Obx(() => _buildInfoRow('名称', controller.portfolioName.value.isNotEmpty ? controller.portfolioName.value : '未设置')),
                      const SizedBox(height: 12),
                      Obx(() => _buildInfoRow('币种', controller.getCurrencyLabel(controller.portfolioCurrency.value))),
                      const SizedBox(height: 12),
                      Obx(() => _buildInfoRow('投资类型', controller.getPortfolioTypeLabel(controller.portfolioType.value.toString().split('.').last))),
                      const SizedBox(height: 12),
                      Obx(() => _buildInfoRow('交易方向', controller.getDirectionLabel(controller.portfolioDirection.value.toString().split('.').last))),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 提示信息
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha:0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha:0.2),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '创建后您可以随时在设置中修改这些信息',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                onPressed: isLoading ? null : onPrevious,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  minimumSize: const Size(80, 44),
                  foregroundColor: isLoading ? Colors.grey : Theme.of(context).primaryColor,
                ),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                ),
                label: const Text('上一步'),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  minimumSize: const Size(140, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('创建投资组合'),
                          SizedBox(width: 8),
                          Icon(
                            Icons.check,
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
} 