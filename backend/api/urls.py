from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import NutritionalTargetView, FoodIntakeView, DailyStepsView, CaloriesBurnedView, DashboardView, RunningActivityView, RunningStatsView, WeeklyNutritionSummaryView, WeeklySummaryView

# Membuat router untuk viewsets
router = DefaultRouter()
router.register(r'nutritional-target', NutritionalTargetView, basename='nutritional-target')
router.register(r'food-intake', FoodIntakeView, basename='food-intake')  # Pencarian otomatis dalam list() di viewset
router.register(r'daily-steps', DailyStepsView, basename='daily-steps')
router.register(r'calories-burned', CaloriesBurnedView, basename='calories-burned')
router.register(r'running-activity', RunningActivityView, basename='running-activity')
router.register(r'dashboard', DashboardView, basename='dashboard')
router.register(r'running-stats', RunningStatsView, basename='running-stats') 


# Menambahkan URL untuk mendaftarkan semua viewsets
urlpatterns = [
    path('', include(router.urls)),  # Mendaftarkan semua viewsets ke router
    path('nutrition-weekly-summary/', WeeklyNutritionSummaryView.as_view(), name='nutrition-weekly-summary'),
    path('api/weekly-summary/', WeeklySummaryView.as_view(), name='weekly-summary'), #Untuk weekly running

]
