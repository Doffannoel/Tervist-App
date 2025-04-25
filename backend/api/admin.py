from django import forms
from django.contrib import admin
from .models import CyclingActivity, DailySteps, FoodDatabase, CaloriesBurned, FoodIntake, FoodMeasurement, NutritionalTarget, RunningActivity

class FoodMeasurementInline(admin.TabularInline):
    model = FoodMeasurement
    extra = 1  # jumlah form kosong yang muncul otomatis

class FoodMeasurementInline(admin.TabularInline):
    model = FoodMeasurement
    extra = 1

@admin.register(FoodDatabase)
class FoodDatabaseAdmin(admin.ModelAdmin):
    list_display = ['name']
    inlines = [FoodMeasurementInline]

@admin.register(FoodIntake)
class FoodIntakeAdmin(admin.ModelAdmin):
    list_display = ['user', 'food_data', 'meal_type', 'serving_size', 'date', 'time']
    search_fields = ['user__username', 'food_data__name']
    list_filter = ['meal_type', 'date', 'user']

@admin.register(NutritionalTarget)
class NutritionalTargetAdmin(admin.ModelAdmin):
    list_display = ['user', 'calorie_target', 'protein_target', 'carbs_target', 'fats_target']
    search_fields = ['user__username']
    fields = ['user', 'calorie_target', 'protein_target', 'carbs_target', 'fats_target']


# Registrasi model DailySteps
@admin.register(DailySteps)
class DailyStepsAdmin(admin.ModelAdmin):
    list_display = ('user', 'steps', 'date')
    search_fields = ('user__username',)
    list_filter = ('date', 'user')

# Registrasi model CaloriesBurned
@admin.register(CaloriesBurned)
class CaloriesBurnedAdmin(admin.ModelAdmin):
    list_display = ('user', 'exercise_calories', 'bmr_calories', 'total_calories', 'date')
    search_fields = ('user__username',)
    list_filter = ('date', 'user')
    autocomplete_fields = ['user']  # mencegah user kosong


class RunningActivityForm(forms.ModelForm):
    hours = forms.IntegerField(label='Jam', required=False, min_value=0, initial=0)
    minutes = forms.IntegerField(label='Menit', required=False, min_value=0, initial=0)
    seconds = forms.IntegerField(label='Detik', required=False, min_value=0, initial=0)

    class Meta:
        model = RunningActivity
        fields = ['user', 'date', 'distance_km', 'steps', 'route_data']  # ✅ Tambahkan 'route_data'

    def clean(self):
        cleaned_data = super().clean()
        hours = cleaned_data.get('hours') or 0
        minutes = cleaned_data.get('minutes') or 0
        seconds = cleaned_data.get('seconds') or 0
        total_seconds = hours * 3600 + minutes * 60 + seconds
        cleaned_data['time_seconds'] = total_seconds
        return cleaned_data

    def save(self, commit=True):
        instance = super().save(commit=False)
        instance.time_seconds = self.cleaned_data['time_seconds']

        if instance.distance_km > 0:
            instance.pace = (instance.time_seconds / 60) / instance.distance_km
        else:
            instance.pace = 0

        weight = instance.user.weight or 60
        MET = 5.0
        calories = (float(weight) * MET * instance.time_seconds) / 60
        instance.calories_burned = round(calories)

        if commit:
            instance.save()
        return instance

class RunningActivityForm(forms.ModelForm):
    hours = forms.IntegerField(label='Jam', required=False, min_value=0, initial=0)
    minutes = forms.IntegerField(label='Menit', required=False, min_value=0, initial=0)
    seconds = forms.IntegerField(label='Detik', required=False, min_value=0, initial=0)

    class Meta:
        model = RunningActivity
        fields = ['user', 'date', 'distance_km', 'steps']  # exclude fields yang dihitung otomatis

    def clean(self):
        cleaned_data = super().clean()
        hours = cleaned_data.get('hours') or 0
        minutes = cleaned_data.get('minutes') or 0
        seconds = cleaned_data.get('seconds') or 0
        total_seconds = hours * 3600 + minutes * 60 + seconds
        cleaned_data['time_seconds'] = total_seconds
        return cleaned_data

    def save(self, commit=True):
        instance = super().save(commit=False)
        instance.time_seconds = self.cleaned_data['time_seconds']

        # Hitung pace (menit/km)
        if instance.distance_km > 0:
            instance.pace = (instance.time_seconds / 60) / instance.distance_km
        else:
            instance.pace = 0

        # Hitung calories_burned berdasarkan berat & waktu
        if instance.user:
            weight = instance.user.weight or 60
        else:
            weight = 60

        MET = 5.0  # nilai MET moderat
        calories = (float(weight) * MET * instance.time_seconds) / 60
        instance.calories_burned = round(calories)

        if commit:
            instance.save()
        return instance

@admin.register(RunningActivity)
class RunningActivityAdmin(admin.ModelAdmin):
    form = RunningActivityForm
    list_display = (
        'user',
        'date',
        'distance_km',
        'formatted_time',
        'pace',
        'pace_min_per_km',
        'calories_burned',
        'steps',
    )
    list_filter = ('user', 'date')
    search_fields = ('user__username',)
    autocomplete_fields = ['user']
    fields = ['user', 'date', 'distance_km', 'steps', 'route_data']  # ✅ Biar bisa edit route_data manual

    @admin.display(description='Time (hh:mm:ss)')
    def formatted_time(self, obj):
        seconds = obj.time_seconds
        hours = seconds // 3600
        minutes = (seconds % 3600) // 60
        secs = seconds % 60
        return f"{hours:02}:{minutes:02}:{secs:02}"

    @admin.display(description='Pace (min/km)')
    def pace_min_per_km(self, obj):
        return round(obj.pace_min_per_km, 2)
    
    
@admin.register(CyclingActivity)
class CyclingActivityAdmin(admin.ModelAdmin):
    list_display = (
        'user',
        'date',
        'get_duration_minutes',
        'distance_km',
        'avg_speed_kmh',
        'max_speed_kmh',
        'elevation_gain_m',
        'calories_burned',
    )
    list_filter = ('date', 'user')
    search_fields = ('user__username',)

    @admin.display(description='Duration (min)')
    def get_duration_minutes(self, obj):
        return round(obj.duration.total_seconds() / 60, 1)
    
