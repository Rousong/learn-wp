import 'package:flutter/material.dart';
import 'package:trade_flex/mobile/trading/widgets/mobile_portfolio_summary_card.dart';
import 'package:trade_flex/mobile/trading/widgets/mobile_current_position_card.dart';
import 'package:trade_flex/mobile/trading/widgets/mobile_note_card.dart';

/// 移动端卡片轮播组件
/// 
/// 用于显示多个卡片并支持左右滑动
class MobileCardCarousel extends StatefulWidget {
  const MobileCardCarousel({Key? key}) : super(key: key);

  @override
  State<MobileCardCarousel> createState() => _MobileCardCarouselState();
}

class _MobileCardCarouselState extends State<MobileCardCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 卡片区域
        SizedBox(
          height: 220, // 降低卡片高度
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: const [
              // 投资组合概览卡片
              MobilePortfolioSummaryCard(),
              
              // 当前持仓卡片
              MobileCurrentPositionCard(),
              
              // 笔记卡片
              MobileNoteCard(),
            ],
          ),
        ),
        
        // 页面指示器
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _totalPages,
            (index) => _buildIndicator(index),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator(int index) {
    final bool isActive = index == _currentPage;
    
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 8,
        width: isActive ? 24 : 8,
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
} 