import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/withdrew_deposit/deposit_withdraw_form_controller.dart';
import 'package:trade_flex/core/constants/portfolio_enums.dart';
import 'package:trade_flex/core/utils/portfolio_utils.dart';
import 'package:intl/intl.dart';

/// 移动端出入金表单组件
/// 
/// 提供简化的出入金操作表单，适合移动端使用
class MobileDepositWithdrawForm extends GetView<DepositWithdrawFormController> {
  const MobileDepositWithdrawForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 标题栏
          _buildHeader(context),
          
          // 表单内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              child: Column(
                children: [
                  // 操作类型选择（入金/出金）
                  _buildOperationTypeSelector(context),
                  
                  const SizedBox(height: 16),
                  
                  // 金额输入
                  _buildAmountField(context),
                  
                  const SizedBox(height: 16),
                  
                  // 日期选择
                  _buildDateSelector(context),
                  
                  const SizedBox(height: 16),
                  
                  // 备注输入
                  _buildRemarksField(context),
                  
                  const SizedBox(height: 24),
                  
                  // 提交按钮
                  _buildSubmitButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建标题栏
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(10),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '资金操作',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作类型选择器
  Widget _buildOperationTypeSelector(BuildContext context) {
    return Obx(() => Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => controller.isDeposit.value = true,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: controller.isDeposit.value 
                  ? Colors.green.withAlpha(20)
                  : Colors.grey.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: controller.isDeposit.value 
                    ? Colors.green 
                    : Colors.grey.shade300,
                  width: controller.isDeposit.value ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_downward,
                    color: controller.isDeposit.value ? Colors.green : Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '入金',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: controller.isDeposit.value ? FontWeight.bold : FontWeight.normal,
                      color: controller.isDeposit.value ? Colors.green : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: InkWell(
            onTap: () => controller.isDeposit.value = false,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: !controller.isDeposit.value 
                  ? Colors.red.withAlpha(20)
                  : Colors.grey.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: !controller.isDeposit.value 
                    ? Colors.red 
                    : Colors.grey.shade300,
                  width: !controller.isDeposit.value ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_upward,
                    color: !controller.isDeposit.value ? Colors.red : Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '出金',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: !controller.isDeposit.value ? FontWeight.bold : FontWeight.normal,
                      color: !controller.isDeposit.value ? Colors.red : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ));
  }

  /// 构建金额输入字段
  Widget _buildAmountField(BuildContext context) {
    return Obx(() {
      final selectedPortfolio = controller.currentPortfolio.value;
      final currencySymbol = PortfolioUtils.getCurrencySymbol(
        selectedPortfolio?.currency ?? PortfolioCurrency.cny
      );
      
      return TextFormField(
        controller: controller.amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: controller.isDeposit.value ? '入金金额' : '出金金额',
          hintText: '0.00',
          prefixIcon: Icon(
            controller.isDeposit.value ? Icons.arrow_downward : Icons.arrow_upward,
            color: controller.isDeposit.value ? Colors.green : Colors.red,
          ),
          suffixText: currencySymbol,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: controller.isDeposit.value ? Colors.green : Colors.red,
              width: 2,
            ),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '请输入金额';
          }
          if (double.tryParse(value) == null) {
            return '请输入有效数字';
          }
          if (double.parse(value) <= 0) {
            return '金额必须大于0';
          }
          return null;
        },
      );
    });
  }

  /// 构建日期选择器
  Widget _buildDateSelector(BuildContext context) {
    return Obx(() => InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '交易日期',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('yyyy年MM月dd日').format(controller.selectedDate.value),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    ));
  }

  /// 构建备注输入字段
  Widget _buildRemarksField(BuildContext context) {
    return TextFormField(
      controller: controller.remarksController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: '备注（可选）',
        hintText: '输入备注信息...',
        prefixIcon: const Icon(Icons.note_add),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        alignLabelWithHint: true,
      ),
    );
  }

  /// 构建提交按钮
  Widget _buildSubmitButton(BuildContext context) {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isSubmitting.value 
          ? null 
          : () => controller.handleSubmit(),
        style: ElevatedButton.styleFrom(
          backgroundColor: controller.isDeposit.value ? Colors.green : Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: controller.isSubmitting.value
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  controller.isDeposit.value ? Icons.arrow_downward : Icons.arrow_upward,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  controller.isDeposit.value ? '确认入金' : '确认出金',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
      ),
    ));
  }

  /// 选择日期
  Future<void> _selectDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('zh', 'CN'),
    );
    
    if (selectedDate != null) {
      controller.selectedDate.value = selectedDate;
    }
  }
} 