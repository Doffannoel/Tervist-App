from django.conf import settings
from django.db import models
from authentication.models import CustomUser
from django.utils import timezone

class NutritionalTarget(models.Model):
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    calorie_target = models.FloatField(default=0.0)  # Total calories to consume per day
    protein_target = models.FloatField(default=0.0)  # Protein target per day in grams
    carbs_target = models.FloatField(default=0.0)  # Carbs target per day in grams
    fats_target = models.FloatField(default=0.0)  # Fats target per day in grams
    steps_goal = models.IntegerField(default=0)  # Step goal per day based on activity level
    calories_burned_goal = models.FloatField(default=0.0)  # Calories burned goal based on TDEE

    def calculate_targets(self):
        """Calculate and update the daily calorie, protein, carbs, fats, and steps goals based on user data."""
        user = self.user
        bmr = 10 * user.weight + 6.25 * user.height - 5 * user.age
        if user.gender == 'Male':
            bmr += 5  # Adjustment for males
        else:
            bmr -= 161  # Adjustment for females

        # Factor in the activity level for TDEE calculation
        activity_multipliers = {
            'Sedentary': 1.2,
            'Low Active': 1.375,
            'Active': 1.55,
            'Very Active': 1.725,
        }

        tdee = bmr * activity_multipliers.get(user.activity_level, 1.2)  # Total Daily Energy Expenditure

        # Adjust based on goal (Weight Gain, Weight Loss, Maintain Weight)
        if user.goal == 'Weight Gain':
            self.calorie_target = tdee + 500  # Add 500 calories for weight gain
        elif user.goal == 'Weight Loss':
            self.calorie_target = tdee - 500  # Subtract 500 calories for weight loss
        else:
            self.calorie_target = tdee  # Maintain current weight

        # Calculate the nutritional targets based on the TDEE
        self.protein_target = tdee * 0.15 / 4  # 15% of TDEE for protein (in grams, 1g protein = 4 calories)
        self.carbs_target = tdee * 0.55 / 4  # 55% of TDEE for carbohydrates (in grams, 1g carbs = 4 calories)
        self.fats_target = tdee * 0.30 / 9  # 30% of TDEE for fats (in grams, 1g fat = 9 calories)

        # Set the daily step goal based on activity level
        step_goals = {
            'Sedentary': 5000,
            'Low Active': 7500,
            'Active': 10000,
            'Very Active': 12000,
        }
        self.steps_goal = step_goals.get(user.activity_level, 10000)  # Default to 10,000 steps if undefined

        # Set the daily calories burned goal based on TDEE (calories burned through activity)
        self.calories_burned_goal = tdee * 0.75  # Assume the goal is 75% of TDEE for active users (you can adjust this logic)

        self.save()

    def __str__(self):
        if self.user:
            return f"{self.user.username} - Calorie: {self.calorie_target} kcal, Protein: {self.protein_target}g, Carbs: {self.carbs_target}g, Fats: {self.fats_target}g, Step Goal: {self.steps_goal} steps, Calories Burned Goal: {self.calories_burned_goal} kcal"
        return f"Unknown User - Calorie: {self.calorie_target} kcal, Protein: {self.protein_target}g, Carbs: {self.carbs_target}g, Fats: {self.fats_target}g, Step Goal: {self.steps_goal} steps, Calories Burned Goal: {self.calories_burned_goal} kcal"

    
class FoodDatabase(models.Model):
    MEASUREMENT_CHOICES = [
        ('Per gram', 'Per gram'),
        ('Small', 'Small'),
        ('Medium', 'Medium'),
        ('Large', 'Large'),
        ('Extra Large', 'Extra Large'),
        ('Jumbo', 'Jumbo'),
        ('Per serving (150 g)', 'Per serving (150 g)'),
        ('Per serving (300 g)', 'Per serving (300 g)'),
        ('Per slice (100 g)', 'Per slice (100 g)'),
        ('Per slice (98.0 g)', 'Per slice (98.0 g)'),
        ('Per serving (82.3 g)', 'Per serving (82.3 g)'),
        ('Per slice (83.1 g)', 'Per slice (83.1 g)'),
        ('Per slice (76.8 g)', 'Per slice (76.8 g)'),
        ('Per slice (102 g)', 'Per slice (102 g)'),
        ('Per serving (135 g)', 'Per serving (135 g)'),
        ('Per piece (20 g)', 'Per piece (20 g)'),
    ]
    
    name = models.CharField(max_length=100)
    measurement = models.CharField(max_length=50, choices=MEASUREMENT_CHOICES)
    calories = models.IntegerField()
    protein = models.FloatField()
    carbs = models.FloatField()
    fat = models.FloatField()
    saturated_fat = models.FloatField()
    trans_fat = models.FloatField(default=0.0)  # Menambahkan nilai default 0.0
    monounsaturated_fat = models.FloatField(default=0.0)  # Menambahkan nilai default
    polyunsaturated_fat = models.FloatField(default=0.0)  # Menambahkan nilai default
    dietary_fiber = models.FloatField(default=0.0)  # Menambahkan nilai default
    total_sugars = models.FloatField(default=0.0)  # Menambahkan nilai default
    net_carbs = models.FloatField(default=0.0)  # Menambahkan nilai default
    cholesterol = models.FloatField(default=0.0)  # Menambahkan nilai default
    sodium = models.FloatField(default=0.0)  # Menambahkan nilai default
    potassium = models.FloatField(default=0.0)  # Menambahkan nilai default
    vitamin_a = models.FloatField(default=0.0)  # Menambahkan nilai default
    vitamin_c = models.FloatField(default=0.0)  # Menambahkan nilai default
    calcium = models.FloatField(default=0.0)  # Menambahkan nilai default
    iron = models.FloatField(default=0.0)  # Menambahkan nilai default

    def __str__(self):
        return self.name

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
    exercise_calories = models.IntegerField()  # Kalori terbakar dari olahraga
    bmr_calories = models.IntegerField()  # Kalori terbakar dari BMR
    total_calories = models.IntegerField()  # Total kalori yang terbakar
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