import 'dart:async';

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
  Timer? timer;
  TextEditingController whoSendController = TextEditingController();
  TextEditingController contentSendController = TextEditingController();
  List dataSearch = [];
  List temporaryData = [];
  String? myselftEmail;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      load();
    });
    super.initState();
  }

  Future<void> load() async {
    dataFriends = await userController.getFriends();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      myselftEmail = prefs.getString("emailUser")!;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                width: 5,
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
          ),
        ],
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
              child: SizedBox(
                height: double.infinity,
                width: double.infinity,
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

  void addFriendsAll() {}
}
