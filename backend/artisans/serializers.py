from rest_framework import serializers
from .models import ArtisanProfile
from accounts.serializers import UserSerializer
from categories.models import Category
from categories.serializers import CategorySerializer


class ArtisanProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    category = CategorySerializer(read_only=True)
    specialty = serializers.CharField(required=False, allow_blank=True, allow_null=True)
    category_id = serializers.PrimaryKeyRelatedField(
        source='category',
        queryset=Category.objects.all(),
        write_only=True,
        required=False,
        allow_null=True,
    )
    profile_picture = serializers.ImageField(write_only=True, required=False, allow_null=True)
    status_label = serializers.CharField(source='get_profile_status_display', read_only=True)
    is_complete = serializers.SerializerMethodField()
    experience_years = serializers.IntegerField(required=False, allow_null=True)
    bio = serializers.CharField(required=False, allow_blank=True, allow_null=True)
    availability = serializers.CharField(required=False, allow_blank=True, allow_null=True)
    profile_status = serializers.ChoiceField(choices=ArtisanProfile.STATUS_CHOICES, required=False)
    
    class Meta:
        model = ArtisanProfile
        fields = [
            'id',
            'user',
            'category',
            'category_id',
            'specialty',
            'city',
            'experience_years',
            'bio',
            'availability',
            'profile_picture',
            'profile_status',
            'status_label',
            'is_complete',
            'rating',
            'completed_jobs',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'user', 'rating', 'completed_jobs', 'created_at', 'updated_at']

    def get_is_complete(self, obj):
        return obj.profile_status == 'complete'

    def update(self, instance, validated_data):
        profile_picture = validated_data.pop('profile_picture', None)
        user_data = {}

        if profile_picture is not None:
            user_data['profile_picture'] = profile_picture

        if 'specialty' in validated_data and validated_data['specialty'] == '':
            validated_data['specialty'] = None
        if 'bio' in validated_data and validated_data['bio'] == '':
            validated_data['bio'] = None
        if 'availability' in validated_data and validated_data['availability'] == '':
            validated_data['availability'] = None
        if 'experience_years' in validated_data and validated_data['experience_years'] in ['', None]:
            validated_data['experience_years'] = None

        for attr, value in validated_data.items():
            setattr(instance, attr, value)

        instance.save()

        if user_data:
            user = instance.user
            for attr, value in user_data.items():
                setattr(user, attr, value)
            user.save()

        return instance
