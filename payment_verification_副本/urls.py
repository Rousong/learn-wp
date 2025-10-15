from django.urls import path
from . import views

app_name = 'payment_verification'

urlpatterns = [
    # 支付验证
    path('verify/', views.PaymentVerificationView.as_view(), name='verify_payment'),
    path('verify-receipt/', views.verify_receipt_view, name='verify_receipt'),  # 兼容性路由
    
    # 用户订阅状态
    path('subscription/status/', views.UserSubscriptionStatusView.as_view(), name='subscription_status'),
    path('subscription/status/<str:user_id>/', views.UserSubscriptionStatusView.as_view(), name='subscription_status_by_id'),
    path('subscription/detail/<str:user_id>/', views.UserSubscriptionDetailView.as_view(), name='subscription_detail'),
    
    # 支付记录
    path('records/', views.PaymentRecordListView.as_view(), name='payment_records'),
    
    # 健康检查
    path('health/', views.HealthCheckView.as_view(), name='health_check'),
]
