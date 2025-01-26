import 'package:app_chat/config/format_time.dart';
import 'package:app_chat/controllers/user_controller.dart';
import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  final Map dataNotifications;
  const Notifications({super.key, required this.dataNotifications});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  UserController userController = UserController();
  List dataFriendRequests = [];
  List dataNotifications = [];
  @override
  void initState() {
    dataFriendRequests = widget.dataNotifications['dataFriendRequests'];
    dataNotifications = widget.dataNotifications['dataNotifications'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Notifications")),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: dataNotifications.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(dataNotifications[index]['content']),
                );
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: dataFriendRequests.length,
              itemBuilder: (context, index) {
                if (dataFriendRequests[index]['status'] == "pending") {
                  return ListTile(
                    leading: InkWell(
                        onTap: () {
                          confirmFriend(index, "accepted");
                        },
                        child: const Icon(Icons.check)),
                    title: InkWell(
                        onTap: () {
                          refuseFriend(index, "rejected");
                        },
                        child: const Icon(Icons.close)),
                    trailing: Text(FormatTime().coverTimeFromIso(
                        dataFriendRequests[index]['created_at'])),
                  );
                } else {
                  return ListTile(
                    title: Text(dataFriendRequests[index]['status']),
                    trailing: Text(FormatTime().coverTimeFromIso(
                        dataFriendRequests[index]['created_at'])),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> confirmFriend(int index, String status) async {
    dataFriendRequests[index]['status'] = status;
    final result = await userController.updateNotifications(
        dataFriendRequests[index]['sender_id'], status);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result['message'])));
    setState(() {});
  }

  Future<void> refuseFriend(int index, String status) async {
    dataFriendRequests[index]['status'] = status;
    final result = await userController.updateNotifications(
        dataFriendRequests[index]['sender_id'], status);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result['message'])));
    setState(() {});
  }
}
