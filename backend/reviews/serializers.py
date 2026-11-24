from rest_framework import serializers
from .models import Review
from accounts.serializers import UserSerializer
from artisans.serializers import ArtisanProfileSerializer


class ReviewSerializer(serializers.ModelSerializer):
    client = UserSerializer(read_only=True)
    artisan = ArtisanProfileSerializer(read_only=True)
    
    class Meta:
        model = Review
        fields = ['id', 'client', 'artisan', 'rating', 'comment', 'created_at']
        read_only_fields = ['id', 'client', 'created_at']
