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
  bool _hasScrolledToBottom = false;
  bool _isAgreed = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
      if (!_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 协议内容
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '用户许可协议',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
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
                  
                  const SizedBox(height: 20),
                  
                  if (_hasScrolledToBottom)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              '您已阅读完整个协议，现在可以选择同意',
                              style: TextStyle(fontSize: 14),
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
        
        const SizedBox(height: 16),
        
        // 同意选项
        Row(
          children: [
            Checkbox(
              value: _isAgreed,
              onChanged: _hasScrolledToBottom ? (value) {
                setState(() {
                  _isAgreed = value ?? false;
                });
              } : null,
              activeColor: Theme.of(context).primaryColor,
            ),
            Expanded(
              child: GestureDetector(
                onTap: _hasScrolledToBottom ? () {
                  setState(() {
                    _isAgreed = !_isAgreed;
                  });
                } : null,
                child: Text(
                  '我已阅读并同意用户许可协议',
                  style: TextStyle(
                    fontSize: 14,
                    color: _hasScrolledToBottom ? Colors.black87 : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 同意按钮
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isAgreed ? widget.onAgreed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '同意并继续',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

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
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
} 