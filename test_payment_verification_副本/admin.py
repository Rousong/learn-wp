from django.contrib import admin
from django.utils.html import format_html
from django.urls import reverse
from django.utils.safestring import mark_safe
import json

from .models import PaymentRecord, VerificationLog, UserSubscription


@admin.register(PaymentRecord)
class PaymentRecordAdmin(admin.ModelAdmin):
    """支付记录管理 - 测试版本"""
    
    list_display = [
        'transaction_id', 'user_id', 'platform', 'product_type', 
        'status', 'purchase_date', 'expiry_date', 'is_active_display',
        'days_until_expiry_display', 'created_at'
    ]
    
    list_filter = [
        'platform', 'product_type', 'status', 'purchase_date', 'created_at'
    ]
    
    search_fields = [
        'transaction_id', 'user_id', 'product_id'
    ]
    
    readonly_fields = [
        'transaction_id', 'receipt_data_display', 'verification_response_display',
        'is_active_display', 'days_until_expiry_display', 'created_at', 'updated_at'
    ]
    
    fieldsets = (
        ('基本信息 (测试)', {
            'fields': ('user_id', 'platform', 'product_type', 'product_id')
        }),
        ('支付信息 (测试)', {
            'fields': ('transaction_id', 'purchase_date', 'expiry_date', 'receipt_data_display')
        }),
        ('验证状态 (测试)', {
            'fields': ('status', 'verification_date', 'verification_response_display')
        }),
        ('状态信息 (测试)', {
            'fields': ('is_active_display', 'days_until_expiry_display')
        }),
        ('时间戳', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    def is_active_display(self, obj):
        """显示是否有效"""
        if obj.is_active():
            return format_html('<span style="color: green;">✓ 有效 (测试)</span>')
        else:
            return format_html('<span style="color: red;">✗ 无效 (测试)</span>')
    is_active_display.short_description = '是否有效'
    
    def days_until_expiry_display(self, obj):
        """显示距离过期天数"""
        days = obj.days_until_expiry()
        if days is None:
            return '永不过期 (测试)'
        elif days == 0:
            return format_html('<span style="color: red;">已过期 (测试)</span>')
        elif days <= 7:
            return format_html('<span style="color: orange;">{} 天 (测试)</span>', days)
        else:
            return f'{days} 天 (测试)'
    days_until_expiry_display.short_description = '距离过期'
    
    def receipt_data_display(self, obj):
        """显示收据数据（截断）"""
        if obj.receipt_data:
            truncated = obj.receipt_data[:200] + '...' if len(obj.receipt_data) > 200 else obj.receipt_data
            return format_html('<pre style="max-width: 400px; overflow: auto;">[TEST] {}</pre>', truncated)
        return '无'
    receipt_data_display.short_description = '收据数据'
    
    def verification_response_display(self, obj):
        """显示验证响应（格式化JSON）"""
        if obj.verification_response:
            try:
                data = json.loads(obj.verification_response)
                formatted = json.dumps(data, indent=2, ensure_ascii=False)
                return format_html('<pre style="max-width: 400px; overflow: auto;">[TEST] {}</pre>', formatted)
            except:
                return f'[TEST] {obj.verification_response}'
        return '无'
    verification_response_display.short_description = '验证响应'


@admin.register(VerificationLog)
class VerificationLogAdmin(admin.ModelAdmin):
    """验证日志管理 - 测试版本"""
    
    list_display = [
        'payment_record', 'is_successful', 'request_ip', 
        'created_at', 'error_message_short'
    ]
    
    list_filter = [
        'is_successful', 'created_at', 'payment_record__platform'
    ]
    
    search_fields = [
        'payment_record__transaction_id', 'request_ip', 'error_message'
    ]
    
    readonly_fields = [
        'payment_record', 'request_data_display', 'response_data_display',
        'created_at'
    ]
    
    fieldsets = (
        ('基本信息 (测试)', {
            'fields': ('payment_record', 'is_successful', 'created_at')
        }),
        ('请求信息 (测试)', {
            'fields': ('request_ip', 'user_agent', 'request_data_display')
        }),
        ('响应信息 (测试)', {
            'fields': ('response_data_display', 'error_message')
        }),
    )
    
    def error_message_short(self, obj):
        """显示错误信息（截断）"""
        if obj.error_message:
            message = obj.error_message[:50] + '...' if len(obj.error_message) > 50 else obj.error_message
            return f'[TEST] {message}'
        return '无'
    error_message_short.short_description = '错误信息'
    
    def request_data_display(self, obj):
        """显示请求数据（格式化）"""
        if obj.request_data:
            try:
                data = json.loads(obj.request_data)
                formatted = json.dumps(data, indent=2, ensure_ascii=False)
                return format_html('<pre style="max-width: 400px; overflow: auto;">[TEST] {}</pre>', formatted)
            except:
                return f'[TEST] {obj.request_data}'
        return '无'
    request_data_display.short_description = '请求数据'
    
    def response_data_display(self, obj):
        """显示响应数据（格式化）"""
        if obj.response_data:
            try:
                data = json.loads(obj.response_data)
                formatted = json.dumps(data, indent=2, ensure_ascii=False)
                return format_html('<pre style="max-width: 400px; overflow: auto;">[TEST] {}</pre>', formatted)
            except:
                return f'[TEST] {obj.response_data}'
        return '无'
    response_data_display.short_description = '响应数据'


@admin.register(UserSubscription)
class UserSubscriptionAdmin(admin.ModelAdmin):
    """用户订阅管理 - 测试版本"""
    
    list_display = [
        'user_id', 'is_premium', 'subscription_type', 'subscription_expiry',
        'current_subscription_link', 'subscription_count', 'created_at'
    ]
    
    list_filter = [
        'is_premium', 'subscription_type', 'created_at'
    ]
    
    search_fields = [
        'user_id'
    ]
    
    readonly_fields = [
        'subscription_count', 'current_subscription_link', 'created_at', 'updated_at'
    ]
    
    fieldsets = (
        ('用户信息 (测试)', {
            'fields': ('user_id',)
        }),
        ('订阅状态 (测试)', {
            'fields': ('is_premium', 'subscription_type', 'subscription_expiry')
        }),
        ('关联信息 (测试)', {
            'fields': ('current_subscription_link', 'subscription_count')
        }),
        ('时间戳', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    def current_subscription_link(self, obj):
        """显示当前订阅链接"""
        if obj.current_subscription:
            url = reverse('admin:test_payment_verification_paymentrecord_change', 
                         args=[obj.current_subscription.id])
            return format_html('<a href="{}">[TEST] {}</a>', url, obj.current_subscription.transaction_id)
        return '无'
    current_subscription_link.short_description = '当前订阅'
    
    def subscription_count(self, obj):
        """显示订阅历史数量"""
        return f'{obj.subscription_history.count()} (测试)'
    subscription_count.short_description = '历史订阅数量'
    
    actions = ['update_subscription_status']
    
    def update_subscription_status(self, request, queryset):
        """批量更新订阅状态"""
        updated_count = 0
        for subscription in queryset:
            subscription.update_subscription_status()
            updated_count += 1
        
        self.message_user(request, f'成功更新 {updated_count} 个用户的测试订阅状态')
    update_subscription_status.short_description = '更新测试订阅状态'
