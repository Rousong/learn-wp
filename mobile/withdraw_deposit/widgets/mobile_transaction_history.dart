import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/withdrew_deposit/transaction_history_controller.dart';
import 'package:trade_flex/core/controllers/withdrew_deposit/deposit_withdraw_form_controller.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/utils/portfolio_utils.dart';
import 'package:intl/intl.dart';
import 'package:trade_flex/core/utils/snackbar_utils.dart';
import 'package:trade_flex/mobile/withdraw_deposit/widgets/mobile_edit_transaction_bottom_sheet.dart';

/// 移动端交易历史组件
/// 
/// 显示出入金历史记录列表，适合移动端滚动查看
class MobileTransactionHistory extends GetView<TransactionHistoryController> {
  const MobileTransactionHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final formController = Get.find<DepositWithdrawFormController>();

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
          
          // 历史记录列表
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            
            if (controller.historyRecords.isEmpty) {
              return _buildEmptyState(context);
            }
            
            return _buildHistoryList(context, formController);
          }),
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
            Icons.history,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '交易历史',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const Spacer(),
          // 过滤按钮
          PopupMenuButton<String>(
            icon: Icon(
              Icons.filter_list,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('所有记录'),
              ),
              const PopupMenuItem(
                value: 'deposit',
                child: Text('仅入金记录'),
              ),
              const PopupMenuItem(
                value: 'withdraw',
                child: Text('仅出金记录'),
              ),
            ],
            onSelected: (value) {
              // TODO: 实现过滤功能
            },
          ),
        ],
      ),
    );
  }

  /// 构建历史记录列表
  Widget _buildHistoryList(BuildContext context, DepositWithdrawFormController formController) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        itemCount: controller.historyRecords.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final record = controller.historyRecords[index];
          return _buildHistoryItem(context, record, formController);
        },
      ),
    );
  }

  /// 构建单个历史记录项
  Widget _buildHistoryItem(
    BuildContext context,
    DepositsAndWithdrawal record,
    DepositWithdrawFormController formController,
  ) {
    final isDeposit = record.isDeposit;
    final amountColor = isDeposit ? Colors.green : Colors.red;
    final amountPrefix = isDeposit ? '+' : '-';
    final amountValue = double.tryParse(record.amount) ?? 0.0;
    final recordCurrency = record.currency;
    final recordCurrencySymbol = PortfolioUtils.getCurrencySymbol(recordCurrency);

    return Dismissible(
      key: Key('transaction_${record.id}'),
      // 左滑显示编辑 (从右向左滑动)
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, color: Colors.white, size: 24),
            SizedBox(height: 4),
            Text('编辑', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      // 右滑显示删除 (从左向右滑动)
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 24),
            SizedBox(height: 4),
            Text('删除', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) { // 右滑删除
          return await _showDeleteConfirmDialog(context, record);
        } else if (direction == DismissDirection.startToEnd) { // 左滑编辑
          _showEditBottomSheet(context, record);
          return false; // 不移除项
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          controller.deleteRecord(record.id);
          SnackbarUtils.success('成功', '记录已删除');
        }
      },
      child: Obx(() {
        final statCurrency = formController.selectedCurrency.value;
        final showExchangeRate = statCurrency != null && statCurrency != recordCurrency;
        double statAmount = 0.0;
        String statCurrencySymbol = '';
        
        if (showExchangeRate) {
          final exchangeRate = formController.getExchangeRate(recordCurrency, statCurrency);
          statAmount = amountValue * exchangeRate;
          statCurrencySymbol = PortfolioUtils.getCurrencySymbol(statCurrency);
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: amountColor.withAlpha(10),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: amountColor.withAlpha(50),
            ),
          ),
          child: Column(
            children: [
              // 主要信息行
              Row(
                children: [
                  // 类型图标
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: amountColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                      color: amountColor,
                      size: 20,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 交易信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDeposit ? '入金' : '出金',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: amountColor,
                          ),
                        ),
                        Text(
                          DateFormat('yyyy-MM-dd HH:mm').format(record.transactionDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 金额信息
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$amountPrefix$recordCurrencySymbol ${amountValue.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: amountColor,
                        ),
                      ),
                      if (showExchangeRate)
                        Text(
                          '≈ $statCurrencySymbol ${statAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              
              // 投资组合和备注信息
              if ((record.portfolioName.isNotEmpty) || (record.note?.isNotEmpty ?? false))
                Column(
                  children: [
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (record.portfolioName.isNotEmpty) ...[
                          Icon(
                            Icons.account_balance,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            record.portfolioName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        if ((record.portfolioName.isNotEmpty) && (record.note?.isNotEmpty ?? false))
                          const SizedBox(width: 16),
                        if (record.note?.isNotEmpty ?? false) ...[
                          Icon(
                            Icons.note,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              record.note ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
            ],
          ),
        );
      }),
    );
  }

  /// 显示编辑底部表单
  void _showEditBottomSheet(BuildContext context, DepositsAndWithdrawal record) {
    MobileEditTransactionBottomSheet.show(context, record, controller);
  }

  /// 显示删除确认对话框
  Future<bool?> _showDeleteConfirmDialog(BuildContext context, DepositsAndWithdrawal record) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除这条${record.isDeposit ? "入金" : "出金"}记录吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无交易记录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '您还没有任何出入金记录\n通过上方表单添加您的第一笔交易',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 