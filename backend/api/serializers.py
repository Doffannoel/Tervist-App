from rest_framework import serializers
from .models import CalorieBudget, DailySteps, Food, CaloriesBurned

class CalorieBudgetSerializer(serializers.ModelSerializer):
    class Meta:
        model = CalorieBudget
        fields = ['calorie_budget']  # Kalori budget yang dihitung

    def create(self, validated_data):
        user = validated_data.get('user')
        calorie_budget = CalorieBudget(user=user)
        calorie_budget.calculate_calories()  # Menghitung kalori budget berdasarkan user
        return calorie_budget

class DailyStepsSerializer(serializers.ModelSerializer):
    class Meta:
        model = DailySteps
        fields = ['steps']  # Langkah yang diambil oleh pengguna

class CaloriesBurnedSerializer(serializers.ModelSerializer):
    class Meta:
        model = CaloriesBurned
        fields = ['exercise_calories', 'bmr_calories', 'total_calories']  # Kalori yang terbakar


class FoodSerializer(serializers.ModelSerializer):
    class Meta:
        model = Food
        fields = ['meal_type', 'calories']