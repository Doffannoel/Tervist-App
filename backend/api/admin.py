from django.contrib import admin
from .models import FoodDatabase, DailySteps, CaloriesBurned, FoodIntake, NutritionalTarget

# Registrasi model FoodDatabase
@admin.register(FoodDatabase)
class FoodDatabaseAdmin(admin.ModelAdmin):
    list_display = ['name', 'measurement', 'calories', 'protein', 'carbs', 'fat']
    search_fields = ['name']
    list_filter = ['measurement']

@admin.register(FoodIntake)
class FoodIntakeAdmin(admin.ModelAdmin):
    list_display = ['user', 'food_data', 'meal_type', 'serving_size', 'date', 'time']
    search_fields = ['user__username', 'food_data__name']
    list_filter = ['meal_type', 'date', 'user']

@admin.register(NutritionalTarget)
class NutritionalTargetAdmin(admin.ModelAdmin):
    list_display = ['user', 'calorie_target', 'protein_target', 'carbs_target', 'fats_target']
    search_fields = ['user__username']
    fields = ['user', 'calorie_target', 'protein_target', 'carbs_target', 'fats_target']


# Registrasi model DailySteps
@admin.register(DailySteps)
class DailyStepsAdmin(admin.ModelAdmin):
    list_display = ('user', 'steps', 'date')
    search_fields = ('user__username',)
    list_filter = ('date', 'user')

# Registrasi model CaloriesBurned
@admin.register(CaloriesBurned)
class CaloriesBurnedAdmin(admin.ModelAdmin):
    list_display = ('user', 'exercise_calories', 'bmr_calories', 'total_calories', 'date')
    search_fields = ('user__username',)
    list_filter = ('date', 'user')
