from rest_framework import viewsets, permissions, status
from datetime import datetime
from rest_framework.response import Response
from django.utils import timezone
from .models import CaloriesBurned, DailySteps, FoodDatabase, FoodIntake, NutritionalTarget
from .serializers import DailyStepsSerializer, CaloriesBurnedSerializer, FoodDatabaseSerializer, FoodIntakeSerializer, NutritionalTargetSerializer

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
        
        # Mengambil data langsung dari model NutritionalTarget
        nutritional_target = NutritionalTarget.objects.filter(user=user).first()
        nutritional_target_data = NutritionalTargetSerializer(nutritional_target).data if nutritional_target else {}

        # Mengambil data makanan yang dikonsumsi hari ini
        food_intake = FoodIntake.objects.filter(user=user, date=timezone.now().date())
        food_intake_data = FoodIntakeSerializer(food_intake, many=True).data

        # Menambahkan pengkategorian makan untuk Breakfast, Lunch, Dinner, Snack
        categorized_food = {
            "Breakfast": [],
            "Lunch": [],
            "Dinner": [],
            "Snack": []
        }

        for food in food_intake_data:
            meal_type = food.get("meal_type")
            categorized_food[meal_type].append(food)

        response_data = {
            "nutritional_target": nutritional_target_data,
            "categorized_food": categorized_food,
        }
        
        return Response(response_data, status=status.HTTP_200_OK)
