import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/constants/trading_transactions_enums.dart';
import 'package:trade_flex/core/utils/formatting_utils.dart';
import 'package:trade_flex/mobile/trading/controller/mobile_trading_records_controller.dart';
import 'package:trade_flex/mobile/trading/widgets/mobile_edit_trade_screen.dart';

/// 移动端交易详情对话框
class MobileTradeDetailDialog extends StatelessWidget {
  final TradingTransaction trade;
  final MobileTradingRecordsController controller;

  const MobileTradeDetailDialog({
    Key? key,
    required this.trade,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头部区域
            _buildHeader(context, operationIcon, operationColor, operationText, statusInfo, profitLoss, profitPercent, profitColor),
            
            // 详细信息区域 - 可滚动
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // 交易基本信息
                    _buildDetailSection(
                      '交易信息',
                      Icons.info_outline,
                      Colors.blue,
                      [
                        _buildEnhancedDetailRow('股票代码', trade.symbol, Icons.code),
                        if (trade.subPositionSymbol.isNotEmpty)
                          _buildEnhancedDetailRow('子持仓', trade.subPositionSymbol, Icons.account_tree),
                        _buildEnhancedDetailRow('交易数量', '${amount.toStringAsFixed(0)}股', Icons.numbers),
                        _buildEnhancedDetailRow('成交价格', FormattingUtils.formatCurrency(price), Icons.attach_money),
                        _buildEnhancedDetailRow('交易日期', DateFormat('yyyy-MM-dd HH:mm').format(trade.tradeDate), Icons.schedule),
                        _buildEnhancedDetailRow('交易ID', trade.transactionId, Icons.fingerprint),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 价格分析
                    _buildDetailSection(
                      '价格分析',
                      Icons.analytics_outlined,
                      Colors.orange,
                      [
                        if (nowAvgPrice > 0)
                          _buildEnhancedDetailRow('现在均价', FormattingUtils.formatCurrency(nowAvgPrice), Icons.trending_up),
                        if (nowDilutedAvgPrice > 0)
                          _buildEnhancedDetailRow('摊薄均价', FormattingUtils.formatCurrency(nowDilutedAvgPrice), Icons.show_chart),
                        if (fees > 0)
                          _buildEnhancedDetailRow('手续费', FormattingUtils.formatCurrency(fees), Icons.receipt),
                        if (dividend > 0)
                          _buildEnhancedDetailRow('股息金额', FormattingUtils.formatCurrency(dividend), Icons.savings),
                      ],
                    ),
                    
                    // 情绪指数
                    if (trade.fearGreedIndex > 0) ...[
                      const SizedBox(height: 20),
                      _buildDetailSection(
                        '市场情绪',
                        Icons.psychology_outlined,
                        Colors.deepPurple,
                        [
                          _buildEnhancedDetailRow(
                            '恐惧贪婪指数', 
                            '${trade.fearGreedIndex} (${_getFearGreedText(trade.fearGreedIndex)})',
                            Icons.sentiment_satisfied,
                          ),
                        ],
                      ),
                    ],
                    
                    // 资产位置
                    if (trade.assetLocation != null && trade.assetLocation!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildDetailSection(
                        '资产信息',
                        Icons.location_on_outlined,
                        Colors.teal,
                        [
                          _buildEnhancedDetailRow('资产位置', trade.assetLocation!, Icons.place),
                        ],
                      ),
                    ],
                    
                    // 备注信息
                    if (trade.description != null && trade.description!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildDetailSection(
                        '备注信息',
                        Icons.note_outlined,
                        Colors.purple,
                        [
                          _buildEnhancedDetailRow('备注', trade.description!, Icons.description),
                        ],
                      ),
                    ],
                    
                    // 音频文件
                    if (trade.audioFilePath != null && trade.audioFilePath!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildDetailSection(
                        '音频记录',
                        Icons.audiotrack_outlined,
                        Colors.indigo,
                        [
                          _buildEnhancedDetailRow('音频文件', '已录制语音备注', Icons.mic),
                        ],
                      ),
                    ],
                    
                    // 时间信息
                    const SizedBox(height: 20),
                    _buildDetailSection(
                      '时间信息',
                      Icons.access_time_outlined,
                      Colors.grey,
                      [
                        _buildEnhancedDetailRow('创建时间', DateFormat('yyyy-MM-dd HH:mm:ss').format(trade.createTime), Icons.add_circle_outline),
                        _buildEnhancedDetailRow('更新时间', DateFormat('yyyy-MM-dd HH:mm:ss').format(trade.updateTime), Icons.update),
                        _buildEnhancedDetailRow('是否已平仓', trade.isClosed ? '是' : '否', trade.isClosed ? Icons.check_circle : Icons.radio_button_unchecked),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 操作按钮
                    _buildActionButtons(context, operationColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建头部区域
  Widget _buildHeader(
    BuildContext context,
    IconData operationIcon,
    Color operationColor,
    String operationText,
    Map<String, dynamic> statusInfo,
    double profitLoss,
    double profitPercent,
    Color profitColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: operationColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: operationColor.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: Icon(
                  operationIcon,
                  color: operationColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trade.subPositionSymbol.isNotEmpty 
                          ? trade.subPositionSymbol 
                          : trade.symbol,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: operationColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            operationText,
                            style: TextStyle(
                              fontSize: 14,
                              color: operationColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusInfo['color'].withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusInfo['text'],
                            style: TextStyle(
                              fontSize: 14,
                              color: statusInfo['color'],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 盈亏信息卡片
          if (trade.profitOrLoss != null && trade.profitOrLoss!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    FormattingUtils.formatCurrency(profitLoss),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: profitColor,
                    ),
                  ),
                  if (trade.percentOfPl != null && trade.percentOfPl!.isNotEmpty)
                    Text(
                      '${profitPercent >= 0 ? '+' : ''}${profitPercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 16,
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
  Widget _buildDetailSection(String title, IconData icon, Color color, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
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
  Widget _buildEnhancedDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons(BuildContext context, Color operationColor) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditDialog(context);
            },
            icon: const Icon(Icons.edit),
            label: const Text('编辑'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.check),
            label: const Text('确定'),
            style: ElevatedButton.styleFrom(
              backgroundColor: operationColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
        return {'text': '平仓', 'color': Colors.black};
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