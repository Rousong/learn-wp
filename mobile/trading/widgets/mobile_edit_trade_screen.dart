import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:trade_flex/core/constants/trading_transactions_enums.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/controllers/trading/edit_trade_controller.dart';

/// 移动端交易编辑屏幕
class MobileEditTradeScreen extends StatelessWidget {
  final TradingTransaction trade;
  final Function(TradingTransaction) onTradeUpdated;
  final VoidCallback? onShowOverlay;
  final Function(bool)? onHideOverlay;

  const MobileEditTradeScreen({
    super.key,
    required this.trade,
    required this.onTradeUpdated,
    this.onShowOverlay,
    this.onHideOverlay,
  });

  @override
  Widget build(BuildContext context) {
    // 使用 Get.put 来创建和查找 EditTradeController 实例
    final EditTradeController controller = Get.put(
      EditTradeController(
        originalTrade: trade,
        onTradeUpdated: onTradeUpdated,
        onShowOverlay: onShowOverlay,
        onHideOverlay: onHideOverlay,
      ),
      tag: trade.id.toString(),
    );

    // 判断是否为股息记录
    final bool isDividendTrade = trade.operate == TradeOperate.dividend;
    
    // 判断是否为兑换交易
    final bool isSwapTrade =
        trade.operate == TradeOperate.swapFrom || trade.operate == TradeOperate.swapTo;

    // 获取交易类型相关信息
    String operateText;
    IconData operateIcon;
    Color operateColor;

    switch (trade.operate) {
      case TradeOperate.openLong:
        operateText = '做多';
        operateIcon = Icons.trending_up;
        operateColor = Colors.green;
        break;
      case TradeOperate.closeLong:
        operateText = '平多';
        operateIcon = Icons.call_made;
        operateColor = Colors.blue;
        break;
      case TradeOperate.openShort:
        operateText = '做空';
        operateIcon = Icons.trending_down;
        operateColor = Colors.red;
        break;
      case TradeOperate.closeShort:
        operateText = '平空';
        operateIcon = Icons.call_received;
        operateColor = Colors.orange;
        break;
      case TradeOperate.swapFrom:
        operateText = '兑换买入';
        operateIcon = Icons.swap_horiz;
        operateColor = Colors.purple;
        break;
      case TradeOperate.swapTo:
        operateText = '兑换卖出';
        operateIcon = Icons.swap_horiz;
        operateColor = Colors.purple;
        break;
      case TradeOperate.dividend:
        operateText = '股息';
        operateIcon = Icons.payments_outlined;
        operateColor = Colors.teal;
        break;
      default:
        operateText = '其他';
        operateIcon = Icons.help_outline;
        operateColor = Colors.grey;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '编辑交易记录',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          // 保存按钮
          Obx(() => TextButton(
                onPressed: controller.isSubmitting.value ? null : controller.handleUpdateTrade,
                child: controller.isSubmitting.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.onPrimary,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        '保存',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              )),
        ],
      ),
      body: Form(
        key: controller.formKey,
        child: Column(
          children: [
            // 交易类型信息栏
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: operateColor.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(operateIcon, color: operateColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        operateText,
                        style: TextStyle(
                          color: operateColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'ID: ${trade.id}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  // 兑换交易提示
                  if (isSwapTrade) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange.shade600, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '提示: 您正在编辑兑换交易的一部分。请记得检查并手动修改对应的另一部分交易记录以保持数据一致。',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // 主要内容区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 基础信息卡片
                    _buildMobileFormCard(
                      context: context,
                      title: '基本信息',
                      icon: Icons.info_outline,
                      child: isDividendTrade 
                          ? _buildMobileDividendBasicInfo(context, controller)
                          : _buildMobileBasicInfo(context, controller, isSwapTrade),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 主观情绪卡片 (非股息记录才显示)
                    if (!isDividendTrade) ...[
                      _buildMobileFormCard(
                        context: context,
                        title: '主观情绪',
                        icon: Icons.psychology_outlined,
                        child: _buildMobileFearGreedIndexSlider(context, controller),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // 附加信息卡片
                    _buildMobileFormCard(
                      context: context,
                      title: '附加信息',
                      icon: Icons.note_alt_outlined,
                      child: _buildMobileAdditionalInfo(context, controller, isDividendTrade),
                    ),
                    
                    // 底部安全区域
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 移动端专用组件 --- //

  /// 移动端表单卡片
  Widget _buildMobileFormCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  /// 移动端基本信息
  Widget _buildMobileBasicInfo(BuildContext context, EditTradeController controller, bool isSwapTrade) {
    return Column(
      children: [
        // 交易日期
        _buildMobileDatePicker(context, controller, isEnabled: !isSwapTrade),
        const SizedBox(height: 16),
        
        // 代码和价格
        Row(
          children: [
            Expanded(
              child: _buildMobileReadOnlyField(
                context,
                '代码',
                controller.symbolController.text,
                Icons.token,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMobileTextField(
                context,
                controller.priceController,
                '价格',
                true,
                isNumber: true,
                prefixIcon: Icons.attach_money,
                enabled: !isSwapTrade,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 数量
        _buildMobileTextField(
          context,
          controller.amountController,
          '数量',
          true,
          isNumber: true,
          prefixIcon: Icons.numbers,
        ),
        
        const SizedBox(height: 16),
        
        // 当前均价和摊薄均价
        Row(
          children: [
            Expanded(
              child: _buildMobileReadOnlyField(
                context,
                '当前均价',
                trade.nowAvgPrice,
                Icons.price_check,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMobileReadOnlyField(
                context,
                '摊薄均价',
                trade.nowDilutedAvgPrice,
                Icons.price_change,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 移动端股息基本信息
  Widget _buildMobileDividendBasicInfo(BuildContext context, EditTradeController controller) {
    return Column(
      children: [
        // 交易日期
        _buildMobileDatePicker(context, controller, isEnabled: true),
        const SizedBox(height: 16),
        
        // 代码和子持仓
        Row(
          children: [
            Expanded(
              child: _buildMobileReadOnlyField(
                context,
                '代码',
                controller.symbolController.text,
                Icons.token,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMobileReadOnlyField(
                context,
                '子持仓',
                trade.subPositionSymbol,
                Icons.category,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 派息数量和派息金额
        Row(
          children: [
            Expanded(
              child: _buildMobileTextField(
                context,
                controller.amountController,
                '派息数量',
                true,
                isNumber: true,
                prefixIcon: Icons.numbers,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMobileTextField(
                context,
                controller.dividendController,
                '派息金额',
                true,
                isNumber: true,
                prefixIcon: Icons.payments_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 移动端日期选择器
  Widget _buildMobileDatePicker(BuildContext context, EditTradeController controller, {required bool isEnabled}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('交易日期', style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        )),
        const SizedBox(height: 8),
        InkWell(
          onTap: isEnabled ? () => controller.selectDate(context) : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: isEnabled 
                ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
              color: isEnabled ? null : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                      DateFormat('yyyy-MM-dd').format(controller.selectedDate.value),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    )),
                Icon(Icons.calendar_today, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 移动端只读字段
  Widget _buildMobileReadOnlyField(BuildContext context, String label, String value, IconData? icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        )),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 移动端文本输入框
  Widget _buildMobileTextField(
    BuildContext context,
    TextEditingController textController,
    String label,
    bool isRequired, {
    bool isNumber = false,
    String? hint,
    int maxLines = 1,
    IconData? prefixIcon,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: textController,
          enabled: enabled,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            hintText: hint,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 13),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
            ),
          ),
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入$label';
                  }
                  if (isNumber && double.tryParse(value) == null) {
                    return '请输入有效的数字';
                  }
                  return null;
                }
              : (value) {
                  if (isNumber && value != null && value.isNotEmpty && double.tryParse(value) == null) {
                    return '请输入有效的数字';
                  }
                  return null;
                },
        ),
      ],
    );
  }

  /// 移动端恐惧贪婪指数滑块
  Widget _buildMobileFearGreedIndexSlider(BuildContext context, EditTradeController controller) {
    return Obx(() {
      final fearGreedValue = controller.fearGreedIndex.value;

      Color getColorForValue(int value) {
        if (value <= 25) return Colors.red.shade700;
        if (value <= 45) return Colors.orange;
        if (value <= 55) return Colors.yellow.shade600;
        if (value <= 75) return Colors.lightGreen;
        return Colors.green.shade700;
      }

      String getSentimentDescription() {
        if (fearGreedValue <= 25) return "极度恐惧";
        if (fearGreedValue <= 45) return "恐惧";
        if (fearGreedValue <= 55) return "中性";
        if (fearGreedValue <= 75) return "贪婪";
        return "极度贪婪";
      }

      final color = getColorForValue(fearGreedValue);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和当前值
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('恐惧贪婪指数', style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sentiment_satisfied_alt, size: 16, color: color),
                    const SizedBox(width: 4),
                    Text(
                      "${fearGreedValue.toInt()} - ${getSentimentDescription()}",
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 滑块
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              trackShape: const RoundedRectSliderTrackShape(),
              trackHeight: 6.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14.0),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.3),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 28.0),
            ),
            child: Slider(
              value: fearGreedValue.toDouble(),
              min: 0.0,
              max: 100.0,
              divisions: 100,
              onChanged: (value) => controller.updateFearGreedIndex(value.toInt()),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 标签
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('极度恐惧', style: TextStyle(color: Colors.red.shade700, fontSize: 10)),
              const Text('恐惧', style: TextStyle(color: Colors.orange, fontSize: 10)),
              Text('中性', style: TextStyle(color: Colors.yellow.shade600, fontSize: 10)),
              const Text('贪婪', style: TextStyle(color: Colors.lightGreen, fontSize: 10)),
              Text('极度贪婪', style: TextStyle(color: Colors.green.shade700, fontSize: 10)),
            ],
          ),
        ],
      );
    });
  }

  /// 移动端附加信息
  Widget _buildMobileAdditionalInfo(BuildContext context, EditTradeController controller, bool isDividendTrade) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签输入
        _buildMobileTagInput(context, controller),
        
        const SizedBox(height: 16),
        
        // 已选标签显示
        Obx(() {
          if (controller.selectedTags.isEmpty) {
            return const SizedBox.shrink();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                              Text(
                  '已选标签',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.selectedTags.map((tag) {
                  return Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 12)),
                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => controller.removeSelectedTag(tag),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          );
        }),
        
        // 常用标签云
        _buildMobileTagCloud(context, controller),
        
        const SizedBox(height: 16),
        
        // 备注输入
        _buildMobileTextField(
          context,
          controller.descriptionController,
          '备注',
          false,
          hint: '相关备注信息',
          maxLines: 3,
          prefixIcon: Icons.description,
        ),
      ],
    );
  }

  /// 移动端标签输入
  Widget _buildMobileTagInput(BuildContext context, EditTradeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('标签', style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        )),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.tagController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            hintText: '输入标签，用空格分隔',
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 13),
            prefixIcon: Icon(Icons.label, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
            suffixIcon: Obx(() => controller.showAddTagButton.value
                ? IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: controller.addCustomTag,
                    tooltip: '添加标签',
                  )
                : const SizedBox.shrink()),
          ),
        ),
      ],
    );
  }

  /// 移动端标签云
  Widget _buildMobileTagCloud(BuildContext context, EditTradeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('常用标签', style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        )),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.isLoadingTags.value) {
            return const SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (controller.availableTags.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '暂无常用标签',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
              ),
            );
          }
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.availableTags.map((tag) {
                return Obx(() {
                  final isSelected = controller.selectedTags.contains(tag);
                  return InkWell(
                    onTap: () => controller.toggleTagSelection(tag),
                    child: Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 12)),
                      backgroundColor: isSelected
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                          : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
                      ),
                      deleteIcon: Icon(
                        isSelected ? Icons.check : Icons.add,
                        size: 16,
                      ),
                      deleteIconColor: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      onDeleted: () => controller.toggleTagSelection(tag),
                    ),
                  );
                });
              }).toList(),
            ),
          );
        }),
      ],
    );
  }
} 