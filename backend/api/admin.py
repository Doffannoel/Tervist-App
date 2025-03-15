from django.contrib import admin
from .models import CalorieBudget, DailySteps, Food, CaloriesBurned

# Registrasi model CalorieBudget
@admin.register(CalorieBudget)
class CalorieBudgetAdmin(admin.ModelAdmin):
    list_display = ('user', 'calorie_budget')  # Menampilkan user dan calorie_budget di daftar admin
    search_fields = ('user__username',)  # Mencari berdasarkan username pengguna
    list_filter = ('user',)  # Filter berdasarkan user

# Registrasi model DailySteps
@admin.register(DailySteps)
class DailyStepsAdmin(admin.ModelAdmin):
    list_display = ('user', 'steps', 'date')  # Menampilkan user, steps, dan tanggal di daftar admin
    search_fields = ('user__username',)  # Mencari berdasarkan username pengguna
    list_filter = ('date', 'user')  # Filter berdasarkan tanggal dan user

# Registrasi model Food
@admin.register(Food)
class FoodAdmin(admin.ModelAdmin):
    list_display = ('user', 'name', 'meal_type', 'calories', 'date')  # Menampilkan data makanan di admin
    search_fields = ('user__username', 'name')  # Mencari berdasarkan username pengguna dan nama makanan
    list_filter = ('meal_type', 'date', 'user')  # Filter berdasarkan meal_type, tanggal, dan user

# Registrasi model CaloriesBurned
@admin.register(CaloriesBurned)
class CaloriesBurnedAdmin(admin.ModelAdmin):
    list_display = ('user', 'exercise_calories', 'bmr_calories', 'total_calories', 'date')  # Menampilkan kalori yang terbakar
    search_fields = ('user__username',)  # Mencari berdasarkan username pengguna
    list_filter = ('date', 'user')  # Filter berdasarkan tanggal dan user
