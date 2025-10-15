import json
import logging
import time
from datetime import datetime, timedelta
from django.utils import timezone
from .models import PaymentRecord, VerificationLog, UserSubscription

logger = logging.getLogger(__name__)


class BasePaymentVerificationService:
    """基础支付验证服务 - 测试版本"""
    
    def __init__(self):
        self.platform = None
    
    def verify_receipt(self, receipt_data, user_id=None, product_id=None):
        """验证收据，由子类实现"""
        raise NotImplementedError("子类必须实现verify_receipt方法")
    
    def _create_payment_record(self, verification_result, receipt_data, user_id=None):
        """创建支付记录 - 测试版本"""
        try:
            # 确保必要字段不为空
            product_id = verification_result.get('product_id') or 'test_unknown_product'
            transaction_id = verification_result.get('transaction_id') or f'test_tx_{int(time.time())}'
            product_type = verification_result.get('product_type') or 'monthly'
            
            # 处理日期时间序列化
            verification_response = verification_result.copy()
            if 'purchase_date' in verification_response and verification_response['purchase_date']:
                verification_response['purchase_date'] = verification_response['purchase_date'].isoformat()
            if 'expiry_date' in verification_response and verification_response['expiry_date']:
                verification_response['expiry_date'] = verification_response['expiry_date'].isoformat()
            
            # 使用 update_or_create 来处理恢复购买场景，避免 unique 冲突
            payment_record, created = PaymentRecord.objects.update_or_create(
                transaction_id=transaction_id,
                defaults={
                    'user_id': user_id,
                    'platform': self.platform,
                    'product_type': product_type,
                    'product_id': product_id,
                    'receipt_data': receipt_data,
                    'purchase_date': verification_result.get('purchase_date') or timezone.now(),
                    'expiry_date': verification_result.get('expiry_date'),
                    'status': 'verified' if verification_result.get('is_valid') else 'failed',
                    'verification_date': timezone.now(),
                    'verification_response': json.dumps(verification_response, default=str)
                }
            )
                
            # 记录是新创建还是更新的现有记录
            if created:
                logger.info(f"创建新支付记录: {transaction_id}")
            else:
                logger.info(f"更新现有支付记录（恢复购买）: {transaction_id}")
            
            # 如果有用户ID，更新用户订阅状态
            if user_id and verification_result.get('is_valid'):
                self._update_user_subscription(user_id, payment_record)
            
            return payment_record
        except Exception as e:
            logger.error(f"[TEST] 创建/更新支付记录失败: {e}")
            return None
    
    def _update_user_subscription(self, user_id, payment_record):
        """更新用户订阅状态 - 测试版本"""
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
            logger.error(f"[TEST] 更新用户订阅状态失败: {e}")
    
    def _log_verification(self, payment_record, request_data, is_successful, 
                         response_data=None, error_message=None, request_ip=None, user_agent=None):
        """记录验证日志 - 测试版本"""
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
            logger.error(f"[TEST] 记录验证日志失败: {e}")


class IOSPaymentVerificationService(BasePaymentVerificationService):
    """iOS App Store 支付验证服务 - 测试版本（仅Mock）"""
    
    def __init__(self):
        super().__init__()
        self.platform = 'ios'
    
    def verify_receipt(self, receipt_data, user_id=None, product_id=None):
        """验证iOS收据 - 测试版本（仅Mock）"""
        try:
            # 测试环境总是使用模拟验证
            verification_result = self._mock_ios_verification(receipt_data, product_id)
            
            # 创建支付记录
            payment_record = self._create_payment_record(verification_result, receipt_data, user_id)
            
            # 记录验证日志
            if payment_record:
                self._log_verification(
                    payment_record=payment_record,
                    request_data=json.dumps({'receipt_data': receipt_data[:100] + '...'}),
                    is_successful=verification_result.get('is_valid', False),
                    response_data=json.dumps({'test_mode': True, 'result': verification_result}, default=str),
                    error_message=verification_result.get('error_message')
                )
            
            return verification_result
            
        except Exception as e:
            logger.error(f"[TEST] iOS收据验证异常: {e}")
            return {
                'is_valid': False,
                'error_message': f'测试验证过程中发生异常: {str(e)}',
                'transaction_id': '',
                'product_type': '',
                'purchase_date': None,
                'expiry_date': None,
                'is_active': False,
                'days_until_expiry': None
            }
    
    def _mock_ios_verification(self, receipt_data, product_id=None):
        """模拟iOS验证 - 测试版本"""
        try:
            # 使用提供的产品ID或默认值
            if not product_id:
                product_id = 'test_ios_monthly_subscription'
            
            transaction_id = f'test_ios_transaction_{int(time.time())}'
            purchase_date = timezone.now()
            product_type = self._get_product_type(product_id)
            
            # 根据收据数据模拟不同的验证结果
            if 'invalid' in receipt_data.lower():
                return {
                    'is_valid': False,
                    'error_message': '测试收据无效',
                    'transaction_id': '',
                    'product_type': '',
                    'purchase_date': None,
                    'expiry_date': None,
                    'is_active': False,
                    'days_until_expiry': None
                }
            
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
            logger.error(f"[TEST] iOS模拟验证异常: {e}")
            return {
                'is_valid': False,
                'error_message': f'测试收据验证失败: {str(e)}',
                'transaction_id': '',
                'product_type': '',
                'purchase_date': None,
                'expiry_date': None,
                'is_active': False,
                'days_until_expiry': None
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
            return 'monthly'  # 默认为月费


class AndroidPaymentVerificationService(BasePaymentVerificationService):
    """Android Google Play 支付验证服务 - 测试版本（仅Mock）"""
    
    def __init__(self):
        super().__init__()
        self.platform = 'android'
    
    def verify_receipt(self, receipt_data, user_id=None, product_id=None):
        """验证Android收据 - 测试版本（仅Mock）"""
        try:
            # 解析收据数据
            receipt_json = json.loads(receipt_data)
            purchase_token = receipt_json.get('purchaseToken')
            
            if not purchase_token:
                return {
                    'is_valid': False,
                    'error_message': '测试收据数据中缺少purchaseToken',
                    'transaction_id': '',
                    'product_type': '',
                    'purchase_date': None,
                    'expiry_date': None,
                    'is_active': False,
                    'days_until_expiry': None
                }
            
            # 测试环境使用模拟验证
            verification_result = self._mock_android_verification(receipt_json)
            
            # 创建支付记录
            payment_record = self._create_payment_record(verification_result, receipt_data, user_id)
            
            # 记录验证日志
            if payment_record:
                self._log_verification(
                    payment_record=payment_record,
                    request_data=json.dumps({'receipt_data': receipt_data[:100] + '...'}),
                    is_successful=verification_result.get('is_valid', False),
                    response_data=json.dumps({'test_mode': True, 'result': verification_result}, default=str),
                    error_message=verification_result.get('error_message')
                )
            
            return verification_result
            
        except Exception as e:
            logger.error(f"[TEST] Android收据验证异常: {e}")
            return {
                'is_valid': False,
                'error_message': f'测试验证过程中发生异常: {str(e)}',
                'transaction_id': '',
                'product_type': '',
                'purchase_date': None,
                'expiry_date': None,
                'is_active': False,
                'days_until_expiry': None
            }
    
    def _mock_android_verification(self, receipt_json):
        """模拟Android验证 - 测试版本"""
        product_id = receipt_json.get('productId', 'test_android_product')
        purchase_time = receipt_json.get('purchaseTime', 0)
        order_id = receipt_json.get('orderId', f'test_android_order_{int(time.time())}')
        purchase_token = receipt_json.get('purchaseToken', '')
        
        # 根据购买token模拟不同的验证结果
        if 'invalid' in purchase_token.lower():
            return {
                'is_valid': False,
                'error_message': '测试购买token无效',
                'transaction_id': '',
                'product_type': '',
                'purchase_date': None,
                'expiry_date': None,
                'is_active': False,
                'days_until_expiry': None
            }
        
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
    """Windows Microsoft Store 支付验证服务 - 测试版本（仅Mock）"""
    
    def __init__(self):
        super().__init__()
        self.platform = 'windows'
    
    def verify_receipt(self, receipt_data, user_id=None, product_id=None):
        """验证Windows收据 - 测试版本（仅Mock）"""
        try:
            # Windows Store的验证相对简单，主要是验证收据格式
            receipt_json = json.loads(receipt_data)
            
            # 测试环境模拟验证逻辑
            verification_result = self._mock_windows_verification(receipt_json)
            
            # 创建支付记录
            payment_record = self._create_payment_record(verification_result, receipt_data, user_id)
            
            # 记录验证日志
            if payment_record:
                self._log_verification(
                    payment_record=payment_record,
                    request_data=json.dumps({'receipt_data': receipt_data[:100] + '...'}),
                    is_successful=verification_result.get('is_valid', False),
                    response_data=json.dumps({'test_mode': True, 'result': verification_result}, default=str),
                    error_message=verification_result.get('error_message')
                )
            
            return verification_result
            
        except Exception as e:
            logger.error(f"[TEST] Windows收据验证异常: {e}")
            return {
                'is_valid': False,
                'error_message': f'测试验证过程中发生异常: {str(e)}',
                'transaction_id': '',
                'product_type': '',
                'purchase_date': None,
                'expiry_date': None,
                'is_active': False,
                'days_until_expiry': None
            }
    
    def _mock_windows_verification(self, receipt_json):
        """模拟Windows验证 - 测试版本"""
        product_id = receipt_json.get('productId', 'test_windows_product')
        transaction_id = receipt_json.get('transactionId', f'test_windows_tx_{int(time.time())}')
        purchase_date_str = receipt_json.get('purchaseDate', '')
        
        # 根据交易ID模拟不同的验证结果
        if 'invalid' in transaction_id.lower():
            return {
                'is_valid': False,
                'error_message': '测试交易ID无效',
                'transaction_id': '',
                'product_type': '',
                'purchase_date': None,
                'expiry_date': None,
                'is_active': False,
                'days_until_expiry': None
            }
        
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
    """macOS App Store 支付验证服务 - 测试版本（继承自iOS服务，仅Mock）"""
    
    def __init__(self):
        super().__init__()
        self.platform = 'macos'
    
    def _mock_ios_verification(self, receipt_data, product_id=None):
        """重写模拟验证方法以适应macOS - 测试版本"""
        try:
            # 使用提供的产品ID或默认值
            if not product_id:
                product_id = 'test_macos_monthly_subscription'
            
            transaction_id = f'test_macos_transaction_{int(time.time())}'
            purchase_date = timezone.now()
            product_type = self._get_product_type(product_id)
            
            # 根据收据数据模拟不同的验证结果
            if 'invalid' in receipt_data.lower():
                return {
                    'is_valid': False,
                    'error_message': '测试macOS收据无效',
                    'transaction_id': '',
                    'product_type': '',
                    'purchase_date': None,
                    'expiry_date': None,
                    'is_active': False,
                    'days_until_expiry': None
                }
            
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
            logger.error(f"[TEST] macOS模拟验证异常: {e}")
            return {
                'is_valid': False,
                'error_message': f'测试收据验证失败: {str(e)}',
                'transaction_id': '',
                'product_type': '',
                'purchase_date': None,
                'expiry_date': None,
                'is_active': False,
                'days_until_expiry': None
            }


class PaymentVerificationServiceFactory:
    """支付验证服务工厂 - 测试版本"""
    
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
            raise ValueError(f"测试环境不支持的平台: {platform}")


def verify_payment(platform, receipt_data, user_id=None, product_id=None):
    """统一的支付验证入口 - 测试版本"""
    try:
        service = PaymentVerificationServiceFactory.get_service(platform)
        return service.verify_receipt(receipt_data, user_id, product_id)
    except Exception as e:
        logger.error(f"[TEST] 支付验证失败: {e}")
        return {
            'is_valid': False,
            'error_message': f'测试支付验证失败: {str(e)}',
            'transaction_id': '',
            'product_type': '',
            'purchase_date': None,
            'expiry_date': None,
            'is_active': False,
            'days_until_expiry': None
        }


def get_user_subscription_status(user_id):
    """获取用户订阅状态 - 测试版本"""
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