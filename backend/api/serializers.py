from rest_framework import serializers

from authentication.models import CustomUser
from .models import  CyclingActivity, DailySteps, CaloriesBurned, FoodDatabase, FoodIntake, FoodMeasurement, FoodMeasurement, NutritionalTarget, Reminder, RunningActivity, WalkingActivity

class NutritionalTargetSerializer(serializers.ModelSerializer):
    user = serializers.ReadOnlyField(source='user.username')

    class Meta:
        model = NutritionalTarget
        fields = ['id', 'user', 'calorie_target', 'protein_target', 'carbs_target', 'fats_target','steps_goal', 'calories_burned_goal']

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

class FoodMeasurementSerializer(serializers.ModelSerializer):
    class Meta:
        model = FoodMeasurement
        fields = [
            'id', 'label', 'gram_equivalent',
            'calories', 'protein', 'carbs', 'fat',
            'saturated_fat','monounsaturated_fat', 'polyunsaturated_fat',
            'dietary_fiber', 'total_sugars', 'cholesterol',
            'sodium', 'potassium', 'vitamin_a', 'vitamin_c', 'calcium', 'iron',
        ]


class FoodDatabaseSerializer(serializers.ModelSerializer):
    measurements = FoodMeasurementSerializer(many=True, read_only=True)

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
            'meal_type', 'name', 'manual_calories', 'manual_protein', 'manual_carbs', 'manual_fats',
            'date', 'time'
        ]
        read_only_fields = ['user']

class RunningActivitySerializer(serializers.ModelSerializer):
    user = serializers.ReadOnlyField(source='user.username')  # Get username instead of user ID

    class Meta:
        model = RunningActivity
        fields = ['id', 'user', 'distance_km', 'time_seconds', 'pace', 'calories_burned', 'steps', 'date', 'route_data']

class WalkingActivitySerializer(serializers.ModelSerializer):
    class Meta:
        model = WalkingActivity
        fields = [
            'id', 'user', 'distance_km', 'time_seconds', 
            'pace', 'calories_burned', 'steps', 'date'
        ]
        read_only_fields = ['user', 'pace', 'calories_burned']

    def validate_distance_km(self, value):
        if value < 0 or value > 50:
            raise serializers.ValidationError("Invalid walking distance")
        return value

    def validate_time_seconds(self, value):
        if value < 0 or value > 3600:
            raise serializers.ValidationError("Invalid walking duration")
        return value

    def validate_steps(self, value):
        if value < 0 or value > 20000:
            raise serializers.ValidationError("Invalid step count")
        return value
        

# NEW: Serializer untuk statistik ringkasan lari
class RunningStatsSerializer(serializers.Serializer):
    weekly = serializers.DictField()
    year_to_date = serializers.DictField()

class UserProfileSerializer(serializers.ModelSerializer):
    remaining_calories = serializers.SerializerMethodField()
    id = serializers.IntegerField(read_only=True) 

    class Meta:
        model = CustomUser
        fields = [
            'id', 'email', 'username', 'bio', 'city', 'state', 'birthday',
            'gender', 'weight', 'calorie_target', 'total_calories_consumed', 'remaining_calories'
        ]

    def get_remaining_calories(self, obj):
        """Menghitung sisa kalori yang bisa dikonsumsi"""
        return obj.calorie_target - obj.total_calories_consumed
    
    
class CyclingActivitySerializer(serializers.ModelSerializer):
    class Meta:
        model = CyclingActivity
        fields = '__all__'
        read_only_fields = ['user', 'calories_burned']

class ReminderSerializer(serializers.ModelSerializer):
    user = serializers.ReadOnlyField(source='user.username')
    
    class Meta:
        model = Reminder
        fields = ['id', 'user', 'meal_type', 'time', 'is_active', 'created_at', 'updated_at']
        read_only_fields = ['user', 'created_at', 'updated_at']