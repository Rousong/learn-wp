import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:trade_flex/core/utils/theme_helper.dart';
import 'package:trade_flex/core/controllers/position/position_grid_controller.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/repositories/sub_position_repository.dart';
import 'package:trade_flex/mobile/position/widgets/mobile_position_card.dart';
import 'package:trade_flex/mobile/position/widgets/mobile_sub_position_card.dart';

/// 移动端持仓列表组件
class MobilePositionList extends StatefulWidget {
  final List<PlutoRow> positions;
  final bool isLongPosition;

  const MobilePositionList({
    super.key,
    required this.positions,
    required this.isLongPosition,
  });

  @override
  State<MobilePositionList> createState() => _MobilePositionListState();
}

class _MobilePositionListState extends State<MobilePositionList> {
  final SubPositionRepository _subPositionRepository = SubPositionRepository.instance;
  final Map<int, List<SubPosition>> _subPositionsCache = {};
  final Map<int, bool> _expandedStates = {};
  late final PositionGridController _gridController;

  @override
  void initState() {
    super.initState();
    _gridController = Get.find<PositionGridController>();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.positions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              widget.isLongPosition ? '暂无多头持仓' : '暂无空头持仓',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      itemCount: widget.positions.length,
      itemBuilder: (context, index) {
        final position = widget.positions[index];
        final positionId = position.cells['id']?.value as int?;
        
        if (positionId == null) return const SizedBox.shrink();

        return _buildPositionItem(context, position, positionId, index);
      },
    );
  }

  /// 构建持仓项目
  Widget _buildPositionItem(BuildContext context, PlutoRow position, int positionId, int index) {
    final isExpanded = _expandedStates[positionId] ?? false;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 2,
      color: ThemeHelper.getSurfaceColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withAlpha(20),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 主持仓卡片
          MobilePositionCard(
            position: position,
            isLongPosition: widget.isLongPosition,
            isExpanded: isExpanded,
            onTap: () => _toggleExpansion(positionId),
            onEdit: () => _editPosition(position),
            onDelete: () => _deletePosition(position),
          ),
          // 子持仓列表
          if (isExpanded) _buildSubPositionsList(context, positionId),
        ],
      ),
    );
  }

  /// 构建子持仓列表
  Widget _buildSubPositionsList(BuildContext context, int positionId) {
    return FutureBuilder<List<SubPosition>>(
      future: _getSubPositions(positionId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '加载子持仓失败: ${snapshot.error}',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          );
        }

        final subPositions = snapshot.data ?? [];
        
        if (subPositions.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '暂无子持仓',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          );
        }

        return Column(
          children: [
            // 子持仓标题栏
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        '子持仓 (${subPositions.length})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...subPositions.map((subPosition) => MobileSubPositionCard(
              subPosition: subPosition,
              onEdit: () => _editSubPosition(subPosition),
              onDelete: () => _deleteSubPosition(subPosition),
            )),
          ],
        );
      },
    );
  }

  /// 获取子持仓数据
  Future<List<SubPosition>> _getSubPositions(int positionId) async {
    // 检查缓存
    if (_subPositionsCache.containsKey(positionId)) {
      return _subPositionsCache[positionId]!;
    }

    // 从数据库获取
    final subPositions = await _subPositionRepository.getSubPositionsByParentId(positionId);
    
    // 缓存结果
    _subPositionsCache[positionId] = subPositions;
    
    return subPositions;
  }

  /// 切换展开状态
  void _toggleExpansion(int positionId) {
    setState(() {
      _expandedStates[positionId] = !(_expandedStates[positionId] ?? false);
    });
  }

  /// 编辑主持仓
  void _editPosition(PlutoRow position) {
    final positionId = position.cells['id']?.value as int?;
    
    if (positionId == null) {
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法获取持仓ID')),
        );
      }
      return;
    }
    
    // 导航到移动端编辑页面
    Get.toNamed('/editMainPosition', arguments: {
      'positionId': positionId,
      'onEditComplete': () {
        // 编辑完成后刷新数据
        _gridController.refreshTables();
      },
    });
  }

  /// 编辑子持仓
  void _editSubPosition(SubPosition subPosition) {
    // 导航到移动端编辑页面
    Get.toNamed('/editSubPosition', arguments: {
      'positionId': subPosition.parentPositionId,
      'subPositionId': subPosition.id,
      'onEditComplete': () {
        // 编辑完成后刷新数据
        _gridController.refreshTables();
      },
    });
  }
  
  /// 删除主持仓
  void _deletePosition(PlutoRow position) {
    final positionId = position.cells['id']?.value as int?;
    
    if (positionId == null) {
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法获取持仓ID')),
        );
      }
      return;
    }
    
    // 使用控制器的删除方法
    _gridController.deletePosition(positionId.toString(), true, context);
    
    // 删除后清除缓存
    _subPositionsCache.remove(positionId);
    _expandedStates.remove(positionId);
  }
  
  /// 删除子持仓
  void _deleteSubPosition(SubPosition subPosition) {
    // 使用控制器的删除方法
    _gridController.deletePosition(subPosition.id.toString(), false, context);
    
    // 删除后清除缓存
    _subPositionsCache.remove(subPosition.parentPositionId);
  }
} 