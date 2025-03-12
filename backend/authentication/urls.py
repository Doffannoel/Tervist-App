from authentication.views import LoginView, SignUpView
from django.urls import path

urlpatterns = [
    path('signup/', SignUpView.as_view(), name='signup'),  # Endpoint untuk Sign Up
    path('login/', LoginView.as_view(), name='login'),      # Endpoint untuk Login
]