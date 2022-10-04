from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from .urls import app_name
from .models import AuthToken
class AuthTokenTestCase(APITestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.get_token_url = reverse('{}:auth_get_token_url'.format(app_name))
        cls.verify_token_url = reverse('{}:auth_verify_token_url'.format(app_name))
    
    def test_auth_token(self):
        response = self.client.post(self.get_token_url, {'mobile':'989033340030'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        uid = response.data.get('uuid')
        auth = AuthToken.objects.get(uid=uid)
        response = self.client.post(self.verify_token_url, {'uuid':str(uid), 'token': AuthToken.generate_numeric_token()})
        self.assertNotEqual(response.status_code, status.HTTP_200_OK)
        response = self.client.post(self.verify_token_url, {'uuid':str(uid), 'token': auth.token})
        self.assertEqual(response.status_code, status.HTTP_200_OK)


