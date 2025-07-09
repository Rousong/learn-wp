import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/constants/trading_transactions_enums.dart';
import 'package:trade_flex/core/utils/formatting_utils.dart';
import 'package:trade_flex/mobile/trading/controller/mobile_trading_records_controller.dart';
import 'package:trade_flex/mobile/trading/controller/mobile_trade_detail_controller.dart';
import 'package:trade_flex/mobile/trading/widgets/mobile_edit_trade_screen.dart';

/// 移动端交易详情底部表单
class MobileTradeDetailBottomSheet extends StatelessWidget {
  final TradingTransaction trade;
  final MobileTradingRecordsController controller;
  final MobileTradeDetailController detailController;

  MobileTradeDetailBottomSheet({
    Key? key,
    required this.trade,
    required this.controller,
  }) : detailController = Get.put(
          MobileTradeDetailController(tradeId: trade.id),
          tag: 'trade_detail_${trade.id}',
        ),
        super(key: key);

  /// 显示交易详情底部表单
  static void show(BuildContext context, TradingTransaction trade, MobileTradingRecordsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MobileTradeDetailBottomSheet(
        trade: trade,
        controller: controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final operationStyle = controller.getTradeOperationStyle(trade.operate);
    final operationIcon = operationStyle['icon'] as IconData;
    final operationColor = operationStyle['color'] as Color;
    final operationText = operationStyle['text'] as String;
    
    // 解析各种数值
    final profitLoss = controller.parseDouble(trade.profitOrLoss);
    final profitPercent = controller.parseDouble(trade.percentOfPl);
    final price = controller.parseDouble(trade.price);
    final amount = controller.parseDouble(trade.amount);
    final nowAvgPrice = controller.parseDouble(trade.nowAvgPrice);
    final nowDilutedAvgPrice = controller.parseDouble(trade.nowDilutedAvgPrice);
    final fees = controller.parseDouble(trade.fees);
    final dividend = controller.parseDouble(trade.dividend);
    
    final isProfit = profitLoss >= 0;
    final profitColor = isProfit ? Colors.green : Colors.red;
    final statusInfo = _getTradeStatusInfo(trade.status);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // 拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 头部区域
          _buildHeader(context, theme, colorScheme, operationIcon, operationColor, operationText, statusInfo, profitLoss, profitPercent, profitColor),
          
          // 详细信息区域 - 可滚动
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 交易基本信息
                  _buildDetailSection(
                    context,
                    theme,
                    colorScheme,
                    '交易信息',
                    Icons.info_outline,
                    theme.primaryColor,
                    [
                      _buildEnhancedDetailRow(context, theme, '股票代码', trade.symbol, Icons.code),
                      if (trade.subPositionSymbol.isNotEmpty)
                        _buildEnhancedDetailRow(context, theme, '子持仓', trade.subPositionSymbol, Icons.account_tree),
                      _buildEnhancedDetailRow(context, theme, '交易数量', '${amount.toStringAsFixed(0)}股', Icons.numbers),
                      _buildEnhancedDetailRow(context, theme, '成交价格', FormattingUtils.formatCurrency(price), Icons.attach_money),
                      _buildEnhancedDetailRow(context, theme, '交易日期', DateFormat('yyyy-MM-dd HH:mm').format(trade.tradeDate), Icons.schedule),
                      _buildEnhancedDetailRow(context, theme, '交易ID', trade.transactionId, Icons.fingerprint),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 价格分析
                  _buildDetailSection(
                    context,
                    theme,
                    colorScheme,
                    '价格分析',
                    Icons.analytics_outlined,
                    Colors.orange,
                    [
                      if (nowAvgPrice > 0)
                        _buildEnhancedDetailRow(context, theme, '现在均价', FormattingUtils.formatCurrency(nowAvgPrice), Icons.trending_up),
                      if (nowDilutedAvgPrice > 0)
                        _buildEnhancedDetailRow(context, theme, '摊薄均价', FormattingUtils.formatCurrency(nowDilutedAvgPrice), Icons.show_chart),
                      if (fees > 0)
                        _buildEnhancedDetailRow(context, theme, '手续费', FormattingUtils.formatCurrency(fees), Icons.receipt),
                      if (dividend > 0)
                        _buildEnhancedDetailRow(context, theme, '股息金额', FormattingUtils.formatCurrency(dividend), Icons.savings),
                    ],
                  ),
                  
                  // 标签信息 - 只在有标签或正在加载时显示
                  Obx(() {
                    if (detailController.isLoading.value || detailController.tags.isNotEmpty) {
                      return Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildTagsSection(context, theme, colorScheme),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  
                  // 情绪指数
                  if (trade.fearGreedIndex > 0) ...[
                    const SizedBox(height: 16),
                    _buildDetailSection(
                      context,
                      theme,
                      colorScheme,
                      '情绪指数',
                      Icons.psychology_outlined,
                      Colors.deepPurple,
                      [
                        _buildEnhancedDetailRow(
                          context,
                          theme,
                          '恐惧贪婪指数', 
                          '${trade.fearGreedIndex} (${_getFearGreedText(trade.fearGreedIndex)})',
                          Icons.sentiment_satisfied,
                        ),
                      ],
                    ),
                  ],
                  
                  // 资产位置
                  if (trade.assetLocation != null && trade.assetLocation!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDetailSection(
                      context,
                      theme,
                      colorScheme,
                      '资产信息',
                      Icons.location_on_outlined,
                      Colors.teal,
                      [
                        _buildEnhancedDetailRow(context, theme, '资产位置', trade.assetLocation!, Icons.place),
                      ],
                    ),
                  ],
                  
                  // 备注信息
                  if (trade.description != null && trade.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDetailSection(
                      context,
                      theme,
                      colorScheme,
                      '备注信息',
                      Icons.note_outlined,
                      Colors.purple,
                      [
                        _buildEnhancedDetailRow(context, theme, '备注', trade.description!, Icons.description),
                      ],
                    ),
                  ],
                  
                  // 时间信息
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    context,
                    theme,
                    colorScheme,
                    '时间信息',
                    Icons.access_time_outlined,
                    colorScheme.outline,
                    [
                      _buildEnhancedDetailRow(context, theme, '创建时间', DateFormat('yyyy-MM-dd HH:mm:ss').format(trade.createTime), Icons.add_circle_outline),
                      _buildEnhancedDetailRow(context, theme, '更新时间', DateFormat('yyyy-MM-dd HH:mm:ss').format(trade.updateTime), Icons.update),
                      _buildEnhancedDetailRow(context, theme, '是否已平仓', trade.isClosed ? '是' : '否', trade.isClosed ? Icons.check_circle : Icons.radio_button_unchecked),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 操作按钮
                  _buildActionButtons(context, theme, operationColor),
                  
                  // 底部安全区域
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建标签区域
  Widget _buildTagsSection(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Obx(() {
      // 如果正在加载，显示加载指示器
      if (detailController.isLoading.value) {
        return _buildDetailSection(
          context,
          theme,
          colorScheme,
          '标签',
          Icons.tag,
          Colors.indigo,
          [
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ],
        );
      }
      
      // 如果没有标签，完全隐藏标签区域
      if (detailController.tags.isEmpty) {
        return const SizedBox.shrink();
      }
      
      // 有标签时显示标签区域
      return _buildDetailSection(
        context,
        theme,
        colorScheme,
        '标签',
        Icons.tag,
        Colors.indigo,
        [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: detailController.tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.label,
                    size: 14,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tag,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      );
    });
  }

  /// 构建头部区域
  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    IconData operationIcon,
    Color operationColor,
    String operationText,
    Map<String, dynamic> statusInfo,
    double profitLoss,
    double profitPercent,
    Color profitColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            operationColor.withValues(alpha: 0.1),
            operationColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: operationColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: operationColor.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: Icon(
                  operationIcon,
                  color: operationColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trade.subPositionSymbol.isNotEmpty 
                          ? trade.subPositionSymbol 
                          : trade.symbol,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: operationColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            operationText,
                            style: TextStyle(
                              fontSize: 12,
                              color: operationColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusInfo['color'].withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            statusInfo['text'],
                            style: TextStyle(
                              fontSize: 12,
                              color: statusInfo['color'],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 盈亏信息卡片
          if (trade.profitOrLoss != null && trade.profitOrLoss!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: profitColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: profitColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '盈亏情况',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    FormattingUtils.formatCurrency(profitLoss),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: profitColor,
                    ),
                  ),
                  if (trade.percentOfPl != null && trade.percentOfPl!.isNotEmpty)
                    Text(
                      '${profitPercent >= 0 ? '+' : ''}${profitPercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: profitColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 构建详情区块
  Widget _buildDetailSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  /// 构建增强版详情行
  Widget _buildEnhancedDetailRow(BuildContext context, ThemeData theme, String label, String value, IconData icon) {
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: colorScheme.outline,
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons(BuildContext context, ThemeData theme, Color operationColor) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditDialog(context);
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('编辑'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.check, size: 18),
            label: const Text('确定'),
            style: ElevatedButton.styleFrom(
              backgroundColor: operationColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 获取交易状态信息
  Map<String, dynamic> _getTradeStatusInfo(TradeStatus status) {
    switch (status) {
      case TradeStatus.newPosition:
        return {'text': '新建仓', 'color': Colors.blue};
      case TradeStatus.raiseAvgPrice:
        return {'text': '提高均价', 'color': Colors.orange};
      case TradeStatus.lowerAvgPrice:
        return {'text': '降低均价', 'color': Colors.purple};
      case TradeStatus.takeProfit:
        return {'text': '止盈', 'color': Colors.green};
      case TradeStatus.stopLoss:
        return {'text': '止损', 'color': Colors.red};
      case TradeStatus.costPrice:
        return {'text': '成本价', 'color': Colors.grey};
      case TradeStatus.swapFrom:
        return {'text': '换出', 'color': Colors.teal};
      case TradeStatus.swapTo:
        return {'text': '换入', 'color': Colors.cyan};
      case TradeStatus.close:
        return {'text': '平仓', 'color': Colors.indigo};
      case TradeStatus.dividend:
        return {'text': '股息', 'color': Colors.teal};
    }
  }

  /// 获取恐惧贪婪指数文本
  String _getFearGreedText(int index) {
    if (index <= 25) return '极度恐惧';
    if (index <= 45) return '恐惧';
    if (index <= 55) return '中性';
    if (index <= 75) return '贪婪';
    return '极度贪婪';
  }

  /// 显示编辑屏幕
  void _showEditDialog(BuildContext context) {
    Get.to(
      () => MobileEditTradeScreen(
        trade: trade,
        onTradeUpdated: (updatedTrade) {
          Get.back();
          Future.delayed(const Duration(milliseconds: 100), () {
            controller.loadData(controller.portfolioId);
          });
        },
      ),
    );
  }
} 