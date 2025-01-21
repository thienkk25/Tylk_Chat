import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  Future<List> getChats() async {
    final prefs = await SharedPreferences.getInstance();
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${prefs.getString('token')!}"
    };
    final uri = Uri.parse("http://localhost:3000/v1/api/chat");
    final response = await http.get(
      uri,
      headers: headers,
    );
    final data = jsonDecode(response.body);

    return data;
  }

  Future<Map> chats(List participants, String content, String senderId) async {
    final prefs = await SharedPreferences.getInstance();
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${prefs.getString('token')!}"
    };
    final uri = Uri.parse("http://localhost:3000/v1/api/chat");
    final response = await http.post(
      uri,
      body: jsonEncode({
        "participants": participants,
        "content": content,
        "sender_id": senderId
      }),
      headers: headers,
    );
    final data = jsonDecode(response.body);

    return data;
  }

  Future<List> getMessages(
      String chatId, String renderId, int limit, int page) async {
    final prefs = await SharedPreferences.getInstance();
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${prefs.getString('token')!}"
    };

    final uri = Uri.parse(
        "http://localhost:3000/v1/api/chat/messages?chat_id=$chatId&render_id=$renderId&limit=$limit&page=$page");
    final response = await http.get(
      uri,
      headers: headers,
    );
    final data = jsonDecode(response.body);

    return data;
  }

  Future<Map> messages(String chatId, String senderId, String content,
      String messageType, List attachments, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${prefs.getString('token')!}"
    };
    final uri = Uri.parse("http://localhost:3000/v1/api/chat/$chatId/messages");
    final response = await http.post(
      uri,
      body: jsonEncode({
        "chat_id": chatId,
        "sender_id": senderId,
        "content": content,
        "message_type": messageType,
        "attachments": attachments,
        "status": status
      }),
      headers: headers,
    );
    final data = jsonDecode(response.body);

    return data;
  }
}
