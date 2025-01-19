import 'package:app_chat/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PeopleOnline extends StatefulWidget {
  const PeopleOnline({super.key});

  @override
  State<PeopleOnline> createState() => _PeopleOnlineState();
}

class _PeopleOnlineState extends State<PeopleOnline> {
  final userController = UserController();

  List dataFriends = [];
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      load();
    });
    super.initState();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    dataFriends = await userController.getFriends(prefs.getString('idUser')!);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: dataFriends.length,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        backgroundColor:
                            dataFriends[index]['status'] == 'online'
                                ? Colors.green
                                : Colors.grey,
                        radius: 10,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      dataFriends[index]['username'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
