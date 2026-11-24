from rest_framework import serializers

from artisans.models import ArtisanProfile
from .models import User


class UserSerializer(serializers.ModelSerializer):
    artisan_profile_status = serializers.SerializerMethodField()
    artisan_profile_id = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            'id',
            'full_name',
            'email',
            'phone',
            'role',
            'profile_picture',
            'is_verified',
            'artisan_profile_status',
            'artisan_profile_id',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'is_verified', 'created_at', 'updated_at']

    def get_artisan_profile_status(self, obj):
        try:
            profile = obj.artisan_profile
        except ArtisanProfile.DoesNotExist:
            profile = None
        if profile is None:
            return 'incomplete' if obj.role == 'artisan' else None
        return profile.profile_status

    def get_artisan_profile_id(self, obj):
        try:
            profile = obj.artisan_profile
        except ArtisanProfile.DoesNotExist:
            profile = None
        return profile.id if profile else None


class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8, style={'input_type': 'password'})
    password_confirmation = serializers.CharField(write_only=True, min_length=8, style={'input_type': 'password'})
    email_or_phone = serializers.CharField(write_only=True, required=True)
    user_type = serializers.CharField(write_only=True, required=False, allow_null=True, allow_blank=True)

    class Meta:
        model = User
        fields = [
            'id',
            'full_name',
            'email_or_phone',
            'password',
            'password_confirmation',
            'role',
            'user_type',
        ]
        read_only_fields = ['id']

    def validate(self, attrs):
        if attrs.get('password') != attrs.get('password_confirmation'):
            raise serializers.ValidationError({'password_confirmation': 'Passwords do not match'})

        email_or_phone = attrs.get('email_or_phone', '').strip()
        if not email_or_phone:
            raise serializers.ValidationError({'email_or_phone': 'This field is required'})

        if '@' in email_or_phone:
            if User.objects.filter(email__iexact=email_or_phone).exists():
                raise serializers.ValidationError({'email_or_phone': 'User already exists'})
        elif User.objects.filter(phone=email_or_phone).exists():
            raise serializers.ValidationError({'email_or_phone': 'User already exists'})

        user_type = attrs.pop('user_type', None)
        if user_type:
            attrs['role'] = user_type

        attrs['email_or_phone'] = email_or_phone
        attrs.pop('password_confirmation', None)
        return attrs

    def create(self, validated_data):
        password = validated_data.pop('password')
        email_or_phone = validated_data.pop('email_or_phone')
        user = User.objects.create_user(
            email_or_phone,
            password=password,
            full_name=validated_data['full_name'],
            role=validated_data.get('role', 'client'),
        )
        if user.role == 'artisan':
            ArtisanProfile.objects.get_or_create(user=user, defaults={'profile_status': 'incomplete'})
        return user
