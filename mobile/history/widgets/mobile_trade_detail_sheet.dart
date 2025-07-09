import 'package:flutter/material.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/constants/trading_transactions_enums.dart';
import 'package:intl/intl.dart';

/// 移动端交易详情底部表单
/// 
/// 显示交易记录的详细信息
class MobileTradeDetailSheet {
  /// 显示交易详情底部表单
  static void show(BuildContext context, TradingTransaction trade) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TradeDetailSheet(trade: trade),
    );
  }
}

class _TradeDetailSheet extends StatelessWidget {
  final TradingTransaction trade;

  const _TradeDetailSheet({required this.trade});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[600]
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 标题栏
          _buildHeader(context),
          
          // 详情内容
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildContent(context),
            ),
          ),
          
          // 底部安全区域
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 构建标题栏
  Widget _buildHeader(BuildContext context) {
    final operationStyle = _getTradeOperationStyle(trade.operate);
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            operationStyle['icon'] as IconData,
            color: operationStyle['color'] as Color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  operationStyle['text'] as String,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: operationStyle['color'] as Color,
                  ),
                ),
                Text(
                  'ID: ${trade.id}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
        ],
      ),
    );
  }

  /// 构建详情内容
  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 基本信息
        _buildSection(
          context,
          '基本信息',
          Icons.info_outline,
          [
            _buildInfoRow(context, '交易日期', _formatDate(trade.tradeDate)),
            _buildInfoRow(context, '标的代码', trade.symbol),
            if (trade.subPositionSymbol.isNotEmpty)
              _buildInfoRow(context, '子持仓', trade.subPositionSymbol),
            _buildInfoRow(context, '交易状态', _getTradeStatusText(trade.status)),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // 交易详情
        _buildSection(
          context,
          '交易详情',
          Icons.receipt_long,
          [
            _buildInfoRow(context, '价格', trade.price),
            _buildInfoRow(context, '数量', trade.amount),
            _buildInfoRow(context, '总金额', _calculateTotalAmount()),
            if (trade.nowAvgPrice.isNotEmpty)
              _buildInfoRow(context, '当前均价', trade.nowAvgPrice),
            if (trade.nowDilutedAvgPrice.isNotEmpty)
              _buildInfoRow(context, '摊薄均价', trade.nowDilutedAvgPrice),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // 盈亏信息
        if (trade.profitOrLoss != null && trade.profitOrLoss!.isNotEmpty)
          _buildSection(
            context,
            '盈亏信息',
            Icons.trending_up,
            [
              _buildProfitLossRow(context, '盈亏金额', trade.profitOrLoss!),
              if (trade.percentOfPl != null && trade.percentOfPl!.isNotEmpty)
                _buildInfoRow(context, '盈亏比例', '${trade.percentOfPl}%'),
            ],
          ),
        
        const SizedBox(height: 20),
        
        // 费用信息
        _buildSection(
          context,
          '费用信息',
          Icons.account_balance_wallet,
          [
            if (trade.fees != null && trade.fees!.isNotEmpty)
              _buildInfoRow(context, '手续费', trade.fees!),
            if (trade.dividend != null && trade.dividend!.isNotEmpty)
              _buildInfoRow(context, '股息金额', trade.dividend!),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // 备注信息
        if (trade.description != null && trade.description!.isNotEmpty)
          _buildSection(
            context,
            '备注信息',
            Icons.note,
            [
              _buildNoteRow(context, trade.description!),
            ],
          ),
      ],
    );
  }

  /// 构建信息段落
  Widget _buildSection(BuildContext context, String title, IconData icon, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.grey.withAlpha(30)
            : Colors.grey.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 段落标题
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.grey.withAlpha(60)
                  : Colors.grey.withAlpha(40),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon, 
                  size: 18, 
                  color: isDark 
                      ? Colors.grey[300]
                      : Colors.grey[700],
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark 
                        ? Colors.grey[300]
                        : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          
          // 段落内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建盈亏信息行
  Widget _buildProfitLossRow(BuildContext context, String label, String value) {
    final pl = double.tryParse(value) ?? 0;
    final isProfit = pl >= 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${isProfit ? '+' : ''}$value',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isProfit ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建备注行
  Widget _buildNoteRow(BuildContext context, String note) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.blue.withAlpha(30)
            : Colors.blue.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark 
              ? Colors.blue.withAlpha(80)
              : Colors.blue.withAlpha(50),
        ),
      ),
      child: Text(
        note,
        style: TextStyle(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  /// 计算总金额
  String _calculateTotalAmount() {
    try {
      final price = double.parse(trade.price);
      final amount = double.parse(trade.amount);
      final total = price * amount;
      return total.toStringAsFixed(2);
    } catch (e) {
      return '计算错误';
    }
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return DateFormat('yyyy年MM月dd日 HH:mm').format(date);
  }

  /// 获取交易操作样式
  Map<String, dynamic> _getTradeOperationStyle(TradeOperate operate) {
    switch (operate) {
      case TradeOperate.openLong:
        return {'icon': Icons.trending_up, 'color': Colors.green, 'text': '买入开多'};
      case TradeOperate.openShort:
        return {'icon': Icons.trending_down, 'color': Colors.red, 'text': '卖出开空'};
      case TradeOperate.closeLong:
        return {'icon': Icons.call_made, 'color': Colors.blue, 'text': '卖出平多'};
      case TradeOperate.closeShort:
        return {'icon': Icons.call_received, 'color': Colors.orange, 'text': '买入平空'};
      case TradeOperate.swapFrom:
        return {'icon': Icons.swap_horiz, 'color': Colors.purple, 'text': '换出'};
      case TradeOperate.swapTo:
        return {'icon': Icons.swap_horiz, 'color': Colors.purple, 'text': '换入'};
      case TradeOperate.deposit:
        return {'icon': Icons.account_balance_wallet, 'color': Colors.teal, 'text': '入金'};
      case TradeOperate.withdraw:
        return {'icon': Icons.money_off, 'color': Colors.brown, 'text': '出金'};
      case TradeOperate.dividend:
        return {'icon': Icons.attach_money, 'color': Colors.teal, 'text': '股息'};
    }
  }

  /// 获取交易状态文本
  String _getTradeStatusText(TradeStatus status) {
    switch (status) {
      case TradeStatus.newPosition:
        return '新建仓';
      case TradeStatus.raiseAvgPrice:
        return '提高均价';
      case TradeStatus.lowerAvgPrice:
        return '降低均价';
      case TradeStatus.takeProfit:
        return '止盈';
      case TradeStatus.stopLoss:
        return '止损';
      case TradeStatus.costPrice:
        return '成本价';
      case TradeStatus.swapFrom:
        return '换出';
      case TradeStatus.swapTo:
        return '换入';
      case TradeStatus.close:
        return '平仓';
      case TradeStatus.dividend:
        return '股息';
      }
  }
} 