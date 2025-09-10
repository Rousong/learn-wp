from django.db import models
from django.utils import timezone


class PaymentRecord(models.Model):
    """支付记录模型"""
    
    PLATFORM_CHOICES = [
        ('ios', 'iOS App Store'),
        ('android', 'Google Play Store'),
        ('windows', 'Microsoft Store'),
        ('macos', 'Mac App Store'),
    ]
    
    PRODUCT_TYPE_CHOICES = [
        ('monthly', '月费订阅'),
        ('yearly', '年费订阅'),
        ('lifetime', '终身购买'),
    ]
    
    STATUS_CHOICES = [
        ('pending', '待验证'),
        ('verified', '已验证'),
        ('failed', '验证失败'),
        ('expired', '已过期'),
        ('refunded', '已退款'),
    ]
    
    # 基本信息
    user_id = models.CharField('用户标识', max_length=255, blank=True, null=True, 
                              help_text='可选的用户唯一标识')
    platform = models.CharField('平台', max_length=20, choices=PLATFORM_CHOICES)
    product_type = models.CharField('产品类型', max_length=20, choices=PRODUCT_TYPE_CHOICES)
    product_id = models.CharField('产品ID', max_length=255)
    
    # 支付信息
    transaction_id = models.CharField('交易ID', max_length=255, unique=True)
    receipt_data = models.TextField('收据数据')
    purchase_date = models.DateTimeField('购买时间')
    expiry_date = models.DateTimeField('到期时间', blank=True, null=True)
    
    # 验证状态
    status = models.CharField('状态', max_length=20, choices=STATUS_CHOICES, default='pending')
    verification_date = models.DateTimeField('验证时间', blank=True, null=True)
    verification_response = models.TextField('验证响应', blank=True, null=True)
    
    # 元数据
    created_at = models.DateTimeField('创建时间', auto_now_add=True)
    updated_at = models.DateTimeField('更新时间', auto_now=True)
    
    class Meta:
        verbose_name = '支付记录'
        verbose_name_plural = '支付记录'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user_id']),
            models.Index(fields=['platform']),
            models.Index(fields=['transaction_id']),
            models.Index(fields=['status']),
        ]
    
    def __str__(self):
        return f"{self.platform} - {self.product_type} - {self.transaction_id}"
    
    def is_active(self):
        """检查订阅是否仍然有效"""
        if self.status != 'verified':
            return False
        
        if self.product_type == 'lifetime':
            return True
        
        if self.expiry_date:
            return timezone.now() < self.expiry_date
        
        return False
    
    def days_until_expiry(self):
        """返回距离过期的天数"""
        if self.product_type == 'lifetime':
            return None
        
        if self.expiry_date:
            delta = self.expiry_date - timezone.now()
            return delta.days if delta.days > 0 else 0
        
        return 0


class VerificationLog(models.Model):
    """验证日志模型"""
    
    payment_record = models.ForeignKey(PaymentRecord, on_delete=models.CASCADE, 
                                      related_name='verification_logs')
    
    # 验证请求信息
    request_data = models.TextField('请求数据')
    request_ip = models.GenericIPAddressField('请求IP', blank=True, null=True)
    user_agent = models.TextField('用户代理', blank=True, null=True)
    
    # 验证结果
    is_successful = models.BooleanField('验证成功')
    response_data = models.TextField('响应数据', blank=True, null=True)
    error_message = models.TextField('错误信息', blank=True, null=True)
    
    # 时间戳
    created_at = models.DateTimeField('创建时间', auto_now_add=True)
    
    class Meta:
        verbose_name = '验证日志'
        verbose_name_plural = '验证日志'
        ordering = ['-created_at']
    
    def __str__(self):
        status = "成功" if self.is_successful else "失败"
        return f"{self.payment_record.transaction_id} - {status} - {self.created_at}"


class UserSubscription(models.Model):
    """用户订阅状态模型"""
    
    user_id = models.CharField('用户标识', max_length=255, unique=True)
    
    # 当前订阅信息
    current_subscription = models.ForeignKey(PaymentRecord, on_delete=models.SET_NULL, 
                                           blank=True, null=True, 
                                           related_name='active_subscriptions')
    
    # 订阅历史
    subscription_history = models.ManyToManyField(PaymentRecord, 
                                                 related_name='user_subscriptions',
                                                 blank=True)
    
    # 状态信息
    is_premium = models.BooleanField('是否为付费用户', default=False)
    subscription_type = models.CharField('订阅类型', max_length=20, blank=True, null=True)
    subscription_expiry = models.DateTimeField('订阅到期时间', blank=True, null=True)
    
    # 元数据
    created_at = models.DateTimeField('创建时间', auto_now_add=True)
    updated_at = models.DateTimeField('更新时间', auto_now=True)
    
    class Meta:
        verbose_name = '用户订阅'
        verbose_name_plural = '用户订阅'
    
    def __str__(self):
        return f"{self.user_id} - {'付费' if self.is_premium else '免费'}"
    
    def update_subscription_status(self):
        """更新订阅状态"""
        if self.current_subscription and self.current_subscription.is_active():
            self.is_premium = True
            self.subscription_type = self.current_subscription.product_type
            self.subscription_expiry = self.current_subscription.expiry_date
        else:
            self.is_premium = False
            self.subscription_type = None
            self.subscription_expiry = None
        
        self.save()
