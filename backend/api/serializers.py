from rest_framework import serializers
from .models import  DailySteps, CaloriesBurned, FoodDatabase, FoodIntake, NutritionalTarget, RunningActivity

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
    food_data = FoodDatabaseSerializer(read_only=True)
    food_data_id = serializers.PrimaryKeyRelatedField(
        queryset=FoodDatabase.objects.all(), source='food_data', write_only=True, required=False
    )

    class Meta:
        model = FoodIntake
        fields = [
            'id', 'user', 'food_data', 'food_data_id', 'serving_size',
            'meal_type', 'manual_calories', 'manual_protein', 'manual_carbs', 'manual_fats',
            'date', 'time'
        ]
        read_only_fields = ['user']

class RunningActivitySerializer(serializers.ModelSerializer):
    user = serializers.ReadOnlyField(source='user.username')  # Get username instead of user ID

    class Meta:
        model = RunningActivity
        fields = ['id', 'user', 'distance_km', 'time_seconds', 'pace', 'calories_burned', 'steps', 'date']
