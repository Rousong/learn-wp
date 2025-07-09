import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/statistics/time_range_filter_controller.dart';
import 'package:intl/intl.dart';

/// 移动端时间范围过滤器组件
/// 
/// 提供时间范围选择功能
class MobileTimeRangeFilter extends StatelessWidget {
  const MobileTimeRangeFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TimeRangeFilterController>();
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Icon(
                  Icons.date_range,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '时间范围选择',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Obx(() => controller.isLoadingSnapshots.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          
          // 内容区域
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 快捷选择按钮
                _buildQuickSelectButtons(controller),
                
                const SizedBox(height: 16),
                
                // 自定义日期范围
                _buildCustomDateRange(context, controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建快捷选择按钮
  Widget _buildQuickSelectButtons(TimeRangeFilterController controller) {
    final quickOptions = [
      {'label': '最近7天', 'days': 7},
      {'label': '最近30天', 'days': 30},
      {'label': '最近90天', 'days': 90},
      {'label': '最近1年', 'days': 365},
    ];

    return Row(
      children: quickOptions.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final days = option['days'] as int;
        final label = option['label'] as String;
        final isLast = index == quickOptions.length - 1;
        
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 8),
            child: Obx(() {
              final currentRange = controller.dateRange.value;
              final currentDays = currentRange.end.difference(currentRange.start).inDays + 1;
              final isSelected = currentDays == days;
              
              return FilterChip(
                label: Text(
                  label,
                  style: const TextStyle(fontSize: 10),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    final endDate = DateTime.now();
                    final startDate = endDate.subtract(Duration(days: days - 1));
                    controller.setDateRange(DateTimeRange(start: startDate, end: endDate));
                  }
                },
                selectedColor: Theme.of(Get.context!).colorScheme.primary.withValues(alpha: 0.2),
                checkmarkColor: Theme.of(Get.context!).colorScheme.primary,
              );
            }),
          ),
        );
      }).toList(),
    );
  }

  /// 构建自定义日期范围选择
  Widget _buildCustomDateRange(BuildContext context, TimeRangeFilterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '自定义时间范围',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final dateRange = controller.dateRange.value;
          return InkWell(
            onTap: () => _showDateRangePicker(context, controller),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${DateFormat('yyyy/MM/dd').format(dateRange.start)} - ${DateFormat('yyyy/MM/dd').format(dateRange.end)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }



  /// 显示日期范围选择器
  Future<void> _showDateRangePicker(BuildContext context, TimeRangeFilterController controller) async {
    final currentRange = controller.dateRange.value;
    
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: currentRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
      helpText: '选择统计时间范围',
      cancelText: '取消',
      confirmText: '确定',
      fieldStartLabelText: '开始日期',
      fieldEndLabelText: '结束日期',
    );

    if (pickedRange != null) {
      controller.setDateRange(pickedRange);
    }
  }
} 