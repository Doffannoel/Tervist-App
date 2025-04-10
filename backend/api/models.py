from django.conf import settings
from django.db import models
from authentication.models import CustomUser
from django.utils import timezone
from decimal import Decimal

class NutritionalTarget(models.Model):
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    calorie_target = models.FloatField(default=0.0)
    protein_target = models.FloatField(default=0.0)
    carbs_target = models.FloatField(default=0.0)
    fats_target = models.FloatField(default=0.0)
    steps_goal = models.IntegerField(default=0)
    calories_burned_goal = models.FloatField(default=0.0)

    def calculate_targets(self, manual_data=None):
        """Calculate and update targets based on user data or manual input."""
        if self.user:
            user = self.user
        elif manual_data:
            class TempUser:
                def __init__(self, data):
                    self.weight = Decimal(str(data.get('weight', 0)))
                    self.height = Decimal(str(data.get('height', 0)))
                    self.age = int(data.get('age', 25))
                    self.gender = data.get('gender', 'Male')
                    self.activity_level = data.get('activity_level', 'Low Active')
                    self.goal = data.get('goal', 'Maintain Weight')
                    self.username = "TempUser"
            user = TempUser(manual_data)
        else:
            print("ERROR: No user data available for calculation")
            return

        # Convert user values ke Decimal supaya gak bentrok
        weight = Decimal(str(user.weight))
        height = Decimal(str(user.height))
        age = Decimal(str(user.age))

        bmr = Decimal('10') * weight + Decimal('6.25') * height - Decimal('5') * age
        if user.gender == 'Male':
            bmr += Decimal('5')
        else:
            bmr -= Decimal('161')

        activity_multipliers = {
            'Sedentary': Decimal('1.2'),
            'Low Active': Decimal('1.375'),
            'Active': Decimal('1.55'),
            'Very Active': Decimal('1.725'),
        }
        multiplier = activity_multipliers.get(user.activity_level, Decimal('1.2'))
        tdee = bmr * multiplier

        # Calorie target based on goal
        if user.goal == 'Weight Gain':
            calorie_target = tdee + Decimal('500')
        elif user.goal == 'Weight Loss':
            calorie_target = tdee - Decimal('500')
        else:
            calorie_target = tdee

        # Assign to model fields
        self.calorie_target = float(calorie_target)
        self.protein_target = float(calorie_target * Decimal('0.15') / Decimal('4'))
        self.carbs_target = float(calorie_target * Decimal('0.55') / Decimal('4'))
        self.fats_target = float(calorie_target * Decimal('0.30') / Decimal('9'))
        self.calories_burned_goal = float(tdee * Decimal('0.75'))

        step_goals = {
            'Sedentary': 5000,
            'Low Active': 7500,
            'Active': 10000,
            'Very Active': 12000,
        }
        self.steps_goal = step_goals.get(user.activity_level, 10000)

        self.save()

    def __str__(self):
        if self.user:
            return f"{self.user.username} - Calorie: {self.calorie_target} kcal, Protein: {self.protein_target}g, Carbs: {self.carbs_target}g, Fats: {self.fats_target}g"
        return f"Unknown User - Calorie: {self.calorie_target} kcal, Protein: {self.protein_target}g, Carbs: {self.carbs_target}g, Fats: {self.fats_target}g"

    
class FoodDatabase(models.Model):
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name


class FoodMeasurement(models.Model):
    food = models.ForeignKey(FoodDatabase, on_delete=models.CASCADE, related_name="measurements")
    label = models.CharField(max_length=50)
    gram_equivalent = models.FloatField()

    # Nutrisi makro
    calories = models.FloatField(default=0.0)
    protein = models.FloatField(default=0.0)
    carbs = models.FloatField(default=0.0)
    fat = models.FloatField(default=0.0)

    # Nutrisi tambahan (micro + breakdown)
    saturated_fat = models.FloatField(default=0.0)
    polyunsaturated_fat = models.FloatField(default=0.0)
    monounsaturated_fat = models.FloatField(default=0.0)
    cholesterol = models.FloatField(default=0.0)  # dalam mg
    sodium = models.FloatField(default=0.0)       # dalam mg
    dietary_fiber = models.FloatField(default=0.0)
    total_sugars = models.FloatField(default=0.0)
    potassium = models.FloatField(default=0.0)    # dalam mg
    vitamin_a = models.FloatField(default=0.0)    # dalam µg
    vitamin_c = models.FloatField(default=0.0)
    calcium = models.FloatField(default=0.0)      # dalam mg
    iron = models.FloatField(default=0.0)

    def __str__(self):
        return f"{self.food.name} - {self.label}"

class FoodIntake(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    food_data = models.ForeignKey(FoodDatabase, on_delete=models.CASCADE, null=True, blank=True)
    serving_size = models.CharField(max_length=50, null=True, blank=True)

    meal_type = models.CharField(
        max_length=20,
        choices=[('Breakfast', 'Breakfast'), ('Lunch', 'Lunch'), ('Dinner', 'Dinner'), ('Snack', 'Snack')],
        default='Lunch'
    )
    date = models.DateField(default=timezone.now)
    time = models.TimeField(default=timezone.now)

    # Manual input fields (Log Empty Meal)
    manual_calories = models.FloatField(null=True, blank=True)
    manual_protein = models.FloatField(null=True, blank=True)
    manual_carbs = models.FloatField(null=True, blank=True)
    manual_fats = models.FloatField(null=True, blank=True)

    def __str__(self):
        return f"{self.user.username} - {self.meal_type} - {self.date}"


class DailySteps(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE,null=True, blank=True)
    steps = models.IntegerField()
    date = models.DateField(default=timezone.now)

    
    def __str__(self):
        if self.user:
            return f"{self.user.username} - {self.steps} steps on {self.date}"
        return f"Unknown User - {self.steps} steps on {self.date}"


class CaloriesBurned(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    exercise_calories = models.IntegerField(null=True, blank=True)  # Kalori terbakar dari olahraga
    bmr_calories = models.IntegerField(null=True,blank=True)  # Kalori terbakar dari BMR
    total_calories = models.IntegerField(null=True,  blank=True)  # Total kalori yang terbakar
    date = models.DateField(default=timezone.now)

    def __str__(self):
        if self.user:
            return f"{self.user.username} - Total: {self.total_calories} kcal (Exercise: {self.exercise_calories}, BMR: {self.bmr_calories})"
        return f"Unknown User - Total: {self.total_calories} kcal"



class RunningActivity(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    distance_km = models.FloatField()  # Distance covered in kilometers
    time_seconds = models.IntegerField()  # Time taken in seconds
    pace = models.FloatField()  # Pace (time per km in minutes)
    calories_burned = models.IntegerField()  # Calories burned during the activity
    steps = models.IntegerField()  # Total steps during the activity
    date = models.DateField(default=timezone.now)  # Date of the activity

    def calculate_pace(self):
        """ Calculate the pace in minutes per kilometer """
        if self.distance_km > 0:
            self.pace = (self.time_seconds / 60) / self.distance_km
        else:
            self.pace = 0
        self.save()

    @property
    def pace_min_per_km(self):
        if self.distance_km > 0:
            return (self.time_seconds / 60) / self.distance_km
        return 0

    def __str__(self):
        if self.user:
            return f"{self.user.username} - {self.distance_km} km on {self.date}"
        return f"Unknown User - {self.distance_km} km on {self.date}"

class CyclingActivity(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    date = models.DateField()
    duration = models.DurationField()  # misal: timedelta(minutes=78)
    distance_km = models.DecimalField(max_digits=5, decimal_places=2)
    avg_speed_kmh = models.DecimalField(max_digits=4, decimal_places=1)
    max_speed_kmh = models.DecimalField(max_digits=4, decimal_places=1)
    elevation_gain_m = models.PositiveIntegerField(default=0)
    calories_burned = models.DecimalField(max_digits=6, decimal_places=2, null=True, blank=True)

    def save(self, *args, **kwargs):
        if not self.calories_burned:
            weight_kg = self.user.weight or 60  # fallback default 60 kg jika kosong
            duration_hours = self.duration.total_seconds() / 3600
            self.calories_burned = self.calculate_calories(duration_hours, weight_kg, float(self.avg_speed_kmh))
        super().save(*args, **kwargs)

    @staticmethod
    def calculate_calories(duration_hours, weight_kg, avg_speed_kmh):
        if avg_speed_kmh < 16:
            met = 4.0
        elif avg_speed_kmh < 19:
            met = 6.8
        elif avg_speed_kmh < 22:
            met = 8.0
        elif avg_speed_kmh < 25:
            met = 10.0
        else:
            met = 12.0
        return met * weight_kg * duration_hours

    def __str__(self):
        return f"{self.user.username} - {self.date} - {self.distance_km}km"
    

class Reminder(models.Model):
    MEAL_CHOICES = [
        ('Breakfast', 'Breakfast'),
        ('Lunch', 'Lunch'),
        ('Dinner', 'Dinner'),
        ('Snack', 'Snack'),
    ]
    
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    meal_type = models.CharField(max_length=20, choices=MEAL_CHOICES)
    time = models.TimeField()
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        # Ensure each user can have only one reminder per meal type
        unique_together = ('user', 'meal_type')
    
    def __str__(self):
              return f"{self.user.username} - {self.meal_type} at {self.time.strftime('%H:%M')}"