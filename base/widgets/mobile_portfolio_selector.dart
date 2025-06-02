import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/base/portfolio_selector_controller.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/constants/portfolio_enums.dart';
import 'package:trade_flex/core/utils/theme_helper.dart';
import 'package:trade_flex/mobile/base/widgets/mobile_create_portfolio_bottom_sheet.dart';

/// 移动端投资组合选择器组件
/// 
/// 显示当前选中的投资组合，并允许用户切换和添加新投资组合
class MobilePortfolioSelector extends GetView<PortfolioSelectorController> {
  const MobilePortfolioSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingPortfolios.value) {
        return Container(
          constraints: const BoxConstraints(maxWidth: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }
      
      if (controller.activePortfolios.isEmpty) {
        return Container(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withValues(alpha:0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '无投资组合',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildAddButton(context),
            ],
          ),
        );
      }
      
      return Container(
        constraints: const BoxConstraints(maxWidth: 200),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withValues(alpha:0.3),
                    width: 1,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: controller.portfolioEventController.selectedPortfolioId.value > 0 ? controller.portfolioEventController.selectedPortfolioId.value : null,
                    isExpanded: true,
                    isDense: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    items: controller.activePortfolios.map((Portfolio portfolio) {
                      return DropdownMenuItem<int>(
                        value: portfolio.id,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getPortfolioIcon(portfolio.portfolioType),
                              size: 14,
                              color: _getPortfolioThemeColor(context, portfolio.portfolioType),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                portfolio.portfolioName,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 4),
                            _getDirectionTag(context, portfolio.direction),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        controller.changeSelectedPortfolio(newValue);
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildAddButton(context),
          ],
        ),
      );
    });
  }

  /// 构建添加按钮
  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCreatePortfolioBottomSheet(context),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  /// 显示创建投资组合的底部弹出页面
  void _showCreatePortfolioBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MobileCreatePortfolioBottomSheet(),
    );
  }

  /// 获取方向标签
  Widget _getDirectionTag(BuildContext context, PortfolioDirection direction) {
    final Color textColor = direction == PortfolioDirection.long
        ? ThemeHelper.getSuccessColor(context)
        : (direction == PortfolioDirection.short 
            ? ThemeHelper.getErrorColor(context) 
            : ThemeHelper.getPrimaryColor(context));
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        direction == PortfolioDirection.long 
            ? '多' 
            : (direction == PortfolioDirection.short ? '空' : '多/空'),
        style: TextStyle(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 获取投资组合图标
  IconData _getPortfolioIcon(PortfolioType type) {
    switch (type) {
      case PortfolioType.stock:
        return Icons.show_chart;
      case PortfolioType.futures:
        return Icons.timeline;
      case PortfolioType.options:
        return Icons.call_split;
      case PortfolioType.crypto:
        return Icons.currency_bitcoin;
      case PortfolioType.forex:
        return Icons.currency_exchange;
      case PortfolioType.cfd:
        return Icons.currency_bitcoin;
      case PortfolioType.indexx:
        return Icons.show_chart;
      case PortfolioType.other:
        return Icons.currency_bitcoin;
    }
  }

  /// 获取投资组合主题颜色
  Color _getPortfolioThemeColor(BuildContext context, PortfolioType type) {
    final Color primaryColor = ThemeHelper.getPrimaryColor(context);
    final Color secondaryColor = ThemeHelper.getSecondaryColor(context);
    final Color tertiaryColor = ThemeHelper.getTertiaryColor(context);
    
    switch (type) {
      case PortfolioType.stock:
        return primaryColor;
      case PortfolioType.futures:
        return secondaryColor;
      case PortfolioType.options:
        return tertiaryColor;
      case PortfolioType.crypto:
        return HSLColor.fromColor(primaryColor)
            .withHue((HSLColor.fromColor(primaryColor).hue + 30) % 360)
            .toColor();
      case PortfolioType.forex:
        return HSLColor.fromColor(primaryColor)
            .withHue((HSLColor.fromColor(primaryColor).hue + 60) % 360)
            .toColor();
      case PortfolioType.cfd:
        return HSLColor.fromColor(primaryColor)
            .withHue((HSLColor.fromColor(primaryColor).hue + 90) % 360)
            .toColor();
      case PortfolioType.indexx:
        return HSLColor.fromColor(primaryColor)
            .withHue((HSLColor.fromColor(primaryColor).hue + 120) % 360)
            .toColor();
      case PortfolioType.other:
        return HSLColor.fromColor(primaryColor)
            .withLightness((HSLColor.fromColor(primaryColor).lightness + 0.1).clamp(0.0, 1.0))
            .toColor();
    }
  }
} 