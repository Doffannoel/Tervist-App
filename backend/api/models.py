from django.db import models
from authentication.models import CustomUser
from django.utils import timezone

class CalorieBudget(models.Model):
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE)
    calorie_budget = models.FloatField(default=0.0)  # Total kalori yang perlu dikonsumsi per hari

    def calculate_calories(self):
        """Menghitung dan mengupdate kalori budget pengguna berdasarkan data pengguna."""
        user = self.user
        bmr = 10 * user.weight + 6.25 * user.height - 5 * user.age
        if user.gender == 'Male':
            bmr += 5  # Penyesuaian untuk laki-laki
        else:
            bmr -= 161  # Penyesuaian untuk perempuan

        # Faktor activity level
        activity_multipliers = {
            'Sedentary': 1.2,
            'Low Active': 1.375,
            'Active': 1.55,
            'Very Active': 1.725,
        }
        
        tdee = bmr * activity_multipliers.get(user.activity_level, 1.2)

        # Menyesuaikan dengan goal
        if user.goal == 'Weight Gain':
            self.calorie_budget = tdee + 500  # Menambah 500 kalori untuk kenaikan berat badan
        elif user.goal == 'Weight Loss':
            self.calorie_budget = tdee - 500  # Mengurangi 500 kalori untuk penurunan berat badan
        else:
            self.calorie_budget = tdee  # Menjaga berat badan tetap stabil

        self.save()

    def __str__(self):
        return f"Calorie budget for {self.user.username}"
    
class Food(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    calories = models.IntegerField()  # Kalori per makanan
    meal_type = models.CharField(max_length=20, choices=[('Breakfast', 'Breakfast'), ('Lunch', 'Lunch'), ('Dinner', 'Dinner'), ('Snack', 'Snack')])
    date = models.DateField(default=timezone.now)  # Tanggal makan

class DailySteps(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE)
    steps = models.IntegerField()
    date = models.DateField(default=timezone.now)

class CaloriesBurned(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE)
    exercise_calories = models.IntegerField()  # Kalori terbakar dari olahraga
    bmr_calories = models.IntegerField()  # Kalori terbakar dari BMR
    total_calories = models.IntegerField()  # Total kalori yang terbakar
    date = models.DateField(default=timezone.now)