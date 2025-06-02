import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/position/edit_sub_position_controller.dart';
import 'package:trade_flex/core/database/database.dart';

/// 移动端编辑子持仓页面
class EditSubPositionPage extends StatelessWidget {
  final int positionId;
  final int subPositionId;
  final Function() onEditComplete;

  const EditSubPositionPage({
    super.key,
    required this.positionId,
    required this.subPositionId,
    required this.onEditComplete,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      EditSubPositionController(
        positionId: positionId,
        subPositionId: subPositionId,
        onEditComplete: onEditComplete,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑子持仓'),
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
              // 主持仓信息卡片（只读）
              _buildMainPositionCard(context, controller),
              
              const SizedBox(height: 16),
              
              // 子持仓信息卡片
              _buildSubPositionCard(context, controller),
              
              const SizedBox(height: 16),
              
              // 子持仓统计信息卡片
              _buildSubPositionStatsCard(context, controller),
              
              const SizedBox(height: 16),
              
              // 合并选项卡片
              Obx(() {
                if (controller.showMergeOption.value) {
                  return _buildMergeOptionCard(context, controller);
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        );
      }),
    );
  }

  /// 构建主持仓信息卡片（只读）
  Widget _buildMainPositionCard(BuildContext context, EditSubPositionController controller) {
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
                  color: Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '主持仓信息',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 主持仓名称（只读）
            TextFormField(
              controller: controller.mainPositionNameController,
              decoration: InputDecoration(
                labelText: '主持仓名称',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                prefixIcon: const Icon(Icons.lock, color: Colors.grey),
              ),
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建子持仓信息卡片
  Widget _buildSubPositionCard(BuildContext context, EditSubPositionController controller) {
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
                  Icons.description,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '子持仓信息',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 子持仓名称输入
            TextFormField(
              controller: controller.subPositionNameController,
              decoration: InputDecoration(
                labelText: '子持仓名称',
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

  /// 构建子持仓统计信息卡片
  Widget _buildSubPositionStatsCard(BuildContext context, EditSubPositionController controller) {
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
                  '子持仓统计',
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
              final subPosition = controller.subPosition.value;
              if (subPosition == null) return const SizedBox.shrink();
              
              return Column(
                children: [
                  _buildStatRow('持仓量', subPosition.holdCnt),
                  _buildStatRow('平均成本', subPosition.avgPrice),
                  _buildStatRow('摊薄均价', subPosition.dilutedAvgPrice),
                  _buildStatRow('盈亏', subPosition.profitOrLoss),
                  _buildStatRow('手续费', subPosition.fee ?? '0'),
                  _buildStatRow('股息', subPosition.dividendAmount ?? '0'),
                  _buildStatRow('开仓日期', subPosition.openDate.toString().split(' ')[0]),
                  if (subPosition.closeDate != null)
                    _buildStatRow('平仓日期', subPosition.closeDate.toString().split(' ')[0]),
                  _buildStatRow('状态', subPosition.isClosed ? '已平仓' : '持仓中'),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 构建合并选项卡片
  Widget _buildMergeOptionCard(BuildContext context, EditSubPositionController controller) {
    return Card(
      elevation: 2,
      color: Colors.amber[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.merge_type,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '合并子持仓',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            const Text(
              '选择要将当前子持仓合并到的目标子持仓：',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            
            // 子持仓选择下拉框
            Obx(() => DropdownButtonFormField<SubPosition>(
              decoration: InputDecoration(
                labelText: '目标子持仓',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              value: controller.selectedSubPositionForMerge.value,
              onChanged: controller.updateMergeTarget,
              items: controller.allSubPositions
                  .map<DropdownMenuItem<SubPosition>>((SubPosition value) {
                return DropdownMenuItem<SubPosition>(
                  value: value,
                  child: Text(
                    '${value.subPositionSymbol} (持仓: ${value.holdCnt}, 成本: ${value.avgPrice})',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            )),
            
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '注意: 合并后，当前子持仓的数据将被合并到目标子持仓，并且当前子持仓将被删除。此操作不可撤销。',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 合并按钮
            Center(
              child: Obx(() => ElevatedButton.icon(
                onPressed: controller.isMerging.value ? null : controller.mergeSubPositions,
                icon: controller.isMerging.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.merge_type),
                label: Text(controller.isMerging.value ? '合并中...' : '合并子持仓'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              )),
            ),
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