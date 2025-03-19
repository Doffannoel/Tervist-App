from rest_framework import serializers
from .models import  DailySteps, CaloriesBurned, FoodDatabase, FoodIntake, NutritionalTarget

class NutritionalTargetSerializer(serializers.ModelSerializer):
    user = serializers.ReadOnlyField(source='user.username')

    class Meta:
        model = NutritionalTarget
        fields = ['id', 'user', 'calorie_target', 'protein_target', 'carbs_target', 'fats_target']

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

class FoodDatabaseSerializer(serializers.ModelSerializer):
    class Meta:
        model = FoodDatabase
        fields = '__all__'

class FoodIntakeSerializer(serializers.ModelSerializer):
    food_data = FoodDatabaseSerializer()  # Menampilkan detail makanan dari FoodDatabase

    class Meta:
        model = FoodIntake
        fields = ['id','user', 'food_data', 'meal_type', 'serving_size', 'date', 'time']