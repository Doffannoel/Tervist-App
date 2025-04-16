from rest_framework import serializers
from .models import CustomUser
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from django.contrib.auth import authenticate

# dah fix di atas
class SignUpSerializer(serializers.ModelSerializer):
    confirm_password = serializers.CharField(write_only=True, label="Confirm Password")
    target_weight = serializers.DecimalField(
        max_digits=5, decimal_places=2, required=False, allow_null=True, label="Target Weight"
    )
    timeline = serializers.ChoiceField(
        choices=[('Weeks', 'Weeks'), ('Months', 'Months')],
        required=False,
        allow_null=True,
        label="Timeline"
    )

    class Meta:
        model = CustomUser
        fields = [
            'email', 'username', 'gender', 'weight', 'height', 'age',
            'activity_level', 'goal', 'target_weight', 'timeline',
            'password', 'confirm_password'
        ]
        extra_kwargs = {
            'password': {'write_only': True},
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
        if data['password'] != data['confirm_password']:
            raise serializers.ValidationError("Passwords do not match.")
        try:
            validate_password(data['password'])
        except ValidationError as e:
            raise serializers.ValidationError({"password": e.messages})
        return data

    def create(self, validated_data):
        validated_data.pop('confirm_password')
        return CustomUser.objects.create_user(**validated_data)


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
        fields = [
            'id', 'email', 'username', 'gender', 'weight', 'height', 'age',
            'bio', 'city', 'state', 'birthday', 'activity_level',
            'goal', 'target_weight', 'timeline', 'profile_picture'
        ]
        read_only_fields = ['email']  # Atur field read-only jika perlu

    def validate_weight(self, value):
        if value is not None and (value < 30 or value > 300):
            raise serializers.ValidationError("Weight must be between 30 and 300 kg.")
        return value


    def update(self, instance, validated_data):
        """Override to update only the user profile fields."""
        instance.username = validated_data.get('username', instance.username)
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
            # ✅ Tambahkan ini agar profile_picture ikut di-update
    # ✅ Tambahkan ini agar profile_picture ikut di-update
        if 'profile_picture' in validated_data:
            instance.profile_picture = validated_data['profile_picture']
            print("Gambar diterima:", validated_data.get("profile_picture"))
        instance.save()
        return instance
        


