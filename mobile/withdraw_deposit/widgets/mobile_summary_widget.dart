import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/controllers/withdrew_deposit/summary_controller.dart';
import 'package:trade_flex/core/controllers/withdrew_deposit/deposit_withdraw_form_controller.dart';
import 'package:trade_flex/core/controllers/withdrew_deposit/transaction_history_controller.dart';
import 'package:trade_flex/core/constants/portfolio_enums.dart';
import 'package:trade_flex/core/utils/portfolio_utils.dart';
import 'package:trade_flex/core/services/api/exchange_rate_service.dart';
import 'package:trade_flex/core/utils/theme_helper.dart';

/// 移动端摘要组件
///
/// 经过重新设计，将功能拆分为多个独立的卡片，以提高可读性和用户体验。
/// 包括投资组合概览与设置、现金仓位管理。
class MobileSummaryWidget extends StatelessWidget {
  const MobileSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final summaryController = Get.find<SummaryController>();
    final formController = Get.find<DepositWithdrawFormController>();
    final historyController = Get.find<TransactionHistoryController>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildPortfolioOverviewCard(context, summaryController, formController, historyController),
            const SizedBox(height: 16),
            _buildCashManagementCard(context, summaryController, formController, historyController),
          ],
        ),
      ),
    );
  }

  /// 构建一个通用的卡片容器
  Widget _buildCard({
    required BuildContext context,
    required Widget title,
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: title,
          ),
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  /// 构建卡片标题
  Widget _buildCardTitle(BuildContext context, String title, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  /// 构建投资组合概览与设置卡片
  Widget _buildPortfolioOverviewCard(
    BuildContext context,
    SummaryController summaryController,
    DepositWithdrawFormController formController,
    TransactionHistoryController historyController,
  ) {
    return _buildCard(
      context: context,
      title: Row(
        children: [
          Expanded(
            child: _buildCardTitle(context, '投资组合概览', icon: Icons.account_balance_wallet),
          ),
          Text(
            '统计所有组合',
            style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color),
          ),
          const SizedBox(width: 4),
          Obx(() => Switch(
                value: historyController.showAllPortfolios.value,
                onChanged: (newValue) => historyController.toggleShowAllPortfolios(),
                activeColor: ThemeHelper.getPrimaryColor(context),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPortfolioInfoContent(context, summaryController, formController, historyController),
          const Divider(height: 24, thickness: 1),
          _buildStatCurrencySelector(context, formController),
        ],
      ),
    );
  }

  /// 构建现金仓位管理卡片
  Widget _buildCashManagementCard(
    BuildContext context,
    SummaryController summaryController,
    DepositWithdrawFormController formController,
    TransactionHistoryController historyController,
  ) {
    return Obx(() {
      // 检查是否有入金记录或持仓信息
      if (!summaryController.hasPositions.value || !summaryController.hasDeposits.value) {
        return _buildCard(
          context: context,
          title: _buildCardTitle(context, '现金仓位管理', icon: Icons.pie_chart),
          child: _buildEmptyStateCard(context),
        );
      }

      final selectedPortfolio = formController.currentPortfolio.value;
      final showAllPortfolios = historyController.showAllPortfolios.value;

      if (!showAllPortfolios && selectedPortfolio == null) {
        return const SizedBox.shrink(); // 如果没有选择投资组合，则不显示此卡片
      }

      final statCurrency = formController.selectedCurrency.value;
      if (statCurrency == null) {
        return const Center(child: Text('请先选择统计货币'));
      }
      
      return _buildCard(
        context: context,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCardTitle(context, '现金仓位管理', icon: Icons.pie_chart),
            ElevatedButton(
              onPressed: () => summaryController.saveTargetCashRatio(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeHelper.getPrimaryColor(context),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('保存', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
        child: _buildCashManagementContent(context, summaryController, formController),
      );
    });
  }

  /// 构建投资组合信息 - 完全参考桌面端实现
  Widget _buildPortfolioInfoContent(
    BuildContext context,
    SummaryController summaryController,
    DepositWithdrawFormController formController,
    TransactionHistoryController historyController,
  ) {
    return Obx(() {
      final selectedPortfolio = formController.currentPortfolio.value;
      final showAllPortfolios = historyController.showAllPortfolios.value;
      final statCurrency = formController.selectedCurrency.value;

      // 显示所有投资组合的情况
      if (showAllPortfolios) {
        if (statCurrency == null) {
          return const Row(children: [Text('请选择统计货币')]);
        }

        // 计算所有投资组合的总净入金合计（转换为统计货币）
        double totalAmount = 0.0;
        
        // 使用historyController中的投资组合历史记录计算总额
        for (final record in historyController.historyRecords) {
          final exchangeRate = summaryController.getExchangeRate(record.currency, statCurrency);
          final recordAmount = double.tryParse(record.amount) ?? 0.0;
          final convertedAmount = recordAmount * exchangeRate;
          
          if (record.isDeposit) {
            totalAmount += convertedAmount;
          } else {
            totalAmount -= convertedAmount;
          }
        }

        final isPositive = totalAmount >= 0;
        final statCurrencySymbol = PortfolioUtils.getCurrencySymbol(statCurrency);

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '所有投资组合',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '统计货币: ${PortfolioUtils.getCurrencyLabel(statCurrency)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('合计总净入金', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${isPositive ? "+" : ""}$statCurrencySymbol ${totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }

      // 原有的单个投资组合显示逻辑
      if (selectedPortfolio == null) {
        return const Row(children: [Text('加载投资组合信息...')]);
      }

      final portfolioCurrency = selectedPortfolio.currency;
      final portfolioTotal = summaryController.totalsByPortfolio[selectedPortfolio.id] ?? 0.0;
      final isPositive = portfolioTotal >= 0;
      final portfolioCurrencySymbol = PortfolioUtils.getCurrencySymbol(portfolioCurrency);
      
      final statCurrencyValue = formController.selectedCurrency.value ?? portfolioCurrency;
      final exchangeRate = summaryController.getExchangeRate(portfolioCurrency, statCurrencyValue);
      final statAmount = portfolioTotal * exchangeRate;
      final statCurrencySymbol = PortfolioUtils.getCurrencySymbol(statCurrencyValue);
      
      return Row(
         children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedPortfolio.portfolioName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '币种: ${PortfolioUtils.getCurrencyLabel(selectedPortfolio.currency)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('总净入金', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${isPositive ? "+" : ""}$portfolioCurrencySymbol ${portfolioTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ),
              if (portfolioCurrency != statCurrencyValue) ...[
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.currency_exchange, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        ExchangeRateService.instance.hasError.value == true
                          ? '汇率获取失败'
                          : '≈ $statCurrencySymbol ${statAmount.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      );
    });
  }

  /// 构建统计货币选择器
  Widget _buildStatCurrencySelector(BuildContext context, DepositWithdrawFormController formController) {
    return Obx(() => DropdownButtonFormField<PortfolioCurrency?>(
      value: formController.selectedCurrency.value,
      decoration: InputDecoration(
        labelText: '统计货币',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      items: formController.availableCurrencies.map((currency) {
        return DropdownMenuItem<PortfolioCurrency?>(
          value: currency,
          child: Text(
            PortfolioUtils.getCurrencyLabel(currency),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
            formController.selectedCurrency.value = newValue;
        }
      },
      isExpanded: true,
    ));
  }

  /// 构建现金管理卡片的内容
  Widget _buildCashManagementContent(
    BuildContext context,
    SummaryController summaryController,
    DepositWithdrawFormController formController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTargetRatioSlider(context, summaryController),
        const SizedBox(height: 16),
        _buildCashDifferenceInfo(context, summaryController, formController),
        const SizedBox(height: 16),
        _buildAllocationVisual(context, summaryController, formController),
      ],
    );
  }

  /// 构建目标现金比例滑块
  Widget _buildTargetRatioSlider(BuildContext context, SummaryController summaryController) {
    return Obx(() {
      final targetCashRatioValue = summaryController.targetCashRatio.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('目标现金比例', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(targetCashRatioValue * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ThemeHelper.getPrimaryColor(context),
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: targetCashRatioValue,
            min: 0.0,
            max: 1.0,
            divisions: 20,
            activeColor: ThemeHelper.getPrimaryColor(context),
            inactiveColor: Colors.grey[300],
            onChanged: (value) => summaryController.onTargetRatioChanged(value),
            label: '${(targetCashRatioValue * 100).toInt()}%',
          ),
        ],
      );
    });
  }

  /// 构建现金差额信息提示
  Widget _buildCashDifferenceInfo(
    BuildContext context,
    SummaryController summaryController,
    DepositWithdrawFormController formController
  ) {
    return Obx((){
      final statCurrency = formController.selectedCurrency.value!;
      final statCurrencySymbol = PortfolioUtils.getCurrencySymbol(statCurrency);
      final cashDifference = summaryController.getCashDifference();
      final needsWithdrawal = summaryController.getNeedsWithdrawal();
      final totalAssetsValue = summaryController.getTotalAssetsValue(formController.currentPortfolio.value?.id ?? 0);

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: needsWithdrawal ? Colors.red.withAlpha(20) : Colors.green.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: needsWithdrawal ? Colors.red.withAlpha(80) : Colors.green.withAlpha(80)),
        ),
        child: Row(
          children: [
            Icon(
              needsWithdrawal ? Icons.arrow_upward : Icons.arrow_downward,
              color: needsWithdrawal ? Colors.red : Colors.green,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cashDifference.abs() < 0.01
                        ? '已达到目标现金比例'
                        : (needsWithdrawal ? '建议取出或增加投资' : '建议存入或减少投资'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: needsWithdrawal ? Colors.red[700] : Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      cashDifference.abs() < 0.01
                          ? '当前总资产 $statCurrencySymbol ${totalAssetsValue.toStringAsFixed(2)}'
                          : (needsWithdrawal
                              ? '可操作金额: $statCurrencySymbol ${cashDifference.abs().toStringAsFixed(2)}'
                              : '需操作金额: $statCurrencySymbol ${cashDifference.abs().toStringAsFixed(2)}'),
                      style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 构建资金分配可视化条
  Widget _buildAllocationVisual(
    BuildContext context,
    SummaryController summaryController,
    DepositWithdrawFormController formController
  ) {
    return Obx(() {
      final portfolioId = formController.currentPortfolio.value?.id ?? 0;
      final showAllPortfolios = Get.find<TransactionHistoryController>().showAllPortfolios.value;
      final statCurrency = formController.selectedCurrency.value!;
      final statCurrencySymbol = PortfolioUtils.getCurrencySymbol(statCurrency);
      
      final targetCashRatioValue = summaryController.targetCashRatio.value;
      final cashRatio = showAllPortfolios
          ? summaryController.allPortfoliosCashRatio.value
          : (summaryController.currentCashRatio[portfolioId] ?? 0.1);
      final cashAmount = summaryController.getCashAmount(portfolioId);
      final investedAmount = summaryController.getInvestedAmount(portfolioId);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('当前资金分配', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {

              final marker = Column(
                children: [
                  Container(width: 2, height: 8, color: Colors.orangeAccent),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('目标', style: TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ],
              );

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Allocation bar
                  Container(
                    height: 25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.5),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Row(
                      children: [
                        Expanded(
                          flex: (cashRatio * 100).toInt(),
                          child: Container(
                            color: Colors.blue.shade300,
                            alignment: Alignment.center,
                            child: Text(
                              '现金 ${(cashRatio * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: ((1 - cashRatio) * 100).toInt(),
                          child: Container(
                            color: Colors.green.shade300,
                            alignment: Alignment.center,
                            child: Text(
                              '持仓 ${((1 - cashRatio) * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 28,
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment(-1.0 + 2 * targetCashRatioValue, 0),
                      child: marker,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 35), // Space for marker
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('现金: $statCurrencySymbol ${cashAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
              Text('持仓: $statCurrencySymbol ${investedAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      );
    });
  }

  /// 构建空状态卡片
  Widget _buildEmptyStateCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '暂无数据显示',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            '请先添加您的入金和持仓记录，以便我们为您分析和管理现金仓位。',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 