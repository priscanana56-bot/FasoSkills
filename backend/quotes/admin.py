from django.contrib import admin
from .models import Quote


@admin.register(Quote)
class QuoteAdmin(admin.ModelAdmin):
    list_display = ('request', 'artisan', 'amount', 'status', 'created_at')
    list_filter = ('status', 'created_at')
    search_fields = ('request__title', 'artisan__user__first_name', 'artisan__user__last_name')
