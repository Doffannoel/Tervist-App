from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
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

        if extra_fields.get("is_staff") is not True:
            raise ValueError("Superuser must have is_staff=True.")
        if extra_fields.get("is_superuser") is not True:
            raise ValueError("Superuser must have is_superuser=True.")

        return self.create_user(email, password, **extra_fields)


class CustomUser(AbstractBaseUser, PermissionsMixin):
    email = models.EmailField(unique=True)  # Email sebagai username utama
    username = models.CharField(max_length=30, unique=True)  # Username pengguna
    gender = models.CharField(
        max_length=10, choices=[('Male', 'Male'), ('Female', 'Female'), ('Other', 'Other')]
    )
    weight = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True )  # Berat badan
    height = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)  # Tinggi badan
    age = models.PositiveIntegerField(null=True, blank=True)  # Usia
    date_joined = models.DateTimeField(default=timezone.now)  # Waktu bergabung
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_superuser = models.BooleanField(default=False)

    # Menggunakan CustomUserManager untuk manajer
    objects = CustomUserManager()

    USERNAME_FIELD = 'email'  # Gunakan email sebagai field utama
    REQUIRED_FIELDS = ['username']  # Hanya membutuhkan 'username' saat pembuatan superuser

    def __str__(self):
        return self.email
