from authentication.views import ForgotPasswordView, LoginView, ResetPasswordView, SignUpView, ProfileView, VerifyOTPView
from django.urls import path

urlpatterns = [
    path('signup/', SignUpView.as_view(), name='signup'),  # Endpoint untuk Sign Up
    path('login/', LoginView.as_view(), name='login'),      # Endpoint untuk Login
    path('forgot-password/', ForgotPasswordView.as_view(), name='forgot-password'),
    path('reset-password/', ResetPasswordView.as_view(), name='reset-password'),  # Endpoint reset password
    path('verify-otp/', VerifyOTPView.as_view(), name='verify-otp'),
    path('profile/', ProfileView.as_view(), name='profile')
    
]