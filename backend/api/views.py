from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from rest_framework import status
from .models import CalorieBudget, CaloriesBurned, DailySteps, Food
from authentication.models import CustomUser
from .serializers import CalorieBudgetSerializer
from django.utils import timezone

class DashboardView(APIView):
    permission_classes = [AllowAny] 

    def get(self, request):
        """ Menghitung dan mendapatkan data lengkap untuk dashboard pengguna """
        try:
            user = request.user

            calorie_budget_obj, created = CalorieBudget.objects.get_or_create(user=user)
            calorie_budget_obj.calculate_calories()  # Menghitung kalori berdasarkan data pengguna

            # Mengambil data langkah harian
            daily_steps = DailySteps.objects.filter(user=user).last()  # Ambil data langkah terakhir
            steps = daily_steps.steps if daily_steps else 0  # Jika tidak ada data langkah, defaultkan 0

            # Mengambil data makanan yang telah dikonsumsi hari ini
            food_data = Food.objects.filter(user=user, date=timezone.now())
            total_calories_consumed = sum([food.calories for food in food_data])  # Total kalori yang dimakan hari ini

            # Menghitung kalori yang tersisa untuk dimakan
            calorie_budget = calorie_budget_obj.calorie_budget  # Kalori yang perlu dikonsumsi
            calories_left = calorie_budget - total_calories_consumed  # Sisa kalori yang bisa dimakan

            # Mengambil kalori yang terbakar hari ini
            calories_burned_obj = CaloriesBurned.objects.filter(user=user).last()
            calories_burned = calories_burned_obj.total_calories if calories_burned_obj else 0

            # Menyusun data untuk response
            response_data = {
                "calorie_budget": calorie_budget,
                "calories_left": calories_left,
                "calories_burned": calories_burned,
                "steps": steps,
                "food_consumed": [{"meal": food.meal_type, "calories": food.calories} for food in food_data]
            }

            return Response(response_data, status=status.HTTP_200_OK)
        except CustomUser.DoesNotExist:
            return Response({"detail": "User not found."}, status=status.HTTP_404_NOT_FOUND)
