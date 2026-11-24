from rest_framework import serializers
from .models import Quote
from service_requests.models import ServiceRequest
from service_requests.serializers import ServiceRequestSerializer
from artisans.serializers import ArtisanProfileSerializer


class QuoteSerializer(serializers.ModelSerializer):
    request = ServiceRequestSerializer(read_only=True)
    request_id = serializers.PrimaryKeyRelatedField(
        source='request',
        queryset=ServiceRequest.objects.all(),
        write_only=True,
    )
    artisan = ArtisanProfileSerializer(read_only=True)
    
    class Meta:
        model = Quote
        fields = ['id', 'request', 'request_id', 'artisan', 'amount', 'estimated_days', 'message', 'status', 'created_at', 'updated_at']
        read_only_fields = ['id', 'artisan', 'created_at', 'updated_at']
