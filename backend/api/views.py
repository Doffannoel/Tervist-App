from collections import defaultdict
from rest_framework import viewsets, permissions, status
from datetime import datetime, timedelta
from django.db.models import Sum
from rest_framework.response import Response
from django.utils import timezone
from django.utils.timezone import now
from authentication.models import CustomUser
from .models import CaloriesBurned, CyclingActivity, DailySteps, FoodDatabase, FoodIntake, NutritionalTarget, RunningActivity
from .serializers import CyclingActivitySerializer, DailyStepsSerializer, CaloriesBurnedSerializer, FoodDatabaseSerializer, FoodIntakeSerializer, NutritionalTargetSerializer, RunningActivitySerializer, UserProfileSerializer
from rest_framework.views import APIView
from django.db.models import Avg, Sum, Count
from calendar import monthrange
from rest_framework.viewsets import ModelViewSet

class NutritionalTargetView(viewsets.ModelViewSet):
    queryset = NutritionalTarget.objects.all()
    serializer_class = NutritionalTargetSerializer
    permission_classes = [permissions.AllowAny]
    
    def perform_create(self, serializer):
        nutritional_target = serializer.save()
        if self.request.user.is_authenticated:
            nutritional_target.user = self.request.user
            nutritional_target.save()
            nutritional_target.calculate_targets()
        else:
            # Gunakan data dari request langsung
            nutritional_target.calculate_targets(manual_data=self.request.data)

class FoodIntakeView(viewsets.ModelViewSet):
    queryset = FoodIntake.objects.all()
    serializer_class = FoodIntakeSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        user = self.request.user
        data = self.request.data
        instance = serializer.save(user=user)

        # === SCENARIO 1: Input dari FoodDatabase ===
        if instance.food_data:
            if not instance.meal_type:
                current_time = datetime.now().time()
                if current_time >= datetime.strptime("06:00", "%H:%M").time() and current_time < datetime.strptime("10:00", "%H:%M").time():
                    instance.meal_type = "Breakfast"
                elif current_time >= datetime.strptime("10:00", "%H:%M").time() and current_time < datetime.strptime("15:00", "%H:%M").time():
                    instance.meal_type = "Lunch"
                elif current_time >= datetime.strptime("15:00", "%H:%M").time() and current_time < datetime.strptime("20:00", "%H:%M").time():
                    instance.meal_type = "Dinner"
                else:
                    instance.meal_type = "Snack"
            instance.save()

            try:
                nt = NutritionalTarget.objects.get(user=user)
                nt.calorie_target -= instance.food_data.calories
                nt.protein_target -= instance.food_data.protein
                nt.carbs_target -= instance.food_data.carbs
                nt.fats_target -= instance.food_data.fat
                nt.save()
            except NutritionalTarget.DoesNotExist:
                pass

        # === SCENARIO 2: Input Manual (Log Empty Meal) ===
        elif instance.manual_calories is not None:
            if not instance.meal_type:
                return Response({"error": "Meal type is required for manual input."}, status=status.HTTP_400_BAD_REQUEST)
            instance.save()

            try:
                nt = NutritionalTarget.objects.get(user=user)
                nt.calorie_target -= instance.manual_calories or 0
                nt.protein_target -= instance.manual_protein or 0
                nt.carbs_target -= instance.manual_carbs or 0
                nt.fats_target -= instance.manual_fats or 0
                nt.save()
            except NutritionalTarget.DoesNotExist:
                pass

        else:
            return Response({"error": "Either food_data or manual nutritional values are required."}, status=status.HTTP_400_BAD_REQUEST)

    def list(self, request):
        search_query = request.GET.get('search', None)
        if search_query:
            food_items = FoodDatabase.objects.filter(name__icontains=search_query)
            return Response(FoodDatabaseSerializer(food_items, many=True).data)
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
    
class CyclingActivityViewSet(viewsets.ModelViewSet):
    queryset = CyclingActivity.objects.all()
    serializer_class = CyclingActivitySerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return self.queryset.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class WeeklyNutritionSummaryView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        print("DEBUG: User = ", request.user)
        print("DEBUG: Authenticated? ", request.user.is_authenticated)
        user = request.user
        today = timezone.now().date()
        week_ago = today - timezone.timedelta(days=6)  # 7 hari terakhir

        # Ambil semua makanan dalam 7 hari terakhir
        food_logs = FoodIntake.objects.filter(user=user, date__range=[week_ago, today])

        # Siapkan struktur: Senin - Minggu (default 0)
        daily_totals = { (week_ago + timezone.timedelta(days=i)): 0 for i in range(7) }

        for entry in food_logs:
            calories = entry.manual_calories or (entry.food_data.calories if entry.food_data else 0)
            daily_totals[entry.date] += calories

        # Buat array data siap frontend
        data = []
        for day, cal in daily_totals.items():
            data.append({
                "date": day.strftime("%a"),  # contoh: 'Mon'
                "calories": round(cal)
            })

        # Ambil goal harian
        target = NutritionalTarget.objects.filter(user=user).first()
        calorie_goal = target.calorie_target if target else 0
        total_eaten = sum(d['calories'] for d in data)
        weekly_goal = calorie_goal * 7
        net = total_eaten - weekly_goal

        return Response({
            "week_data": data,
            "goal": round(calorie_goal),
            "total_eaten": round(total_eaten),
            "net_difference": round(net),
            "net_average": round(net / 7) if calorie_goal else 0,
        })
    

class RunningStatsView(viewsets.ViewSet):
    permission_classes = [permissions.IsAuthenticated]  # ganti AllowAny

    def list(self, request):
        user = request.user  # tidak perlu user_id dari query params

        today = timezone.now().date()
        week_ago = today - timedelta(days=7)
        year_start = today.replace(month=1, day=1)

        weekly_activities = RunningActivity.objects.filter(user=user, date__gte=week_ago)
        avg_runs = weekly_activities.count()
        avg_distance = weekly_activities.aggregate(Avg('distance_km'))['distance_km__avg'] or 0
        avg_time = weekly_activities.aggregate(Avg('time_seconds'))['time_seconds__avg'] or 0

        ytd_activities = RunningActivity.objects.filter(user=user, date__gte=year_start)
        total_runs = ytd_activities.count()
        total_distance = ytd_activities.aggregate(Sum('distance_km'))['distance_km__sum'] or 0
        total_time = ytd_activities.aggregate(Sum('time_seconds'))['time_seconds__sum'] or 0
        total_steps = ytd_activities.aggregate(Sum('steps'))['steps__sum'] or 0

        return Response({
            "weekly": {
                "average_per_week": avg_runs,
                "average_distance_per_week": round(avg_distance, 2),
                "average_time_per_week": f"{round(avg_time / 60)} min"
            },
            "year_to_date": {
                "total_count": total_runs,
                "total_distance": f"{round(total_distance, 2)} km",
                "total_time": f"{round(total_time / 3600)} h",
                "total_elevation_gain": "0 m"
            }
        })

    
class CyclingStatsView(viewsets.ViewSet):
    permission_classes = [permissions.IsAuthenticated]

    def list(self, request):
        user = request.user
        today = timezone.now().date()
        week_ago = today - timedelta(days=7)
        year_start = today.replace(month=1, day=1)

        # Weekly stats
        weekly_activities = CyclingActivity.objects.filter(user=user, date__gte=week_ago)
        avg_rides = weekly_activities.count()
        avg_distance = weekly_activities.aggregate(Avg('distance_km'))['distance_km__avg'] or 0
        avg_duration = weekly_activities.aggregate(Avg('duration'))['duration__avg'] or timedelta(seconds=0)

        # Year to date
        ytd_activities = CyclingActivity.objects.filter(user=user, date__gte=year_start)
        total_rides = ytd_activities.count()
        total_distance = ytd_activities.aggregate(Sum('distance_km'))['distance_km__sum'] or 0
        total_duration = ytd_activities.aggregate(Sum('duration'))['duration__sum'] or timedelta(seconds=0)
        total_elevation = ytd_activities.aggregate(Sum('elevation_gain_m'))['elevation_gain_m__sum'] or 0

        return Response({
            "weekly": {
                "average_per_week": avg_rides,
                "average_distance_per_week": f"{round(avg_distance, 2)} km",
                "average_time_per_week": f"{round(avg_duration.total_seconds() / 60)} min"
            },
            "year_to_date": {
                "total_count": total_rides,
                "total_distance": f"{round(total_distance, 2)} km",
                "total_time": f"{round(total_duration.total_seconds() / 3600)} h",
                "total_elevation_gain": f"{total_elevation} m"
            }
        })

    
class MonthlySummaryView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        today = timezone.now().date()
        start_year = today.year

        summary = defaultdict(lambda: {"distance_km": 0, "time_minutes": 0})

        activities = RunningActivity.objects.filter(
            user=user,
            date__year=start_year
        )

        for activity in activities:
            month = activity.date.strftime("%b")  # e.g., 'Jan', 'Feb'
            summary[month]["distance_km"] += activity.distance_km
            summary[month]["time_minutes"] += activity.time_seconds // 60

        ordered_months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

        response_data = [
            {
                "month": m,
                "distance_km": summary[m]["distance_km"],
                "time_minutes": summary[m]["time_minutes"]
            }
            for m in ordered_months
        ]

        return Response(response_data)

class UserProfileViewSet(viewsets.ModelViewSet):
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # Supaya queryset tidak kosong, tapi tetap aman
        return CustomUser.objects.filter(id=self.request.user.id)

    def get_object(self):
        # Selalu mengembalikan user yang sedang login
        return self.request.user
    
