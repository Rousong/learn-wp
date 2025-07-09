import 'package:flutter/material.dart';

/// 移动端用户许可协议页面
/// 
/// 展示用户许可协议内容并处理用户同意操作
class MobileEulaPageContent extends StatefulWidget {
  final VoidCallback onAgreed;

  const MobileEulaPageContent({
    Key? key,
    required this.onAgreed,
  }) : super(key: key);

  @override
  State<MobileEulaPageContent> createState() => _MobileEulaPageContentState();
}

class _MobileEulaPageContentState extends State<MobileEulaPageContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 页面标题
          Text(
            '用户许可协议',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          
          // 协议内容
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '重要提示：',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '在使用本软件（以下简称"本软件"）之前，请您仔细阅读并理解本协议的全部内容。一旦您下载、安装、复制或以其他方式使用本软件，即表示您同意受本协议的约束。',
                      style: TextStyle(height: 1.6),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildSection('1. 接受条款', 
                      '通过下载、安装或使用Trade Flex应用程序，您同意受本协议条款的约束。如果您不同意这些条款，请不要使用本应用程序。'),
                    
                    _buildSection('2. 应用程序描述', 
                      'Trade Flex是一款交易日记应用程序，旨在帮助用户记录、跟踪和分析他们的投资交易。本应用程序仅供个人使用。'),
                    
                    _buildSection('3. 数据隐私', 
                      '我们重视您的隐私。您的交易数据将存储在您的设备上，我们不会收集或传输您的个人交易信息到我们的服务器。'),
                    
                    _buildSection('4. 免责声明', 
                      '本应用程序提供的信息仅供参考，不构成投资建议。投资有风险，您应该根据自己的判断做出投资决策。'),
                    
                    _buildSection('5. 使用限制', 
                      '您同意不会将本应用程序用于任何非法目的，也不会以任何可能损害、禁用、过载或损害应用程序的方式使用。'),
                    
                    _buildSection('6. 更新和修改', 
                      '我们保留随时修改本协议的权利。任何修改将在应用程序中发布，继续使用应用程序即表示您接受修改后的条款。'),
                    
                    const SizedBox(height: 16),
                    const Text(
                      '您一旦点击"我已阅读并同意上述协议"或实际使用本软件，即视为已阅读、理解并同意接受本协议的全部条款。',
                      style: TextStyle(fontWeight: FontWeight.bold, height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 同意按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onAgreed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '我已阅读并同意上述协议',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建协议条款段落
  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
} 