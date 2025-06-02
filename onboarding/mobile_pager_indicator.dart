import 'package:flutter/material.dart';

/// 移动端页面指示器组件
/// 
/// 专为移动端设计的页面指示器，具有更大的触摸区域和动画效果
class MobilePagerIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final Function(int) onPageSelected;
  final Color activeColor;
  final Color inactiveColor;

  const MobilePagerIndicator({
    Key? key,
    required this.currentPage,
    required this.pageCount,
    required this.onPageSelected,
    required this.activeColor,
    required this.inactiveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(pageCount, (index) {
          final isActive = index == currentPage;
          return GestureDetector(
            onTap: () => onPageSelected(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
} 