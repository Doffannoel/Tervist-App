from rest_framework import viewsets, permissions, status
from datetime import datetime
from django.db.models import Sum
from rest_framework.response import Response
from django.utils import timezone
from .models import CaloriesBurned, DailySteps, FoodDatabase, FoodIntake, NutritionalTarget, RunningActivity
from .serializers import DailyStepsSerializer, CaloriesBurnedSerializer, FoodDatabaseSerializer, FoodIntakeSerializer, NutritionalTargetSerializer, RunningActivitySerializer

class NutritionalTargetView(viewsets.ModelViewSet):
    queryset = NutritionalTarget.objects.all()
    serializer_class = NutritionalTargetSerializer
    permission_classes = [permissions.AllowAny]
    
    def perform_create(self, serializer):
        if self.request.user.is_authenticated:
            # Menyimpan pengguna dan menghitung target nutrisi
            nutritional_target = serializer.save(user=self.request.user)
            nutritional_target.calculate_targets()  # Hitung kalori dan target makronutrien setelah penyimpanan
            
        else:
            serializer.save()

class FoodIntakeView(viewsets.ModelViewSet):
    queryset = FoodIntake.objects.all()  # Menggunakan FoodIntake sebagai queryset
    serializer_class = FoodIntakeSerializer
    permission_classes = [permissions.AllowAny]
    
    def perform_create(self, serializer):
        if self.request.user.is_authenticated:
            food_data = serializer.validated_data.get('food_data')  # Ambil data dari FoodDatabase yang dipilih
            
            if not food_data:
                return Response({"error": "Food data is required."}, status=status.HTTP_400_BAD_REQUEST)
            
            meal = serializer.save(user=self.request.user)

            # Menentukan kategori waktu makan berdasarkan jam
            current_time = datetime.now().time()  # Mendapatkan waktu sekarang
            if current_time >= datetime.strptime("06:00", "%H:%M").time() and current_time < datetime.strptime("10:00", "%H:%M").time():
                meal.meal_type = "Breakfast"
            elif current_time >= datetime.strptime("10:00", "%H:%M").time() and current_time < datetime.strptime("15:00", "%H:%M").time():
                meal.meal_type = "Lunch"
            elif current_time >= datetime.strptime("15:00", "%H:%M").time() and current_time < datetime.strptime("20:00", "%H:%M").time():
                meal.meal_type = "Dinner"
            else:
                meal.meal_type = "Snack"
            
            meal.save()  # Simpan perubahan meal_type ke database

            # Update NutritionalTarget (kalori, protein, carbs, fats)
            user = self.request.user
            nutritional_target = NutritionalTarget.objects.get(user=user)
            
            # Mengurangi kalori yang dimakan dari target
            nutritional_target.calorie_target -= food_data.calories
            nutritional_target.protein_target -= food_data.protein
            nutritional_target.carbs_target -= food_data.carbs
            nutritional_target.fats_target -= food_data.fat

            nutritional_target.save()

            # Update macronutrients di profil pengguna (jika perlu)
            user_profile = user.profile
            user_profile.protein_left -= food_data.protein
            user_profile.carbs_left -= food_data.carbs
            user_profile.fats_left -= food_data.fat
            user_profile.save()

        else:
            serializer.save()

    def list(self, request):
        # Mendukung pencarian makanan berdasarkan query parameter 'search'
        search_query = request.GET.get('search', None)
        if search_query:
            food_items = FoodDatabase.objects.filter(name__icontains=search_query)  # Pencarian berdasarkan nama makanan
            return Response(FoodDatabaseSerializer(food_items, many=True).data)  # Menampilkan hasil pencarian
        else:
            return Response({"message": "No search query provided"}, status=status.HTTP_400_BAD_REQUEST)

class DailyStepsView(viewsets.ModelViewSet):
    queryset = DailySteps.objects.all()
    serializer_class = DailyStepsSerializer
    permission_classes = [permissions.AllowAny]
    
    def perform_create(self, serializer):
        if self.request.user.is_authenticated:
            serializer.save(user=self.request.user)
        else:
            serializer.save()

class CaloriesBurnedView(viewsets.ModelViewSet):
    queryset = CaloriesBurned.objects.all()
    serializer_class = CaloriesBurnedSerializer
    permission_classes = [permissions.AllowAny]
    
    def perform_create(self, serializer):
        if self.request.user.is_authenticated:
            serializer.save(user=self.request.user)
        else:
            # Perhatikan bahwa model CaloriesBurned memerlukan user
            # Anda mungkin perlu menambahkan null=True, blank=True di model
            serializer.save()

class DashboardView(viewsets.ViewSet):
    permission_classes = [permissions.AllowAny]
    
    def list(self, request):
        user = request.user if request.user.is_authenticated else None
        
        # Get today's date
        today = timezone.now().date()

        # Get the total steps for today (from DailySteps)
        total_steps = DailySteps.objects.filter(user=user, date=today).aggregate(Sum('steps'))['steps__sum'] or 0

        # Get the total calories burned for today (from CaloriesBurned)
        total_calories_burned = CaloriesBurned.objects.filter(user=user, date=today).aggregate(Sum('total_calories'))['total_calories__sum'] or 0
        
        # Get the total calories burned for today (from RunningActivity)
        total_running_calories_burned = RunningActivity.objects.filter(user=user, date=today).aggregate(Sum('calories_burned'))['calories_burned__sum'] or 0
        total_calories_burned += total_running_calories_burned  # Add running activity calories to total calories

        # Get the total steps for today from RunningActivity
        total_running_steps = RunningActivity.objects.filter(user=user, date=today).aggregate(Sum('steps'))['steps__sum'] or 0
        total_steps += total_running_steps  # Add running activity steps to total steps

        # Get nutritional target data for the user
        nutritional_target = NutritionalTarget.objects.filter(user=user).first()
        nutritional_target_data = NutritionalTargetSerializer(nutritional_target).data if nutritional_target else {}

        # Get the food intake data for today
        food_intake = FoodIntake.objects.filter(user=user, date=timezone.now().date())
        food_intake_data = FoodIntakeSerializer(food_intake, many=True).data

        # Categorize the food intake into Breakfast, Lunch, Dinner, Snack
        categorized_food = {
            "Breakfast": [],
            "Lunch": [],
            "Dinner": [],
            "Snack": []
        }

        for food in food_intake_data:
            meal_type = food.get("meal_type")
            categorized_food[meal_type].append(food)

        # Prepare the response data
        response_data = {
            "nutritional_target": nutritional_target_data,
            "total_steps": total_steps,
            "steps_goal": nutritional_target.steps_goal if nutritional_target else 0,
            "calories_burned_goal": nutritional_target.calories_burned_goal if nutritional_target else 0,
            "total_calories_burned": total_calories_burned,
            "categorized_food": categorized_food,
        }
        
        return Response(response_data, status=status.HTTP_200_OK)


class RunningActivityView(viewsets.ModelViewSet):
    queryset = RunningActivity.objects.all()
    serializer_class = RunningActivitySerializer
    permission_classes = [permissions.AllowAny]

    def perform_create(self, serializer):
        if self.request.user.is_authenticated:
            user = self.request.user
            distance = serializer.validated_data['distance_km']
            time = serializer.validated_data['time_seconds']
            steps = serializer.validated_data['steps']
            calories_burned = self.calculate_calories_burned(distance, time, steps)  # Calculate calories

            # Save RunningActivity
            running_activity = serializer.save(
                user=user,
                calories_burned=calories_burned
            )
            running_activity.calculate_pace()  # Calculate pace after saving the data

            # Update DailySteps (add steps from the running activity)
            self.update_daily_steps(user, steps)

            # Update CaloriesBurned (add calories from the running activity)
            self.update_calories_burned(user, calories_burned)
        else:
            serializer.save()

    def update_daily_steps(self, user, steps):
        """Update the DailySteps model with the steps from the running activity"""
        today = timezone.now().date()
        daily_steps, created = DailySteps.objects.get_or_create(user=user, date=today)
        daily_steps.steps += steps  # Add the steps from the running activity
        daily_steps.save()

    def update_calories_burned(self, user, calories_burned):
        """Update the CaloriesBurned model with the calories burned from the running activity"""
        today = timezone.now().date()
        calories_burned_model, created = CaloriesBurned.objects.get_or_create(user=user, date=today)
        calories_burned_model.total_calories += calories_burned  # Add the calories burned from the running activity
        calories_burned_model.save()

    def calculate_calories_burned(self, distance, time, steps):
        """Calculate calories burned based on distance, time, and steps."""
        # Example calculation: MET value of 5 for moderate activity (e.g., walking or running)
        MET = 5.0
        weight = self.request.user.weight  # Ensure the user profile has weight data
        calories = (weight * MET * time) / 60  # Basic estimation based on weight and time
        return round(calories)
