import 'package:flutter/material.dart';

/// 移动端欢迎页面内容组件
/// 
/// 专为移动端设计的欢迎页面，具有简洁的布局和动画效果
class MobileWelcomePageContent extends StatelessWidget {
  const MobileWelcomePageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 主要图标或插图
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(60),
          ),
          child: Icon(
            Icons.trending_up,
            size: 60,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        
        // 功能特点列表
        _buildFeatureItem(
          context,
          Icons.track_changes,
          '记录交易',
          '轻松记录每一笔交易的详细信息',
        ),
        const SizedBox(height: 16),
        
        _buildFeatureItem(
          context,
          Icons.analytics,
          '分析表现',
          '深入分析您的交易策略和收益',
        ),
        const SizedBox(height: 16),
        
        _buildFeatureItem(
          context,
          Icons.insights,
          '获得洞察',
          '发现交易模式，提升投资技能',
        ),
      ],
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).primaryColor,
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
    );
  }
} 