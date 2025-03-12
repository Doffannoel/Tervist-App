from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import CustomUser
from .serializers import SignUpSerializer, LoginSerializer
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken

class SignUpView(APIView):
    def post(self, request):
        # Menggunakan serializer untuk memvalidasi dan menyimpan data
        serializer = SignUpSerializer(data=request.data)

        if serializer.is_valid():
            # Menyimpan pengguna baru
            serializer.save()
            return Response({"detail": "User created successfully!"}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class LoginView(APIView):
    def post(self, request):
        # Menggunakan serializer untuk memvalidasi input login
        serializer = LoginSerializer(data=request.data)

        if serializer.is_valid():
            email = request.data.get("email")
            password = request.data.get("password")
            
            # Autentikasi pengguna
            user = authenticate(request, email=email, password=password)
            if user is not None:
                refresh = RefreshToken.for_user(user)
                return Response({
                    "access_token": str(refresh.access_token),
                    "refresh_token": str(refresh),
                }, status=status.HTTP_200_OK)
            return Response({"detail": "Invalid credentials"}, status=status.HTTP_400_BAD_REQUEST)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
