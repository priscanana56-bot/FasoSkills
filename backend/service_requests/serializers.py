from rest_framework import serializers
from .models import ServiceRequest
from accounts.serializers import UserSerializer


class ServiceRequestSerializer(serializers.ModelSerializer):
    client = UserSerializer(read_only=True)
    
    class Meta:
        model = ServiceRequest
        fields = ['id', 'client', 'title', 'description', 'city', 'address', 'status', 'created_at', 'updated_at']
        read_only_fields = ['id', 'client', 'created_at', 'updated_at']
