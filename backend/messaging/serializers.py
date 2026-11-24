from rest_framework import serializers

from accounts.serializers import UserSerializer
from .models import Conversation, Message


class MessageSerializer(serializers.ModelSerializer):
    sender = UserSerializer(read_only=True)
    is_me = serializers.SerializerMethodField()

    class Meta:
        model = Message
        fields = ['id', 'sender', 'text', 'is_read', 'sent_at', 'is_me']
        read_only_fields = ['id', 'sender', 'is_read', 'sent_at', 'is_me']

    def get_is_me(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.sender_id == request.user.id
        return False


class ConversationListSerializer(serializers.ModelSerializer):
    other_user = serializers.SerializerMethodField()
    last_message = serializers.SerializerMethodField()
    last_message_at = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()

    class Meta:
        model = Conversation
        fields = [
            'id',
            'other_user',
            'last_message',
            'last_message_at',
            'unread_count',
            'updated_at',
        ]

    def get_other_user(self, obj):
        request = self.context.get('request')
        other = obj.participants.exclude(pk=request.user.pk).first()
        if other:
            return UserSerializer(other).data
        return None

    def get_last_message(self, obj):
        last = obj.messages.order_by('-sent_at').first()
        return last.text if last else ''

    def get_last_message_at(self, obj):
        last = obj.messages.order_by('-sent_at').first()
        return last.sent_at if last else obj.updated_at

    def get_unread_count(self, obj):
        request = self.context.get('request')
        return obj.messages.filter(is_read=False).exclude(sender=request.user).count()


class ConversationCreateSerializer(serializers.Serializer):
    participant_id = serializers.IntegerField()

    def validate_participant_id(self, value):
        from accounts.models import User
        if not User.objects.filter(pk=value).exists():
            raise serializers.ValidationError('Utilisateur introuvable.')
        return value


class MessageCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Message
        fields = ['text']
