import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/mobile/base/mobile_base_page.dart';
import 'package:trade_flex/core/controllers/position/positon_screen_controller.dart';
import 'package:trade_flex/mobile/position/widgets/mobile_position_content.dart';

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
      builder: (controller) {
        // 检查是否有投资组合
        if (!controller.hasPortfolios.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return const MobilePositionContent();
      },
    );
  }
} 