from django.contrib.auth.backends import ModelBackend
from authentication.models import CustomUser

class EmailBackend(ModelBackend):
    """
    Custom backend untuk login menggunakan email.
    """
    def authenticate(self, request, username=None, password=None, **kwargs):
        try:
            user = CustomUser.objects.get(email=username)
            if user.check_password(password):
                return user
        except CustomUser.DoesNotExist:
            return None
    def get_user(self, user_id):
        try:
            return CustomUser.objects.get(pk=user_id)
        except CustomUser.DoesNotExist:
            return None
