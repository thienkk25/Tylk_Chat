import 'package:app_chat/services/others_provider.dart';
import 'package:app_chat/services/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserController {
  final userService = UserService();
  Future<Map> loginUser(String email, String password) async {
    return await userService.loginUser(email, password);
  }

  Future<Map> registerUser(String email, String password) async {
    return await userService.registerUser(email, password);
  }

  Future<List> getFriends() async {
    final data = await userService.getFriends();
    return data['data'];
  }

  Future<List?> addFriends(List<String> receiverIds) async {
    final data = await userService.addFriends(receiverIds);
    return data['data'];
  }

  Future<List> getSearchClients(String searchQuery) async {
    final data = await userService.getSearchClients(searchQuery);
    return data['data'];
  }

  Future<Map> getNotifications(WidgetRef ref) async {
    final data = await userService.getNotifications();
    if (data['data'].isNotEmpty && data['data']['dataFriendRequests'] != null) {
      int dataFriendRequests = data['data']['dataFriendRequests'].length;
      ref.read(notificationState.notifier).state = dataFriendRequests;
      return data['data'];
    } else {
      ref.read(notificationState.notifier).state = 0;
      return {
        "dataFriendRequests": [],
        "dataNotifications": [],
      };
    }
  }

  Future<Map> updateNotifications(String senderId, String status) async {
    final data = await userService.updateNotifications(senderId, status);
    return data;
  }
}
