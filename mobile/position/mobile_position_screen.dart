import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/mobile/base/mobile_base_page.dart';
import 'package:trade_flex/core/controllers/position/positon_screen_controller.dart';
import 'package:trade_flex/core/controllers/position/position_grid_controller.dart';
import 'package:trade_flex/core/utils/theme_helper.dart';
import 'package:trade_flex/mobile/position/widgets/mobile_position_list.dart';

/// 移动端持仓屏幕组件
class MobilePositionScreen extends MobileBasePage {
  /// 持仓页面构造函数
  MobilePositionScreen({
    super.key,
  }) : super(
    title: '持仓',
    pageIndex: 1,
    contentBuilder: (context) => _buildPositionContent(context),
  );
  
  /// 构建持仓页面内容
  static Widget _buildPositionContent(BuildContext context) {
    return GetBuilder<PositionScreenController>(
      builder: (screenController) {
        // 检查是否有投资组合
        if (!screenController.hasPortfolios.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '暂无投资组合',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '请先创建一个投资组合查看持仓信息',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        // 获取PositionGridController
        final gridController = Get.find<PositionGridController>();
        
        return Column(
          children: [
            // 表头和操作按钮
            _buildHeader(context, gridController),
            const SizedBox(height: 6),
            // 选项卡
            _buildTabBar(context, gridController),
            const SizedBox(height: 6),
            // 持仓列表内容
            Expanded(
              child: _buildTabBarView(context, gridController),
            ),
          ],
        );
      },
    );
  }
  
  /// 构建表头
  static Widget _buildHeader(BuildContext context, PositionGridController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: ThemeHelper.getPrimaryColor(context),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => Text(
                    controller.portfolioName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ThemeHelper.getPrimaryColor(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  )),
                ),
              ],
            ),
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
  static Widget _buildTabBar(BuildContext context, PositionGridController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Obx(() {
        return DefaultTabController(
          length: 2,
          initialIndex: controller.currentTabIndex,
          child: TabBar(
            onTap: (index) {
              controller.setCurrentTabIndex(index);
            },
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('多头持仓'),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: ThemeHelper.getPrimaryColor(context).withAlpha(50),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${controller.longRows.length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeHelper.getPrimaryColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('空头持仓'),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: ThemeHelper.getPrimaryColor(context).withAlpha(50),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${controller.shortRows.length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeHelper.getPrimaryColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            labelColor: ThemeHelper.getPrimaryColor(context),
            unselectedLabelColor: ThemeHelper.getPrimaryColor(context).withAlpha(100),
            indicatorColor: ThemeHelper.getPrimaryColor(context),
            labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontSize: 14),
          ),
        );
      }),
    );
  }
  
  /// 构建选项卡内容视图
  static Widget _buildTabBarView(BuildContext context, PositionGridController controller) {
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