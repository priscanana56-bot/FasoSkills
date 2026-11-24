from rest_framework import viewsets, permissions
from .models import Quote
from .serializers import QuoteSerializer


class QuoteViewSet(viewsets.ModelViewSet):
    queryset = Quote.objects.all()
    serializer_class = QuoteSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def perform_create(self, serializer):
        artisan_profile = self.request.user.artisan_profile
        serializer.save(artisan=artisan_profile)
    
    def get_queryset(self):
        user = self.request.user
        if user.role == 'client':
            return Quote.objects.filter(request__client=user)
        elif user.role == 'artisan':
            return Quote.objects.filter(artisan__user=user)
        return Quote.objects.all()
