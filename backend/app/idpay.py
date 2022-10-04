from json import dumps
from requests import post
from django.conf import settings


class IDPay:

    API_URL = "https://api.idpay.ir/v1.1/payment"

    STATUS = {
        1	: 'پرداخت انجام نشده است',
        2	: 'پرداخت ناموفق بوده است',
        3	: 'خطا رخ داده است',
        4	: 'بلوکه شده',
        5	: 'برگشت به پرداخت کننده',
        6	: 'برگشت خورده سیستمی',
        7	: 'انصراف از پرداخت',
        8	: 'به درگاه پرداخت منتقل شد',
        10	: 'در انتظار تایید پرداخت',
        100	: 'پرداخت تایید شده است',
        101	: 'پرداخت قبلا تایید شده است',
        200	: 'به دریافت کننده واریز شد',
    }
    ERRORS = {
        11:	'کاربر مسدود شده است.',
        12:	'API Key یافت نشد.',
        13:	'درخواست شما با IP های ثبت شده در وب سرویس همخوانی ندارد.',
        14:	'وب سرویس شما در حال بررسی است و یا تایید نشده است.',
        21:	'حساب بانکی متصل به وب سرویس تایید نشده است.',
        22:	'وب سریس یافت نشد.',
        23:	'اعتبار سنجی وب سرویس ناموفق بود.',
        24:	'حساب بانکی مرتبط با این وب سرویس غیر فعال شده است.',
        31:	'کد تراکنش id نباید خالی باشد.',
        32:	'شماره سفارش order_id نباید خالی باشد.',
        33:	'مبلغ amount نباید خالی باشد.',
        34:	'مبلغ amount باید بیشتر از 1000 ریال باشد.',
        35:	'مبلغ amount باید کمتر از {max-amount} ریال باشد.',
        36:	'مبلغ amount بیشتر از حد مجاز است.',
        37:	'آدرس بازگشت callback نباید خالی باشد.',
        38:	'دامنه آدرس بازگشت با آدرس ثبت شده در وب سرویس همخوانی ندارد.',
        41:	'فیلتر وضعیت تراکنش ها می بایست آرایه ای (لیستی) از وضعیت های مجاز در مستندات باشد.',
        42:	'فیلتر تاریخ پرداخت می بایست آرایه ای شامل المنت های min و max از نوع timestamp باشد.',
        43:	'فیلتر تاریخ تسویه می بایست آرایه ای شامل المنت های min و max از نوع timestamp باشد.',
        51:	'تراکنش ایجاد نشد.',
        52:	'استعلام نتیجه ای نداشت.',
        53:	'تایید پرداخت امکان پذیر نیست.',
        54:	'مدت زمان تایید پرداخت سپری شده است.',
    }

    def __init__(self, sandbox:bool = False):
        self.headers = {
            "X-API-KEY": settings.IDPAY_API_KEY,
            'Content-Type': 'application/json',
        }
        if sandbox:
            self.headers["X-SANDBOX"] = "1"

    def get_status_text(self, status: int):
        return self.STATUS.get(status) or ""

    def get_error_text(self, err: int):
        return self.ERRORS.get(err) or ""

    def request(self, route, **kwargs):
        try:
            response = post(f"{self.API_URL}{route}", data=dumps(kwargs), headers=self.headers)
            data = response.json()
            if response.status_code in [200, 201]:
                return data, None
            else:
                return None, data
        except Exception as e:
            print("[Exception]", e)
            return None, {"error_code": 0, "error_message": str(e)}

    def new(self, order_id: str, amount: int, callback: str, name: str = None, phone: str = None, mail: str = None, desc: str = None):
        return self.request("", order_id=order_id, amount=amount, callback=callback, name=name, phone=phone, mail=mail, desc=desc)

    def verify(self, id: str, order_id: str):
        return self.request("/verify", id=id, order_id=order_id)

    def inquiry(self, id: str, order_id: str):
        return self.request("/inquiry", id=id, order_id=order_id)
