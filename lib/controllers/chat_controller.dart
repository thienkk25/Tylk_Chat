import 'package:app_chat/services/chat_service.dart';

class ChatController {
  final chatService = ChatService();

  Future<List> getChats() async {
    List data = await chatService.getChats();
    return data;
  }

  Future<Map> chats(List participants, String content, String senderId) async {
    return await chatService.chats(participants, content, senderId);
  }

  Future<List> getMessages(
      String chatId, String renderId, int limit, int page) async {
    List data = await chatService.getMessages(chatId, renderId, limit, page);
    return data;
  }

  Future<Map> messages(String chatId, String senderId, String content,
      String messageType, List attachments, String status) async {
    return await chatService.messages(
        chatId, senderId, content, messageType, attachments, status);
  }
}
