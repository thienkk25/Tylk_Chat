import 'package:app_chat/services/user_service.dart';

class UserController {
  final userService = UserService();
  Future<Map> loginUser(String email, String password) async {
    return await userService.loginUser(email, password);
  }

  Future<Map> registerUser(String email, String password) async {
    return await userService.registerUser(email, password);
  }
}
