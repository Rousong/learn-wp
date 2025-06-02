import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 移动端空投资组合屏幕
/// 
/// 当用户没有投资组合时显示的界面
class MobileEmptyPortfolioScreen extends StatelessWidget {
  const MobileEmptyPortfolioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 空状态图标
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.folder_open,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 标题
              const Text(
                '还没有投资组合',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // 描述
              Text(
                '创建您的第一个投资组合\n开始记录和分析您的交易',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // 创建按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: 导航到创建投资组合页面
                    Get.snackbar(
                      '提示',
                      '创建投资组合功能即将推出',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text(
                    '创建投资组合',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 导入按钮
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: 导航到导入投资组合页面
                    Get.snackbar(
                      '提示',
                      '导入投资组合功能即将推出',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  icon: const Icon(Icons.upload_file),
                  label: const Text(
                    '导入现有数据',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 