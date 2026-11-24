from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models
import re


class UserManager(BaseUserManager):
    use_in_migrations = True

    def _create_user(self, email_or_phone, password, **extra_fields):
        if not email_or_phone:
            raise ValueError("Vous devez fournir un email ou un numéro de téléphone")
        
        # Determine if it's an email or phone number
        is_email = '@' in email_or_phone
        
        if is_email:
            email = self.normalize_email(email_or_phone)
            phone = extra_fields.pop('phone', None)
        else:
            phone = email_or_phone
            email = extra_fields.pop('email', None)

        if not email and not phone:
            raise ValueError("Email ou téléphone est obligatoire")

        # Generate a username if not provided (for compatibility with AbstractUser)
        if 'username' not in extra_fields or not extra_fields['username']:
            username = email_or_phone.replace('@', '_').replace('.', '_')
            # Ensure username uniqueness
            original_username = username
            counter = 1
            while self.model.objects.filter(username=username).exists():
                username = f"{original_username}_{counter}"
                counter += 1
            extra_fields['username'] = username

        user = self.model(
            email=email,
            phone=phone,
            **extra_fields
        )
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_user(self, email_or_phone, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", False)
        extra_fields.setdefault("is_superuser", False)
        return self._create_user(email_or_phone, password, **extra_fields)

    def create_superuser(self, email_or_phone, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        if extra_fields.get("is_staff") is not True:
            raise ValueError("Superuser must have is_staff=True.")
        if extra_fields.get("is_superuser") is not True:
            raise ValueError("Superuser must have is_superuser=True.")
        return self._create_user(email_or_phone, password, **extra_fields)


class User(AbstractUser):
    ROLE_CHOICES = [
        ('admin', 'Administrateur'),
        ('artisan', 'Artisan'),
        ('client', 'Client'),
    ]

    full_name = models.CharField(max_length=255)
    phone = models.CharField(max_length=20, blank=True, null=True, unique=True)
    email = models.EmailField(blank=True, null=True, unique=True)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='client')
    profile_picture = models.ImageField(upload_to='profile_pics/', blank=True, null=True)
    is_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    objects = UserManager()

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = []

    class Meta:
        db_table = 'users'

    def __str__(self):
        return f"{self.full_name} ({self.role})"
