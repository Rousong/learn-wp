import 'package:flutter/material.dart';

/// 移动端分析表现页面内容组件
/// 
/// 展示交易分析功能的介绍
class MobileAnalyzePerformancePageContent extends StatelessWidget {
  const MobileAnalyzePerformancePageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 主要图标
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(60),
          ),
          child: const Icon(
            Icons.analytics,
            size: 60,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 24),
        
        // 分析功能展示
        Row(
          children: [
            Expanded(
              child: _buildAnalysisCard(
                context,
                Icons.trending_up,
                '收益率',
                '实时计算投资回报',
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnalysisCard(
                context,
                Icons.pie_chart,
                '资产分布',
                '可视化投资组合',
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildAnalysisCard(
                context,
                Icons.show_chart,
                '趋势分析',
                '发现交易模式',
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnalysisCard(
                context,
                Icons.assessment,
                '风险评估',
                '管理投资风险',
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalysisCard(BuildContext context, IconData icon, String title, String description, Color color) {
    return Container(
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
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 