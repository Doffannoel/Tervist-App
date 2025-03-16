from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from django.utils import timezone
from .models import CalorieBudget, CaloriesBurned, DailySteps, Food
from .serializers import CalorieBudgetSerializer, DailyStepsSerializer, CaloriesBurnedSerializer, FoodSerializer

class CalorieBudgetView(viewsets.ModelViewSet):
    queryset = CalorieBudget.objects.all()
    serializer_class = CalorieBudgetSerializer
    permission_classes = [permissions.AllowAny]
    
    def perform_create(self, serializer):
        if self.request.user.is_authenticated:
            serializer.save(user=self.request.user)
        else:
            serializer.save()

class FoodIntakeView(viewsets.ModelViewSet):
    queryset = Food.objects.all()
    serializer_class = FoodSerializer
    permission_classes = [permissions.AllowAny]
    
    def perform_create(self, serializer):
        if self.request.user.is_authenticated:
            serializer.save(user=self.request.user)
        else:
            serializer.save()

class DailyStepsView(viewsets.ModelViewSet):
    queryset = DailySteps.objects.all()
    serializer_class = DailyStepsSerializer
    permission_classes = [permissions.AllowAny]
    
    def perform_create(self, serializer):
        if self.request.user.is_authenticated:
            serializer.save(user=self.request.user)
        else:
            serializer.save()

class CaloriesBurnedView(viewsets.ModelViewSet):
    queryset = CaloriesBurned.objects.all()
    serializer_class = CaloriesBurnedSerializer
    permission_classes = [permissions.AllowAny]
    
    def perform_create(self, serializer):
        if self.request.user.is_authenticated:
            serializer.save(user=self.request.user)
        else:
            # Perhatikan bahwa model CaloriesBurned memerlukan user
            # Anda mungkin perlu menambahkan null=True, blank=True di model
            serializer.save()

class DashboardView(viewsets.ViewSet):  # ViewSet tanpa model
    permission_classes = [permissions.AllowAny]
    
    def list(self, request):
        user = request.user if request.user.is_authenticated else None

        # Mengambil data langsung dari model
        calorie_budget = CalorieBudget.objects.filter(user=user).first()
        calorie_budget_data = CalorieBudgetSerializer(calorie_budget).data if calorie_budget else {}

        food_intake = Food.objects.filter(user=user, date=timezone.now().date())
        food_intake_data = FoodSerializer(food_intake, many=True).data

        daily_steps = DailySteps.objects.filter(user=user).last()
        daily_steps_data = DailyStepsSerializer(daily_steps).data if daily_steps else {}

        calories_burned = CaloriesBurned.objects.filter(user=user).last()
        calories_burned_data = CaloriesBurnedSerializer(calories_burned).data if calories_burned else {}

        # Menggabungkan hasil dari berbagai sumber
        response_data = {
            "calorie_budget": calorie_budget_data,
            "food_intake": food_intake_data,
            "daily_steps": daily_steps_data,
            "calories_burned": calories_burned_data
        }
        
        return Response(response_data, status=status.HTTP_200_OK)