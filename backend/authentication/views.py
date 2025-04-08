from datetime import timedelta
from django.utils import timezone
import random
from rest_framework import status, permissions, generics
from rest_framework.generics import CreateAPIView, GenericAPIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from django.conf import settings
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from django.core.mail import send_mail

from .models import CustomUser, PasswordResetOTP
from .serializers import ForgotPasswordSerializer, ResetPasswordSerializer, SignUpSerializer, LoginSerializer, ProfileSerializer
from authentication import serializers

class SignUpView(CreateAPIView):
    queryset = CustomUser.objects.all()
    serializer_class = SignUpSerializer
    permission_classes = [AllowAny]

    def perform_create(self, serializer):
        # Ambil data activity_level, goal, target_weight, dan timeline dari request
        activity_level = self.request.data.get("activity_level")
        goal = self.request.data.get("goal")
        target_weight = self.request.data.get("target_weight", None)
        timeline = self.request.data.get("timeline", None)

        # Validasi dan pastikan field activity_level dan goal sesuai dengan pilihan yang ada
        if activity_level not in ['Sedentary', 'Low Active', 'Active', 'Very Active']:
            raise serializers.ValidationError({"activity_level": "Invalid activity level."})

        if goal not in ['Weight Gain', 'Maintain Weight', 'Weight Loss']:
            raise serializers.ValidationError({"goal": "Invalid goal."})

        # Jika goal adalah Weight Gain atau Weight Loss, pastikan target_weight dan timeline diisi
        if goal == 'Weight Gain' or goal == 'Weight Loss':
            if not target_weight:
                raise serializers.ValidationError({"target_weight": "Target weight is required."})
            if not timeline:
                raise serializers.ValidationError({"timeline": "Timeline is required."})

        # Jika validasi lolos, simpan pengguna dengan data yang telah ditambahkan
        serializer.save(
            activity_level=activity_level,
            goal=goal,
            target_weight=target_weight,
            timeline=timeline
        )


class LoginView(GenericAPIView):
    serializer_class = LoginSerializer
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data.get("email")
            password = serializer.validated_data.get("password")
            user = authenticate(request, email=email, password=password)
            
            if user is not None:
                refresh = RefreshToken.for_user(user)
                return Response({
                    "access_token": str(refresh.access_token),
                    "refresh_token": str(refresh),
                }, status=status.HTTP_200_OK)
            return Response({"detail": "Invalid credentials"}, status=status.HTTP_400_BAD_REQUEST)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class ForgotPasswordView(GenericAPIView):
    serializer_class = ForgotPasswordSerializer  # Menambahkan serializer_class
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data.get("email")
            try:
                user = CustomUser.objects.get(email=email)
                otp = str(random.randint(1000, 9999))
                expiration_time = timezone.now() + timedelta(minutes=30)
                PasswordResetOTP.objects.create(user=user, otp=otp, expires_at=expiration_time)
                
                send_mail(
                    'Your OTP Code',
                    f'Your OTP code is: {otp}',
                    settings.EMAIL_HOST_USER,
                    [email],
                    fail_silently=False,
                )
                
                return Response({"detail": "OTP sent to your email!"}, status=status.HTTP_200_OK)
            except CustomUser.DoesNotExist:
                return Response({"detail": "Email not found!"}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class ResetPasswordView(GenericAPIView):
    serializer_class = ResetPasswordSerializer
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            otp = serializer.validated_data['otp']
            new_password = serializer.validated_data['new_password']
            
            try:
                otp_record = PasswordResetOTP.objects.get(otp=otp)
                if otp_record.expires_at < timezone.now():
                    return Response({"detail": "OTP expired!"}, status=status.HTTP_400_BAD_REQUEST)
                
                user = otp_record.user
                user.set_password(new_password)
                user.save()
                otp_record.delete()
                
                return Response({"detail": "Password reset successful!"}, status=status.HTTP_200_OK)
            except PasswordResetOTP.DoesNotExist:
                return Response({"detail": "Invalid OTP!"}, status=status.HTTP_400_BAD_REQUEST)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class VerifyOTPView(GenericAPIView):
    permission_classes = [AllowAny]

    def post(self, request):
        otp = request.data.get('otp')

        try:
            otp_record = PasswordResetOTP.objects.get(otp=otp)
            if otp_record.is_expired():
                return Response({"detail": "OTP expired!"}, status=status.HTTP_400_BAD_REQUEST)
            return Response({"detail": "OTP is valid."}, status=status.HTTP_200_OK)
        except PasswordResetOTP.DoesNotExist:
            return Response({"detail": "Invalid OTP!"}, status=status.HTTP_400_BAD_REQUEST)

class ProfileView(generics.RetrieveUpdateAPIView):
    permission_classes = [permissions.IsAuthenticated]  # Only authenticated users can view/update their profile
    serializer_class = ProfileSerializer
    queryset = CustomUser.objects.all()  # Retrieve all CustomUser objects

    def get_object(self):
        # Ensure we return the currently authenticated user
        return self.request.user
    
