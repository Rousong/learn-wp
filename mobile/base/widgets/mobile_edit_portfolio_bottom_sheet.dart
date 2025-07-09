import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;
import 'package:trade_flex/core/constants/portfolio_enums.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/repositories/portfolio_repository.dart';
import 'package:trade_flex/core/repositories/fee_model_repository.dart';
import 'package:trade_flex/core/utils/portfolio_utils.dart';
import 'package:trade_flex/core/utils/snackbar_utils.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/event/portfolio_event_controller.dart';

/// 移动端编辑投资组合底部弹出页面
class MobileEditPortfolioBottomSheet extends StatefulWidget {
  /// 要编辑的投资组合
  final Portfolio portfolio;

  const MobileEditPortfolioBottomSheet({
    Key? key,
    required this.portfolio,
  }) : super(key: key);

  @override
  State<MobileEditPortfolioBottomSheet> createState() => _MobileEditPortfolioBottomSheetState();
}

class _MobileEditPortfolioBottomSheetState extends State<MobileEditPortfolioBottomSheet> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'MobileEditPortfolioForm');
  final _nameController = TextEditingController();
  
  // 表单数据
  late String _selectedCurrency;
  late PortfolioType _selectedType;
  late PortfolioDirection _selectedDirection;
  FeeModel? _selectedFeeModel;
  List<FeeModel> _feeModels = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
    _loadFeeModels();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// 初始化表单数据
  void _initializeFormData() {
    _nameController.text = widget.portfolio.portfolioName;
    _selectedCurrency = PortfolioUtils.getCurrencyCode(widget.portfolio.currency);
    _selectedType = widget.portfolio.portfolioType;
    _selectedDirection = widget.portfolio.direction;
  }

  /// 加载费率模式
  Future<void> _loadFeeModels() async {
    try {
      final feeModels = await FeeModelRepository.instance.getAllFeeModels();
      setState(() {
        _feeModels = feeModels;
        // 设置当前选中的费率模式
        if (widget.portfolio.feeModeId != null) {
          _selectedFeeModel = feeModels.firstWhereOrNull(
            (feeModel) => feeModel.id == widget.portfolio.feeModeId,
          );
        }
      });
    } catch (e) {
      LogService.instance.e('加载费率模式失败: $e');
    }
  }

  /// 更新投资组合
  Future<void> _updatePortfolio() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedPortfolio = widget.portfolio.copyWith(
        portfolioName: _nameController.text.trim(),
        currency: PortfolioUtils.getCurrencyFromString(_selectedCurrency),
        portfolioType: _selectedType,
        direction: _selectedDirection,
        feeModeId: drift.Value(_selectedFeeModel?.id),
        updateTime: DateTime.now(),
      );

      // 更新投资组合
      final success = await PortfolioRepository.instance.updatePortfolio(updatedPortfolio);
      if (!success) throw Exception('更新失败，未修改任何记录');
      
      // 更新投资组合状态
      final portfolioController = Get.find<PortfolioEventController>();
      portfolioController.notifyPortfolioChanged();

      // 检查组件是否仍然挂载
      if (!mounted) return;
      
      // 关闭底部弹出页面
      Navigator.of(context).pop();
      
      // 显示成功消息
      SnackbarUtils.success('成功', '投资组合更新成功');
      
    } catch (e) {
      LogService.instance.e('更新投资组合失败: $e');
      SnackbarUtils.error('错误', '更新投资组合失败');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // 顶部拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 标题栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  '编辑投资组合',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // 表单内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 投资组合名称
                    _buildSectionTitle('投资组合名称'),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: '请输入投资组合名称',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入投资组合名称';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // 币种选择
                    _buildSectionTitle('币种'),
                    DropdownButtonFormField<String>(
                      value: _selectedCurrency,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: ['CNY', 'USD', 'EUR', 'JPY', 'GBP', 'HKD']
                          .map((currency) => DropdownMenuItem(
                                value: currency,
                                child: Text(PortfolioUtils.getCurrencyFullLabel(currency)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCurrency = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // 投资组合类型
                    _buildSectionTitle('投资组合类型'),
                    DropdownButtonFormField<PortfolioType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: PortfolioType.values
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(PortfolioUtils.getPortfolioTypeLabel(type)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // 交易方向
                    _buildSectionTitle('交易方向'),
                    DropdownButtonFormField<PortfolioDirection>(
                      value: _selectedDirection,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: PortfolioDirection.values
                          .map((direction) => DropdownMenuItem(
                                value: direction,
                                child: Text(PortfolioUtils.getDirectionLabel(direction)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDirection = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // 费率模式（可选）
                    _buildSectionTitle('费率模式（可选）'),
                    DropdownButtonFormField<FeeModel?>(
                      value: _selectedFeeModel,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<FeeModel?>(
                          value: null,
                          child: Text('无费率模式'),
                        ),
                        ..._feeModels.map((feeModel) => DropdownMenuItem(
                              value: feeModel,
                              child: Text(feeModel.name),
                            )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedFeeModel = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // 状态信息
                    _buildSectionTitle('投资组合状态'),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.portfolio.isClosed 
                                ? Icons.pause_circle_outline 
                                : Icons.play_circle_outline,
                            color: widget.portfolio.isClosed 
                                ? Colors.orange 
                                : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.portfolio.isClosed ? '已关闭' : '活跃',
                            style: TextStyle(
                              color: widget.portfolio.isClosed 
                                  ? Colors.orange 
                                  : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '创建时间: ${widget.portfolio.createTime.toString().substring(0, 19)}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          
          // 底部按钮
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updatePortfolio,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        '保存更改',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建章节标题
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
} 