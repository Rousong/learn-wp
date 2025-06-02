import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/position/edit_main_position_controller.dart';
import 'package:trade_flex/core/constants/asset_types.dart';

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

    return Scaffold(
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
              decoration: InputDecoration(
                labelText: '主持仓名称',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: const Icon(Icons.edit),
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
                labelText: '市场',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              value: controller.selectedMarket.value.isEmpty ? null : controller.selectedMarket.value,
              onChanged: (value) => controller.selectedMarket.value = value ?? '',
              items: const [
                DropdownMenuItem(value: 'GLOBAL', child: Text('全球')),
                DropdownMenuItem(value: 'US', child: Text('美股')),
                DropdownMenuItem(value: 'HK', child: Text('港股')),
                DropdownMenuItem(value: 'CN', child: Text('A股')),
              ],
            )),
            
            const SizedBox(height: 12),
            
            // 资产类型选择
            Obx(() => DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: '资产类型',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              value: controller.selectedAssetType.value == 'ALL' ? null : controller.selectedAssetType.value,
              onChanged: (value) => controller.selectedAssetType.value = value ?? 'ALL',
              items: AssetTypes.assetTypeList.map((String identifier) {
                String translationKey = AssetTypes.toKey[identifier] ?? identifier;
                return DropdownMenuItem(
                  value: identifier,
                  child: Text(translationKey),
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
                    decoration: InputDecoration(
                      labelText: '资产代码',
                      hintText: '例如：AAPL',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      prefixIcon: const Icon(Icons.search),
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
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.searchResults.length,
                    itemBuilder: (context, index) {
                      final asset = controller.searchResults[index];
                      return ListTile(
                        title: Text(asset.assetCode.value),
                        subtitle: Text(asset.assetName.value ?? ''),
                        trailing: Text(asset.closePrice.value ?? ''),
                                                 onTap: () => controller.selectAndBindAsset(controller.selectedAssetType.value, asset),
                      );
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            
            // 资产绑定预览
            Obx(() {
              if (controller.assetBindingPreviewVisible.value) {
                return Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          SizedBox(width: 8),
                          Text('已绑定资产', style: TextStyle(fontWeight: FontWeight.bold)),
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
                            decoration: InputDecoration(
                              labelText: '手动输入最新价格',
                              hintText: '例如：10.55',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              prefixIcon: const Icon(Icons.attach_money),
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
                   _buildStatRow('持仓方向', position.positionDirection.name == 'long' ? '多头' : '空头'),
                   _buildStatRow('总持仓量', position.totalHoldCnt),
                   _buildStatRow('平均成本', position.totalAvgPrice),
                   _buildStatRow('摊薄均价', position.totalDilutedAvgPrice),
                   _buildStatRow('总盈亏', position.totalProfitOrLoss),
                   _buildStatRow('总手续费', position.totalFee ?? '0'),
                   _buildStatRow('总股息', position.totalDividendAmount ?? '0'),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 构建统计行
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
} 