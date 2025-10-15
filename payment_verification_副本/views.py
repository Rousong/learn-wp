from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
import logging

from .serializers import (
    PaymentVerificationRequestSerializer,
    PaymentVerificationResponseSerializer,
    UserSubscriptionStatusSerializer,
    PaymentRecordSerializer,
    UserSubscriptionSerializer
)
from .services import verify_payment, get_user_subscription_status
from .models import PaymentRecord, UserSubscription

logger = logging.getLogger(__name__)


@method_decorator(csrf_exempt, name='dispatch')
class PaymentVerificationView(APIView):
    """支付验证API视图"""
    permission_classes = [AllowAny]
    
    def post(self, request):
        """验证支付收据"""
        try:
            # 验证请求数据
            serializer = PaymentVerificationRequestSerializer(data=request.data)
            if not serializer.is_valid():
                return Response(
                    {
                        "error": "Request parameters are invalid",
                        "details": serializer.errors
                    },
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # 获取验证后的数据
            platform = serializer.validated_data['platform']
            receipt_data = serializer.validated_data['receipt_data']
            user_id = serializer.validated_data.get('user_id')
            product_id = serializer.validated_data.get('product_id')
            
            # 记录请求信息
            request_ip = self._get_client_ip(request)
            user_agent = request.META.get('HTTP_USER_AGENT', '')
            
            logger.info(f"收到支付验证请求: platform={platform}, user_id={user_id}, ip={request_ip}")
            
            # 执行支付验证
            verification_result = verify_payment(
                platform=platform,
                receipt_data=receipt_data,
                user_id=user_id,
                product_id=product_id
            )
            
            # 序列化响应数据
            response_serializer = PaymentVerificationResponseSerializer(data=verification_result)
            if response_serializer.is_valid():
                logger.info(f"支付验证完成: user_id={user_id}, is_valid={verification_result.get('is_valid')}")
                return Response(response_serializer.validated_data)
            else:
                logger.error(f"响应数据序列化失败: {response_serializer.errors}")
                return Response(
                    {
                        "error": "响应数据格式错误",
                        "details": response_serializer.errors
                    },
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR
                )
                
        except Exception as e:
            logger.error(f"支付验证异常: {e}")
            return Response(
                {
                    "error": "支付验证失败",
                    "details": str(e)
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def _get_client_ip(self, request):
        """获取客户端IP地址"""
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip


@method_decorator(csrf_exempt, name='dispatch')
class UserSubscriptionStatusView(APIView):
    """用户订阅状态查询API视图"""
    permission_classes = [AllowAny]
    
    def get(self, request, user_id=None):
        """获取用户订阅状态"""
        try:
            # 从URL参数或查询参数获取user_id
            if not user_id:
                user_id = request.query_params.get('user_id')
            
            if not user_id:
                return Response(
                    {"error": "缺少用户ID参数"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # 获取用户订阅状态
            subscription_status = get_user_subscription_status(user_id)
            
            # 序列化响应数据
            serializer = UserSubscriptionStatusSerializer(data=subscription_status)
            if serializer.is_valid():
                logger.info(f"查询用户订阅状态: user_id={user_id}, is_premium={subscription_status.get('is_premium')}")
                return Response(serializer.validated_data)
            else:
                return Response(
                    {
                        "error": "响应数据格式错误",
                        "details": serializer.errors
                    },
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR
                )
                
        except Exception as e:
            logger.error(f"查询用户订阅状态异常: {e}")
            return Response(
                {
                    "error": "查询失败",
                    "details": str(e)
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


@method_decorator(csrf_exempt, name='dispatch')
class PaymentRecordListView(APIView):
    """支付记录列表API视图"""
    permission_classes = [AllowAny]
    
    def get(self, request):
        """获取支付记录列表"""
        try:
            # 获取查询参数
            user_id = request.query_params.get('user_id')
            platform = request.query_params.get('platform')
            status_filter = request.query_params.get('status')
            limit = int(request.query_params.get('limit', 10))
            
            # 构建查询
            queryset = PaymentRecord.objects.all()
            
            if user_id:
                queryset = queryset.filter(user_id=user_id)
            if platform:
                queryset = queryset.filter(platform=platform)
            if status_filter:
                queryset = queryset.filter(status=status_filter)
            
            # 限制返回数量
            queryset = queryset[:limit]
            
            # 序列化数据
            serializer = PaymentRecordSerializer(queryset, many=True)
            
            return Response({
                'count': len(serializer.data),
                'results': serializer.data
            })
            
        except Exception as e:
            logger.error(f"获取支付记录列表异常: {e}")
            return Response(
                {
                    "error": "查询失败",
                    "details": str(e)
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


@method_decorator(csrf_exempt, name='dispatch')
class UserSubscriptionDetailView(APIView):
    """用户订阅详情API视图"""
    permission_classes = [AllowAny]
    
    def get(self, request, user_id):
        """获取用户订阅详情"""
        try:
            subscription = UserSubscription.objects.get(user_id=user_id)
            subscription.update_subscription_status()  # 更新状态
            
            serializer = UserSubscriptionSerializer(subscription)
            
            logger.info(f"查询用户订阅详情: user_id={user_id}")
            return Response(serializer.data)
            
        except UserSubscription.DoesNotExist:
            return Response(
                {
                    'user_id': user_id,
                    'is_premium': False,
                    'subscription_type': None,
                    'subscription_expiry': None,
                    'current_subscription_details': None
                }
            )
        except Exception as e:
            logger.error(f"查询用户订阅详情异常: {e}")
            return Response(
                {
                    "error": "查询失败",
                    "details": str(e)
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


@method_decorator(csrf_exempt, name='dispatch')
class HealthCheckView(APIView):
    """健康检查API视图"""
    permission_classes = [AllowAny]
    
    def get(self, request):
        """健康检查"""
        return Response({
            'status': 'healthy',
            'service': 'payment_verification',
            'version': '1.0.0'
        })


# 兼容性视图 - 为了与现有API结构保持一致
def verify_receipt_view(request):
    """兼容性支付验证视图（函数式视图）"""
    if request.method == 'POST':
        view = PaymentVerificationView()
        return view.post(request)
    else:
        return JsonResponse(
            {'error': '仅支持POST请求'},
            status=405
        )
