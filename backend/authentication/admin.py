from django.contrib import admin
from .models import CustomUser

# Registrasi CustomUser di admin panel
class CustomUserAdmin(admin.ModelAdmin):
    list_display = ('email', 'username','gender', 'weight', 'height', 'age', 'is_active', 'is_staff')
    search_fields = ('email', 'username')
    list_filter = ('is_active', 'is_staff', 'gender')
    ordering = ('email',)

admin.site.register(CustomUser, CustomUserAdmin)
