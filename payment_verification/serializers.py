from rest_framework import serializers
from .models import PaymentRecord, VerificationLog, UserSubscription


class PaymentVerificationRequestSerializer(serializers.Serializer):
    """支付验证请求序列化器"""
    
    platform = serializers.ChoiceField(
        choices=['ios', 'android', 'windows', 'macos'],
        help_text='支付平台'
    )
    receipt_data = serializers.CharField(
        max_length=10000,
        help_text='收据数据'
    )
    user_id = serializers.CharField(
        max_length=255,
        required=False,
        allow_blank=True,
        help_text='用户标识（可选）'
    )
    product_id = serializers.CharField(
        max_length=255,
        required=False,
        allow_blank=True,
        help_text='产品ID（可选）'
    )


class PaymentVerificationResponseSerializer(serializers.Serializer):
    """支付验证响应序列化器"""
    
    is_valid = serializers.BooleanField(help_text='验证是否成功')
    transaction_id = serializers.CharField(help_text='交易ID', allow_blank=True)
    product_type = serializers.CharField(help_text='产品类型', allow_blank=True)
    purchase_date = serializers.DateTimeField(help_text='购买时间', allow_null=True)
    expiry_date = serializers.DateTimeField(help_text='到期时间', allow_null=True)
    is_active = serializers.BooleanField(help_text='订阅是否有效')
    days_until_expiry = serializers.IntegerField(help_text='距离过期天数', allow_null=True)
    error_message = serializers.CharField(help_text='错误信息', allow_blank=True)


class UserSubscriptionStatusSerializer(serializers.Serializer):
    """用户订阅状态序列化器"""
    
    user_id = serializers.CharField(help_text='用户标识')
    is_premium = serializers.BooleanField(help_text='是否为付费用户')
    subscription_type = serializers.CharField(help_text='订阅类型', allow_blank=True, allow_null=True)
    subscription_expiry = serializers.DateTimeField(help_text='订阅到期时间', allow_null=True)
    days_until_expiry = serializers.IntegerField(help_text='距离过期天数', allow_null=True)


class PaymentRecordSerializer(serializers.ModelSerializer):
    """支付记录序列化器"""
    
    days_until_expiry = serializers.SerializerMethodField()
    is_active = serializers.SerializerMethodField()
    
    class Meta:
        model = PaymentRecord
        fields = [
            'id', 'user_id', 'platform', 'product_type', 'product_id',
            'transaction_id', 'purchase_date', 'expiry_date',
            'status', 'verification_date', 'is_active', 'days_until_expiry',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_days_until_expiry(self, obj):
        return obj.days_until_expiry()
    
    def get_is_active(self, obj):
        return obj.is_active()


class VerificationLogSerializer(serializers.ModelSerializer):
    """验证日志序列化器"""
    
    class Meta:
        model = VerificationLog
        fields = [
            'id', 'payment_record', 'is_successful', 'error_message',
            'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class UserSubscriptionSerializer(serializers.ModelSerializer):
    """用户订阅序列化器"""
    
    current_subscription_details = PaymentRecordSerializer(
        source='current_subscription',
        read_only=True
    )
    
    class Meta:
        model = UserSubscription
        fields = [
            'user_id', 'is_premium', 'subscription_type', 'subscription_expiry',
            'current_subscription_details', 'created_at', 'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at']
