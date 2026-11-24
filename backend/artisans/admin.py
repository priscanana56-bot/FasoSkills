from django.contrib import admin
from .models import ArtisanProfile


@admin.register(ArtisanProfile)
class ArtisanProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'category', 'city', 'experience_years', 'rating', 'completed_jobs', 'created_at')
    list_filter = ('category', 'city', 'created_at')
    search_fields = ('user__first_name', 'user__last_name', 'user__username')
