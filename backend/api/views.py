from collections import defaultdict
from django.db import IntegrityError
from rest_framework import viewsets, permissions, status
from datetime import datetime, timedelta
from django.db.models import Sum
from rest_framework.response import Response
from rest_framework_simplejwt.authentication import JWTAuthentication
from django.utils import timezone
from django.utils.timezone import now
from authentication.models import CustomUser
from .models import CaloriesBurned, CyclingActivity, DailySteps, FoodDatabase, FoodIntake, NutritionalTarget, Reminder, RunningActivity
from .serializers import CyclingActivitySerializer, DailyStepsSerializer, CaloriesBurnedSerializer, FoodDatabaseSerializer, FoodIntakeSerializer, NutritionalTargetSerializer, ReminderSerializer, RunningActivitySerializer, UserProfileSerializer
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
        
        # Debugging print statements
        print("Food Intake Creation Data:")
        print(f"User: {user.username}")
        print(f"Input Data: {data}")
        
        # Determine meal type if not provided
        meal_type = data.get('meal_type')
        if not meal_type:
            current_time = datetime.now().time()
            if current_time >= datetime.strptime("06:00", "%H:%M").time() and current_time < datetime.strptime("10:00", "%H:%M").time():
                meal_type = "Breakfast"
            elif current_time >= datetime.strptime("10:00", "%H:%M").time() and current_time < datetime.strptime("15:00", "%H:%M").time():
                meal_type = "Lunch"
            elif current_time >= datetime.strptime("15:00", "%H:%M").time() and current_time < datetime.strptime("20:00", "%H:%M").time():
                meal_type = "Dinner"
            else:
                meal_type = "Snack"
        
        # Prepare instance data
        instance_data = {
            'user': user,
            'meal_type': meal_type,
            'date': data.get('date', timezone.now().date()),
            'time': data.get('time', timezone.now().time())
        }
        
        # Handle food data from database
        food_data_id = data.get('food_data_id')
        manual_calories = data.get('manual_calories')
        
        try:
            if food_data_id:
                # Scenario 1: Food from database
                food_data = FoodDatabase.objects.get(id=food_data_id)
                instance_data['food_data'] = food_data
                calories = food_data.calories
                
                # Optional: Adjust for serving size if needed
                serving_size = data.get('serving_size', 1)
                try:
                    serving_size = float(serving_size)
                    calories *= serving_size
                except (ValueError, TypeError):
                    pass
                
                print(f"Database Food Selected: {food_data.name}")
                print(f"Calories: {calories}")
                
                # Create instance with food data
                instance = serializer.save(**instance_data)
            
            elif manual_calories is not None:
                # Scenario 2: Manual calories input
                instance_data['manual_calories'] = float(manual_calories)
                calories = float(manual_calories)
                
                print(f"Manual Calories Input: {calories}")
                
                # Create instance with manual calories
                instance = serializer.save(**instance_data)
            
            else:
                # No calories provided
                return Response(
                    {"error": "Either food from database or manual calories are required"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Update Nutritional Target
            try:
                nt = NutritionalTarget.objects.get(user=user)
                nt.calorie_target -= calories
                nt.save()
                
                print(f"Updated Nutritional Target. Remaining Calories: {nt.calorie_target}")
            
            except NutritionalTarget.DoesNotExist:
                print("No Nutritional Target found for user")
            
            return Response(
                self.get_serializer(instance).data, 
                status=status.HTTP_201_CREATED
            )
        
        except FoodDatabase.DoesNotExist:
            return Response(
                {"error": "Selected food item not found in database"},
                status=status.HTTP_400_BAD_REQUEST
        )

    def list(self, request):
        # Existing search functionality
        search_query = request.GET.get('search', None)
        if search_query:
            food_items = FoodDatabase.objects.filter(name__icontains=search_query)
            return Response(FoodDatabaseSerializer(food_items, many=True).data)
        else:
            # List user's food intakes
            food_intakes = FoodIntake.objects.filter(user=request.user)
            return Response(FoodIntakeSerializer(food_intakes, many=True).data)


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
    authentication_classes = [JWTAuthentication]
    permission_classes = [permissions.AllowAny]
    
    def list(self, request):
        # Cek header dan authentikasi
        auth_header = request.META.get('HTTP_AUTHORIZATION', '')
        user = request.user if request.user.is_authenticated else None
        
        print(f"Dashboard auth header: {auth_header}")
        print(f"Dashboard user authenticated: {user is not None}")
        
        if user:
            print(f"User ID: {user.id}, Username: {user.username}, Email: {user.email}")
        
        # Get today's date
        today = timezone.now().date()
        print(f"Filtering data for date: {today}")
        
        if user is None:
            # Return default data for unauthorized users
            return Response({
                "message": "Please log in to view your personalized dashboard",
                "calorie_target": 1236,
                "total_steps": 0,
                "steps_goal": 10000,
                "distance_km": 1.7,
                "pace": "14 min/km",
                "calories_burned_goal": 1000,
                "total_calories_burned": 0,
                "exercise_calories": 286,
                "bmr_calories": 200,
                "categorized_food": {
                    "Breakfast": [],
                    "Lunch": [],
                    "Dinner": [],
                    "Snack": []
                }
            }, status=status.HTTP_200_OK)
        
        # Get the total steps for today (from DailySteps and RunningActivity)
        steps_data = DailySteps.objects.filter(user=user, date=today)
        total_steps = steps_data.aggregate(Sum('steps'))['steps__sum'] or 0
        print(f"Steps from DailySteps: {total_steps} (records: {steps_data.count()})")
        
        running_steps_data = RunningActivity.objects.filter(user=user, date=today)
        total_running_steps = running_steps_data.aggregate(Sum('steps'))['steps__sum'] or 0
        print(f"Steps from RunningActivity: {total_running_steps} (records: {running_steps_data.count()})")
        
        total_steps += total_running_steps
        
        # Get distance and pace information
        distance_km = running_steps_data.aggregate(Sum('distance_km'))['distance_km__sum'] or 0
        print(f"Total distance: {distance_km} km")
        
        # Get average pace (jika ada beberapa aktivitas, ini akan jadi rata-rata tertimbang)
        pace = "14 min/km"  # Default value
        if running_steps_data.exists() and distance_km > 0:
            total_time_seconds = running_steps_data.aggregate(Sum('time_seconds'))['time_seconds__sum'] or 0
            avg_pace_minutes = (total_time_seconds / 60) / distance_km if distance_km > 0 else 0
            pace = f"{int(avg_pace_minutes)} min/km"
        print(f"Average pace: {pace}")

        # Get calories burned information
        calories_burned_data = CaloriesBurned.objects.filter(user=user, date=today)
        total_calories_burned = calories_burned_data.aggregate(Sum('total_calories'))['total_calories__sum'] or 0
        print(f"Calories from CaloriesBurned: {total_calories_burned} (records: {calories_burned_data.count()})")
        
        total_running_calories_burned = running_steps_data.aggregate(Sum('calories_burned'))['calories_burned__sum'] or 0
        print(f"Calories from RunningActivity: {total_running_calories_burned}")
        
        total_calories_burned += total_running_calories_burned
        
        # Get exercise and BMR breakdown if available
        exercise_calories = calories_burned_data.aggregate(Sum('exercise_calories'))['exercise_calories__sum'] or 0
        bmr_calories = calories_burned_data.aggregate(Sum('bmr_calories'))['bmr_calories__sum'] or 0
        print(f"Exercise calories: {exercise_calories}, BMR calories: {bmr_calories}")

        # Get nutritional target data
        nutritional_target = NutritionalTarget.objects.filter(user=user).first()
        nutritional_target_data = NutritionalTargetSerializer(nutritional_target).data if nutritional_target else {}
        print(f"Nutritional target: {nutritional_target_data}")

        # Get and categorize food intake
        food_intake_data = FoodIntake.objects.filter(user=user, date=today)
        print(f"Food intake records: {food_intake_data.count()}")
        
        serialized_food = FoodIntakeSerializer(food_intake_data, many=True).data

        categorized_food = {
            "Breakfast": [],
            "Lunch": [],
            "Dinner": [],
            "Snack": []
        }

        for food in serialized_food:
            meal_type = food.get("meal_type")
            if meal_type in categorized_food:
                categorized_food[meal_type].append(food)
        
        for meal_type, items in categorized_food.items():
            print(f"{meal_type} items: {len(items)}")

        # Prepare the response data
        response_data = {
            "nutritional_target": nutritional_target_data,
            "total_steps": total_steps,
            "steps_goal": nutritional_target.steps_goal if nutritional_target else 10000,
            "distance_km": distance_km or 1.7,  # Default to 1.7 if no data
            "pace": pace,
            
            "calories_burned_goal": nutritional_target.calories_burned_goal if nutritional_target else 1000,
            "total_calories_burned": total_calories_burned,
            "exercise_calories": exercise_calories or 286,  # Default to 286 if no data
            "bmr_calories": bmr_calories or 200,  # Default to 200 if no data
            
            "calorie_target": nutritional_target.calorie_target if nutritional_target else 1236,
            "categorized_food": categorized_food,
        }
        
        print(f"Response prepared with {len(response_data)} keys")
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
        print("FOOD LOG COUNT", food_logs.count())
        print("DATES IN FOOD LOG", list(food_logs.values_list('date', flat=True)))  # 

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
    
class ReminderViewSet(viewsets.ModelViewSet):
    serializer_class = ReminderSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        """Return only the current user's reminders"""
        return Reminder.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        """Create a new reminder for the current user"""
        try:
            serializer.save(user=self.request.user)
        except IntegrityError:
            # User already has a reminder for this meal type, update it instead
            meal_type = serializer.validated_data.get('meal_type')
            reminder = Reminder.objects.get(user=self.request.user, meal_type=meal_type)
            
            # Update the existing reminder
            reminder.time = serializer.validated_data.get('time')
            reminder.is_active = serializer.validated_data.get('is_active', True)
            reminder.save()
            
            return Response(
                ReminderSerializer(reminder).data,
                status=status.HTTP_200_OK
            )
    
    def update(self, request, *args, **kwargs):
        """Update an existing reminder"""
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)
        return Response(serializer.data)