from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CalorieBudgetView, FoodIntakeView, DailyStepsView, CaloriesBurnedView, DashboardView

router = DefaultRouter()
router.register(r'calorie-budget', CalorieBudgetView, basename='calorie-budget')
router.register(r'food-intake', FoodIntakeView, basename='food-intake')
router.register(r'daily-steps', DailyStepsView, basename='daily-steps')
router.register(r'calories-burned', CaloriesBurnedView, basename='calories-burned')
router.register(r'dashboard', DashboardView, basename='dashboard')

urlpatterns = [
    path('', include(router.urls)),
]
