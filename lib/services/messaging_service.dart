import '../config/api_config.dart';
import '../models/conversation.dart';
import 'api_service.dart';

class MessagingService {
  final ApiService _api;

  MessagingService({ApiService? api}) : _api = api ?? ApiService();

  Future<List<Conversation>> getConversations() async {
    final data = await _api.get(ApiConfig.conversationsUrl);
    return _api.parseList(data, Conversation.fromJson);
  }

  Future<List<ChatMessage>> getMessages(int conversationId) async {
    final data = await _api.get(
      ApiConfig.conversationMessagesUrl(conversationId),
    );
    return _api.parseList(data, ChatMessage.fromJson);
  }

  Future<ChatMessage> sendMessage(int conversationId, String text) async {
    final data =
        await _api.post(
              ApiConfig.conversationSendUrl(conversationId),
              body: {'text': text},
            )
            as Map<String, dynamic>;
    return ChatMessage.fromJson(data);
  }

  Future<Conversation> createConversation(int participantId) async {
    final data =
        await _api.post(
              ApiConfig.conversationsUrl,
              body: {'participant_id': participantId},
            )
            as Map<String, dynamic>;
    return Conversation.fromJson(data);
  }
}
