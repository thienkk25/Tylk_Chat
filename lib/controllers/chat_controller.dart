import 'package:app_chat/services/chat_service.dart';

class ChatController {
  final chatService = ChatService();

  Future<List> getChats() async {
    List data = await chatService.getChats();
    return data;
  }

  Future<Map?> chats(
      List participants, String content, String receiverId) async {
    return await chatService.chats(participants, content, receiverId);
  }

  Future<List> getMessages(String receiverId, int limit, int page) async {
    List data = await chatService.getMessages(receiverId, limit, page);

    return data;
  }

  Future<Map?> messages(String receiverId, String content, String messageType,
      List attachments, String status) async {
    return await chatService.messages(
        receiverId, content, messageType, attachments, status);
  }

  Future<Map> sendAddMessage(String email, String content, String messageType,
      List attachments, String status) async {
    return await chatService.sendAddMessage(
        email, content, messageType, attachments, status);
  }
}
