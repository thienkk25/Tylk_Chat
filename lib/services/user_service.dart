import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final headers = {"Content-Type": "application/json"};

class UserService {
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

  Future<Map> getFriends(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final uri = Uri.parse("http://localhost:3000/v1/api/user/${id}/friends");
    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${prefs.getString('token')!}"
      },
    );
    final data = jsonDecode(response.body);

    return data;
  }
}
