from collections import defaultdict
from django.db import IntegrityError
from django.shortcuts import get_object_or_404
from rest_framework import viewsets, permissions, status, filters
from datetime import datetime, timedelta
from django.db.models import Sum, Min
from rest_framework.response import Response
from rest_framework_simplejwt.authentication import JWTAuthentication
from django.utils import timezone
from django.utils.timezone import now
from authentication.models import CustomUser
from .models import CaloriesBurned, CyclingActivity, DailySteps, FoodDatabase, FoodIntake, FoodMeasurement, NutritionalTarget, Reminder, RunningActivity, WalkingActivity
from .serializers import CyclingActivitySerializer, DailyStepsSerializer, CaloriesBurnedSerializer, FoodDatabaseSerializer, FoodIntakeSerializer, NutritionalTargetSerializer, ReminderSerializer, RunningActivitySerializer, UserProfileSerializer, WalkingActivitySerializer
from rest_framework.views import APIView
from django.db.models import Avg, Sum, Count
from calendar import monthrange
from rest_framework.viewsets import ModelViewSet
from rest_framework.decorators import action, api_view, permission_classes 
from rest_framework.permissions import AllowAny
from rest_framework.exceptions import ValidationError
from pytz import timezone as pytz_timezone 
from decimal import Decimal

def get_today_local():
    local_tz = pytz_timezone("Asia/Jakarta")
    return timezone.localtime(timezone.now(), local_tz).date()

@api_view(['POST'])
@permission_classes([AllowAny])
def calculate_nutrition_preview(request):
    data = request.data
    try:
        weight = Decimal(str(data.get('weight', 0)))
        height = Decimal(str(data.get('height', 0)))
        age = Decimal(str(data.get('age', 25)))
        gender = data.get('gender', 'Male')
        goal = data.get('goal', 'Maintain Weight')
        activity_level = data.get('activity_level', 'Low Active')

        # BMR
        bmr = Decimal('10') * weight + Decimal('6.25') * height - Decimal('5') * age
        if gender == 'Male':
            bmr += Decimal('5')
        else:
            bmr -= Decimal('161')

        # TDEE multiplier
        activity_multipliers = {
            'Sedentary': Decimal('1.2'),
            'Low Active': Decimal('1.375'),
            'Active': Decimal('1.55'),
            'Very Active': Decimal('1.725'),
        }
        multiplier = activity_multipliers.get(activity_level, Decimal('1.2'))
        tdee = bmr * multiplier

        # Calorie adjustment
        if goal.lower() == 'weight gain':
            calorie_target = tdee + Decimal('500')
        elif goal.lower() == 'weight loss':
            calorie_target = tdee - Decimal('500')
        else:
            calorie_target = tdee

        protein_target = calorie_target * Decimal('0.15') / Decimal('4')
        carbs_target = calorie_target * Decimal('0.55') / Decimal('4')
        fats_target = calorie_target * Decimal('0.30') / Decimal('9')

        return Response({
            'calorie_target': round(calorie_target),
            'protein_target': round(protein_target),
            'carbs_target': round(carbs_target),
            'fats_target': round(fats_target),
        }, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class NutritionalTargetView(viewsets.ModelViewSet):
    queryset = NutritionalTarget.objects.all()
    serializer_class = NutritionalTargetSerializer
    permission_classes = [permissions.AllowAny]

    def perform_create(self, serializer):
        if self.request.user.is_authenticated:
            if NutritionalTarget.objects.filter(user=self.request.user).exists():
                raise ValidationError("Target already exists for this user")
            
            print("🔥 REQUEST.DATA:", self.request.data)  # <--- Tambahan pertama

            # Simpan objek terlebih dahulu
            nutritional_target = serializer.save(user=self.request.user)

            # Cek apakah data preview dikirim dari frontend
            if (
                'calorie_target' in self.request.data
                and 'protein_target' in self.request.data
                and 'carbs_target' in self.request.data
                and 'fats_target' in self.request.data
            ):
                # ✅ Preview dikirim, jadi gak perlu dihitung ulang
                print("🔁 Skipping calculate_targets karena data preview sudah tersedia.")
                return
            else:
                # ❗Jika tidak ada data preview, hitung seperti biasa
                print("⚙️ Menjalankan calculate_targets() dari backend")
                nutritional_target.calculate_targets()


            print("🔥 TERSIMPAN:", {
            "calorie_target": nutritional_target.calorie_target,
            "protein_target": nutritional_target.protein_target,
            "carbs_target": nutritional_target.carbs_target,
            "fats_target": nutritional_target.fats_target,
        })
        else:
            # Jika user belum login (AllowAny), tetap bisa pakai manual_data
            nutritional_target = serializer.save()
            nutritional_target.calculate_targets(manual_data=self.request.data)


    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def daily_summary(self, request):
        user = request.user
        print("✅ DAILY SUMMARY HIT by", user.email)
        date_str = request.GET.get('date')
        if not date_str:
            return Response({'error': 'Date is required'}, status=400)

        try:
            date = datetime.strptime(date_str, '%Y-%m-%d').date()
        except ValueError:
            return Response({'error': 'Invalid date format'}, status=400)

        # Get target
        target = NutritionalTarget.objects.filter(user=user).first()
        if not target:
            return Response({'error': 'No target set'}, status=404)

        # Get intake
        intake_qs = FoodIntake.objects.filter(user=user, date=date)
        total_calories = sum(i.manual_calories or 0 for i in intake_qs)
        total_protein = sum(i.manual_protein or 0 for i in intake_qs)
        total_carbs = sum(i.manual_carbs or 0 for i in intake_qs)
        total_fats = sum(i.manual_fats or 0 for i in intake_qs)


        response_data = {
            "calorie_target": target.calorie_target,
            "protein_target": target.protein_target,
            "carbs_target": target.carbs_target,
            "fats_target": target.fats_target,
            "calories_consumed": total_calories,
            "protein_consumed": total_protein,
            "carbs_consumed": total_carbs,
            "fats_consumed": total_fats,
        }

        print("📦 DAILY SUMMARY RESPONSE:", response_data)
        return Response(response_data, status=status.HTTP_200_OK)
    
class FoodDatabaseViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = FoodDatabase.objects.all()
    serializer_class = FoodDatabaseSerializer
    permission_classes = [permissions.AllowAny]
    filter_backends = [filters.SearchFilter]
    search_fields = ['name']
    
class FoodIntakeView(viewsets.ModelViewSet):
    queryset = FoodIntake.objects.all()
    serializer_class = FoodIntakeSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        user = self.request.user
        data = self.request.data

        print("🔥 Food Intake Creation Data:")
        print(f"User: {user.username}")
        print(f"Input Data: {data}")
        food_name = data.get('name', 'Custom Meal')

    # Tentukan meal_type otomatis kalau gak dikirim
        meal_type = data.get('meal_type')
        # Zona waktu lokal
        local_tz = pytz_timezone('Asia/Jakarta')
        input_time_str = data.get('time')
        input_time = timezone.localtime(timezone.now(), local_tz).time()  # default fallback

        if input_time_str:
            try:
                # Coba parse HH:mm atau HH:mm:ss
                if len(input_time_str.strip()) == 5:
                    input_time_naive = datetime.strptime(input_time_str, "%H:%M")
                else:
                    input_time_naive = datetime.strptime(input_time_str, "%H:%M:%S")

                input_time = local_tz.localize(
                    datetime.combine(timezone.now().date(), input_time_naive.time())
                ).time()
            except Exception as e:
                print(f"❌ Gagal parsing time string '{input_time_str}', fallback to localtime. Error: {e}")

        # Auto-detect meal type jika belum dikirim
        if not meal_type:
            if datetime.strptime("06:00", "%H:%M").time() <= input_time < datetime.strptime("10:00", "%H:%M").time():
                meal_type = "Breakfast"
            elif datetime.strptime("10:00", "%H:%M").time() <= input_time < datetime.strptime("15:00", "%H:%M").time():
                meal_type = "Lunch"
            elif (
                datetime.strptime("15:00", "%H:%M").time() <= input_time
                or input_time < datetime.strptime("02:00", "%H:%M").time()
            ):
                meal_type = "Dinner"
            else:
                meal_type = "Snack"

            print(f"🕒 Final parsed input_time (WIB): {input_time}")
            print(f"🍽️ Auto-detected meal_type: {meal_type}")


        # Siapkan data dasar
        instance_data = {
            'user': user,
            'name': food_name,
            'meal_type': meal_type,
            'date': data.get('date', get_today_local()),

            'time': data.get('time', timezone.now().time())
        }

        food_data_id = data.get('food_data_id')
        measurement_id = data.get('measurement_id')
        serving_size = data.get('serving_size', 1.0)

        try:
            serving_size = float(serving_size)
        except (ValueError, TypeError):
            serving_size = 1.0

        manual_calories = data.get('manual_calories')

        try:
            if food_data_id:
                food_data = FoodDatabase.objects.get(id=food_data_id)
                instance_data['name'] = food_data.name
                instance_data['food_data'] = food_data

                # Ambil measurement

                if measurement_id is not None:
                    try:
                        # Try to get by ID first
                        measurement = food_data.measurements.get(id=measurement_id)
                    except FoodMeasurement.DoesNotExist:
                        # If that fails, try using it as an index
                        measurements = list(food_data.measurements.all())
                        try:
                            idx = int(measurement_id)
                            if 0 <= idx < len(measurements):
                                measurement = measurements[idx]
                            else:
                                measurement = food_data.measurements.first()
                        except (ValueError, TypeError, IndexError):
                            # If all fails, use the first measurement
                            measurement = food_data.measurements.first()
                else:
                    measurement = food_data.measurements.first()

                if measurement:
                    instance_data['manual_calories'] = measurement.calories * serving_size
                    instance_data['manual_protein'] = measurement.protein * serving_size
                    instance_data['manual_carbs'] = measurement.carbs * serving_size
                    instance_data['manual_fats'] = measurement.fat * serving_size

            elif manual_calories is not None:
                # Mode input manual
                instance_data['manual_calories'] = float(manual_calories)
                instance_data['manual_protein'] = float(data.get('manual_protein', 0))
                instance_data['manual_carbs'] = float(data.get('manual_carbs', 0))
                instance_data['manual_fats'] = float(data.get('manual_fats', 0))

            else:
                return Response({"error": "Harus pilih makanan atau isi kalori manual"}, status=status.HTTP_400_BAD_REQUEST)

            # ✅ Simpan instance-nya
            instance = serializer.save(**instance_data)

            # Optional: perbarui target kalau pakai formula dinamis
            try:
                nt = NutritionalTarget.objects.get(user=user)
                nt.save()
            except NutritionalTarget.DoesNotExist:
                print("❌ User belum punya nutritional target")

            return Response(self.get_serializer(instance).data, status=status.HTTP_201_CREATED)

        except FoodDatabase.DoesNotExist:
            return Response({"error": "Makanan tidak ditemukan"}, status=status.HTTP_400_BAD_REQUEST)

    def list(self, request):
        user = request.user
        search_query = request.GET.get('search', None)
        date_filter = request.GET.get('date', None)

        today = get_today_local()
        food_intakes = FoodIntake.objects.filter(user=user) 
        if search_query:
            food_items = FoodDatabase.objects.filter(name__icontains=search_query)
            return Response(FoodDatabaseSerializer(food_items, many=True).data)

        # food_intakes = FoodIntake.objects.filter(user=user)

        if date_filter:
            food_intakes = food_intakes.filter(date=date_filter)
            # Debug timezone information
        print(f"Server timezone now: {timezone.now()}")
        print(f"Local server date used for filtering: {today}")
        
        # Get date parameter from request if available
        date_param = request.GET.get('date')
        if date_param:
            try:
                today = datetime.strptime(date_param, '%Y-%m-%d').date()
                print(f"Using date parameter instead: {today}")
            except ValueError:
                print(f"Invalid date parameter: {date_param}")

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
        local_tz = pytz_timezone("Asia/Jakarta")
        date_str = request.GET.get('date')
        if date_str:
            try:
                today = datetime.strptime(date_str, "%Y-%m-%d").date()
            except ValueError:
                today = get_today_local()
                print(f"❌ Invalid date string received, fallback to local today: {today}")
        else:
            today = get_today_local()
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
        
        # total_running_steps = running_steps_data.aggregate(Sum('steps'))['steps__sum'] or 0
        # print(f"Steps from RunningActivity: {total_running_steps} (records: {running_steps_data.count()})")
        
        total_steps = steps_data.aggregate(Sum('steps'))['steps__sum'] or 0
        
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
        print(f"Food intake for today ({today}): {list(food_intake_data.values())}")
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
            meal_type_clean = str(meal_type).capitalize().strip()
            if meal_type_clean in categorized_food:
                categorized_food[meal_type_clean].append(food)

        
        for meal_type, items in categorized_food.items():
            print(f"Meal type {meal_type}: {items}")
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
            calories_burned = self.calculate_calories_burned(distance, time, steps)

            running_activity = serializer.save(
                user=user,
                calories_burned=calories_burned
            )
            running_activity.calculate_pace()

            # Update steps and calories burned in DailySteps and CaloriesBurned
            self.update_daily_steps(user, steps)
            self.update_calories_burned(user, calories_burned)

        else:
            serializer.save()

    def update_daily_steps(self, user, steps):
        today = get_today_local()

        # Update DailySteps for today
        daily_steps, created = DailySteps.objects.get_or_create(user=user, date=today)

        # If new DailySteps entry, set steps, otherwise add to the existing ones
        if created:
            daily_steps.steps = steps
        else:
            daily_steps.steps += steps  # Accumulate steps if already exists

        daily_steps.save()

    def update_calories_burned(self, user, calories_burned):
        today = get_today_local()

        # Update CaloriesBurned for today
        calories_obj, created = CaloriesBurned.objects.get_or_create(user=user, date=today)

        # If new CaloriesBurned entry, set total_calories, otherwise add to the existing ones
        if created:
            calories_obj.total_calories = calories_burned
        else:
            calories_obj.total_calories += calories_burned  # Accumulate calories if already exists

        calories_obj.save()

    def calculate_calories_burned(self, distance, time, steps):
        MET = 5.0
        weight = getattr(self.request.user, 'weight', 60) or 60  # fallback
        weight = float(weight)
        time_minutes = float(time) / 60.0

        if time <= 0 or weight <= 0:
            return 1

        # Rumus yang bener
        calories = ((MET * weight * 3.5) / 200) * time_minutes
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
        user = request.user
        today = get_today_local()
        week_ago = today - timezone.timedelta(days=6)

        # Ambil semua makanan dalam 7 hari terakhir
        food_logs = FoodIntake.objects.filter(user=user, date__range=[week_ago, today])

        # Siapkan struktur Senin - Minggu default 0
        daily_totals = { (week_ago + timezone.timedelta(days=i)): 0 for i in range(7) }

        for entry in food_logs:
            calories = entry.manual_calories or 0
            daily_totals[entry.date] += calories

        # Buat array untuk frontend
        data = []
        for day, cal in daily_totals.items():
            data.append({
                "date": day.strftime("%a"),  # contoh: 'Mon'
                "calories": round(cal)
            })

        # Ambil target kalori harian
        target = NutritionalTarget.objects.filter(user=user).first()
        calorie_goal = target.calorie_target if target else 0
        total_eaten = sum(d['calories'] for d in data)
        weekly_goal = calorie_goal * 7

        if calorie_goal > 0:
            net = total_eaten - weekly_goal
            net_average = net / 7
        else:
            net = 0
            net_average = 0

        return Response({
            "week_data": data,
            "goal": round(calorie_goal),
            "total_eaten": round(total_eaten),
            "net_difference": round(net),
            "net_average": round(net_average),
        })
    
class RunningStatsView(viewsets.ViewSet):
    permission_classes = [permissions.IsAuthenticated]  # ganti AllowAny

    def list(self, request):
        user = request.user  # tidak perlu user_id dari query params

        today = get_today_local()
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
        today = get_today_local()
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
        today = get_today_local()
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
    
    def perform_update(self, serializer):
        user = serializer.save()
        try:
            target = NutritionalTarget.objects.get(user=user)
            target.calculate_targets()  # hitung ulang target otomatis saat user update profil
        except NutritionalTarget.DoesNotExist:
            pass
    
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
    
class WalkingActivityView(viewsets.ModelViewSet):
    queryset = WalkingActivity.objects.all()
    serializer_class = WalkingActivitySerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        if self.request.user.is_authenticated:
            user = self.request.user
            distance = serializer.validated_data['distance_km']
            time = serializer.validated_data['time_seconds']
            steps = serializer.validated_data['steps']
            
            # Hitung kalori yang dibakar
            calories_burned = self.calculate_calories_burned(distance, time, steps)

            walking_activity = serializer.save(
                user=user,
                calories_burned=calories_burned
            )

            # Update langkah dan kalori terbakar
            self.update_daily_steps(user, steps)
            self.update_calories_burned(user, calories_burned)

        else:
            serializer.save()

    def calculate_calories_burned(self, distance, time, steps):
        MET = 3.5  # MET untuk berjalan (lebih rendah dari berlari)
        weight = getattr(self.request.user, 'weight', 60) or 60  # default 60 kg
        weight = float(weight)
        time_minutes = float(time) / 60.0

        if time <= 0 or weight <= 0:
            return 1

        # Rumus perhitungan kalori standar
        calories = ((MET * weight * 3.5) / 200) * time_minutes
        return round(calories)

    def update_daily_steps(self, user, steps):
        today = get_today_local()
        daily_steps, created = DailySteps.objects.get_or_create(user=user, date=today)
        
        if created:
            daily_steps.steps = steps
        else:
            daily_steps.steps += steps

        daily_steps.save()

    def update_calories_burned(self, user, calories_burned):
        today = get_today_local()
        calories_obj, created = CaloriesBurned.objects.get_or_create(user=user, date=today)
        
        if created:
            calories_obj.total_calories = calories_burned
        else:
            calories_obj.total_calories += calories_burned

        calories_obj.save()

class RunningHistoryViewSet(viewsets.ViewSet):
    permission_classes = [permissions.IsAuthenticated]
    
    def list(self, request):
        """Get summary of all running activities"""
        user = request.user
        
        # Get all running activities for this user
        activities = RunningActivity.objects.filter(user=user).order_by('-date')
        
        if not activities.exists():
            return Response({
                "message": "No running activities found",
                "start_date": datetime.now().strftime('%Y-%m-%d'),
                "total_workouts": 0,
                "total_time_seconds": 0,
                "total_distance": 0,
                "total_calories": 0,
                "records": []
            }, status=status.HTTP_200_OK)
        
        # Calculate summary statistics
        total_workouts = activities.count()
        total_time_seconds = activities.aggregate(Sum('time_seconds'))['time_seconds__sum'] or 0
        total_distance = activities.aggregate(Sum('distance_km'))['distance_km__sum'] or 0
        total_distance = round(total_distance, 2)  # Round to 2 decimal places
        total_calories = activities.aggregate(Sum('calories_burned'))['calories_burned__sum'] or 0
        
        # Get the first activity date (when the user started)
        start_date = activities.aggregate(Min('date'))['date__min']
        
        # Prepare records for the list
        records = []
        for activity in activities:
            records.append({
                'id': activity.id,
                'distance': round(activity.distance_km, 2),  # Round to 2 decimal places
                'date': activity.date.strftime('%Y-%m-%d'),
            })
        
        return Response({
            "start_date": start_date.strftime('%Y-%m-%d'),
            "total_workouts": total_workouts,
            "total_time_seconds": total_time_seconds,
            "total_distance": total_distance,
            "total_calories": total_calories,
            "records": records
        }, status=status.HTTP_200_OK)
    
    def retrieve(self, request, pk=None):
        """Get detailed information for a specific running activity"""
        user = request.user
        
        try:
            # Get the specific running activity
            activity = RunningActivity.objects.get(id=pk, user=user)
            
            # Create response data
            response_data = {
                "id": activity.id,
                "distance_km": round(activity.distance_km, 2),
                "time_seconds": activity.time_seconds,
                "pace": activity.pace,
                "calories_burned": activity.calories_burned,
                "steps": activity.steps,
                "date": activity.date.strftime('%Y-%m-%d'),
                # Include any other fields you need
            }
            
            return Response(response_data, status=status.HTTP_200_OK)
        except RunningActivity.DoesNotExist:
            return Response(
                {"error": "Running activity not found"}, 
                status=status.HTTP_404_NOT_FOUND
            )