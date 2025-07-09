import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/trading/trading_operator_area_controller.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/constants/portfolio_enums.dart';
import 'package:trade_flex/core/utils/theme_helper.dart';
import 'package:trade_flex/core/widgets/date_picker.dart';

/// 移动端交易操作区域
/// 
/// 基于桌面端实现的移动端交易操作界面，包含常规交易、兑换交易和股息记录功能
/// 采用紧凑布局设计以适应移动端有限空间
class MobileTradingOperationArea extends GetView<TradingOperatorAreaController> {
  const MobileTradingOperationArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 数据加载由MobileTradingScreenController统一管理，这里不需要手动加载
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12), // 减少内边距
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // // 紧凑标题
              // Row(
              //   children: [
              //     Icon(
              //       Icons.trending_up,
              //       color: Theme.of(context).primaryColor,
              //       size: 18, // 缩小图标
              //     ),
              //     const SizedBox(width: 6),
              //     Text(
              //       '交易操作',
              //       style: TextStyle(
              //         fontSize: 16, // 缩小字体
              //         fontWeight: FontWeight.bold,
              //         color: Theme.of(context).primaryColor,
              //       ),
              //     ),
              //   ],
              // ),
              
              // const SizedBox(height: 12), // 减少间距
              
              // 紧凑标签栏
              _buildCompactTabBar(),
              
              const SizedBox(height: 12), // 减少间距
              
              // 标签内容
              _buildCompactTabContent(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建紧凑标签栏
  Widget _buildCompactTabBar() {
    return GetBuilder<TradingOperatorAreaController>(
      builder: (_) {
        return Container(
          height: 32, // 减少高度
          decoration: BoxDecoration(
            color: ThemeHelper.getPrimaryColor(Get.context!).withAlpha(10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TabBar(
            controller: controller.tabController,
            tabs: const [
              Tab(text: '常规交易'),
              Tab(text: '兑换交易'),
              Tab(text: '股息记录'),
            ],
            labelColor: ThemeHelper.getOnPrimaryColor(Get.context!),
            unselectedLabelColor: ThemeHelper.getPrimaryColor(Get.context!).withAlpha(70),
            indicator: BoxDecoration(
              color: ThemeHelper.getPrimaryColor(Get.context!),
              borderRadius: BorderRadius.circular(16),
            ),
            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), // 缩小字体
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            padding: EdgeInsets.zero,
            indicatorSize: TabBarIndicatorSize.tab,
            onTap: (index) {
              // 添加触觉反馈
              HapticFeedback.lightImpact();
            },
          ),
        );
      }
    );
  }

  /// 构建紧凑标签内容
  Widget _buildCompactTabContent() {
    return GetBuilder<TradingOperatorAreaController>(
      builder: (_) {
        // 为了实现自适应高度，我们直接根据当前选中的 tab 索引来显示对应的 widget。
        // 这会禁用 TabBarView 的滑动切换功能，但能让容器高度动态适应内容。
        final List<Widget> tabContents = [
              _buildCompactRegularTradeTab(),
              _buildCompactExchangeTradeTab(),
              _buildCompactDividendTab(),
        ];
        return tabContents[controller.tabController.index];
      },
    );
  }

  /// 紧凑常规交易标签内容
  Widget _buildCompactRegularTradeTab() {
    return Column(
      children: [
        // 第一行：日期和股票代码
        Row(
          children: [
            Expanded(child: _buildCompactDatePicker()),
            const SizedBox(width: 8), // 减少间距
            Expanded(child: _buildCompactSymbolInput()),
          ],
        ),
        
        const SizedBox(height: 10), // 减少间距
        
        // 第二行：子持仓和价格
        Row(
          children: [
            Expanded(child: _buildCompactSubPositionInput()),
            const SizedBox(width: 8),
            Expanded(child: _buildCompactPriceSection()),
          ],
        ),
        
        const SizedBox(height: 10),
        
        // 第三行：数量
        _buildCompactAmountInput(),
        
        const SizedBox(height: 10), // 减少间距
        
        // 交易按钮
        _buildCompactTradeButtons(),
      ],
    );
  }

  /// 紧凑兑换交易标签内容
  Widget _buildCompactExchangeTradeTab() {
    return Column(
      children: [
        // 第一行：日期和汇率显示
        Row(
          children: [
            Expanded(flex: 2, child: _buildCompactDatePicker()),
            const SizedBox(width: 8),
            Expanded(flex: 3, child: _buildCompactExchangeRateInfo()),
          ],
        ),
        
        const SizedBox(height: 10),
        
        // A资产（持有资产）- 一行显示三个输入框
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'A资产（持有）',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
        const SizedBox(height: 6),
        
        Row(
          children: [
            Expanded(child: _buildCompactAssetSelector()),
            const SizedBox(width: 6),
            Expanded(child: _buildCompactSubPositionInput(label: 'A资产子持仓', forceReadOnly: true, hideIcon: true)),
            const SizedBox(width: 6),
            Expanded(child: _buildCompactAmountInput(label: 'A资产数量', hint: '兑出数量', showQuickSelect: false, hideIcon: true)),
          ],
        ),
        
        const SizedBox(height: 10),
        
        // B资产（获得资产）- 一行显示三个输入框
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'B资产（获得）',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(height: 6),
        
        Row(
          children: [
            Expanded(child: _buildCompactSymbolInput(
              label: 'B资产代码',
              textController: controller.assetBController,
              hint: '输入或选择',
              isAssetB: true,
              hideIcon: true,
            )),
            const SizedBox(width: 6),
            Expanded(child: _buildCompactBSubPositionInput(hideIcon: true)),
            const SizedBox(width: 6),
            Expanded(child: _buildCompactAmountInput(
              label: 'B资产数量',
              textController: controller.amountBController,
              hint: '兑入数量',
              showQuickSelect: false,
              hideIcon: true,
            )),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // 兑换按钮
        _buildCompactExchangeButton(),
      ],
    );
  }

  /// 紧凑股息记录标签内容
  Widget _buildCompactDividendTab() {
    return Column(
      children: [
        // 第一行：日期和资产代码
        Row(
          children: [
            Expanded(child: _buildCompactDatePicker()),
            const SizedBox(width: 8),
            Expanded(child: _buildCompactAssetSelector(label: '资产代码')),
          ],
        ),
        
        const SizedBox(height: 10),
        
        // 第二行：子持仓和派息数量
        Row(
          children: [
            Expanded(child: _buildCompactSubPositionInput(label: '子持仓', forceReadOnly: true)),
            const SizedBox(width: 8),
            Expanded(child: _buildCompactAmountInput(
              label: '派息数量',
              hint: '派息数量',
              showQuickSelect: false,
            )),
          ],
        ),
        
        const SizedBox(height: 10),
        
        // 股息金额
        _buildCompactDividendAmountSection(),
        
        const SizedBox(height: 12),
        
        // 股息记录按钮
        _buildCompactDividendButton(),
      ],
    );
  }

  /// 紧凑日期选择器
  Widget _buildCompactDatePicker() {
    return GetBuilder<TradingOperatorAreaController>(
      builder: (_) {
        return CommonDatePicker(
          selectedDate: controller.selectedDate.value,
          onDateChanged: controller.updateSelectedDate,
          label: '交易日期',
        );
      }
    );
  }

  /// 紧凑股票代码输入
  Widget _buildCompactSymbolInput({
    String label = '股票/资产代码',
    TextEditingController? textController,
    String? hint,
    bool isAssetB = false,
    bool hideIcon = false,
  }) {
    final editingController = textController ?? (isAssetB ? controller.assetBController : controller.symbolController);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Container(
          height: 36, // 减少高度，与A资产选择器保持一致
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
            border: Border.all(color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
          children: [
              // 图标
              if (!hideIcon)
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                  child: Icon(Icons.token, size: 16, color: Colors.grey[600]),
                ),
              // 输入框
              Expanded(
                child: GetBuilder<TradingOperatorAreaController>(
              builder: (_) {
                    return TextField(
                  controller: editingController,
                  decoration: InputDecoration(
                        border: InputBorder.none,
                    hintText: hint ?? '输入代码',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 8),
                        isDense: true,
                        contentPadding: hideIcon ? const EdgeInsets.only(left: 10.0) : EdgeInsets.zero,
                        filled: false,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                  ),
                      style: const TextStyle(fontSize: 12),
                  onChanged: (value) => isAssetB 
                      ? controller.updateBSymbol(value)
                      : controller.updateSymbol(value),
                );
              }
            ),
              ),
              // 下拉菜单
              GetBuilder<TradingOperatorAreaController>(
                builder: (_) {
                  return PopupMenuButton<Position>(
                    icon: const Icon(Icons.arrow_drop_down, size: 16),
                    tooltip: '选择持仓',
                    padding: EdgeInsets.zero,
                    onSelected: (Position selection) {
                      if (isAssetB) {
                        controller.selectBPosition(selection);
                      } else {
                        controller.selectPosition(selection);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return controller.positions.map((Position position) {
                        return PopupMenuItem<Position>(
                          value: position,
                          child: Text(position.positionSymbol, style: const TextStyle(fontSize: 12)),
                        );
                      }).toList();
                    },
                  );
                }
            ),
          ],
          ),
        ),
      ],
    );
  }

  /// 紧凑子持仓输入
  Widget _buildCompactSubPositionInput({
    String label = '子持仓(可选)',
    bool forceReadOnly = false,
    bool hideIcon = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
            GetBuilder<TradingOperatorAreaController>(
              builder: (_) {
                final enabled = controller.symbolController.text.isNotEmpty && !forceReadOnly;
            return Container(
              height: 36, // 减少高度，与A资产选择器保持一致
              decoration: BoxDecoration(
                color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
                border: Border.all(color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // 图标
                  if (!hideIcon)
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                      child: Icon(Icons.account_tree_outlined, size: 16, color: Colors.grey[600]),
                    ),
                  // 输入框
                  Expanded(
                    child: TextField(
                      controller: controller.subPositionController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '输入或选择',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 8),
                        isDense: true,
                        contentPadding: hideIcon ? const EdgeInsets.only(left: 10.0) : EdgeInsets.zero,
                        filled: false,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 12),
                      enabled: enabled,
                      readOnly: forceReadOnly,
                    ),
                  ),
                  // 下拉菜单
                  PopupMenuButton<SubPosition>(
                    icon: const Icon(Icons.arrow_drop_down, size: 16),
                    tooltip: '选择子持仓',
                    padding: EdgeInsets.zero,
                    enabled: controller.selectedPosition.value != null &&
                        controller.subPositions.isNotEmpty,
                    onSelected: (SubPosition selection) {
                      controller.selectSubPosition(selection);
                    },
                    itemBuilder: (BuildContext context) {
                      return controller.subPositions.map((SubPosition subPosition) {
                        return PopupMenuItem<SubPosition>(
                          value: subPosition,
                          child: Text(subPosition.subPositionSymbol, style: const TextStyle(fontSize: 12)),
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
                  );
                }
        ),
      ],
    );
  }

  /// 紧凑B资产子持仓输入
  Widget _buildCompactBSubPositionInput({
    bool hideIcon = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('B资产子持仓', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
            GetBuilder<TradingOperatorAreaController>(
              builder: (_) {
            return Container(
              height: 36, // 减少高度，与A资产选择器保持一致
              decoration: BoxDecoration(
                color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
                border: Border.all(color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // 图标
                  if (!hideIcon)
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                      child: Icon(Icons.account_tree_outlined, size: 16, color: Colors.grey[600]),
                    ),
                  // 输入框
                  Expanded(
                    child: TextField(
                      controller: controller.assetBSubPositionController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '输入或选择',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 8),
                        isDense: true,
                        contentPadding: hideIcon ? const EdgeInsets.only(left: 10.0) : EdgeInsets.zero,
                        filled: false,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 12),
                      readOnly: false,
                      enabled: controller.isBSubPositionEnabled.value,
                      onChanged: (_) => controller.updateExchangeRate(),
                    ),
                  ),
                  // 下拉菜单
                  PopupMenuButton<SubPosition>(
                    icon: const Icon(Icons.arrow_drop_down, size: 16),
                    tooltip: '选择B资产子持仓',
                    padding: EdgeInsets.zero,
                    enabled: controller.selectedBPosition.value != null &&
                        controller.subBPositions.isNotEmpty,
                    onSelected: (SubPosition selection) {
                      controller.selectBSubPosition(selection);
                    },
                    itemBuilder: (BuildContext context) {
                      return controller.subBPositions.map((SubPosition subPosition) {
                        return PopupMenuItem<SubPosition>(
                          value: subPosition,
                          child: Text(subPosition.subPositionSymbol, style: const TextStyle(fontSize: 12)),
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
                  );
                }
        ),
      ],
    );
  }

  /// 紧凑价格输入
  Widget _buildCompactPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('价格', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        GetBuilder<TradingOperatorAreaController>(
          builder: (_) {
            return Container(
              height: 36, // 减少高度，与A资产选择器保持一致
              decoration: BoxDecoration(
                color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
                border: Border.all(color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // 图标
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                    child: Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                  ),
                  // 输入框
                  Expanded(
                    child: TextField(
                      controller: controller.priceController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                hintText: controller.isTotal.value ? '总价' : '单价',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 12),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                  ),
                  // 下拉菜单
                  DropdownButton<bool>(
                  value: controller.isTotal.value,
                  underline: Container(),
                  icon: const Icon(Icons.arrow_drop_down, size: 16),
                    padding: EdgeInsets.zero,
                  onChanged: (bool? value) {
                    if (value != null) {
                      controller.updateIsTotal(value);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: false,
                      child: Text('单价', style: TextStyle(fontSize: 10)),
                    ),
                    DropdownMenuItem(
                      value: true,
                      child: Text('总价', style: TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
                ],
              ),
            );
          }
        ),
      ],
    );
  }

  /// 紧凑数量输入
  Widget _buildCompactAmountInput({
    String label = '数量',
    TextEditingController? textController,
    String? hint,
    bool showQuickSelect = true, // 新增参数控制是否显示快选按钮
    bool hideIcon = false,
  }) {
    final editingController = textController ?? controller.amountController;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        // 根据showQuickSelect参数决定布局
        showQuickSelect ? Row(
          children: [
            // 快速选择按钮（占用1/3宽度）
            Expanded(
              flex: 1,
              child: GetBuilder<TradingOperatorAreaController>(
                builder: (_) {
                  final bool isRegularOrAssetA = (textController == null || textController == controller.amountController);
                  final selectedSubPosition = isRegularOrAssetA ? controller.getSelectedSubPosition() : null;
                  
                  return selectedSubPosition != null
                  ? Container(
                      height: 36, // 与输入框保持一致
                      decoration: BoxDecoration(
                        color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
                        border: Border.all(color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: PopupMenuButton<String>(
                        icon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!hideIcon)
                              Icon(Icons.speed, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 2),
                            const Text('快选', style: TextStyle(fontSize: 10)),
                            Icon(Icons.arrow_drop_down, size: 14, color: Colors.grey[600]),
                          ],
                        ),
                        tooltip: '快速选择数量',
                        onSelected: (String selection) {
                          editingController.text = selection;
                          controller.updateExchangeRate();
                        },
                        itemBuilder: (BuildContext context) {
                          final holdCnt = double.tryParse(selectedSubPosition.holdCnt) ?? 0;
                          final options = <PopupMenuItem<String>>[];
                          if (holdCnt > 0) {
                            options.add(PopupMenuItem<String>(
                              value: holdCnt.toString(), 
                              child: Row(
                                children: [
                                  if (!hideIcon)
                                    const Icon(Icons.select_all, size: 16, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Text('全部: ${holdCnt.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11)),
                                ],
                              ),
                            ));
                            final halfAmount = (holdCnt / 2);
                            options.add(PopupMenuItem<String>(
                              value: halfAmount.toStringAsFixed(2), 
                              child: Row(
                                children: [
                                  if (!hideIcon)
                                    const Icon(Icons.pie_chart_outline, size: 16, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Text('一半: ${halfAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11)),
                                ],
                              ),
                            ));
                            final quarterAmount = (holdCnt / 4);
                            options.add(PopupMenuItem<String>(
                              value: quarterAmount.toStringAsFixed(2), 
                              child: Row(
                                children: [
                                  if (!hideIcon)
                                    const Icon(Icons.pie_chart, size: 16, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text('1/4: ${quarterAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11)),
                                ],
                              ),
                            ));
                          }
                          return options.isNotEmpty ? options : [
                            const PopupMenuItem(
                              enabled: false, 
                              child: Row(
                                children: [
                                  Icon(Icons.warning, size: 16, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text('无可用数量', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            )
                          ];
                        },
                      ),
                    )
                  : Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
                        border: Border.all(color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '需选持仓',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    );
                }
              ),
            ),
            
            const SizedBox(width: 6),
            
            // 数量输入框（占用2/3宽度）
            Expanded(
              flex: 2,
              child: GetBuilder<TradingOperatorAreaController>(
                builder: (_) {
                  return Container(
                    height: 36, // 减少高度，与A资产选择器保持一致
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
                      border: Border.all(color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        // 图标
                        if (!hideIcon)
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                            child: Icon(Icons.numbers, size: 16, color: Colors.grey[600]),
                          ),
                        // 输入框
                        Expanded(
                          child: TextField(
                            controller: editingController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: hint ?? '输入数量',
                              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                              isDense: true,
                              contentPadding: hideIcon ? const EdgeInsets.only(left: 12.0) : EdgeInsets.zero,
                              filled: false,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                            style: const TextStyle(fontSize: 12),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => controller.updateExchangeRate(),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              ),
            ),
          ],
        ) : 
        // 不显示快选按钮时，数量输入框占满整行
        GetBuilder<TradingOperatorAreaController>(
          builder: (_) {
            return Container(
              height: 36, // 减少高度，与A资产选择器保持一致
              decoration: BoxDecoration(
                color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
                border: Border.all(color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // 图标
                  if (!hideIcon)
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                      child: Icon(Icons.numbers, size: 16, color: Colors.grey[600]),
                    ),
                  // 输入框
                  Expanded(
                    child: TextField(
                      controller: editingController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: hint ?? '输入数量',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                        isDense: true,
                        contentPadding: hideIcon ? const EdgeInsets.only(left: 12.0) : EdgeInsets.zero,
                        filled: false,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 12),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => controller.updateExchangeRate(),
                    ),
                  ),
                ],
              ),
            );
          }
        ),
      ],
    );
  }

  /// 紧凑资产选择器
  Widget _buildCompactAssetSelector({String label = 'A资产（持有）'}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Container(
          height: 36, // 减少高度
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
            border: Border.all(color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GetBuilder<TradingOperatorAreaController>(
            builder: (_) {
              return DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<Position>(
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, size: 16),
                    hint: const Padding(
                      padding: EdgeInsets.only(left: 12.0),
                      child: Text('选择持有的资产', style: TextStyle(fontSize: 12)),
                    ),
                    value: controller.selectedPosition.value != null && 
                           controller.positions.any((p) => p.id == controller.selectedPosition.value!.id) 
                         ? controller.selectedPosition.value 
                         : null,
                    onChanged: (Position? newValue) {
                      if (newValue != null) {
                        controller.selectPosition(newValue);
                      }
                    },
                    items: controller.positions.map<DropdownMenuItem<Position>>((Position position) {
                      return DropdownMenuItem<Position>(
                        value: position,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text(position.positionSymbol, style: const TextStyle(fontSize: 12)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }
          ),
        ),
      ],
    );
  }

  /// 紧凑股息金额输入
  Widget _buildCompactDividendAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('股息金额', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        GetBuilder<TradingOperatorAreaController>(
          builder: (_) {
            return Container(
              height: 36, // 减少高度，与A资产选择器保持一致
              decoration: BoxDecoration(
                color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
                border: Border.all(color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // 图标
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                    child: Icon(Icons.attach_money, size: 16, color: Colors.teal[600]),
                  ),
                  // 输入框
                  Expanded(
                    child: TextField(
                      controller: controller.priceController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                hintText: controller.isTotal.value ? '股息总额' : '每股派息',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 12),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                  ),
                  // 下拉菜单
                  DropdownButton<bool>(
                  value: controller.isTotal.value,
                  underline: Container(),
                  icon: const Icon(Icons.arrow_drop_down, size: 16),
                    padding: EdgeInsets.zero,
                  onChanged: (bool? value) {
                    if (value != null) {
                      controller.updateIsTotal(value);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: false,
                      child: Text('每股', style: TextStyle(fontSize: 10)),
                    ),
                    DropdownMenuItem(
                      value: true,
                      child: Text('合计', style: TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
                ],
              ),
            );
          }
        ),
      ],
    );
  }

  /// 紧凑交易按钮
  Widget _buildCompactTradeButtons() {
    return Container(
      padding: const EdgeInsets.all(8), // 进一步减少内边距
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: ThemeHelper.getPrimaryColor(Get.context!).withAlpha(5),
        border: Border.all(
          color: ThemeHelper.getPrimaryColor(Get.context!).withAlpha(15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '交易操作',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12, // 缩小字体
            ),
          ),
          const SizedBox(height: 6),
          // 根据投资组合方向动态显示按钮
          Obx(() => _buildTradeButtonsForDirection(controller.portfolioDirection)),
        ],
      ),
    );
  }
  
  /// 根据投资组合方向构建交易按钮
  Widget _buildTradeButtonsForDirection(PortfolioDirection direction) {
    switch (direction) {
      case PortfolioDirection.long:
        // 只做多：显示做多和平多按钮
        return Row(
          children: [
            Expanded(
              child: _buildCompactTradeButton(
                label: '做多',
                icon: Icons.trending_up,
                color: Colors.green,
                onPressed: () => controller.handleTrade('OPEN_LONG'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactTradeButton(
                label: '平多',
                icon: Icons.check_circle_outline,
                color: Colors.blue,
                onPressed: () => controller.handleTrade('CLOSE_LONG'),
              ),
            ),
          ],
        );
      case PortfolioDirection.short:
        // 只做空：显示做空和平空按钮
        return Row(
          children: [
            Expanded(
              child: _buildCompactTradeButton(
                label: '做空',
                icon: Icons.trending_down,
                color: Colors.red,
                onPressed: () => controller.handleTrade('OPEN_SHORT'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactTradeButton(
                label: '平空',
                icon: Icons.highlight_off,
                color: Colors.orange,
                onPressed: () => controller.handleTrade('CLOSE_SHORT'),
              ),
            ),
          ],
        );
      case PortfolioDirection.both:
        // 多空双向：显示全部四个按钮
        return Row(
          children: [
            Expanded(
              child: _buildCompactTradeButton(
                label: '做多',
                icon: Icons.trending_up,
                color: Colors.green,
                onPressed: () => controller.handleTrade('OPEN_LONG'),
              ),
            ),
            const SizedBox(width: 4), // 减少间距
            Expanded(
              child: _buildCompactTradeButton(
                label: '平多',
                icon: Icons.check_circle_outline,
                color: Colors.blue,
                onPressed: () => controller.handleTrade('CLOSE_LONG'),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildCompactTradeButton(
                label: '做空',
                icon: Icons.trending_down,
                color: Colors.red,
                onPressed: () => controller.handleTrade('OPEN_SHORT'),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildCompactTradeButton(
                label: '平空',
                icon: Icons.highlight_off,
                color: Colors.orange,
                onPressed: () => controller.handleTrade('CLOSE_SHORT'),
              ),
            ),
          ],
        );
    }
  }

  /// 紧凑交易按钮
  Widget _buildCompactTradeButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: () {
        // 添加最明显的震动效果
        HapticFeedback.heavyImpact();
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8), // 调整内边距
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6), // 减少圆角
        ),
        elevation: 1, // 减少阴影
        minimumSize: const Size(0, 32), // 稍微增加高度以适应文字
      ),
      child: Text(
            label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), // 增加字体大小
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 紧凑兑换汇率信息
  Widget _buildCompactExchangeRateInfo() {
    return GetBuilder<TradingOperatorAreaController>(
      builder: (_) {
        // 分析汇率字符串并拆分为两行
        String aToB = '等待输入...';
        String bToA = '等待输入...';
        
        // 尝试解析当前汇率字符串
        final rateValue = controller.exchangeRate.value;
        if (rateValue.contains('=') && !rateValue.contains('等待')) {
          final parts = rateValue.split('=');
          if (parts.length >= 2) {
            // 假设格式为"1 A = X B"
            final aSymbol = controller.symbolController.text.isNotEmpty 
              ? controller.symbolController.text 
              : 'A';
            final bSymbol = controller.assetBController.text.isNotEmpty 
              ? controller.assetBController.text 
              : 'B';
              
            // 提取汇率值
            final rateParts = parts[1].trim().split(' ');
            if (rateParts.isNotEmpty) {
              final rate = double.tryParse(rateParts[0]) ?? 0.0;
              if (rate > 0) {
                aToB = "1 $aSymbol = ${rate.toStringAsFixed(4)} $bSymbol";
                bToA = "1 $bSymbol = ${(1/rate).toStringAsFixed(4)} $aSymbol";
              }
            }
          }
        }
        
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withAlpha(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.swap_horiz, color: Colors.orange.shade700, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '兑换比率',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // A 兑换 B 比率
              Text(
                aToB,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.orange.shade700,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              // B 兑换 A 比率
              Text(
                bToA,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.orange.shade700,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }
    );
  }

  /// 紧凑兑换按钮
  Widget _buildCompactExchangeButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(() {
        return ElevatedButton.icon(
          onPressed: controller.canExchange.value 
            ? () {
                // 添加最明显的震动效果
                HapticFeedback.heavyImpact();
                controller.handleTrade('EXCHANGE');
              }
            : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12), // 减少内边距
            disabledBackgroundColor: const Color.fromARGB(255, 226, 168, 236),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 1,
          ),
          icon: const Icon(Icons.swap_horiz, size: 16), // 缩小图标
          label: const Text(
            '执行兑换交易',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), // 缩小字体
          ),
        );
      }),
    );
  }

  /// 紧凑股息记录按钮
  Widget _buildCompactDividendButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // 添加最明显的震动效果
          HapticFeedback.heavyImpact();
          controller.handleTrade('DIVIDEND');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 1,
        ),
        icon: const Icon(Icons.savings, size: 16, color: Colors.white),
        label: const Text(
          '记录股息',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}