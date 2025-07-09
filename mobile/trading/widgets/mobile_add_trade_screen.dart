import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:trade_flex/core/constants/trading_transactions_enums.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/controllers/trading/add_trade_controller.dart';

/// 移动端交易添加屏幕
class MobileAddTradeScreen extends StatefulWidget {
  final Function(TradingTransaction) onTradeAdded;
  final int portfolioId;

  const MobileAddTradeScreen({
    super.key,
    required this.onTradeAdded,
    required this.portfolioId,
  });

  @override
  State<MobileAddTradeScreen> createState() => _MobileAddTradeScreenState();
}

class _MobileAddTradeScreenState extends State<MobileAddTradeScreen>
    with SingleTickerProviderStateMixin {
  late AddTradeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AddTradeController(
      onTradeAdded: widget.onTradeAdded,
      portfolioId: widget.portfolioId,
    ));
    controller.initTabController(this);
  }

  @override
  void dispose() {
    controller.tabController.dispose();
    Get.delete<AddTradeController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '添加交易记录',
          style: TextStyle(color: colorScheme.onPrimary),
        ),
        backgroundColor: theme.primaryColor,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: controller.handleAddTrade,
            child: Text(
              '添加',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: controller.formKey,
        child: Column(
          children: [
            // Tab 区域
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: controller.tabController,
                tabs: const [
                  Tab(text: '常规交易'),
                  Tab(text: '兑换交易'),
                  Tab(text: '股息记录'),
                ],
                labelColor: colorScheme.onPrimary,
                unselectedLabelColor: colorScheme.onSurface,
                indicator: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontSize: 14),
                dividerColor: Colors.transparent,
              ),
            ),
            
            // 表单区域
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: [
                  _buildRegularTradeForm(),
                  _buildExchangeTradeForm(),
                  _buildDividendForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 常规交易表单
  Widget _buildRegularTradeForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMobileFormCard(
            title: '基本信息',
            icon: Icons.info_outline,
            child: Column(
              children: [
                _buildMobileDatePicker(),
                const SizedBox(height: 16),
                _buildMobileTradeTypeSelector(),
                const SizedBox(height: 16),
                _buildMobileSymbolInput(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildMobilePriceField()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMobileAmountField()),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMobileSubPositionInput(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildMobileFearGreedSection(),
          const SizedBox(height: 16),
          _buildMobileAdditionalInfoSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 兑换交易表单
  Widget _buildExchangeTradeForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMobileFormCard(
            title: '兑换信息',
            icon: Icons.swap_horiz,
            child: Column(
              children: [
                _buildMobileDatePicker(),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildMobileExchangeAssets(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildMobileFearGreedSection(),
          const SizedBox(height: 16),
          _buildMobileAdditionalInfoSection(isExchange: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 股息记录表单
  Widget _buildDividendForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMobileFormCard(
            title: '股息信息',
            icon: Icons.payments_outlined,
            child: Column(
              children: [
                _buildMobileDatePicker(),
                const SizedBox(height: 16),
                _buildMobileSymbolInput(readOnly: true),
                const SizedBox(height: 16),
                _buildMobileSubPositionInput(readOnly: true, required: true),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildMobileAmountField()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMobileDividendAmountField()),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildMobileAdditionalInfoSection(isDividend: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 移动端表单卡片
  Widget _buildMobileFormCard({
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

  // 移动端日期选择器
  Widget _buildMobileDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('交易日期', style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        )),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => controller.selectDate(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(8),
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

  // 移动端交易类型选择器
  Widget _buildMobileTradeTypeSelector() {
    final tradeTypes = <TradeOperate, Map<String, dynamic>>{
      TradeOperate.openLong: {
        'text': '做多',
        'icon': Icons.trending_up,
        'color': Colors.green,
      },
      TradeOperate.closeLong: {
        'text': '平多',
        'icon': Icons.call_made,
        'color': Colors.blue,
      },
      TradeOperate.openShort: {
        'text': '做空',
        'icon': Icons.trending_down,
        'color': Colors.red,
      },
      TradeOperate.closeShort: {
        'text': '平空',
        'icon': Icons.call_received,
        'color': Colors.orange,
      },
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('交易类型', style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        )),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Obx(() => DropdownButtonFormField<TradeOperate>(
                value: controller.selectedOperate.value,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                items: tradeTypes.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Row(
                      children: [
                        Icon(
                          entry.value['icon'] as IconData,
                          color: entry.value['color'] as Color,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.value['text'] as String,
                          style: TextStyle(
                            color: entry.value['color'] as Color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: controller.updateTradeOperate,
                icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                dropdownColor: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              )),
        ),
      ],
    );
  }

  // 移动端股票代码输入
  Widget _buildMobileSymbolInput({bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '股票/资产代码',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.isLoadingPositions.value) {
            return const SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final List<Position> currentPositions = controller.positions.toList();

          return Stack(
            children: [
              TextFormField(
                controller: controller.symbolController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintText: readOnly ? '请选择资产' : '例如: AAPL, BTC',
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 13),
                  prefixIcon: Icon(Icons.token, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
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
                ),
                enabled: !readOnly,
                validator: (value) {
                  if (readOnly) {
                    if (controller.selectedPosition.value == null) {
                      return '请选择资产';
                    }
                    return null;
                  }
                  if (value == null || value.isEmpty) {
                    return '请输入股票/资产代码';
                  }
                  return null;
                },
              ),
              if (currentPositions.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: PopupMenuButton<Position>(
                    icon: const Icon(Icons.arrow_drop_down),
                    tooltip: '选择持仓',
                    onSelected: controller.onPositionSelected,
                    itemBuilder: (BuildContext context) {
                      return currentPositions.map((Position position) {
                        return PopupMenuItem<Position>(
                          value: position,
                          child: Text(position.positionSymbol),
                        );
                      }).toList();
                    },
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  // 移动端价格字段
  Widget _buildMobilePriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '价格',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.priceController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            hintText: '输入价格',
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 13),
            prefixIcon: Icon(Icons.attach_money, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
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
            suffixIcon: Obx(() => DropdownButton<bool>(
                  value: controller.isTotal.value,
                  underline: Container(),
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  onChanged: controller.updatePriceType,
                  items: const [
                    DropdownMenuItem(
                      value: false,
                      child: Text('单价', style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem(
                      value: true,
                      child: Text('总价', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                )),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入价格';
            }
            if (double.tryParse(value) == null) {
              return '请输入有效的数字';
            }
            return null;
          },
        ),
      ],
    );
  }

  // 移动端数量字段
  Widget _buildMobileAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '数量',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.amountController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            hintText: '交易数量',
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 13),
            prefixIcon: Icon(Icons.numbers, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
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
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入数量';
            }
            if (double.tryParse(value) == null) {
              return '请输入有效的数字';
            }
            return null;
          },
        ),
      ],
    );
  }

  // 移动端子持仓输入
  Widget _buildMobileSubPositionInput({bool readOnly = false, bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '子持仓',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          final bool subPositionEnabled = controller.isSubPositionEnabled.value;
          final List<SubPosition> currentSubPositions = controller.subPositions.toList();

          return Stack(
            children: [
              TextFormField(
                controller: controller.subPositionController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintText: readOnly
                      ? (required ? '请选择子持仓' : '请选择子持仓 (可选)')
                      : '可选，用于区分不同批次',
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 13),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                  filled: !subPositionEnabled || readOnly,
                  fillColor: (!subPositionEnabled || readOnly) ? Theme.of(context).colorScheme.surfaceContainerHighest : null,
                ),
                enabled: !readOnly && subPositionEnabled,
                validator: required
                    ? (value) {
                        if (value == null || value.isEmpty) {
                          return '请选择子持仓';
                        }
                        return null;
                      }
                    : null,
              ),
              if (subPositionEnabled && currentSubPositions.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: PopupMenuButton<SubPosition>(
                    icon: const Icon(Icons.arrow_drop_down),
                    tooltip: '选择子持仓',
                    onSelected: controller.onSubPositionSelected,
                    itemBuilder: (BuildContext context) {
                      return currentSubPositions.map((SubPosition subPosition) {
                        return PopupMenuItem<SubPosition>(
                          value: subPosition,
                          child: Text(subPosition.subPositionSymbol),
                        );
                      }).toList();
                    },
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  // 移动端恐惧贪婪指数部分
  Widget _buildMobileFearGreedSection() {
    return _buildMobileFormCard(
      title: '主观情绪',
      icon: Icons.psychology_outlined,
      child: _buildMobileFearGreedSlider(),
    );
  }

  // 移动端恐惧贪婪指数滑块
  Widget _buildMobileFearGreedSlider() {
    return Obx(() {
      final fearGreedValue = controller.fearGreedIndex.value;

      Color getColorForValue(double value) {
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
              value: fearGreedValue,
              min: 0.0,
              max: 100.0,
              divisions: 100,
              onChanged: controller.updateFearGreedIndex,
            ),
          ),
          const SizedBox(height: 8),
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

  // 移动端附加信息部分
  Widget _buildMobileAdditionalInfoSection({bool isExchange = false, bool isDividend = false}) {
    TextEditingController descriptionController;
    if (isExchange) {
      descriptionController = controller.descriptionSwapController;
    } else if (isDividend) {
      descriptionController = controller.descriptionDividendController;
    } else {
      descriptionController = controller.descriptionController;
    }

    return _buildMobileFormCard(
      title: '附加信息',
      icon: Icons.note_alt_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标签输入
          _buildMobileTagInput(),
          const SizedBox(height: 16),
          // 已选标签显示
          Obx(() {
            if (controller.selectedTags.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '已选标签',
                  style: TextStyle(fontWeight: FontWeight.w500),
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
          _buildMobileTagCloud(),
          const SizedBox(height: 16),
          // 备注输入
          _buildMobileTextField(
            descriptionController,
            '备注',
            false,
            hint: '相关备注信息',
            maxLines: 3,
            prefixIcon: Icons.description,
          ),
        ],
      ),
    );
  }

  // 移动端标签输入
  Widget _buildMobileTagInput() {
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
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
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

  // 移动端标签云
  Widget _buildMobileTagCloud() {
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
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
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
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
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

  // 移动端通用文本字段
  Widget _buildMobileTextField(
    TextEditingController textController,
    String label,
    bool isRequired, {
    bool isNumber = false,
    String? hint,
    int maxLines = 1,
    IconData? prefixIcon,
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

  // 移动端兑换资产部分
  Widget _buildMobileExchangeAssets() {
    return Column(
      children: [
        // 兑出资产 A
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '兑出资产 (A)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              _buildMobileSymbolInput(readOnly: true),
              const SizedBox(height: 12),
              _buildMobileSubPositionInput(readOnly: true),
              const SizedBox(height: 12),
              _buildMobileTextField(
                controller.amountAController,
                'A资产数量',
                true,
                isNumber: true,
                hint: '兑出数量',
                prefixIcon: Icons.numbers,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 兑换图标
        Center(
          child: Icon(
            Icons.swap_vert,
            size: 32,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        // 兑入资产 B
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '兑入资产 (B)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              _buildMobileAssetBInput(),
              const SizedBox(height: 12),
              _buildMobileSubPositionBInput(),
              const SizedBox(height: 12),
              _buildMobileTextField(
                controller.amountBController,
                'B资产数量',
                true,
                isNumber: true,
                hint: '兑入数量',
                prefixIcon: Icons.numbers,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 移动端资产B输入
  Widget _buildMobileAssetBInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('资产B代码', style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            )),
            Text(' *', style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.isLoadingPositions.value) {
            return const SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final List<Position> currentPositions = controller.positions.toList();

          return Stack(
            children: [
              TextFormField(
                controller: controller.assetBController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintText: '输入或选择资产B',
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 13),
                  prefixIcon: Icon(Icons.currency_exchange, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
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
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入或选择资产B代码';
                  }
                  return null;
                },
              ),
              if (currentPositions.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: PopupMenuButton<Position>(
                    icon: const Icon(Icons.arrow_drop_down),
                    tooltip: '选择已有资产',
                    onSelected: controller.onAssetBSelected,
                    itemBuilder: (BuildContext context) {
                      return currentPositions.map((Position position) {
                        return PopupMenuItem<Position>(
                          value: position,
                          child: Text(position.positionSymbol),
                        );
                      }).toList();
                    },
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  // 移动端资产B子持仓输入
  Widget _buildMobileSubPositionBInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('子持仓 (资产B)', style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        )),
        const SizedBox(height: 8),
        Obx(() {
          final bool loading = controller.isLoadingSubPositionsB.value;
          final bool enabled = controller.isSubPositionBEnabled.value;
          final List<SubPosition> currentSubBPositions = controller.subPositionsB.toList();

          return Stack(
            children: [
              TextFormField(
                controller: controller.assetBSubPositionController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintText: enabled ? '输入或选择子持仓' : '先输入资产B代码',
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 13),
                  prefixIcon: Icon(Icons.layers, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                  filled: !enabled || loading,
                  fillColor: (!enabled || loading) ? Theme.of(context).colorScheme.surfaceContainerHighest : null,
                ),
                enabled: enabled && !loading,
              ),
              if (loading)
                const Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (enabled && currentSubBPositions.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: PopupMenuButton<SubPosition>(
                    icon: const Icon(Icons.arrow_drop_down),
                    tooltip: '选择已有子持仓',
                    onSelected: controller.onSubPositionBSelected,
                    itemBuilder: (BuildContext context) {
                      return currentSubBPositions.map((SubPosition subPosition) {
                        return PopupMenuItem<SubPosition>(
                          value: subPosition,
                          child: Text(subPosition.subPositionSymbol),
                        );
                      }).toList();
                    },
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  // 移动端股息金额字段
  Widget _buildMobileDividendAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '股息金额',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.amountDividendController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            hintText: '输入股息金额',
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 13),
            prefixIcon: Icon(Icons.attach_money, size: 18, color: Colors.teal[600]),
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
            suffixIcon: Obx(() => DropdownButton<bool>(
                  value: controller.isTotal.value,
                  underline: Container(),
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  onChanged: controller.updatePriceType,
                  items: const [
                    DropdownMenuItem(
                      value: false,
                      child: Text('每股派息', style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem(
                      value: true,
                      child: Text('总金额', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                )),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入股息金额';
            }
            if (double.tryParse(value) == null) {
              return '请输入有效的数字';
            }
            return null;
          },
        ),
      ],
    );
  }
} 