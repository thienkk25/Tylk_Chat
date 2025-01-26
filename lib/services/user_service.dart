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

  Future<Map> getFriends() async {
    final prefs = await SharedPreferences.getInstance();
    final uri = Uri.parse("http://localhost:3000/v1/api/user/friends");
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

  Future<Map> addFriends(List<String> receiverIds) async {
    final prefs = await SharedPreferences.getInstance();
    final uri = Uri.parse("http://localhost:3000/v1/api/user/friends");
    final response = await http.post(
      uri,
      body: jsonEncode({"receiver_ids": receiverIds}),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${prefs.getString('token')!}"
      },
    );
    final data = jsonDecode(response.body);

    return data;
  }

  Future<Map> getSearchClients(String searchQuery) async {
    final prefs = await SharedPreferences.getInstance();
    final uri =
        Uri.parse("http://localhost:3000/v1/api/user/$searchQuery/clients");
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

  Future<Map> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final uri = Uri.parse("http://localhost:3000/v1/api/user/notifications");
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

  Future<Map> updateNotifications(String senderId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final uri = Uri.parse("http://localhost:3000/v1/api/user/notifications");
    final response = await http.put(
      uri,
      body: jsonEncode({"sender_id": senderId, "status": status}),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${prefs.getString('token')!}"
      },
    );
    final data = jsonDecode(response.body);
    return data;
  }
}
