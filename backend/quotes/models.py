from django.db import models
from service_requests.models import ServiceRequest
from artisans.models import ArtisanProfile


class Quote(models.Model):
    STATUS_CHOICES = [
        ('pending', 'En attente'),
        ('accepted', 'Accepté'),
        ('rejected', 'Rejeté'),
    ]
    
    request = models.ForeignKey(ServiceRequest, on_delete=models.CASCADE, related_name='quotes')
    artisan = models.ForeignKey(ArtisanProfile, on_delete=models.CASCADE, related_name='quotes')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    estimated_days = models.PositiveIntegerField()
    message = models.TextField(blank=True, null=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'quotes'
    
    def __str__(self):
        return f"Devis pour {self.request.title} - {self.artisan.user.first_name}"
