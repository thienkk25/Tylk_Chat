import 'dart:convert';

import 'package:http/http.dart' as http;

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
}
