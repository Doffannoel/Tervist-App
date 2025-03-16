from django.db import models
from authentication.models import CustomUser
from django.utils import timezone

class NutritionalTarget(models.Model):
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    calorie_target = models.FloatField(default=0.0)  # Total kalori yang perlu dikonsumsi per hari
    protein_target = models.FloatField(default=0.0)  # Target protein harian dalam gram
    carbs_target = models.FloatField(default=0.0)  # Target karbohidrat harian dalam gram
    fats_target = models.FloatField(default=0.0)  # Target lemak harian dalam gram

    def calculate_targets(self):
        """Menghitung dan mengupdate target kalori, protein, karbohidrat, dan lemak pengguna berdasarkan data pengguna."""
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
        
        tdee = bmr * activity_multipliers.get(user.activity_level, 1.2)  # Total Daily Energy Expenditure

        # Menyesuaikan dengan goal
        if user.goal == 'Weight Gain':
            self.calorie_target = tdee + 500  # Menambah 500 kalori untuk kenaikan berat badan
        elif user.goal == 'Weight Loss':
            self.calorie_target = tdee - 500  # Mengurangi 500 kalori untuk penurunan berat badan
        else:
            self.calorie_target = tdee  # Menjaga berat badan tetap stabil

        # Menghitung target nutrisi berdasarkan rasio makronutrien
        self.protein_target = tdee * 0.15 / 4  # 15% dari total kalori untuk protein (dalam gram, 1 gram protein = 4 kalori)
        self.carbs_target = tdee * 0.55 / 4  # 55% dari total kalori untuk karbohidrat (dalam gram, 1 gram carbs = 4 kalori)
        self.fats_target = tdee * 0.30 / 9  # 30% dari total kalori untuk lemak (dalam gram, 1 gram fat = 9 kalori)

        self.save()

    def __str__(self):
        return f"{self.user.username} - Calorie: {self.calorie_target} kcal, Protein: {self.protein_target}g, Carbs: {self.carbs_target}g, Fats: {self.fats_target}g"

    
class FoodDatabase(models.Model):
    MEASUREMENT_CHOICES = [
        ('Per gram', 'Per gram'),
        ('Small', 'Small'),
        ('Medium', 'Medium'),
        ('Large', 'Large'),
        ('Extra Large', 'Extra Large'),
        ('Jumbo', 'Jumbo'),
    ]
    
    name = models.CharField(max_length=100)
    measurement = models.CharField(max_length=50, choices=MEASUREMENT_CHOICES)
    calories = models.IntegerField()
    protein = models.FloatField()
    carbs = models.FloatField()
    fat = models.FloatField()
    saturated_fat = models.FloatField()
    trans_fat = models.FloatField()
    monounsaturated_fat = models.FloatField()
    polyunsaturated_fat = models.FloatField()
    dietary_fiber = models.FloatField()
    total_sugars = models.FloatField()
    net_carbs = models.FloatField()
    cholesterol = models.FloatField()
    sodium = models.FloatField()
    potassium = models.FloatField()
    vitamin_a = models.FloatField()
    vitamin_c = models.FloatField()
    calcium = models.FloatField()
    iron = models.FloatField()

    def __str__(self):
        return self.name
   
    
class FoodIntake(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE)
    food_data = models.ForeignKey(FoodDatabase, on_delete=models.CASCADE)  # Menghubungkan ke FoodDatabase
    serving_size = models.CharField(max_length=50)  # Ukuran porsi yang dimakan
    meal_type = models.CharField(max_length=20, choices=[('Breakfast', 'Breakfast'), ('Lunch', 'Lunch'), ('Dinner', 'Dinner'), ('Snack', 'Snack')])
    date = models.DateField(default=timezone.now)  # Tanggal makan
    time = models.TimeField(default=timezone.now)  # Waktu makan

    def __str__(self):
        return f"{self.food_data.name} ({self.meal_type}) - {self.serving_size} servings"

class DailySteps(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE,null=True, blank=True)
    steps = models.IntegerField()
    date = models.DateField(default=timezone.now)

class CaloriesBurned(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    exercise_calories = models.IntegerField()  # Kalori terbakar dari olahraga
    bmr_calories = models.IntegerField()  # Kalori terbakar dari BMR
    total_calories = models.IntegerField()  # Total kalori yang terbakar
    date = models.DateField(default=timezone.now)