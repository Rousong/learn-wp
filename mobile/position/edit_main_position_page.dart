import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/constants/trade_flex_strings.dart';
import 'package:trade_flex/core/controllers/position/edit_main_position_controller.dart';
import 'package:trade_flex/core/utils/keyboard_utils.dart';

/// 移动端编辑主持仓页面
class EditMainPositionPage extends StatelessWidget {
  final int positionId;
  final Function() onEditComplete;

  const EditMainPositionPage({
    super.key,
    required this.positionId,
    required this.onEditComplete,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      EditMainPositionController(
        positionId: positionId,
        onEditComplete: onEditComplete,
      ),
    );

    return KeyboardDismissible(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('编辑主持仓'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          actions: [
            Obx(() => TextButton(
              onPressed: controller.isSaving.value ? null : controller.saveChanges,
              child: controller.isSaving.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('保存'),
            )),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 主持仓信息卡片
                _buildMainPositionCard(context, controller),
                
                const SizedBox(height: 16),
                
                // 资产绑定卡片
                _buildAssetBindingCard(context, controller),
                
                const SizedBox(height: 16),
                
                // 持仓统计信息卡片
                _buildPositionStatsCard(context, controller),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// 构建主持仓信息卡片
  Widget _buildMainPositionCard(BuildContext context, EditMainPositionController controller) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '主持仓信息',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 主持仓名称输入
            TextFormField(
              controller: controller.mainPositionNameController,
              decoration: const InputDecoration(
                labelText: '主持仓名称',
                prefixIcon: Icon(Icons.edit),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建资产绑定卡片
  Widget _buildAssetBindingCard(BuildContext context, EditMainPositionController controller) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.link,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '资产绑定',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 市场选择
            Obx(() => DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: TradeFlexStrings.market.tr,
              ),
              value: controller.selectedMarket.value == TradeFlexStrings.marketGlobal ? null : controller.selectedMarket.value,
              onChanged: (value) => controller.selectedMarket.value = value ?? TradeFlexStrings.marketGlobal,
              items: EditMainPositionController.marketList.map<DropdownMenuItem<String>>((String identifier) {
                return DropdownMenuItem<String>(
                  value: identifier,
                  child: Text(identifier.tr),
                );
              }).toList(),
            )),
            
            const SizedBox(height: 12),
            
            // 资产类型选择
            Obx(() => DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: TradeFlexStrings.assetType.tr,
              ),
              value: controller.selectedAssetType.value == TradeFlexStrings.assetTypeAll ? null : controller.selectedAssetType.value,
              onChanged: (value) => controller.selectedAssetType.value = value ?? TradeFlexStrings.assetTypeAll,
              items:EditMainPositionController.assetTypeList.map<DropdownMenuItem<String>>((String identifier) {
                                    return DropdownMenuItem<String>(
                                      value: identifier,
                                      child: Text(identifier.tr),
                                    );
              }).toList(),
            )),
            
            const SizedBox(height: 12),
            
            // 资产代码搜索
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.assetCodeController,
                    decoration: const InputDecoration(
                      labelText: '资产代码',
                      hintText: '例如：AAPL',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() => ElevatedButton(
                  onPressed: controller.isSearching.value ? null : controller.searchAsset,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: controller.isSearching.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('搜索'),
                )),
              ],
            ),
            
            // 搜索结果
            Obx(() {
              if (controller.isSearching.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (controller.showSearchResults.value && controller.searchResults.isNotEmpty) {
                return Container(
                  margin: const EdgeInsets.only(top: 12),
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.searchResults.length,
                    itemBuilder: (context, index) {
                      final asset = controller.searchResults[index];
                      return Obx(() => ListTile(
                        title: Text(asset.assetCode.value),
                        subtitle: Text(asset.assetName.value ?? ''),
                        trailing: controller.isSaving.value 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(asset.closePrice.value ?? ''),
                        onTap: controller.isSaving.value 
                            ? null 
                            : () => controller.selectAndBindAsset(controller.selectedAssetType.value, asset),
                        enabled: !controller.isSaving.value,
                      ));
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            
            // 资产绑定预览和绑定状态
            Obx(() {
              if (controller.isSaving.value && !controller.assetBindingPreviewVisible.value) {
                // 显示绑定进行中状态
                return Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '正在绑定资产...',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (controller.assetBindingPreviewVisible.value) {
                return Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text('已绑定资产', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          TextButton(
                            onPressed: controller.isSaving.value ? null : controller.unbindAsset,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('解除绑定', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('代码: ${controller.bindedAssetCode?.value ?? ''}'),
                      Text('价格: ${controller.bindedAssetPrice?.value ?? ''}'),
                      Text('涨跌: ${controller.bindedAssetChange?.value ?? ''}'),
                      Text('更新时间: ${controller.bindedAssetUpdateTime?.value ?? ''}'),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            
            // 手动价格输入
            Obx(() {
              if (!controller.assetBindingPreviewVisible.value) {
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller.manualPriceController,
                            decoration: const InputDecoration(
                              labelText: '手动输入最新价格',
                              hintText: '例如：10.55',
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Obx(() => ElevatedButton(
                          onPressed: controller.isSaving.value ? null : controller.updateManualPrice,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          child: controller.isSaving.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('更新'),
                        )),
                      ],
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  /// 构建持仓统计信息卡片
  Widget _buildPositionStatsCard(BuildContext context, EditMainPositionController controller) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '持仓统计',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Obx(() {
              final position = controller.mainPosition.value;
              if (position == null) return const SizedBox.shrink();
              
              return Column(
                children: [
                   _buildStatRow(context, '持仓方向', position.positionDirection.name == 'long' ? '多头' : '空头'),
                   _buildStatRow(context, '总持仓量', position.totalHoldCnt),
                   _buildStatRow(context, '平均成本', position.totalAvgPrice),
                   _buildStatRow(context, '摊薄均价', position.totalDilutedAvgPrice),
                   _buildStatRow(context, '总盈亏', position.totalProfitOrLoss),
                   _buildStatRow(context, '总手续费', position.totalFee ?? '0'),
                   _buildStatRow(context, '总股息', position.totalDividendAmount ?? '0'),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 构建统计行
  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
} 