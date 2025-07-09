import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/database/database.dart';

/// 移动端创建费率规则底部弹出页面
/// 
/// 用于创建新的费率规则
class MobileCreateFeeRuleBottomSheet extends StatefulWidget {
  final int modelId;
  final Function(FeeRule) onFeeRuleCreated;

  const MobileCreateFeeRuleBottomSheet({
    super.key,
    required this.modelId,
    required this.onFeeRuleCreated,
  });

  @override
  State<MobileCreateFeeRuleBottomSheet> createState() => _MobileCreateFeeRuleBottomSheetState();
}

class _MobileCreateFeeRuleBottomSheetState extends State<MobileCreateFeeRuleBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _valueController = TextEditingController(text: '0.25');
  final _minFeeController = TextEditingController(text: '5');
  final _maxFeeController = TextEditingController(text: '0');
  final _startRangeController = TextEditingController(text: '0');
  final _endRangeController = TextEditingController(text: '0');
  
  String _selectedRuleType = 'universal';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _minFeeController.dispose();
    _maxFeeController.dispose();
    _startRangeController.dispose();
    _endRangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部拖拽指示器和标题
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: theme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '创建费率规则',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 表单内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 基本信息区域
                    _buildSectionTitle('基本信息', Icons.info_outline),
                    const SizedBox(height: 16),
                    
                    // 规则名称
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: '规则名称',
                        hintText: '例如：标准佣金',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.label_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入规则名称';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    
                    // 规则类型
                    DropdownButtonFormField<String>(
                      value: _selectedRuleType,
                      decoration: InputDecoration(
                        labelText: '规则类型',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.category_outlined),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'universal',
                          child: Row(
                            children: [
                              Icon(Icons.swap_horiz, size: 18, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              const Text('通用'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'buy',
                          child: Row(
                            children: [
                              Icon(Icons.arrow_circle_down, size: 18, color: Colors.green.shade700),
                              const SizedBox(width: 8),
                              const Text('买入'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'sell',
                          child: Row(
                            children: [
                              Icon(Icons.arrow_circle_up, size: 18, color: Colors.red.shade700),
                              const SizedBox(width: 8),
                              const Text('卖出'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedRuleType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // 费率参数区域
                    _buildSectionTitle('费率参数', Icons.percent),
                    const SizedBox(height: 16),
                    
                    // 费率百分比
                    TextFormField(
                      controller: _valueController,
                      decoration: InputDecoration(
                        labelText: '费率百分比',
                        hintText: '例如: 0.25 表示 0.25%',
                        suffixText: '%',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.monetization_on),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入费率';
                        }
                        if (double.tryParse(value) == null) {
                          return '请输入有效的数字';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    
                    // 最低和最高费用
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _minFeeController,
                            decoration: InputDecoration(
                              labelText: '最低费用',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.arrow_downward, color: Colors.green.shade700),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入最低费用';
                              }
                              if (double.tryParse(value) == null) {
                                return '请输入有效的数字';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _maxFeeController,
                            decoration: InputDecoration(
                              labelText: '最高费用',
                              hintText: '0表示无上限',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.arrow_upward, color: Colors.blue.shade700),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入最高费用';
                              }
                              if (double.tryParse(value) == null) {
                                return '请输入有效的数字';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // 适用范围区域
                    _buildSectionTitle('适用范围', Icons.tune),
                    const SizedBox(height: 16),
                    
                    // 起始和结束金额
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _startRangeController,
                            decoration: InputDecoration(
                              labelText: '起始金额',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.play_arrow, color: Colors.purple.shade700),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入起始金额';
                              }
                              if (double.tryParse(value) == null) {
                                return '请输入有效的数字';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _endRangeController,
                            decoration: InputDecoration(
                              labelText: '结束金额',
                              hintText: '0表示无限制',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.stop, color: Colors.purple.shade700),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入结束金额';
                              }
                              if (double.tryParse(value) == null) {
                                return '请输入有效的数字';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // 提示信息
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: theme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '• 费率以百分比形式输入，如0.25表示0.25%\n• 金额范围0表示无限制\n• 通用规则适用于买入和卖出操作',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface.withValues(alpha: 0.8),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100), // 为底部按钮留出空间
                  ],
                ),
              ),
            ),
          ),
          
          // 底部操作按钮
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onSurface.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleCreate,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                            ),
                          )
                        : const Text('创建'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建区域标题
  Widget _buildSectionTitle(String title, IconData icon) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
      ],
    );
  }

  /// 处理创建操作
  void _handleCreate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final rule = FeeRule(
        id: 0, // 新建时ID为0，数据库会自动分配
        modelId: widget.modelId,
        name: _nameController.text.trim(),
        ruleType: _selectedRuleType,
        value: _valueController.text.trim(),
        minFee: _minFeeController.text.trim(),
        maxFee: _maxFeeController.text.trim(),
        startRange: _startRangeController.text.trim(),
        endRange: _endRangeController.text.trim(),
        createTime: now,
        updateTime: now,
      );

      widget.onFeeRuleCreated(rule);
      Get.back();
    } catch (e) {
      Get.snackbar('错误', '创建费率规则失败：$e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
} 