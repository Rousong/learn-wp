import json
import logging
import requests
import base64
import time
from datetime import datetime, timedelta
from django.conf import settings
from django.utils import timezone
from .models import PaymentRecord, VerificationLog, UserSubscription

logger = logging.getLogger(__name__)


class BasePaymentVerificationService:
    """基础支付验证服务"""
    
    def __init__(self):
        self.platform = None
    
    def verify_receipt(self, receipt_data, user_id=None, product_id=None):
        """验证收据，由子类实现"""
        raise NotImplementedError("子类必须实现verify_receipt方法")
    
    def _create_payment_record(self, verification_result, receipt_data, user_id=None):
        """创建支付记录"""
        try:
            # 确保必要字段不为空
            product_id = verification_result.get('product_id') or 'unknown_product'
            transaction_id = verification_result.get('transaction_id') or f'tx_{int(time.time())}'
            product_type = verification_result.get('product_type') or 'monthly'
            
            # 处理日期时间序列化
            verification_response = verification_result.copy()
            if 'purchase_date' in verification_response and verification_response['purchase_date']:
                verification_response['purchase_date'] = verification_response['purchase_date'].isoformat()
            if 'expiry_date' in verification_response and verification_response['expiry_date']:
                verification_response['expiry_date'] = verification_response['expiry_date'].isoformat()
            
            payment_record = PaymentRecord.objects.create(
                user_id=user_id,
                platform=self.platform,
                product_type=product_type,
                product_id=product_id,
                transaction_id=transaction_id,
                receipt_data=receipt_data,
                purchase_date=verification_result.get('purchase_date') or timezone.now(),
                expiry_date=verification_result.get('expiry_date'),
                status='verified' if verification_result.get('is_valid') else 'failed',
                verification_date=timezone.now(),
                verification_response=json.dumps(verification_response, default=str)
            )
            
            # 如果有用户ID，更新用户订阅状态
            if user_id and verification_result.get('is_valid'):
                self._update_user_subscription(user_id, payment_record)
            
            return payment_record
        except Exception as e:
            logger.error(f"创建支付记录失败: {e}")
            return None
    
    def _update_user_subscription(self, user_id, payment_record):
        """更新用户订阅状态"""
        try:
            subscription, created = UserSubscription.objects.get_or_create(
                user_id=user_id,
                defaults={
                    'current_subscription': payment_record,
                    'is_premium': True,
                    'subscription_type': payment_record.product_type,
                    'subscription_expiry': payment_record.expiry_date
                }
            )
            
            if not created:
                # 检查是否需要更新当前订阅
                if (not subscription.current_subscription or 
                    payment_record.purchase_date > subscription.current_subscription.purchase_date):
                    subscription.current_subscription = payment_record
                    subscription.update_subscription_status()
            
            # 添加到订阅历史
            subscription.subscription_history.add(payment_record)
            
        except Exception as e:
            logger.error(f"更新用户订阅状态失败: {e}")
    
    def _log_verification(self, payment_record, request_data, is_successful, 
                         response_data=None, error_message=None, request_ip=None, user_agent=None):
        """记录验证日志"""
        try:
            # 确保response_data可以序列化
            if response_data and not isinstance(response_data, str):
                response_data = json.dumps(response_data, default=str)
            
            VerificationLog.objects.create(
                payment_record=payment_record,
                request_data=request_data,
                request_ip=request_ip,
                user_agent=user_agent,
                is_successful=is_successful,
                response_data=response_data,
                error_message=error_message
            )
        except Exception as e:
            logger.error(f"记录验证日志失败: {e}")


class IOSPaymentVerificationService(BasePaymentVerificationService):
    """iOS App Store 支付验证服务"""
    
    def __init__(self):
        super().__init__()
        self.platform = 'ios'
        # App Store验证端点
        self.sandbox_url = 'https://sandbox.itunes.apple.com/verifyReceipt'
        self.production_url = 'https://buy.itunes.apple.com/verifyReceipt'
    
    def verify_receipt(self, receipt_data, user_id=None, product_id=None):
        """验证iOS收据"""
        try:
            # 检查是否为测试环境（简单的收据数据）
            if len(receipt_data) < 100 or receipt_data.startswith('test_'):
                # 使用模拟验证
                verification_result = self._mock_ios_verification(receipt_data, product_id)
            else:
                # 首先尝试生产环境
                result = self._verify_with_apple(receipt_data, self.production_url)
                
                # 如果生产环境返回21007错误（沙盒收据），则尝试沙盒环境
                if result.get('status') == 21007:
                    logger.info("检测到沙盒收据，切换到沙盒环境验证")
                    result = self._verify_with_apple(receipt_data, self.sandbox_url)
                
                # 解析验证结果
                verification_result = self._parse_ios_response(result)
            
            # 创建支付记录
            payment_record = self._create_payment_record(verification_result, receipt_data, user_id)
            
            # 记录验证日志
            if payment_record:
                self._log_verification(
                    payment_record=payment_record,
                    request_data=json.dumps({'receipt_data': receipt_data[:100] + '...'}),
                    is_successful=verification_result.get('is_valid', False),
                    response_data=json.dumps({'mock': True} if len(receipt_data) < 100 else result),
                    error_message=verification_result.get('error_message')
                )
            
            return verification_result
            
        except Exception as e:
            logger.error(f"iOS收据验证异常: {e}")
            return {
                'is_valid': False,
                'error_message': f'验证过程中发生异常: {str(e)}',
                'transaction_id': '',
                'product_type': '',
                'purchase_date': None,
                'expiry_date': None,
                'is_active': False,
                'days_until_expiry': None
            }
    
    def _verify_with_apple(self, receipt_data, url):
        """向Apple服务器验证收据"""
        payload = {
            'receipt-data': receipt_data,
            'password': getattr(settings, 'IOS_SHARED_SECRET', ''),  # App Store共享密钥
            'exclude-old-transactions': True
        }
        
        response = requests.post(
            url,
            json=payload,
            headers={'Content-Type': 'application/json'},
            timeout=30
        )
        
        return response.json()
    
    def _parse_ios_response(self, apple_response):
        """解析Apple验证响应"""
        status = apple_response.get('status', -1)
        
        if status == 0:
            # 验证成功
            receipt = apple_response.get('receipt', {})
            in_app = receipt.get('in_app', [])
            
            if in_app:
                # 获取最新的购买记录
                latest_purchase = max(in_app, key=lambda x: x.get('purchase_date_ms', 0))
                
                # 解析产品信息
                product_id = latest_purchase.get('product_id', '')
                product_type = self._get_product_type(product_id)
                
                # 解析时间
                purchase_date = self._parse_apple_date(latest_purchase.get('purchase_date_ms'))
                expiry_date = self._parse_apple_date(latest_purchase.get('expires_date_ms'))
                
                # 计算到期天数
                days_until_expiry = None
                if expiry_date:
                    delta = expiry_date - timezone.now()
                    days_until_expiry = max(0, delta.days)
                
                return {
                    'is_valid': True,
                    'transaction_id': latest_purchase.get('transaction_id', ''),
                    'product_type': product_type,
                    'product_id': product_id,
                    'purchase_date': purchase_date,
                    'expiry_date': expiry_date,
                    'is_active': expiry_date is None or timezone.now() < expiry_date,
                    'days_until_expiry': days_until_expiry,
                    'error_message': ''
                }
            else:
                return {
                    'is_valid': False,
                    'error_message': '收据中没有找到购买记录',
                    'transaction_id': '',
                    'product_type': '',
                    'purchase_date': None,
                    'expiry_date': None,
                    'is_active': False,
                    'days_until_expiry': None
                }
        else:
            # 验证失败
            error_messages = {
                21000: '收据数据格式错误',
                21002: '收据数据格式错误',
                21003: '收据无法验证',
                21004: '提供的共享密钥不匹配',
                21005: '收据服务器暂时不可用',
                21006: '收据有效但订阅已过期',
                21007: '收据是沙盒收据，但发送到了生产环境',
                21008: '收据是生产收据，但发送到了沙盒环境',
                21010: '收据无法验证',
            }
            
            error_message = error_messages.get(status, f'未知错误 (状态码: {status})')
            
            return {
                'is_valid': False,
                'error_message': error_message,
                'transaction_id': '',
                'product_type': '',
                'purchase_date': None,
                'expiry_date': None,
                'is_active': False,
                'days_until_expiry': None
            }
    
    def _parse_apple_date(self, date_ms):
        """解析Apple时间戳"""
        if date_ms:
            return timezone.make_aware(datetime.fromtimestamp(int(date_ms) / 1000))
        return None
    
    def _get_product_type(self, product_id):
        """根据产品ID推断产品类型"""
        if 'monthly' in product_id.lower():
            return 'monthly'
        elif 'yearly' in product_id.lower() or 'annual' in product_id.lower():
            return 'yearly'
        elif 'lifetime' in product_id.lower():
            return 'lifetime'
        else:
            return 'monthly'  # 默认为月费
    
    def _mock_ios_verification(self, receipt_data, product_id=None):
        """模拟iOS验证"""
        try:
            # 使用提供的产品ID或默认值
            if not product_id:
                product_id = 'ios_monthly_subscription'
            
            transaction_id = f'ios_transaction_{int(time.time())}'
            purchase_date = timezone.now()
            product_type = self._get_product_type(product_id)
            
            # 计算到期时间
            expiry_date = None
            if product_type == 'monthly':
                expiry_date = purchase_date + timedelta(days=30)
            elif product_type == 'yearly':
                expiry_date = purchase_date + timedelta(days=365)
            # lifetime 不设置到期时间
            
            days_until_expiry = None
            if expiry_date:
                delta = expiry_date - timezone.now()
                days_until_expiry = max(0, delta.days)
            
            return {
                'is_valid': True,
                'transaction_id': transaction_id,
                'product_type': product_type,
                'product_id': product_id,
                'purchase_date': purchase_date,
                'expiry_date': expiry_date,
                'is_active': expiry_date is None or timezone.now() < expiry_date,
                'days_until_expiry': days_until_expiry,
                'error_message': ''
            }
        except Exception as e:
            logger.error(f"iOS模拟验证异常: {e}")
            return {
                'is_valid': False,
                'error_message': f'收据验证失败: {str(e)}',
                'transaction_id': '',
                'product_type': '',
                'purchase_date': None,
                'expiry_date': None,
                'is_active': False,
                'days_until_expiry': None
            }


class AndroidPaymentVerificationService(BasePaymentVerificationService):
    """Android Google Play 支付验证服务"""
    
    def __init__(self):
        super().__init__()
        self.platform = 'android'
    
    def verify_receipt(self, receipt_data, user_id=None, product_id=None):
        """验证Android收据"""
        try:
            # 解析收据数据
            receipt_json = json.loads(receipt_data)
            purchase_token = receipt_json.get('purchaseToken')
            package_name = receipt_json.get('packageName', getattr(settings, 'ANDROID_PACKAGE_NAME', ''))
            
            if not purchase_token:
                return {
                    'is_valid': False,
                    'error_message': '收据数据中缺少purchaseToken',
                    'transaction_id': '',
                    'product_type': '',
                    'purchase_date': None,
                    'expiry_date': None,
                    'is_active': False,
                    'days_until_expiry': None
                }
            
            # 这里应该调用Google Play Developer API验证购买
            # 由于需要服务账号密钥，这里提供一个模拟实现
            verification_result = self._mock_android_verification(receipt_json)
            
            # 创建支付记录
            payment_record = self._create_payment_record(verification_result, receipt_data, user_id)
            
            # 记录验证日志
            if payment_record:
                self._log_verification(
                    payment_record=payment_record,
                    request_data=json.dumps({'receipt_data': receipt_data[:100] + '...'}),
                    is_successful=verification_result.get('is_valid', False),
                    response_data=json.dumps(verification_result),
                    error_message=verification_result.get('error_message')
                )
            
            return verification_result
            
        except Exception as e:
            logger.error(f"Android收据验证异常: {e}")
            return {
                'is_valid': False,
                'error_message': f'验证过程中发生异常: {str(e)}',
                'transaction_id': '',
                'product_type': '',
                'purchase_date': None,
                'expiry_date': None,
                'is_active': False,
                'days_until_expiry': None
            }
    
    def _mock_android_verification(self, receipt_json):
        """模拟Android验证（实际项目中需要调用Google Play API）"""
        # 这里是一个模拟实现，实际项目中需要：
        # 1. 使用Google Play Developer API
        # 2. 验证购买token的有效性
        # 3. 检查订阅状态
        
        product_id = receipt_json.get('productId', '')
        purchase_time = receipt_json.get('purchaseTime', 0)
        order_id = receipt_json.get('orderId', '')
        
        # 模拟验证成功
        product_type = self._get_product_type(product_id)
        purchase_date = timezone.make_aware(datetime.fromtimestamp(purchase_time / 1000)) if purchase_time else timezone.now()
        
        # 计算到期时间
        expiry_date = None
        if product_type == 'monthly':
            expiry_date = purchase_date + timedelta(days=30)
        elif product_type == 'yearly':
            expiry_date = purchase_date + timedelta(days=365)
        # lifetime 不设置到期时间
        
        days_until_expiry = None
        if expiry_date:
            delta = expiry_date - timezone.now()
            days_until_expiry = max(0, delta.days)
        
        return {
            'is_valid': True,
            'transaction_id': order_id,
            'product_type': product_type,
            'product_id': product_id,
            'purchase_date': purchase_date,
            'expiry_date': expiry_date,
            'is_active': expiry_date is None or timezone.now() < expiry_date,
            'days_until_expiry': days_until_expiry,
            'error_message': ''
        }
    
    def _get_product_type(self, product_id):
        """根据产品ID推断产品类型"""
        if 'monthly' in product_id.lower():
            return 'monthly'
        elif 'yearly' in product_id.lower() or 'annual' in product_id.lower():
            return 'yearly'
        elif 'lifetime' in product_id.lower():
            return 'lifetime'
        else:
            return 'monthly'


class WindowsPaymentVerificationService(BasePaymentVerificationService):
    """Windows Microsoft Store 支付验证服务"""
    
    def __init__(self):
        super().__init__()
        self.platform = 'windows'
    
    def verify_receipt(self, receipt_data, user_id=None, product_id=None):
        """验证Windows收据"""
        try:
            # Windows Store的验证相对简单，主要是验证收据格式
            receipt_json = json.loads(receipt_data)
            
            # 模拟验证逻辑
            verification_result = self._mock_windows_verification(receipt_json)
            
            # 创建支付记录
            payment_record = self._create_payment_record(verification_result, receipt_data, user_id)
            
            # 记录验证日志
            if payment_record:
                self._log_verification(
                    payment_record=payment_record,
                    request_data=json.dumps({'receipt_data': receipt_data[:100] + '...'}),
                    is_successful=verification_result.get('is_valid', False),
                    response_data=json.dumps(verification_result),
                    error_message=verification_result.get('error_message')
                )
            
            return verification_result
            
        except Exception as e:
            logger.error(f"Windows收据验证异常: {e}")
            return {
                'is_valid': False,
                'error_message': f'验证过程中发生异常: {str(e)}',
                'transaction_id': '',
                'product_type': '',
                'purchase_date': None,
                'expiry_date': None,
                'is_active': False,
                'days_until_expiry': None
            }
    
    def _mock_windows_verification(self, receipt_json):
        """模拟Windows验证"""
        product_id = receipt_json.get('productId', '')
        transaction_id = receipt_json.get('transactionId', '')
        purchase_date_str = receipt_json.get('purchaseDate', '')
        
        # 解析购买时间
        try:
            purchase_date = timezone.make_aware(datetime.fromisoformat(purchase_date_str.replace('Z', '+00:00')))
        except:
            purchase_date = timezone.now()
        
        product_type = self._get_product_type(product_id)
        
        # 计算到期时间
        expiry_date = None
        if product_type == 'monthly':
            expiry_date = purchase_date + timedelta(days=30)
        elif product_type == 'yearly':
            expiry_date = purchase_date + timedelta(days=365)
        
        days_until_expiry = None
        if expiry_date:
            delta = expiry_date - timezone.now()
            days_until_expiry = max(0, delta.days)
        
        return {
            'is_valid': True,
            'transaction_id': transaction_id,
            'product_type': product_type,
            'product_id': product_id,
            'purchase_date': purchase_date,
            'expiry_date': expiry_date,
            'is_active': expiry_date is None or timezone.now() < expiry_date,
            'days_until_expiry': days_until_expiry,
            'error_message': ''
        }
    
    def _get_product_type(self, product_id):
        """根据产品ID推断产品类型"""
        if 'monthly' in product_id.lower():
            return 'monthly'
        elif 'yearly' in product_id.lower() or 'annual' in product_id.lower():
            return 'yearly'
        elif 'lifetime' in product_id.lower():
            return 'lifetime'
        else:
            return 'monthly'


class MacOSPaymentVerificationService(IOSPaymentVerificationService):
    """macOS App Store 支付验证服务（继承自iOS服务）"""
    
    def __init__(self):
        super().__init__()
        self.platform = 'macos'
    
    def _mock_ios_verification(self, receipt_data, product_id=None):
        """重写模拟验证方法以适应macOS"""
        try:
            # 使用提供的产品ID或默认值
            if not product_id:
                product_id = 'macos_monthly_subscription'
            
            transaction_id = f'macos_transaction_{int(time.time())}'
            purchase_date = timezone.now()
            product_type = self._get_product_type(product_id)
            
            # 计算到期时间
            expiry_date = None
            if product_type == 'monthly':
                expiry_date = purchase_date + timedelta(days=30)
            elif product_type == 'yearly':
                expiry_date = purchase_date + timedelta(days=365)
            # lifetime 不设置到期时间
            
            days_until_expiry = None
            if expiry_date:
                delta = expiry_date - timezone.now()
                days_until_expiry = max(0, delta.days)
            
            return {
                'is_valid': True,
                'transaction_id': transaction_id,
                'product_type': product_type,
                'product_id': product_id,
                'purchase_date': purchase_date,
                'expiry_date': expiry_date,
                'is_active': expiry_date is None or timezone.now() < expiry_date,
                'days_until_expiry': days_until_expiry,
                'error_message': ''
            }
        except Exception as e:
            logger.error(f"macOS模拟验证异常: {e}")
            return {
                'is_valid': False,
                'error_message': f'收据验证失败: {str(e)}',
                'transaction_id': '',
                'product_type': '',
                'purchase_date': None,
                'expiry_date': None,
                'is_active': False,
                'days_until_expiry': None
            }


class PaymentVerificationServiceFactory:
    """支付验证服务工厂"""
    
    @staticmethod
    def get_service(platform):
        """根据平台获取对应的验证服务"""
        services = {
            'ios': IOSPaymentVerificationService,
            'android': AndroidPaymentVerificationService,
            'windows': WindowsPaymentVerificationService,
            'macos': MacOSPaymentVerificationService,
        }
        
        service_class = services.get(platform)
        if service_class:
            return service_class()
        else:
            raise ValueError(f"不支持的平台: {platform}")


def verify_payment(platform, receipt_data, user_id=None, product_id=None):
    """统一的支付验证入口"""
    try:
        service = PaymentVerificationServiceFactory.get_service(platform)
        return service.verify_receipt(receipt_data, user_id, product_id)
    except Exception as e:
        logger.error(f"支付验证失败: {e}")
        return {
            'is_valid': False,
            'error_message': f'支付验证失败: {str(e)}',
            'transaction_id': '',
            'product_type': '',
            'purchase_date': None,
            'expiry_date': None,
            'is_active': False,
            'days_until_expiry': None
        }


def get_user_subscription_status(user_id):
    """获取用户订阅状态"""
    try:
        subscription = UserSubscription.objects.get(user_id=user_id)
        subscription.update_subscription_status()  # 更新状态
        
        days_until_expiry = None
        if subscription.subscription_expiry:
            delta = subscription.subscription_expiry - timezone.now()
            days_until_expiry = max(0, delta.days)
        
        return {
            'user_id': user_id,
            'is_premium': subscription.is_premium,
            'subscription_type': subscription.subscription_type,
            'subscription_expiry': subscription.subscription_expiry,
            'days_until_expiry': days_until_expiry
        }
    except UserSubscription.DoesNotExist:
        return {
            'user_id': user_id,
            'is_premium': False,
            'subscription_type': None,
            'subscription_expiry': None,
            'days_until_expiry': None
        }
