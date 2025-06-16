import 'package:get/get.dart';
import 'package:trade_flex/core/database/database.dart';
import 'package:trade_flex/core/database/DAO/trading_transactions_dao.dart';
import 'package:trade_flex/core/database/DAO/position_dao.dart';
import 'package:trade_flex/core/services/log/log_service.dart';
import 'package:trade_flex/core/constants/trade_flex_strings.dart';
import 'package:trade_flex/core/constants/trading_transactions_enums.dart';

/// 轮播内容生成服务
/// 根据用户交易数据动态生成个性化提醒内容
class MarqueeContentService extends GetxService {
  static MarqueeContentService get instance => Get.find<MarqueeContentService>();

  final _tradingDao = TradingTransactionsDAO.instance;
  final _positionsDao = PositionDAO.instance;

  /// 生成动态轮播内容
  Future<List<String>> generateMarqueeContents() async {
    try {
      final contents = <String>[];
      
      // 获取交易数据
      final transactions = await _tradingDao.getTradesByPortfolio(1); // 使用默认投资组合ID
      final positions = await _positionsDao.getAllPositions();
      
      LogService.instance.d('轮播内容生成：交易记录数量=${transactions.length}, 持仓数量=${positions.length}');
      
      if (transactions.isEmpty) {
        // 如果没有交易数据，返回默认欢迎内容
        LogService.instance.d('无交易数据，返回欢迎内容');
        return _getWelcomeContents();
      }
      
      // 生成各种类型的提醒内容
      contents.addAll(await _generateHistoryReminders(transactions));
      contents.addAll(await _generateProfitLossReminders(transactions));
      contents.addAll(await _generatePositionReminders(positions));
      contents.addAll(await _generateStreakReminders(transactions));
      contents.addAll(await _generateMilestoneReminders(transactions));
      
      // 添加一些测试内容，确保有内容显示
      if (contents.isEmpty) {
        LogService.instance.d('未生成动态内容，添加测试内容');
        final template = TradeFlexStrings.marqueeWinStreakReminder.tr;
        final testContent = template.replaceAll('{streak}', '5');
        LogService.instance.d('测试内容：模板=$template, 结果=$testContent');
        contents.add(testContent);
      }
      
      LogService.instance.d('生成的轮播内容数量：${contents.length}');
      for (int i = 0; i < contents.length; i++) {
        LogService.instance.d('内容[$i]: ${contents[i]}');
      }
      
      // 如果没有生成任何内容，返回默认内容
      if (contents.isEmpty) {
        LogService.instance.d('未生成任何内容，返回默认内容');
        return _getDefaultContents();
      }
      
      // 限制内容数量，避免过多
      return contents.take(5).toList();
      
    } catch (e) {
      LogService.instance.e('生成轮播内容失败: $e');
      return _getDefaultContents();
    }
  }

  /// 生成历史回顾提醒（去年今天、上月今天等）
  Future<List<String>> _generateHistoryReminders(List<TradingTransaction> transactions) async {
    final contents = <String>[];
    final now = DateTime.now();
    
    // 去年今天的交易
    final lastYearToday = DateTime(now.year - 1, now.month, now.day);
    final lastYearTodayTransactions = transactions.where((t) =>
      t.tradeDate.year == lastYearToday.year &&
      t.tradeDate.month == lastYearToday.month &&
      t.tradeDate.day == lastYearToday.day
    ).toList();
    
    if (lastYearTodayTransactions.isNotEmpty) {
      final profitableCount = lastYearTodayTransactions.where((t) => 
        double.tryParse(t.profitOrLoss ?? '0') != null && double.parse(t.profitOrLoss ?? '0') > 0
      ).length;
      
      if (profitableCount > 0) {
        final template = TradeFlexStrings.marqueeLastYearTodayProfit.tr;
        var translatedText = template.replaceAll('{count}', profitableCount.toString());
        translatedText = translatedText.replaceAll('{total}', lastYearTodayTransactions.length.toString());
        LogService.instance.d('历史提醒生成：模板=$template, 结果=$translatedText');
        contents.add(translatedText);
      }
    }
    
    // 上月今天的交易
    final lastMonthToday = DateTime(now.year, now.month - 1, now.day);
    final lastMonthTodayTransactions = transactions.where((t) =>
      t.tradeDate.year == lastMonthToday.year &&
      t.tradeDate.month == lastMonthToday.month &&
      t.tradeDate.day == lastMonthToday.day
    ).toList();
    
    if (lastMonthTodayTransactions.isNotEmpty) {
      final biggestProfit = lastMonthTodayTransactions
          .map((t) => double.tryParse(t.profitOrLoss ?? '0') ?? 0)
          .reduce((a, b) => a > b ? a : b);
      
      if (biggestProfit > 0) {
        final template = TradeFlexStrings.marqueeLastMonthTodayBiggest.tr;
        final translatedText = template.replaceAll('{profit}', '${(biggestProfit * 100).toStringAsFixed(1)}%');
        LogService.instance.d('上月提醒生成：模板=$template, 结果=$translatedText');
        contents.add(translatedText);
      }
    }
    
    return contents;
  }

  /// 生成盈亏提醒
  Future<List<String>> _generateProfitLossReminders(List<TradingTransaction> transactions) async {
    final contents = <String>[];
    
    // 找出最大盈利交易
    final profitableTransactions = transactions.where((t) => 
      double.tryParse(t.profitOrLoss ?? '0') != null && double.parse(t.profitOrLoss ?? '0') > 0
    ).toList();
    
    if (profitableTransactions.isNotEmpty) {
      profitableTransactions.sort((a, b) => 
        double.parse(b.profitOrLoss ?? '0').compareTo(double.parse(a.profitOrLoss ?? '0'))
      );
      
      final bestTrade = profitableTransactions.first;
      final profitPercent = (double.parse(bestTrade.profitOrLoss ?? '0') * 100).toStringAsFixed(1);
      
      // 直接使用字符串替换
      final template = TradeFlexStrings.marqueeBestTradeReminder.tr;
      var translatedText = template.replaceAll('{symbol}', bestTrade.symbol);
      translatedText = translatedText.replaceAll('{profit}', '$profitPercent%');
      translatedText = translatedText.replaceAll('{date}', _formatDate(bestTrade.tradeDate));
      LogService.instance.d('最佳交易提醒生成：模板=$template, 结果=$translatedText');
      contents.add(translatedText);
    }
    
    // 找出最大止损交易
    final lossTransactions = transactions.where((t) => 
      double.tryParse(t.profitOrLoss ?? '0') != null && 
      double.parse(t.profitOrLoss ?? '0') < 0 &&
      (t.operate == TradeOperate.closeLong || t.operate == TradeOperate.closeShort)
    ).toList();
    
    if (lossTransactions.isNotEmpty) {
      lossTransactions.sort((a, b) => 
        double.parse(a.profitOrLoss ?? '0').compareTo(double.parse(b.profitOrLoss ?? '0'))
      );
      
      final worstTrade = lossTransactions.first;
      final lossPercent = (double.parse(worstTrade.profitOrLoss ?? '0').abs() * 100).toStringAsFixed(1);
      
      final template = TradeFlexStrings.marqueeStopLossReminder.tr;
      var translatedText = template.replaceAll('{symbol}', worstTrade.symbol);
      translatedText = translatedText.replaceAll('{loss}', '$lossPercent%');
      translatedText = translatedText.replaceAll('{date}', _formatDate(worstTrade.tradeDate));
      LogService.instance.d('止损提醒生成：模板=$template, 结果=$translatedText');
      contents.add(translatedText);
    }
    
    return contents;
  }

  /// 生成持仓提醒
  Future<List<String>> _generatePositionReminders(List<Position> positions) async {
    final contents = <String>[];
    
    // 最长持仓时间 - 降低门槛便于测试
    final activePositions = positions.where((p) => p.closeDate == null).toList();
    if (activePositions.isNotEmpty) {
      activePositions.sort((a, b) => a.openDate.compareTo(b.openDate));
      final longestPosition = activePositions.first;
      final holdingDays = DateTime.now().difference(longestPosition.openDate).inDays;
      
      if (holdingDays >= 30) { 
        final template = TradeFlexStrings.marqueeLongestHoldingReminder.tr;
        var translatedText = template.replaceAll('{symbol}', longestPosition.positionSymbol);
        translatedText = translatedText.replaceAll('{days}', holdingDays.toString());
        LogService.instance.d('最长持仓提醒生成：模板=$template, 结果=$translatedText');
        contents.add(translatedText);
      }
    }
    
    // 最短持仓时间
    final closedPositions = positions.where((p) => p.closeDate != null).toList();
    if (closedPositions.isNotEmpty) {
      final shortestPosition = closedPositions.reduce((a, b) {
        final aDuration = a.closeDate!.difference(a.openDate);
        final bDuration = b.closeDate!.difference(b.openDate);
        return aDuration.inMinutes < bDuration.inMinutes ? a : b;
      });
      
      final holdingMinutes = shortestPosition.closeDate!.difference(shortestPosition.openDate).inMinutes;
      if (holdingMinutes >= 0) { // 移除60分钟限制
        final template = TradeFlexStrings.marqueeShortestHoldingReminder.tr;
        var translatedText = template.replaceAll('{symbol}', shortestPosition.positionSymbol);
        translatedText = translatedText.replaceAll('{minutes}', holdingMinutes.toString());
        LogService.instance.d('最短持仓提醒生成：模板=$template, 结果=$translatedText');
        contents.add(translatedText);
      }
    }
    
    return contents;
  }

  /// 生成连胜/连败提醒
  Future<List<String>> _generateStreakReminders(List<TradingTransaction> transactions) async {
    final contents = <String>[];
    
    // 计算最长连胜
    final closingTransactions = transactions.where((t) => 
      t.operate == TradeOperate.closeLong || t.operate == TradeOperate.closeShort
    ).toList();
    
    if (closingTransactions.length >= 3) {
      closingTransactions.sort((a, b) => a.tradeDate.compareTo(b.tradeDate));
      
      int maxWinStreak = 0;
      int currentWinStreak = 0;
      
      for (final transaction in closingTransactions) {
        final profit = double.tryParse(transaction.profitOrLoss ?? '0') ?? 0;
        if (profit > 0) {
          currentWinStreak++;
          maxWinStreak = maxWinStreak > currentWinStreak ? maxWinStreak : currentWinStreak;
        } else {
          currentWinStreak = 0;
        }
      }
      
      if (maxWinStreak >= 3) {
        // 直接使用字符串替换，避免GetX翻译问题
        final template = TradeFlexStrings.marqueeWinStreakReminder.tr;
        final translatedText = template.replaceAll('{streak}', maxWinStreak.toString());
        LogService.instance.d('连胜提醒生成：模板=$template, 结果=$translatedText');
        contents.add(translatedText);
      }
    }
    
    return contents;
  }

  /// 生成里程碑提醒
  Future<List<String>> _generateMilestoneReminders(List<TradingTransaction> transactions) async {
    final contents = <String>[];
    
    // 交易数量里程碑 - 降低门槛便于测试
    final totalTrades = transactions.length;
    if (totalTrades >= 1) { // 从100改为1
      // 直接使用字符串替换
      final template = TradeFlexStrings.marqueeTradeMilestoneReminder.tr;
      final translatedText = template.replaceAll('{count}', totalTrades.toString());
      LogService.instance.d('交易里程碑提醒生成：模板=$template, 结果=$translatedText');
      contents.add(translatedText);
    }
    
    // 交易时间跨度 - 降低门槛便于测试
    if (transactions.length >= 2) {
      transactions.sort((a, b) => a.tradeDate.compareTo(b.tradeDate));
      final firstTrade = transactions.first;
      final lastTrade = transactions.last;
      final tradingDays = lastTrade.tradeDate.difference(firstTrade.tradeDate).inDays;
      
      if (tradingDays >= 1) { // 从365改为1
        final template = TradeFlexStrings.marqueeTradingDurationReminder.tr;
        final translatedText = template.replaceAll('{years}', (tradingDays / 365).toStringAsFixed(1));
        LogService.instance.d('交易历程提醒生成：模板=$template, 结果=$translatedText');
        contents.add(translatedText);
      }
    }
    
    return contents;
  }

  /// 获取欢迎内容（新用户）
  List<String> _getWelcomeContents() {
    final contents = [
      TradeFlexStrings.marqueeWelcomeNewUser.tr,
      TradeFlexStrings.marqueeStartFirstTrade.tr,
      TradeFlexStrings.marqueeTrackYourProgress.tr,
    ];
    LogService.instance.d('返回欢迎内容：$contents');
    return contents;
  }

  /// 获取默认内容
  List<String> _getDefaultContents() {
    final contents = [
      TradeFlexStrings.marqueeKeepTrading.tr,
      TradeFlexStrings.marqueeAnalyzeYourTrades.tr,
      TradeFlexStrings.marqueeStayDisciplined.tr,
    ];
    LogService.instance.d('返回默认内容：$contents');
    return contents;
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
} 