from decimal import Decimal
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.utils import timezone
from django.core.validators import FileExtensionValidator

# Manajer pengguna kustom
class CustomUserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        """
        Buat dan kembalikan user dengan email, password, dan field lainnya
        """
        if not email:
            raise ValueError("The Email field must be set")
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)  # Enkripsi password
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        """
        Buat dan kembalikan superuser dengan email dan password
        """
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)

        if extra_fields.get("is_staff") is not True:
            raise ValueError("Superuser must have is_staff=True.")
        if extra_fields.get("is_superuser") is not True:
            raise ValueError("Superuser must have is_superuser=True.")

        return self.create_user(email, password, **extra_fields)


class CustomUser(AbstractBaseUser, PermissionsMixin):
    email = models.EmailField(unique=True)
    username = models.CharField(max_length=30, unique=True)
    gender = models.CharField(
        max_length=10, 
        choices=[('Male', 'Male'), ('Female', 'Female'), ('Other', 'Other')]
    )
    weight = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    height = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    age = models.PositiveIntegerField(null=True, blank=True)
    bio = models.TextField(null=True, blank=True)
    city = models.CharField(max_length=100, null=True, blank=True)
    state = models.CharField(max_length=100, null=True, blank=True)
    birthday = models.DateField(null=True, blank=True)
    profile_picture = models.ImageField(
        upload_to='profile_picture/',
        null=True,
        blank=True,
        validators=[FileExtensionValidator(allowed_extensions=['jpg', 'jpeg', 'png'])]
    )
    
    # New fields
    activity_level = models.CharField(
        max_length=20, 
        choices=[('Sedentary', 'Sedentary'), ('Low Active', 'Low Active'), ('Active', 'Active'), ('Very Active', 'Very Active')],
        default='Sedentary'
    )
    goal = models.CharField(
        max_length=20, 
        choices=[('Weight Gain', 'Weight Gain'), ('Maintain Weight', 'Maintain Weight'), ('Weight Loss', 'Weight Loss')],
        default='Maintain Weight'
    )
    target_weight = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    timeline = models.CharField(max_length=20, choices=[('Weeks', 'Weeks'), ('Months', 'Months')], null=True, blank=True)
    
    # Calorie tracking fields
    calorie_target = models.FloatField(default=0.0)  # Total calories to consume per day
    total_calories_consumed = models.FloatField(default=0.0)  # Total calories consumed by the user
    remaining_calories = models.FloatField(default=0.0)  # Remaining calories to be consumed
    
    # Tracking
    date_joined = models.DateTimeField(default=timezone.now)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_superuser = models.BooleanField(default=False)

    objects = CustomUserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    def __str__(self):
        return self.email

    def save(self, *args, **kwargs):
        """Override save method to calculate remaining calories when saving the user."""
        self.remaining_calories = self.calorie_target - self.total_calories_consumed
        super().save(*args, **kwargs)

    def calculate_calorie_target(self):
        """Calculate and update calorie target based on user goal, activity level, and other data."""
        # Example logic for calculating calorie target based on activity level and goal
        if self.goal == 'Weight Gain':
            self.calorie_target = 2500  # Example value for weight gain
        elif self.goal == 'Weight Loss':
            self.calorie_target = 1800  # Example value for weight loss
        else:
            self.calorie_target = 2000  # Maintenance goal
        
        self.save()  # Save the changes to the model

    def update_total_calories(self, calories: Decimal):
        """Update total calories consumed by the user."""
        self.total_calories_consumed += calories
        self.save()  # Recalculate remaining calories when updating total calories
    
class PasswordResetOTP(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE)  # Mengaitkan dengan CustomUser
    otp = models.CharField(max_length=6)  # OTP yang dikirim
    created_at = models.DateTimeField(auto_now_add=True)  # Waktu OTP dibuat
    expires_at = models.DateTimeField()  # Waktu kedaluwarsa OTP

    def __str__(self):
        return f"OTP for {self.user.email}"

    def is_expired(self):
        """ Cek apakah OTP sudah kedaluwarsa """
        return self.expires_at < timezone.now()
