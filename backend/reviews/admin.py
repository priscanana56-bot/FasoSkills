from django.contrib import admin
from .models import Review


@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = ('client', 'artisan', 'rating', 'created_at')
    list_filter = ('rating', 'created_at')
    search_fields = ('client__first_name', 'client__last_name', 'artisan__user__first_name', 'artisan__user__last_name')
