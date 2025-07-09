import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/statistics/snapshot_heatmap_controller.dart';
import 'package:intl/intl.dart';

/// 移动端快照热力图组件
/// 
/// 显示GitHub风格的投资组合快照热力图
class MobileSnapshotHeatmap extends StatelessWidget {
  const MobileSnapshotHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SnapshotHeatmapController>();
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
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
                  Icons.calendar_view_month,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '快照历史热力图',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Obx(() => Text(
                  '${controller.currentYear.value}年',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                )),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          
          // 热力图内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              if (!controller.dataReady.value) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              // 在数据加载完成后延迟调用滚动到当前周
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.scrollToCurrentWeek();
              });
              
              return _buildScrollableHeatmap(context, controller);
            }),
          ),
        ],
      ),
    );
  }

  /// 构建可滚动的热力图，包含月份标签和网格
  Widget _buildScrollableHeatmap(BuildContext context, SnapshotHeatmapController controller) {
    final currentYear = controller.currentYear.value;
    final weeks = _getWeeksInYear(currentYear);
    
    // 计算热力图的总宽度，确保有足够空间
    const cellWidth = 13.0; // 每个单元格宽度 (11 + 2 边距)
    double totalWidth = weeks.length * cellWidth + 20; // 额外添加20像素的安全边距
    
    return SizedBox(
      height: 140, // 增加高度以容纳月份标签
      child: SingleChildScrollView(
        controller: controller.scrollController,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 月份标签
              Container(
                height: 20,
                width: totalWidth,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withAlpha(50),
                      width: 1,
                    ),
                  ),
                ),
                child: _buildMonthLabels(context, currentYear, weeks.length, cellWidth),
              ),
              const SizedBox(height: 4),
              // 热力图网格
              _buildHeatmapGrid(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建月份标签
  Widget _buildMonthLabels(BuildContext context, int year, int totalWeeks, double cellWidth) {
    // 创建一个Map来存储每个月的起始周
    Map<int, int> monthStartWeeks = {};
    
    // 获取年初第一天是星期几 (0 = 周日, 6 = 周六)
    final firstDayOfYear = DateTime(year, 1, 1);
    int firstDayOfYearWeekday = firstDayOfYear.weekday % 7;
    
    // 计算每个月的起始周
    for (int month = 1; month <= 12; month++) {
      final firstDayOfMonth = DateTime(year, month, 1);
      int daysSinceYearStart = firstDayOfMonth.difference(firstDayOfYear).inDays;
      int weekOfYear = ((daysSinceYearStart + firstDayOfYearWeekday) / 7).floor();
      monthStartWeeks[month] = weekOfYear;
    }
    
    // 构建月份标签
    List<Widget> monthLabels = [];
    for (int month = 1; month <= 12; month++) {
      int startWeek = monthStartWeeks[month]!;
      
      // 计算标签位置
      double leftPosition = startWeek * cellWidth;
      
      monthLabels.add(
        Positioned(
          left: leftPosition,
          top: 0,
          child: Text(
            '$month月',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
      
      // 添加月份分隔线
      if (month < 12) {
        monthLabels.add(
          Positioned(
            left: leftPosition - 0.5,
            top: 12,
            bottom: 0,
            child: Container(
              width: 1,
              color: Colors.grey.withAlpha(30),
            ),
          ),
        );
      }
    }
    
    return Stack(children: monthLabels);
  }

  /// 构建热力图网格
  Widget _buildHeatmapGrid(BuildContext context, SnapshotHeatmapController controller) {
    final currentYear = controller.currentYear.value;
    final weeks = _getWeeksInYear(currentYear);
    
    return Row(
      mainAxisSize: MainAxisSize.min, // 使用最小所需宽度
      crossAxisAlignment: CrossAxisAlignment.start,
      children: weeks.map((week) => _buildWeekColumn(context, controller, week)).toList(),
    );
  }

  /// 构建一周的列
  Widget _buildWeekColumn(BuildContext context, SnapshotHeatmapController controller, List<DateTime> week) {
    // 计算当前周索引
    final now = DateTime.now();
    final firstDayOfYear = DateTime(controller.currentYear.value, 1, 1);
    final firstWeekday = firstDayOfYear.weekday % 7;
    
    // 计算这一周的索引
    final weekStartDate = week.first;
    int weekIndex = 0;
    if (weekStartDate.year == controller.currentYear.value) {
      weekIndex = ((weekStartDate.difference(firstDayOfYear).inDays + firstWeekday) / 7).floor();
    }
    
    // 判断是否是当前周
    final startOfYear = DateTime(now.year, 1, 1);
    final currentWeekOfYear = (now.difference(startOfYear).inDays / 7).floor();
    final isCurrentWeek = controller.currentYear.value == now.year && weekIndex == currentWeekOfYear;
    
    // 使用GlobalKey标记当前周，用于滚动
    final columnKey = isCurrentWeek ? GlobalKey() : null;
    
    if (isCurrentWeek) {
      // 注册当前周的位置
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final renderBox = columnKey?.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero).dx;
          controller.registerWeekPosition(weekIndex, position);
        }
      });
    }
    
    return SizedBox(
      width: 13, // 固定宽度为13 (11宽 + 2边距)
      child: Column(
        key: columnKey,
        children: week.map((date) => _buildDayCell(context, controller, date)).toList(),
      ),
    );
  }

  /// 构建单日格子
  Widget _buildDayCell(BuildContext context, SnapshotHeatmapController controller, DateTime date) {
    if (date.year != controller.currentYear.value) {
      return Container(
        width: 11,
        height: 11,
        margin: const EdgeInsets.all(1),
      );
    }
    
    final hasSnapshot = controller.hasSnapshotOnDate(date);
    final isToday = _isToday(date);
    final isFuture = date.isAfter(DateTime.now());
    
    Color cellColor;
    if (isFuture) {
      cellColor = Colors.grey[200]!;
    } else if (hasSnapshot) {
      cellColor = Theme.of(context).primaryColor.withAlpha(204); // ~0.8 alpha
    } else {
      cellColor = Colors.grey[300]!;
    }
    
    return Container(
      width: 11,
      height: 11,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(2),
        border: isToday ? Border.all(color: Colors.orange, width: 1) : null,
      ),
      child: Tooltip(
        message: DateFormat('yyyy-MM-dd').format(date) + (hasSnapshot ? ' (有快照)' : ' (无快照)'),
        child: const SizedBox.expand(),
      ),
    );
  }

  /// 获取一年中的所有周
  List<List<DateTime>> _getWeeksInYear(int year) {
    final firstDay = DateTime(year, 1, 1);
    final lastDay = DateTime(year, 12, 31);
    
    // 找到第一周的开始（周日）
    final firstSunday = firstDay.subtract(Duration(days: firstDay.weekday % 7));
    
    List<List<DateTime>> weeks = [];
    DateTime currentSunday = firstSunday;
    
    while (!currentSunday.isAfter(lastDay)) {
      List<DateTime> week = [];
      for (int i = 0; i < 7; i++) {
        week.add(currentSunday.add(Duration(days: i)));
      }
      weeks.add(week);
      currentSunday = currentSunday.add(const Duration(days: 7));
    }
    
    return weeks;
  }

  /// 检查是否是今天
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
} 