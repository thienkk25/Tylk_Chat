import 'dart:async';

import 'package:app_chat/controllers/user_controller.dart';
import 'package:app_chat/screens/notifications.dart';
import 'package:app_chat/services/others_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PeopleOnline extends ConsumerStatefulWidget {
  const PeopleOnline({super.key});

  @override
  ConsumerState<PeopleOnline> createState() => _PeopleOnlineState();
}

class _PeopleOnlineState extends ConsumerState<PeopleOnline> {
  final userController = UserController();

  List dataFriends = [];
  Timer? timer;
  TextEditingController whoSendController = TextEditingController();
  TextEditingController contentSendController = TextEditingController();
  List dataSearch = [];
  List temporaryData = [];
  String? myselftEmail;
  Map dataNotifications = {};
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      load();
    });
    super.initState();
  }

  Future<void> load() async {
    dataFriends = await userController.getFriends();
    dataNotifications = await userController.getNotifications(ref);
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      myselftEmail = prefs.getString("emailUser")!;
    });
  }

  @override
  void dispose() {
    whoSendController.dispose();
    contentSendController.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff18A5A7), Color(0xffBFFFC7)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => Notifications(
                                  dataNotifications: dataNotifications)));
                    },
                    child: Badge(
                      label: Text(ref.watch(notificationState).toString()),
                      child: const Icon(Icons.notifications),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                      onPressed: () {
                        addFriendDialog(context);
                      },
                      child: const Text("Add Friend")),
                )
              ],
            ),
            RefreshIndicator(
              onRefresh: () => load(),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: dataFriends.length,
                itemBuilder: (context, index) => Container(
                  decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadiusDirectional.all(Radius.circular(10)),
                    gradient: LinearGradient(
                      colors: [Color(0xff353A5F), Color(0xff9EBAF3)],
                    ),
                  ),
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
            ),
          ],
        ),
      ),
    );
  }

  void addFriendDialog(context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, StateSetter setDialogState) {
            return Dialog(
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.lightGreen),
                child: Column(
                  children: [
                    ListTile(
                      trailing: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            dataSearch = [];
                            whoSendController.clear();
                            setDialogState(() {});
                          },
                          child: const Icon(Icons.close)),
                      title: const Center(child: Text("Add Friend")),
                    ),
                    SizedBox(
                      height: 40,
                      width: MediaQuery.of(context).size.width / 2,
                      child: SearchBar(
                        controller: whoSendController,
                        leading: const Text("Who: "),
                        trailing: [
                          IconButton(
                            icon: const Icon(Icons.playlist_remove),
                            onPressed: () {
                              whoSendController.clear();
                              dataSearch = [];
                              setDialogState(() {});
                            },
                          ),
                        ],
                        hintText: "Find id, name or email",
                        elevation: const WidgetStatePropertyAll(0),
                        onChanged: (value) {
                          if (timer?.isActive ?? false) {
                            timer?.cancel();
                          }
                          timer = Timer(
                            const Duration(seconds: 1),
                            () async {
                              dataSearch =
                                  await userController.getSearchClients(value);
                              setDialogState(() {});
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: dataSearch.isEmpty
                          ? 0
                          : MediaQuery.of(context).size.height / 3,
                      width: MediaQuery.of(context).size.width / 2,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: dataSearch.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: InkWell(
                              onTap: () {
                                if (dataSearch[index]['email'] !=
                                        myselftEmail &&
                                    myselftEmail != null) {
                                  temporaryData.add(dataSearch[index]);
                                  temporaryData =
                                      temporaryData.toSet().toList();
                                  setDialogState(() => {});
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "Name: ${dataSearch[index]['username']}"),
                                    Text(
                                        "Email: ${dataSearch[index]['email']}"),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: MediaQuery.of(context).size.width / 1.5,
                      height: temporaryData.isEmpty
                          ? 0
                          : MediaQuery.of(context).size.height / 3,
                      padding: const EdgeInsets.all(10.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: temporaryData.length,
                        itemBuilder: (context, index) => Card(
                          child: ListTile(
                            leading: InkWell(
                                onTap: () async {
                                  if (temporaryData[index]['email'] !=
                                          myselftEmail &&
                                      myselftEmail != null) {
                                    await userController.addFriends(
                                        [temporaryData[index]["_id"]]);
                                    temporaryData.removeAt(index);
                                    setDialogState(() {});
                                  } else {
                                    temporaryData.removeAt(index);
                                    setDialogState(() {});
                                  }
                                },
                                child: const Icon(Icons.add)),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "Name: ${temporaryData[index]['username']}"),
                                Text("Email: ${temporaryData[index]['email']}"),
                              ],
                            ),
                            trailing: InkWell(
                                onTap: () {
                                  temporaryData.removeAt(index);
                                  setDialogState(() {});
                                },
                                child: const Icon(Icons.remove)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () {
                              whoSendController.clear();
                              dataSearch = [];
                              temporaryData = [];
                              setDialogState(() => {});
                            },
                            child: Container(
                              height: 30,
                              width: MediaQuery.of(context).size.width / 3,
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color: Colors.red),
                              child: const Center(
                                child: Text(
                                  "Reset All",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              addFriendsAll();
                            },
                            child: Container(
                              height: 30,
                              width: MediaQuery.of(context).size.width / 3,
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color: Colors.blue),
                              child: const Center(
                                child: Text(
                                  "Add All",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> addFriendsAll() async {
    await userController.addFriends([...temporaryData.map((e) => e['_id'])]);
    temporaryData = [];
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Success")));
  }
}
