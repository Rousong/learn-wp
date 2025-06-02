import 'package:flutter/material.dart';

/// 移动端跟踪交易页面内容组件
/// 
/// 展示交易记录功能的介绍
class MobileTrackTradesPageContent extends StatelessWidget {
  const MobileTrackTradesPageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 主要图标
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(60),
          ),
          child: const Icon(
            Icons.timeline,
            size: 60,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 24),
        
        // 功能介绍
        _buildFeatureCard(
          context,
          Icons.add_circle_outline,
          '快速记录',
          '一键添加买入和卖出交易',
          Colors.blue,
        ),
        const SizedBox(height: 12),
        
        _buildFeatureCard(
          context,
          Icons.edit_note,
          '详细信息',
          '记录价格、数量、手续费等',
          Colors.orange,
        ),
        const SizedBox(height: 12),
        
        _buildFeatureCard(
          context,
          Icons.history,
          '交易历史',
          '查看完整的交易记录',
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha:0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 