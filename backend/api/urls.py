from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CyclingActivityViewSet, CyclingHistoryViewSet, CyclingStatsView, FoodDatabaseViewSet, NutritionalTargetView, FoodIntakeView, CaloriesBurnedView, DashboardView, ReminderViewSet, RunningActivityView, RunningHistoryViewSet, RunningStatsView, UserProfileViewSet, WalkingActivityView, WalkingHistoryViewSet, WeeklyNutritionSummaryView, MonthlySummaryView, calculate_nutrition_preview

# Membuat router untuk viewsets
router = DefaultRouter()
router.register(r'nutritional-target', NutritionalTargetView, basename='nutritional-target')
router.register(r'food-intake', FoodIntakeView, basename='food-intake')  # Pencarian otomatis dalam list() di viewset
router.register(r'food-database', FoodDatabaseViewSet, basename='food-database')
# router.register(r'daily-steps', DailyStepsView, basename='daily-steps')
# router.register(r'calories-burned', CaloriesBurnedView, basename='calories-burned')
router.register(r'running-activity', RunningActivityView, basename='running-activity')
router.register(r'walking-activity', WalkingActivityView, basename='walking-activity')
router.register(r'cycling-activity', CyclingActivityViewSet, basename='cycling-activity')
router.register(r'dashboard', DashboardView, basename='dashboard')
router.register(r'running-stats', RunningStatsView, basename='running-stats') 
router.register(r'cycling-stats', CyclingStatsView, basename='cycling-stats')
router.register(r'profile-update', UserProfileViewSet, basename='profile-update')
router.register(r'reminders', ReminderViewSet, basename='reminders')
router.register(r'running-history', RunningHistoryViewSet, basename='running-history')
router.register(r'walking-history', WalkingHistoryViewSet, basename='walking-history')
router.register(r'cycling-history', CyclingHistoryViewSet, basename='cycling-history')



# Menambahkan URL untuk mendaftarkan semua viewsets
urlpatterns = [
    path('', include(router.urls)),  # Mendaftarkan semua viewsets ke router
    path('profile-update/me/', UserProfileViewSet.as_view({
        'get': 'retrieve',
        'put': 'update',
        'patch': 'partial_update'
    }), name='profile-me'),
    path('nutrition-weekly-summary/', WeeklyNutritionSummaryView.as_view(), name='nutrition-weekly-summary'), # Untuk weekly nutrition summary
    path('monthly-summary/', MonthlySummaryView.as_view(), name='monthly-summary'), #Untuk weekly running
    path('calculate-nutrition-preview/', calculate_nutrition_preview, name='calculate_nutrition_preview'),

]