from django.db import models
from accounts.models import User
from artisans.models import ArtisanProfile


class Review(models.Model):
    client = models.ForeignKey(User, on_delete=models.CASCADE, related_name='reviews')
    artisan = models.ForeignKey(ArtisanProfile, on_delete=models.CASCADE, related_name='reviews')
    rating = models.PositiveIntegerField(choices=[(i, i) for i in range(1, 6)])
    comment = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'reviews'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.client.first_name} - {self.artisan.user.first_name} ({self.rating}/5)"
