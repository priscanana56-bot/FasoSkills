from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView, SpectacularRedocView

from accounts.views import RegisterView, UserViewSet, CustomTokenObtainPairView
from artisans.views import ArtisanProfileViewSet
from categories.views import CategoryViewSet
from service_requests.views import ServiceRequestViewSet
from quotes.views import QuoteViewSet
from reviews.views import ReviewViewSet
from messaging.views import ConversationViewSet


router = DefaultRouter()
router.register(r'users', UserViewSet)
router.register(r'artisans', ArtisanProfileViewSet)
router.register(r'categories', CategoryViewSet)
router.register(r'requests', ServiceRequestViewSet)
router.register(r'quotes', QuoteViewSet)
router.register(r'reviews', ReviewViewSet)
router.register(r'conversations', ConversationViewSet, basename='conversation')

urlpatterns = [
    path('admin/', admin.site.urls),
    
    path('api/', include(router.urls)),
    path('api/login/', CustomTokenObtainPairView.as_view(), name='login'),
    path('api/register/', RegisterView.as_view(), name='register'),
    path('api/auth/login/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
