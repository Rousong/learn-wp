import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trade_flex/core/controllers/withdrew_deposit/transaction_history_controller.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/utils/portfolio_utils.dart';
import 'package:drift/drift.dart' as drift;
import 'package:trade_flex/core/utils/snackbar_utils.dart';

/// 移动端编辑出入金记录底部表单
class MobileEditTransactionBottomSheet extends StatefulWidget {
  final DepositsAndWithdrawal record;
  final TransactionHistoryController controller;

  const MobileEditTransactionBottomSheet({
    Key? key,
    required this.record,
    required this.controller,
  }) : super(key: key);

  /// 显示底部表单
  static void show(BuildContext context, DepositsAndWithdrawal record, TransactionHistoryController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MobileEditTransactionBottomSheet(
        record: record,
        controller: controller,
      ),
    );
  }

  @override
  State<MobileEditTransactionBottomSheet> createState() => _MobileEditTransactionBottomSheetState();
}

class _MobileEditTransactionBottomSheetState extends State<MobileEditTransactionBottomSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.record.amount);
    _noteController = TextEditingController(text: widget.record.note ?? '');
    _selectedDate = widget.record.transactionDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// 弹出日期选择器
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// 保存更改
  void _saveChanges() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      SnackbarUtils.error('输入无效', '请输入有效的金额。');
      return;
    }

    final updatedRecord = widget.record.copyWith(
      transactionDate: _selectedDate,
      amount: amount.toString(),
      note: _noteController.text.trim().isEmpty 
          ? const drift.Value.absent() 
          : drift.Value(_noteController.text.trim()),
      updateTime: DateTime.now(),
    );

    widget.controller.updateRecord(updatedRecord);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDeposit = widget.record.isDeposit;
    final title = '编辑${isDeposit ? "入金" : "出金"}记录';

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 头部和拖拽指示器
            Column(
              children: [
                 Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(title, style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 24),
            // 日期字段
            TextFormField(
              readOnly: true,
              controller: TextEditingController(text: DateFormat('yyyy-MM-dd').format(_selectedDate)),
              decoration: InputDecoration(
                labelText: '日期',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            // 金额字段
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: '金额',
                prefixIcon: const Icon(Icons.attach_money),
                suffixText: PortfolioUtils.getCurrencySymbol(widget.record.currency),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            // 备注字段
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: '备注 (可选)',
                prefixIcon: const Icon(Icons.note_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save_as_outlined),
              label: const Text('保存更改'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
} 