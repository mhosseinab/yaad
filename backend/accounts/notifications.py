from django.conf import settings
from kavenegar import KavenegarAPI

def send_auth_sms_token(_auth_token, is_yaad=False):
    try:
        api = KavenegarAPI(settings.KAVEHNEGAR_API_KEY)
        params = {
            'receptor': _auth_token.user.mobile,
            'template': 'VerifyYaad' if is_yaad else 'verify',
            'token': _auth_token.token,
            'type': 'sms',#sms vs call
        }   
        response = api.verify_lookup(params)
        # print(response)
        return True
    except Exception as e:
        print(e)
        return False