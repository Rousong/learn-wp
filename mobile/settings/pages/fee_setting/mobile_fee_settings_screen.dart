import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/settings/fee_model_controller.dart';
import 'package:trade_flex/core/utils/keyboard_utils.dart';
import 'package:trade_flex/mobile/settings/pages/fee_setting/mobile_fee_model_card.dart';
import 'package:trade_flex/mobile/settings/pages/fee_setting/mobile_empty_fee_state.dart';
import 'package:trade_flex/mobile/settings/pages/fee_setting/mobile_create_fee_model_bottom_sheet.dart';

/// 移动端收费模式设置页面
/// 
/// 显示收费模式列表，复用桌面端的FeeModelController
class MobileFeeSettingsScreen extends GetView<FeeModelController> {
  const MobileFeeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissible(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('收费模式设置'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final feeModels = controller.feeModels;
          
          if (feeModels.isEmpty) {
            return const MobileEmptyFeeState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await controller.loadFeeModels();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: feeModels.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final model = feeModels[index];
                return MobileFeeModelCard(
                  model: model,
                  controller: controller,
                );
              },
            ),
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateFeeModelBottomSheet(context),
          tooltip: '添加收费模式',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  /// 显示创建收费模式底部弹出页面
  void _showCreateFeeModelBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MobileCreateFeeModelBottomSheet(
        onFeeModelCreated: (model) async {
          await controller.addFeeModel(model);
        },
      ),
    );
  }
} 