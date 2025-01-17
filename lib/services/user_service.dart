import 'dart:convert';

import 'package:http/http.dart' as http;

class UserService {
  final headers = {"Content-Type": "application/json"};
  Future<Map> loginUser(String email, String password) async {
    final uri = Uri.parse("http://localhost:3000/v1/api/login");
    final response = await http.post(
      uri,
      body: jsonEncode({"email": email, "password": password}),
      headers: headers,
    );
    final data = jsonDecode(response.body);

    return data;
  }

  Future<Map> registerUser(String email, String password) async {
    final uri = Uri.parse("http://localhost:3000/v1/api/register");
    final response = await http.post(
      uri,
      body: jsonEncode({"email": email, "password": password}),
      headers: headers,
    );
    final data = jsonDecode(response.body);

    return data;
  }

  Future<Map> sendChat(String idTo, String content) async {
    final uri = Uri.parse("http://localhost:3000/v1/api/chat");
    final response = await http.post(
      uri,
      body: jsonEncode({"id_to": idTo, "password": content}),
      headers: headers,
    );
    final data = jsonDecode(response.body);

    return data;
  }
}
