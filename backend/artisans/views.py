from rest_framework import viewsets, permissions, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import ArtisanProfile
from .serializers import ArtisanProfileSerializer


class ArtisanProfileViewSet(viewsets.ModelViewSet):
    queryset = ArtisanProfile.objects.filter(profile_status='complete')
    serializer_class = ArtisanProfileSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['category', 'city']
    search_fields = [
        'user__first_name',
        'user__last_name',
        'bio',
        'specialty',
        'city',
        'category__name',
    ]
    ordering_fields = ['rating', 'completed_jobs']
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    def get_queryset(self):
        queryset = ArtisanProfile.objects.all()
        if self.action in ['list', 'retrieve']:
            return queryset.filter(profile_status='complete')
        return queryset

    @action(detail=False, methods=['get', 'patch'], permission_classes=[permissions.IsAuthenticated])
    def me(self, request):
        profile, _ = ArtisanProfile.objects.get_or_create(
            user=request.user,
            defaults={'profile_status': 'incomplete'},
        )
        if request.method == 'GET':
            return Response(self.get_serializer(profile).data)
        serializer = self.get_serializer(profile, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)
