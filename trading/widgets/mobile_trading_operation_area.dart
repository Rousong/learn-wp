import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/trading/trading_operator_area_controller.dart';
import 'package:trade_flex/core/database/database.dart';
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
              // 紧凑标题
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: Theme.of(context).primaryColor,
                    size: 18, // 缩小图标
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '交易操作',
                    style: TextStyle(
                      fontSize: 16, // 缩小字体
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12), // 减少间距
              
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
          ),
        );
      }
    );
  }

  /// 构建紧凑标签内容
  Widget _buildCompactTabContent() {
    return GetBuilder<TradingOperatorAreaController>(
      builder: (_) {
        // 增加高度以避免溢出
        double height;
        switch (controller.tabController.index) {
          case 1: // 兑换交易
            height =360; // 从320增加到380
            break;
          case 2: // 股息记录
            height = 300; // 从260增加到300
            break;
          default: // 常规交易
            height = 360; // 从250增加到280
        }
        
        return SizedBox(
          height: height,
          child: TabBarView(
            controller: controller.tabController,
            children: [
              _buildCompactRegularTradeTab(),
              _buildCompactExchangeTradeTab(),
              _buildCompactDividendTab(),
            ],
          ),
        );
      }
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
            Expanded(child: _buildCompactSubPositionInput(label: 'A资产子持仓', forceReadOnly: true)),
            const SizedBox(width: 6),
            Expanded(child: _buildCompactAmountInput(label: 'A资产数量', hint: '兑出数量')),
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
              hint: '输入获得的资产代码',
              isAssetB: true,
            )),
            const SizedBox(width: 6),
            Expanded(child: _buildCompactBSubPositionInput()),
            const SizedBox(width: 6),
            Expanded(child: _buildCompactAmountInput(
              label: 'B资产数量',
              textController: controller.amountBController,
              hint: '兑入数量',
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
  }) {
    final editingController = textController ?? (isAssetB ? controller.assetBController : controller.symbolController);
    final primaryColor = ThemeHelper.getPrimaryColor(Get.context!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)), // 缩小字体
        const SizedBox(height: 4), // 减少间距
        Stack(
          children: [
            GetBuilder<TradingOperatorAreaController>(
              builder: (_) {
                return TextFormField(
                  controller: editingController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), // 减少圆角
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // 减少内边距
                    hintText: hint ?? '输入代码',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12), // 缩小字体
                    prefixIcon: Icon(Icons.token, size: 16, color: Colors.grey[600]), // 缩小图标
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red.shade400),
                    ),
                    isDense: true, // 启用紧凑模式
                  ),
                  style: const TextStyle(fontSize: 12), // 缩小输入文字
                  onChanged: (value) => isAssetB 
                      ? controller.updateBSymbol(value)
                      : controller.updateSymbol(value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入代码';
                    }
                    return null;
                  },
                );
              }
            ),
            Positioned(
              right: 4,
              top: 4,
              bottom: 4,
              child: GetBuilder<TradingOperatorAreaController>(
                builder: (_) {
                  return PopupMenuButton<Position>(
                    icon: const Icon(Icons.arrow_drop_down, size: 16), // 缩小图标
                    tooltip: '选择持仓',
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
            ),
          ],
        ),
      ],
    );
  }

  /// 紧凑子持仓输入
  Widget _buildCompactSubPositionInput({
    String label = '子持仓(可选)',
    bool forceReadOnly = false,
  }) {
    final primaryColor = ThemeHelper.getPrimaryColor(Get.context!);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Stack(
          children: [
            GetBuilder<TradingOperatorAreaController>(
              builder: (_) {
                final enabled = controller.symbolController.text.isNotEmpty && !forceReadOnly;
                return TextFormField(
                  controller: controller.subPositionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    hintText: '输入或选择',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                    prefixIcon: Icon(Icons.account_tree_outlined, size: 16, color: Colors.grey[600]),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    filled: !enabled,
                    fillColor: !enabled ? Colors.grey.shade100 : null,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 12),
                  enabled: enabled,
                  readOnly: forceReadOnly,
                );
              }
            ),
            Positioned(
              right: 4,
              top: 4,
              bottom: 4,
              child: GetBuilder<TradingOperatorAreaController>(
                builder: (_) {
                  return PopupMenuButton<SubPosition>(
                    icon: const Icon(Icons.arrow_drop_down, size: 16),
                    tooltip: '选择子持仓',
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
                  );
                }
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 紧凑B资产子持仓输入
  Widget _buildCompactBSubPositionInput() {
    final primaryColor = ThemeHelper.getPrimaryColor(Get.context!);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('B资产子持仓', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Stack(
          children: [
            GetBuilder<TradingOperatorAreaController>(
              builder: (_) {
                return TextFormField(
                  controller: controller.assetBSubPositionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    hintText: '输入或选择子持仓',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                    prefixIcon: Icon(Icons.account_tree_outlined, size: 16, color: Colors.grey[600]),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    filled: !controller.isBSubPositionEnabled.value,
                    fillColor: !controller.isBSubPositionEnabled.value ? Colors.grey.shade100 : null,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 12),
                  readOnly: false,
                  enabled: controller.isBSubPositionEnabled.value,
                  onChanged: (_) => controller.updateExchangeRate(),
                );
              }
            ),
            Positioned(
              right: 4,
              top: 4,
              bottom: 4,
              child: GetBuilder<TradingOperatorAreaController>(
                builder: (_) {
                  return PopupMenuButton<SubPosition>(
                    icon: const Icon(Icons.arrow_drop_down, size: 16),
                    tooltip: '选择B资产子持仓',
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
                  );
                }
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 紧凑价格输入
  Widget _buildCompactPriceSection() {
    final primaryColor = ThemeHelper.getPrimaryColor(Get.context!);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('价格', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        GetBuilder<TradingOperatorAreaController>(
          builder: (_) {
            return TextFormField(
              controller: controller.priceController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                hintText: controller.isTotal.value ? '总价' : '单价',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                prefixIcon: Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red.shade400),
                ),
                isDense: true,
                suffixIcon: DropdownButton<bool>(
                  value: controller.isTotal.value,
                  underline: Container(),
                  icon: const Icon(Icons.arrow_drop_down, size: 16),
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
              ),
              style: const TextStyle(fontSize: 12),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入价格';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return '请输入有效的价格';
                }
                return null;
              },
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
  }) {
    final editingController = textController ?? controller.amountController;
    final primaryColor = ThemeHelper.getPrimaryColor(Get.context!);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Stack(
          children: [
            GetBuilder<TradingOperatorAreaController>(
              builder: (_) {
                return TextFormField(
                  controller: editingController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    hintText: hint ?? '输入数量',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                    prefixIcon: Icon(Icons.numbers, size: 16, color: Colors.grey[600]),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red.shade400),
                    ),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 12),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => controller.updateExchangeRate(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入数量';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return '请输入有效的数量';
                    }
                    return null;
                  },
                );
              }
            ),
            // 快速选择数量按钮
            GetBuilder<TradingOperatorAreaController>(
              builder: (_) {
                final bool isRegularOrAssetA = (textController == null || textController == controller.amountController);
                final selectedSubPosition = isRegularOrAssetA ? controller.getSelectedSubPosition() : null;
                
                return selectedSubPosition != null
                ? Positioned(
                    right: 4,
                    top: 4,
                    bottom: 4,
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.arrow_drop_down, size: 16),
                      tooltip: '选择数量',
                      onSelected: (String selection) {
                        editingController.text = selection;
                        controller.updateExchangeRate();
                      },
                      itemBuilder: (BuildContext context) {
                        final holdCnt = double.tryParse(selectedSubPosition.holdCnt) ?? 0;
                        final options = <PopupMenuItem<String>>[];
                        if (holdCnt > 0) {
                          options.add(PopupMenuItem<String>(value: holdCnt.toString(), child: Text('全部: ${holdCnt.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11))));
                          final halfAmount = (holdCnt / 2);
                          options.add(PopupMenuItem<String>(value: halfAmount.toStringAsFixed(2), child: Text('一半: ${halfAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11))));
                          final quarterAmount = (holdCnt / 4);
                          options.add(PopupMenuItem<String>(value: quarterAmount.toStringAsFixed(2), child: Text('1/4: ${quarterAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11))));
                        }
                        return options.isNotEmpty ? options : [const PopupMenuItem(enabled: false, child: Text('无可用数量', style: TextStyle(fontSize: 11)))];
                      },
                    ),
                  )
                : const SizedBox.shrink();
              }
            ),
          ],
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
            border: Border.all(color: Colors.grey.shade300),
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
    final primaryColor = ThemeHelper.getPrimaryColor(Get.context!);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('股息金额', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        GetBuilder<TradingOperatorAreaController>(
          builder: (_) {
            return TextFormField(
              controller: controller.priceController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                hintText: controller.isTotal.value ? '股息总额' : '每股派息',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                prefixIcon: Icon(Icons.attach_money, size: 16, color: Colors.teal[600]),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red.shade400),
                ),
                isDense: true,
                suffixIcon: DropdownButton<bool>(
                  value: controller.isTotal.value,
                  underline: Container(),
                  icon: const Icon(Icons.arrow_drop_down, size: 16),
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
              ),
              style: const TextStyle(fontSize: 12),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入股息金额';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return '请输入有效的金额';
                }
                return null;
              },
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
          // 四个按钮放在一行
          Row(
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
          ),
        ],
      ),
    );
  }

  /// 紧凑交易按钮
  Widget _buildCompactTradeButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4), // 进一步减少内边距
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6), // 减少圆角
        ),
        elevation: 1, // 减少阴影
        minimumSize: const Size(0, 28), // 减少最小高度
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12), // 进一步缩小图标
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9), // 进一步缩小字体
          ),
        ],
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
            ? () => controller.handleTrade('EXCHANGE')
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
        onPressed: () => controller.handleTrade('DIVIDEND'),
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