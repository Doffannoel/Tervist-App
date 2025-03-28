from rest_framework import serializers
from .models import CustomUser
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from django.contrib.auth import authenticate

class SignUpSerializer(serializers.ModelSerializer):
    confirm_password = serializers.CharField(write_only=True, label="Confirm Password")
    target_weight = serializers.DecimalField(max_digits=5, decimal_places=2, required=False, label="Target Weight")
    timeline = serializers.ChoiceField(choices=[('Weeks', 'Weeks'), ('Months', 'Months')], required=False, label="Timeline")

    class Meta:
        model = CustomUser
        fields = ['email', 'username', 'gender', 'weight', 'height', 'age', 'activity_level', 'goal', 'target_weight', 'timeline', 'password', 'confirm_password']
        extra_kwargs = {
            'password': {'write_only': True, 'label': "Password"},
            'email': {'label': "Email Address"},
            'username': {'label': "Username"},
            'gender': {'label': "Gender"},
            'weight': {'label': "Weight (kg)"},
            'height': {'label': "Height (cm)"},
            'age': {'label': "Age"},
            'activity_level': {'label': "Activity Level"},
            'goal': {'label': "Goal"},
        }

    def validate(self, data):
        """
        Validasi bahwa password dan confirm_password cocok.
        """
        if data['password'] != data['confirm_password']:
            raise serializers.ValidationError("Passwords do not match.")
        try:
            validate_password(data['password'])
        except ValidationError as e:
            raise serializers.ValidationError({"password": e.messages})
        return data

    def create(self, validated_data):
        validated_data.pop('confirm_password')  # Menghapus confirm_password karena tidak disimpan
        user = CustomUser.objects.create_user(**validated_data)
        return user

class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        """
        Validasi untuk memastikan kredensial login yang benar.
        """
        email = data.get("email")
        password = data.get("password")

        # Autentikasi menggunakan email dan password
        user = authenticate(email=email, password=password)
        if not user:
            raise serializers.ValidationError("Invalid credentials")
        return data
    
class ForgotPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()

class ResetPasswordSerializer(serializers.Serializer):
    otp = serializers.CharField(max_length=6)
    new_password = serializers.CharField(write_only=True)

class ProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['id', 'username', 'email', 'gender', 'bio', 'city', 'state', 'birthday', 'weight', 'height', 'age', 'activity_level', 'goal', 'target_weight', 'timeline']

    def update(self, instance, validated_data):
        """Override to update only the user profile fields."""
        instance.bio = validated_data.get('bio', instance.bio)
        instance.city = validated_data.get('city', instance.city)
        instance.state = validated_data.get('state', instance.state)
        instance.birthday = validated_data.get('birthday', instance.birthday)
        instance.weight = validated_data.get('weight', instance.weight)
        instance.height = validated_data.get('height', instance.height)
        instance.age = validated_data.get('age', instance.age)
        instance.activity_level = validated_data.get('activity_level', instance.activity_level)
        instance.goal = validated_data.get('goal', instance.goal)
        instance.target_weight = validated_data.get('target_weight', instance.target_weight)
        instance.timeline = validated_data.get('timeline', instance.timeline)
        instance.save()
        return instance
