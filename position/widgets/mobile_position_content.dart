import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/utils/theme_helper.dart';
import 'package:trade_flex/core/controllers/position/position_grid_controller.dart';
import 'package:trade_flex/mobile/position/widgets/mobile_position_list.dart';

/// 移动端持仓内容组件
class MobilePositionContent extends GetView<PositionGridController> {
  const MobilePositionContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 表头和操作按钮
        _buildHeader(context),
        const SizedBox(height: 8),
        // 选项卡
        _buildTabBar(context),
        const SizedBox(height: 8),
        // 持仓列表内容
        Expanded(
          child: _buildTabBarView(context),
        ),
      ],
    );
  }
  
  /// 构建表头
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: ThemeHelper.getPrimaryColor(context),
                size: 24,
              ),
              const SizedBox(width: 8),
              Obx(() => Text(
                controller.portfolioName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ThemeHelper.getPrimaryColor(context),
                ),
              )),
            ],
          ),
          Row(
            children: [
              // 显示已平仓开关
              Row(
                children: [
                  const Text('已平仓', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Obx(() => Switch(
                    value: controller.showClosedPositions,
                    onChanged: (value) {
                      controller.toggleShowClosedPositions(value);
                    },
                    activeColor: ThemeHelper.getPrimaryColor(context),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )),
                ],
              ),
              const SizedBox(width: 8),
              // 刷新最新价格按钮
              Obx(() => IconButton(
                icon: controller.isRefreshOnCooldown 
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.refresh, color: Colors.grey, size: 20),
                        Text(
                          '${controller.cooldownRemainingSeconds}',
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    )
                  : const Icon(Icons.refresh, size: 20),
                tooltip: controller.isRefreshOnCooldown 
                  ? '请等待 ${controller.cooldownRemainingSeconds} 秒'
                  : '刷新最新价格',
                onPressed: controller.isRefreshOnCooldown 
                  ? null 
                  : () {
                      controller.refreshLatestPrices();
                    },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 构建选项卡栏
  Widget _buildTabBar(BuildContext context) {
    return Obx(() {
      return DefaultTabController(
        length: 2,
        initialIndex: controller.currentTabIndex,
        child: TabBar(
          onTap: (index) {
            controller.setCurrentTabIndex(index);
          },
          tabs: const [
            Tab(text: '多头持仓'),
            Tab(text: '空头持仓'),
          ],
          labelColor: ThemeHelper.getPrimaryColor(context),
          unselectedLabelColor: ThemeHelper.getPrimaryColor(context).withAlpha(100),
          indicatorColor: ThemeHelper.getPrimaryColor(context),
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
        ),
      );
    });
  }
  
  /// 构建选项卡内容视图
  Widget _buildTabBarView(BuildContext context) {
    return Obx(() {
      // 显示加载指示器
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      
      // 根据当前选中的选项卡索引显示对应的列表
      return IndexedStack(
        index: controller.currentTabIndex,
        children: [
          // 多头持仓列表
          MobilePositionList(
            positions: controller.longRows,
            isLongPosition: true,
          ),
          // 空头持仓列表
          MobilePositionList(
            positions: controller.shortRows,
            isLongPosition: false,
          ),
        ],
      );
    });
  }
} 