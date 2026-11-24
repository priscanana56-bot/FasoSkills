from rest_framework import permissions, status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from accounts.models import User
from .models import Conversation, Message
from .serializers import (
    ConversationCreateSerializer,
    ConversationListSerializer,
    MessageCreateSerializer,
    MessageSerializer,
)


class ConversationViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticated]
    http_method_names = ['get', 'post', 'head', 'options']

    def get_queryset(self):
        return (
            Conversation.objects.filter(participants=self.request.user)
            .distinct()
            .prefetch_related('participants', 'messages')
        )

    def get_serializer_class(self):
        if self.action == 'create':
            return ConversationCreateSerializer
        return ConversationListSerializer

    def create(self, request, *args, **kwargs):
        serializer = ConversationCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        participant_id = serializer.validated_data['participant_id']
        participant = User.objects.get(pk=participant_id)

        if participant.pk == request.user.pk:
            return Response(
                {'detail': 'Impossible de créer une conversation avec vous-même.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        existing = (
            Conversation.objects.filter(participants=request.user)
            .filter(participants=participant)
            .distinct()
            .first()
        )
        if existing:
            output = ConversationListSerializer(existing, context={'request': request})
            return Response(output.data, status=status.HTTP_200_OK)

        conversation = Conversation.objects.create()
        conversation.participants.add(request.user, participant)
        output = ConversationListSerializer(conversation, context={'request': request})
        return Response(output.data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=['get'])
    def messages(self, request, pk=None):
        conversation = self.get_object()
        conversation.messages.filter(is_read=False).exclude(sender=request.user).update(is_read=True)
        queryset = conversation.messages.select_related('sender').order_by('sent_at')
        serializer = MessageSerializer(queryset, many=True, context={'request': request})
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def send(self, request, pk=None):
        conversation = self.get_object()
        serializer = MessageCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        message = Message.objects.create(
            conversation=conversation,
            sender=request.user,
            text=serializer.validated_data['text'],
        )
        conversation.save(update_fields=['updated_at'])
        output = MessageSerializer(message, context={'request': request})
        return Response(output.data, status=status.HTTP_201_CREATED)
