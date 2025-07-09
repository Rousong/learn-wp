import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/history/history_filter_card_controller.dart';
import 'package:trade_flex/core/constants/position_enums.dart';
import 'package:trade_flex/core/widgets/date_picker.dart';

/// 移动端历史记录筛选器组件
/// 
/// 提供简化的筛选功能，适合移动端使用
class MobileHistoryFilter extends GetView<HistoryFilterCardController> {
  const MobileHistoryFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 筛选器标题
            Text(
              '筛选条件',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // 筛选内容
            Obx(() => controller.positions.isEmpty 
                ? _buildNoDataMessage(context)
                : _buildFilterContent(context)),
          ],
        ),
      ),
    );
  }

  /// 构建无数据消息
  Widget _buildNoDataMessage(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        '暂无可筛选的持仓数据',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
    );
  }

  /// 构建筛选内容
  Widget _buildFilterContent(BuildContext context) {
    return Column(
      children: [
        // 第一行：日期范围
        Row(
          children: [
            // --- 开始日期 ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('开始日期', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Obx(() => CommonDatePicker(
                        selectedDate: controller.startDate,
                        onDateChanged: (date) => controller.setStartDate(date),
                        width: double.infinity,
                      )),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // --- 结束日期 ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('结束日期', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Obx(() => CommonDatePicker(
                        selectedDate: controller.endDate,
                        onDateChanged: (date) => controller.setEndDate(date),
                        width: double.infinity,
                      )),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16), // 添加行间距
        // 第二行：持仓选择和方向
        Row(
          children: [
            // --- 选择持仓 ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('选择持仓', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Obx(() => DropdownButtonFormField<int?>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          isDense: true,
                        ),
                        value: controller.selectedPositionId,
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('全部持仓'),
                          ),
                          ...controller.positions.map((position) => DropdownMenuItem<int?>(
                                value: position.id,
                                child: Text(
                                  '${position.positionSymbol} - ${position.positionDirection == PositionDirection.long ? '多头' : '空头'}',
                                  overflow: TextOverflow.ellipsis, // 防止文本溢出
                                ),
                              )),
                        ],
                        onChanged: (value) => controller.setSelectedPositionId(value),
                        isExpanded: true, // 允许下拉列表扩展
                      )),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // --- 持仓方向 ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('持仓方向', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Obx(() => DropdownButtonFormField<bool?>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          isDense: true,
                        ),
                        value: controller.isLongPosition,
                        items: const [
                          DropdownMenuItem<bool?>(
                            value: null,
                            child: Text('全部'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: true,
                            child: Text('多头'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: false,
                            child: Text('空头'),
                          ),
                        ],
                        onChanged: (value) => controller.setIsLongPosition(value),
                      )),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // --- 操作按钮 ---
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: controller.resetFilters,
              icon: const Icon(Icons.clear),
              label: const Text('清除'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: controller.applyFilters,
              icon: const Icon(Icons.search),
              label: const Text('应用筛选'),
            ),
          ],
        ),
      ],
    );
  }
} 