from rest_framework import serializers
from .models import CalorieBudget, DailySteps, Food, CaloriesBurned

class CalorieBudgetSerializer(serializers.ModelSerializer):
    user = serializers.ReadOnlyField(source='user.username')  # Menampilkan username

    class Meta:
        model = CalorieBudget
        fields = ['id', 'user', 'calorie_budget']  # Menambahkan 'id'

class DailyStepsSerializer(serializers.ModelSerializer):
    user = serializers.ReadOnlyField(source='user.username')

    class Meta:
        model = DailySteps
        fields = ['id', 'user', 'steps', 'date']  # Menambahkan 'id'

class CaloriesBurnedSerializer(serializers.ModelSerializer):
    user = serializers.ReadOnlyField(source='user.username')

    class Meta:
        model = CaloriesBurned
        fields = ['id', 'user', 'exercise_calories', 'bmr_calories', 'total_calories', 'date']  # Menambahkan 'id'

class FoodSerializer(serializers.ModelSerializer):
    user = serializers.ReadOnlyField(source='user.username')

    class Meta:
        model = Food
        fields = ['id', 'user', 'name', 'meal_type', 'calories', 'date']  # Menambahkan 'id'