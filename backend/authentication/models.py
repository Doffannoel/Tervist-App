from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
from django.db import models
from django.utils import timezone

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

        return self.create_user(email, password, **extra_fields)


class CustomUser(AbstractBaseUser):
    email = models.EmailField(unique=True)  # Email sebagai username utama
    username = models.CharField(max_length=30, unique=True)
    first_name = models.CharField(max_length=30)
    last_name = models.CharField(max_length=30)
    gender = models.CharField(
        max_length=10, choices=[('Male', 'Male'), ('Female', 'Female'), ('Other', 'Other')]
    )
    weight = models.DecimalField(max_digits=5, decimal_places=2)  # Berat badan
    height = models.DecimalField(max_digits=5, decimal_places=2)  # Tinggi badan
    age = models.PositiveIntegerField()  # Usia

    # Fields untuk autentikasi
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    # Menggunakan CustomUserManager untuk manajer
    objects = CustomUserManager()

    USERNAME_FIELD = 'email'  # Gunakan email sebagai field utama
    REQUIRED_FIELDS = ['username', 'first_name', 'last_name']

    def __str__(self):
        return self.email
