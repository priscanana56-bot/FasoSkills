from django.db import models
from accounts.models import User
from categories.models import Category


class ArtisanProfile(models.Model):
    STATUS_CHOICES = [
        ('incomplete', 'Profil incomplet'),
        ('complete', 'Profil complet'),
    ]

    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='artisan_profile')
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, related_name='artisans', null=True, blank=True)
    specialty = models.CharField(max_length=150, blank=True, null=True)
    city = models.CharField(max_length=100, blank=True, default='')
    experience_years = models.PositiveIntegerField(default=0, blank=True, null=True)
    bio = models.TextField(blank=True, null=True)
    availability = models.TextField(blank=True, null=True)
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=0.00)
    completed_jobs = models.PositiveIntegerField(default=0)
    profile_status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='incomplete')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'artisan_profiles'
    
    def __str__(self):
        return f"{self.user.first_name} {self.user.last_name} - {self.category.name}"
