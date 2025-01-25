import 'package:app_chat/services/user_service.dart';

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
}
