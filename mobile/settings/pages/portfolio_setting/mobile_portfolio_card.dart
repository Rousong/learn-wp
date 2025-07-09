import 'package:flutter/material.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/controllers/settings/portfolio_settings_controller.dart';

/// 移动端投资组合卡片组件
/// 
/// 显示投资组合信息的卡片，适配移动端布局
/// 支持展开/收起显示详细信息和操作按钮
class MobilePortfolioCard extends StatefulWidget {
  /// 投资组合数据
  final Portfolio portfolio;
  
  /// 控制器
  final PortfolioSettingsController controller;

  const MobilePortfolioCard({
    super.key,
    required this.portfolio,
    required this.controller,
  });

  @override
  State<MobilePortfolioCard> createState() => _MobilePortfolioCardState();
}

class _MobilePortfolioCardState extends State<MobilePortfolioCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final portfolioColor = widget.controller.getPortfolioColor(widget.portfolio.portfolioType, context);
    final isClosed = widget.portfolio.isClosed;
    
    // 根据状态调整颜色
    final cardColor = isClosed 
        ? (theme.brightness == Brightness.dark 
            ? Colors.grey.shade800.withValues(alpha: 0.4) 
            : Colors.grey.shade200)
        : colorScheme.surface;
    final textColor = isClosed ? Colors.grey.shade600 : null;
    final iconColor = isClosed ? portfolioColor.withValues(alpha: 0.2) : portfolioColor;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: Column(
        children: [
          // 主要信息区域
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 投资组合图标
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.controller.getPortfolioIcon(widget.portfolio.portfolioType),
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // 投资组合信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 投资组合名称
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.portfolio.portfolioName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: textColor ?? colorScheme.onSurface,
                                  decoration: isClosed ? TextDecoration.lineThrough : null,
                                  decorationColor: Colors.grey,
                                ),
                              ),
                            ),
                            // 状态标签
                            if (isClosed)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '已关闭',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // 投资组合类型和币种
                        Text(
                          '${widget.controller.getPortfolioTypeLabel(widget.portfolio.portfolioType)} · ${widget.controller.getCurrencyLabel(widget.portfolio.currency)} · ${widget.controller.getDirectionLabel(widget.portfolio.direction)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: textColor ?? colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 展开/收起图标
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
          
          // 展开的详细信息
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 详细信息
                  _buildDetailRow('货币类型', widget.controller.getCurrencyLabel(widget.portfolio.currency), textColor),
                  _buildDetailRow('投资类型', widget.controller.getPortfolioTypeLabel(widget.portfolio.portfolioType), textColor),
                  _buildDetailRow('交易方向', widget.controller.getDirectionLabel(widget.portfolio.direction), textColor),
                  _buildDetailRow(
                    '收费模式', 
                    widget.portfolio.feeModeId != null 
                        ? widget.controller.getFeeModeLabel(widget.portfolio.feeModeId) 
                        : '不记录手续费', 
                    textColor
                  ),
                  _buildDetailRow('创建时间', widget.portfolio.createTime.toString().substring(0, 19), textColor),
                  
                  const SizedBox(height: 16),
                  
                  // 操作按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 编辑按钮
                      _buildActionButton(
                        icon: Icons.edit_outlined,
                        label: '编辑',
                        onPressed: () => widget.controller.showMobileEditPortfolioBottomSheet(widget.portfolio),
                        color: colorScheme.primary,
                      ),
                      
                      // 状态切换按钮
                      _buildActionButton(
                        icon: isClosed ? Icons.play_circle_outline : Icons.pause_circle_outline,
                        label: isClosed ? '激活' : '关闭',
                        onPressed: () => widget.controller.togglePortfolioStatus(widget.portfolio),
                        color: isClosed ? Colors.green : Colors.orange.shade700,
                      ),
                      
                      // 删除按钮
                      _buildActionButton(
                        icon: Icons.delete_outline,
                        label: '删除',
                        onPressed: () => widget.controller.deletePortfolio(widget.portfolio),
                        color: colorScheme.error,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建详细信息行
  Widget _buildDetailRow(String label, String value, Color? textColor) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor ?? theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            foregroundColor: color,
            backgroundColor: color.withValues(alpha: 0.1),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 8),
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
} 