import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:trade_flex/core/services/log/log_service.dart';

/// 支付验证服务
/// 负责与后端API通信，验证各平台的支付收据
class PaymentVerificationService {
  // 测试环境的API地址
  static const String _baseUrl = 'http://127.0.0.1:8000/api/v1';

  static final PaymentVerificationService instance = PaymentVerificationService._init();
  PaymentVerificationService._init();

  /// 验证支付收据
  /// 
  /// [platform] 支付平台 ('ios', 'android', 'windows', 'macos')
  /// [receiptData] 收据数据
  /// [userId] 用户标识（可选）
  /// [productId] 产品ID（可选）
  /// 
  /// 返回验证结果
  Future<PaymentVerificationResult> verifyReceipt({
    required String platform,
    required String receiptData,
    String? userId,
    String? productId,
  }) async {
    try {
      LogService.instance.i('开始验证支付收据: platform=$platform, userId=$userId');

      // 构建请求数据
      final requestData = {
        'platform': platform,
        'receipt_data': receiptData,
        if (userId != null) 'user_id': userId,
        if (productId != null) 'product_id': productId,
      };

      // 发送HTTP请求
      final response = await http.post(
        Uri.parse('$_baseUrl/verify/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestData),
      );

      LogService.instance.d('支付验证响应状态: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        final result = PaymentVerificationResult.fromJson(responseData);
        
        LogService.instance.i('支付验证成功: isValid=${result.isValid}, transactionId=${result.transactionId}');
        return result;
      } else {
        final errorData = json.decode(response.body) as Map<String, dynamic>;
        final errorMessage = errorData['error'] ?? '验证失败';
        
        LogService.instance.e('支付验证失败: $errorMessage');
        return PaymentVerificationResult.failure(errorMessage);
      }
    } catch (e) {
      LogService.instance.e('支付验证异常: $e');
      return PaymentVerificationResult.failure('网络错误或服务异常: $e');
    }
  }

  /// 获取用户订阅状态
  /// 
  /// [userId] 用户标识
  /// 
  /// 返回用户订阅状态
  Future<UserSubscriptionStatus> getUserSubscriptionStatus(String userId) async {
    try {
      LogService.instance.i('查询用户订阅状态: userId=$userId');

      final response = await http.get(
        Uri.parse('$_baseUrl/subscription/status/$userId/'),
        headers: {
          'Accept': 'application/json',
        },
      );

      LogService.instance.d('订阅状态查询响应状态: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        final status = UserSubscriptionStatus.fromJson(responseData);
        
        LogService.instance.i('订阅状态查询成功: isPremium=${status.isPremium}, type=${status.subscriptionType}');
        return status;
      } else {
        LogService.instance.e('订阅状态查询失败: ${response.statusCode}');
        return UserSubscriptionStatus.free(userId);
      }
    } catch (e) {
      LogService.instance.e('订阅状态查询异常: $e');
      return UserSubscriptionStatus.free(userId);
    }
  }

  /// 获取用户订阅详情
  /// 
  /// [userId] 用户标识
  /// 
  /// 返回用户订阅详情
  Future<UserSubscriptionDetail?> getUserSubscriptionDetail(String userId) async {
    try {
      LogService.instance.i('查询用户订阅详情: userId=$userId');

      final response = await http.get(
        Uri.parse('$_baseUrl/subscription/detail/$userId/'),
        headers: {
          'Accept': 'application/json',
        },
      );

      LogService.instance.d('订阅详情查询响应状态: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        final detail = UserSubscriptionDetail.fromJson(responseData);
        
        LogService.instance.i('订阅详情查询成功');
        return detail;
      } else {
        LogService.instance.e('订阅详情查询失败: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      LogService.instance.e('订阅详情查询异常: $e');
      return null;
    }
  }

  /// 获取当前平台标识
  String getCurrentPlatform() {
    if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isWindows) {
      return 'windows';
    } else if (Platform.isMacOS) {
      return 'macos';
    } else {
      return 'unknown';
    }
  }
}

/// 支付验证结果
class PaymentVerificationResult {
  final bool isValid;
  final String transactionId;
  final String productType;
  final DateTime? purchaseDate;
  final DateTime? expiryDate;
  final bool isActive;
  final int? daysUntilExpiry;
  final String errorMessage;

  PaymentVerificationResult({
    required this.isValid,
    required this.transactionId,
    required this.productType,
    this.purchaseDate,
    this.expiryDate,
    required this.isActive,
    this.daysUntilExpiry,
    required this.errorMessage,
  });

  factory PaymentVerificationResult.fromJson(Map<String, dynamic> json) {
    return PaymentVerificationResult(
      isValid: json['is_valid'] ?? false,
      transactionId: json['transaction_id'] ?? '',
      productType: json['product_type'] ?? '',
      purchaseDate: json['purchase_date'] != null 
          ? DateTime.parse(json['purchase_date']) 
          : null,
      expiryDate: json['expiry_date'] != null 
          ? DateTime.parse(json['expiry_date']) 
          : null,
      isActive: json['is_active'] ?? false,
      daysUntilExpiry: json['days_until_expiry'],
      errorMessage: json['error_message'] ?? '',
    );
  }

  factory PaymentVerificationResult.failure(String errorMessage) {
    return PaymentVerificationResult(
      isValid: false,
      transactionId: '',
      productType: '',
      purchaseDate: null,
      expiryDate: null,
      isActive: false,
      daysUntilExpiry: null,
      errorMessage: errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_valid': isValid,
      'transaction_id': transactionId,
      'product_type': productType,
      'purchase_date': purchaseDate?.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'is_active': isActive,
      'days_until_expiry': daysUntilExpiry,
      'error_message': errorMessage,
    };
  }

  @override
  String toString() {
    return 'PaymentVerificationResult(isValid: $isValid, transactionId: $transactionId, isActive: $isActive)';
  }
}

/// 用户订阅状态
class UserSubscriptionStatus {
  final String userId;
  final bool isPremium;
  final String? subscriptionType;
  final DateTime? subscriptionExpiry;
  final int? daysUntilExpiry;

  UserSubscriptionStatus({
    required this.userId,
    required this.isPremium,
    this.subscriptionType,
    this.subscriptionExpiry,
    this.daysUntilExpiry,
  });

  factory UserSubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionStatus(
      userId: json['user_id'] ?? '',
      isPremium: json['is_premium'] ?? false,
      subscriptionType: json['subscription_type'],
      subscriptionExpiry: json['subscription_expiry'] != null 
          ? DateTime.parse(json['subscription_expiry']) 
          : null,
      daysUntilExpiry: json['days_until_expiry'],
    );
  }

  factory UserSubscriptionStatus.free(String userId) {
    return UserSubscriptionStatus(
      userId: userId,
      isPremium: false,
      subscriptionType: null,
      subscriptionExpiry: null,
      daysUntilExpiry: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'is_premium': isPremium,
      'subscription_type': subscriptionType,
      'subscription_expiry': subscriptionExpiry?.toIso8601String(),
      'days_until_expiry': daysUntilExpiry,
    };
  }

  @override
  String toString() {
    return 'UserSubscriptionStatus(userId: $userId, isPremium: $isPremium, type: $subscriptionType)';
  }
}

/// 用户订阅详情
class UserSubscriptionDetail {
  final String userId;
  final bool isPremium;
  final String? subscriptionType;
  final DateTime? subscriptionExpiry;
  final PaymentRecordDetail? currentSubscriptionDetails;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSubscriptionDetail({
    required this.userId,
    required this.isPremium,
    this.subscriptionType,
    this.subscriptionExpiry,
    this.currentSubscriptionDetails,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSubscriptionDetail.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionDetail(
      userId: json['user_id'] ?? '',
      isPremium: json['is_premium'] ?? false,
      subscriptionType: json['subscription_type'],
      subscriptionExpiry: json['subscription_expiry'] != null 
          ? DateTime.parse(json['subscription_expiry']) 
          : null,
      currentSubscriptionDetails: json['current_subscription_details'] != null 
          ? PaymentRecordDetail.fromJson(json['current_subscription_details']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'is_premium': isPremium,
      'subscription_type': subscriptionType,
      'subscription_expiry': subscriptionExpiry?.toIso8601String(),
      'current_subscription_details': currentSubscriptionDetails?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// 支付记录详情
class PaymentRecordDetail {
  final int id;
  final String? userId;
  final String platform;
  final String productType;
  final String productId;
  final String transactionId;
  final DateTime purchaseDate;
  final DateTime? expiryDate;
  final String status;
  final DateTime? verificationDate;
  final bool isActive;
  final int? daysUntilExpiry;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentRecordDetail({
    required this.id,
    this.userId,
    required this.platform,
    required this.productType,
    required this.productId,
    required this.transactionId,
    required this.purchaseDate,
    this.expiryDate,
    required this.status,
    this.verificationDate,
    required this.isActive,
    this.daysUntilExpiry,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentRecordDetail.fromJson(Map<String, dynamic> json) {
    return PaymentRecordDetail(
      id: json['id'],
      userId: json['user_id'],
      platform: json['platform'],
      productType: json['product_type'],
      productId: json['product_id'],
      transactionId: json['transaction_id'],
      purchaseDate: DateTime.parse(json['purchase_date']),
      expiryDate: json['expiry_date'] != null 
          ? DateTime.parse(json['expiry_date']) 
          : null,
      status: json['status'],
      verificationDate: json['verification_date'] != null 
          ? DateTime.parse(json['verification_date']) 
          : null,
      isActive: json['is_active'] ?? false,
      daysUntilExpiry: json['days_until_expiry'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'platform': platform,
      'product_type': productType,
      'product_id': productId,
      'transaction_id': transactionId,
      'purchase_date': purchaseDate.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'status': status,
      'verification_date': verificationDate?.toIso8601String(),
      'is_active': isActive,
      'days_until_expiry': daysUntilExpiry,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
