import 'package:get/get.dart';
import 'package:trade_flex/core/repositories/tag_repository.dart';
import 'package:trade_flex/core/services/log/log_service.dart';

/// 移动端交易详情控制器
/// 
/// 负责管理交易详情页面的数据，包括标签数据的加载和处理
class MobileTradeDetailController extends GetxController {
  final TagRepository _tagRepository = TagRepository.instance;
  
  // 交易ID
  final int tradeId;
  
  // 标签数据
  final RxList<String> tags = <String>[].obs;
  
  // 加载状态
  final RxBool isLoading = false.obs;
  
  MobileTradeDetailController({required this.tradeId});
  
  @override
  void onInit() {
    super.onInit();
    loadTags();
  }
  
  /// 加载交易标签
  Future<void> loadTags() async {
    try {
      isLoading.value = true;
      
      // 使用TagRepository的getTagsForTransaction方法，与桌面端保持一致
      final tagList = await _tagRepository.getTagsForTransaction(tradeId);
      
      // 提取标签名称
      final tagNames = tagList.map((tag) => tag.tagName).toList();
      
      // 更新标签列表
      tags.value = tagNames;
      
      LogService.instance.d('成功加载交易 $tradeId 的标签，共 ${tags.length} 个标签');
    } catch (e) {
      LogService.instance.e('加载交易标签失败: $e');
    } finally {
      isLoading.value = false;
    }
  }
} 