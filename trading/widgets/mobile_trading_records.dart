import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_flex/core/utils/formatting_utils.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/constants/trading_transactions_enums.dart';
import 'package:intl/intl.dart';
import 'package:trade_flex/core/utils/snackbar_utils.dart';
import 'package:trade_flex/mobile/trading/controller/mobile_trading_records_controller.dart';
import 'package:trade_flex/mobile/trading/widgets/mobile_edit_trade_screen.dart';
import 'package:trade_flex/mobile/trading/widgets/mobile_add_trade_screen.dart';
import 'package:trade_flex/mobile/trading/widgets/mobile_trade_detail_dialog.dart';
import 'package:trade_flex/mobile/trading/controller/mobile_trading_screen_controller.dart';
import 'package:trade_flex/core/event/portfolio_event_controller.dart';



/// 移动端交易记录组件
/// 
/// 显示最近的交易记录列表
class MobileTradingRecords extends GetView<MobileTradingRecordsController> {
  const MobileTradingRecords({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 数据加载由MobileTradingScreenController统一管理，这里不需要手动加载
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '最近交易',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const Spacer(),
                Obx(() => controller.isLoading.value
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : _buildAddTradeButton(context),
                ),
              ],
            ),
          ),
          
          // 交易记录列表
          Obx(() {
            if (controller.isLoading.value && controller.recentTrades.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            
            if (controller.recentTrades.isEmpty) {
              return _buildEmptyState(context);
            }
            
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.recentTrades.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                final trade = controller.recentTrades[index];
                return _buildTradingRecordItem(context, trade);
              },
            );
          }),
        ],
      ),
    );
  }

  /// 构建添加交易按钮
  Widget _buildAddTradeButton(BuildContext context) {
    // 获取移动端交易屏幕控制器
    final tradingController = Get.find<MobileTradingScreenController>();
    
    return Obx(() {
      // 如果没有投资组合，不显示按钮
      if (!tradingController.hasPortfolios.value) {
        return const SizedBox.shrink();
      }
      
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _showAddTradeScreen(context),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '添加交易记录',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  /// 显示添加交易屏幕
  void _showAddTradeScreen(BuildContext context) {
    final portfolioController = Get.find<PortfolioEventController>();
    final selectedPortfolioId = portfolioController.selectedPortfolioId.value;
    
    if (selectedPortfolioId == 0) {
      Get.snackbar(
        '提示',
        '请先选择一个投资组合',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    
    Get.to(
      () => MobileAddTradeScreen(
        portfolioId: selectedPortfolioId,
        onTradeAdded: (trade) {
          // 先返回上一页
          Get.back();
          
          // 延迟执行数据加载和提示显示，避免Navigator冲突
          Future.delayed(const Duration(milliseconds: 100), () {
            // 添加成功后重新加载数据
            final tradingController = Get.find<MobileTradingScreenController>();
            tradingController.loadData(selectedPortfolioId);
            
          });
        },
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              '暂无交易记录',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '开始您的第一笔交易吧',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建交易记录项 - 紧凑版本
  Widget _buildTradingRecordItem(BuildContext context, TradingTransaction trade) {
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
    
    final isProfit = profitLoss >= 0;
    final profitColor = isProfit ? Colors.green : Colors.red;
    
    // 获取交易状态信息
    final statusInfo = _getTradeStatusInfo(trade.status);
    
    return Dismissible(
      key: Key('trade_${trade.id}'),
      // 左滑显示编辑（从右向左滑动）
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Colors.blue,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              '编辑',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      // 右滑显示删除（从左向右滑动）
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              '删除',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      // 确认删除回调
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // 右滑删除 - 显示确认对话框
          return await _showDeleteConfirmDialog(context, trade);
        } else if (direction == DismissDirection.startToEnd) {
          // 左滑编辑 - 不执行删除，而是打开编辑
          _showEditDialog(context, trade);
          return false; // 不删除项目
        }
        return false;
      },
      // 删除回调
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _deleteRecord(trade);
        }
      },
      child: InkWell(
        onTap: () => _showTradeDetail(context, trade),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: operationColor.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // 主要信息行
                Row(
                  children: [
                    // 交易类型图标 - 缩小
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: operationColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: operationColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        operationIcon,
                        color: operationColor,
                        size: 18,
                      ),
                    ),
                    
                    const SizedBox(width: 10),
                    
                    // 股票信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  trade.subPositionSymbol.isNotEmpty 
                                      ? trade.subPositionSymbol 
                                      : trade.symbol,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // 交易状态标签 - 缩小
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusInfo['color'].withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: statusInfo['color'].withValues(alpha: 0.2),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  statusInfo['text'],
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: statusInfo['color'],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: operationColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  operationText,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: operationColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                controller.formatDateTime(trade.tradeDate),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // 盈亏信息
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (trade.profitOrLoss != null && trade.profitOrLoss!.isNotEmpty)
                          Text(
                            FormattingUtils.formatCurrency(profitLoss),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: profitColor,
                            ),
                          )
                        else
                          Text(
                            '-',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[500],
                            ),
                          ),
                        if (trade.percentOfPl != null && trade.percentOfPl!.isNotEmpty)
                          Text(
                            '${profitPercent >= 0 ? '+' : ''}${profitPercent.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 10,
                              color: profitColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // 详细数据行 - 紧凑版
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildCompactInfoItem(
                          '数量',
                          '${amount.toStringAsFixed(0)}股',
                          Icons.numbers,
                          Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildCompactInfoItem(
                          '成交价',
                          FormattingUtils.formatCurrency(price),
                          Icons.attach_money,
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildCompactInfoItem(
                          '均价',
                          nowAvgPrice > 0 ? FormattingUtils.formatCurrency(nowAvgPrice) : '-',
                          Icons.trending_up,
                          Colors.orange,
                        ),
                      ),
                      Expanded(
                        child: _buildCompactInfoItem(
                          '摊薄',
                          nowDilutedAvgPrice > 0 ? FormattingUtils.formatCurrency(nowDilutedAvgPrice) : '-',
                          Icons.show_chart,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建紧凑信息项
  Widget _buildCompactInfoItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
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

  /// 显示交易详情 - 使用新的独立对话框
  void _showTradeDetail(BuildContext context, TradingTransaction trade) {
    showDialog(
      context: context,
      builder: (context) => MobileTradeDetailDialog(
        trade: trade,
        controller: controller,
      ),
    );
  }

  /// 显示删除确认对话框
  Future<bool?> _showDeleteConfirmDialog(BuildContext context, TradingTransaction trade) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除这条交易记录吗？\n\n${trade.subPositionSymbol.isNotEmpty ? trade.subPositionSymbol : trade.symbol} - ${controller.getTradeOperationStyle(trade.operate)['text']}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 显示编辑屏幕
  void _showEditDialog(BuildContext context, TradingTransaction trade) {
    // 导航到移动端编辑屏幕
    Get.to(
      () => MobileEditTradeScreen(
        trade: trade,
        onTradeUpdated: (updatedTrade) {
          // 先返回上一页
          Get.back();
          
          // 延迟执行数据加载和提示显示，避免Navigator冲突
          Future.delayed(const Duration(milliseconds: 100), () {
            // 重新加载数据以获取最新的交易记录
            controller.loadData(controller.portfolioId);
          });
        },
      ),
    );
  }

  /// 删除交易记录
  void _deleteRecord(TradingTransaction trade) {
    // 调用控制器的删除方法
    controller.deleteRecord(trade.id).then((result) {
      if (result['success']) {
        // 显示删除成功提示
        SnackbarUtils.success('删除成功',result['message']);
      } else {
        // 检查是否是验证失败
        if (result.containsKey('validationResult')) {
          final validationResult = result['validationResult'] as Map<String, dynamic>;
          final affectedTrade = validationResult['affectedTrade'] as TradingTransaction?;
          String errorMsg = validationResult['message'].toString();
          
          if (affectedTrade != null) {
            // 构建更详细的错误信息
            final dateStr = DateFormat('yyyy-MM-dd').format(affectedTrade.tradeDate);
            errorMsg += '\n受影响的交易: $dateStr (${affectedTrade.symbol}) ${affectedTrade.amount} 股';
          }
          
          // 显示详细错误对话框
          Get.dialog(
            AlertDialog(
              title: const Text('删除失败'),
              content: Text(errorMsg),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('确定'),
                ),
              ],
            ),
          );
        } else {
          // 显示一般删除失败提示
          SnackbarUtils.error('删除失败',result['message']);
        }
      }
    });
  }


} 