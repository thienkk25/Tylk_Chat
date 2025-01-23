import 'package:app_chat/services/chat_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<Map> messages(String senderId, String content, String messageType,
      List attachments, String status) async {
    return await chatService.messages(
        senderId, content, messageType, attachments, status);
  }

  Future<Map> sendAddMessage(String email, String content, String messageType,
      List attachments, String status) async {
    return await chatService.sendAddMessage(
        email, content, messageType, attachments, status);
  }
}
