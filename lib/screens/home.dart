import 'dart:async';

import 'package:app_chat/controllers/chat_controller.dart';
import 'package:app_chat/controllers/user_controller.dart';
import 'package:app_chat/screens/home_chat.dart';
import 'package:app_chat/screens/login.dart';
import 'package:app_chat/screens/people_online.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  UserController userController = UserController();
  ChatController chatController = ChatController();
  Timer? timer;
  List<Widget> pages = [
    const HomeChat(),
    const PeopleOnline(),
  ];
  int selectedIndex = 0;
  late SharedPreferences prefs;
  String myselftEmail = "";
  TextEditingController toSendController = TextEditingController();
  TextEditingController contentSendController = TextEditingController();
  List dataSearch = [];
  // Regular expression for email validation
  final RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      load();
    });
    super.initState();
  }

  Future<void> load() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      myselftEmail = prefs.getString("emailUser")!;
    });
  }

  @override
  void dispose() {
    toSendController.dispose();
    contentSendController.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        actions: [
          Text(myselftEmail),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: InkWell(
                onTap: () async {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const Login()));

                  prefs.remove('token');
                  prefs.remove('idUser');
                  prefs.remove('emailUser');
                },
                child: const Icon(Icons.exit_to_app)),
          ),
        ],
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (value) => setState(() {
                selectedIndex = value;
              }),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.chat), label: "Chat"),
            NavigationDestination(icon: Icon(Icons.people), label: "Friends"),
          ]),
      floatingActionButton: InkWell(
        onTap: () {
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
                                onTap: () => Navigator.pop(context),
                                child: const Icon(Icons.close)),
                            title: const Center(child: Text("Add message")),
                          ),
                          SizedBox(
                            height: 40,
                            width: MediaQuery.of(context).size.width / 2,
                            child: SearchBar(
                              controller: toSendController,
                              leading: const Text("To:"),
                              trailing: [
                                IconButton(
                                  icon: const Icon(Icons.playlist_remove),
                                  onPressed: () {
                                    toSendController.clear();
                                    dataSearch = [];
                                    setDialogState(
                                      () {},
                                    );
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
                                  Durations.medium3,
                                  () async {
                                    dataSearch = await userController
                                        .getSearchClients(value);
                                    setDialogState(
                                      () {},
                                    );
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
                                      toSendController.text =
                                          dataSearch[index]['email'];
                                      dataSearch = [];
                                      setDialogState(() => {});
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                            height: MediaQuery.of(context).size.height / 3,
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                              borderRadius:
                                  BorderRadius.circular(8), // Bo tròn các góc
                            ),
                            child: TextField(
                              controller: contentSendController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              maxLines: null,
                              expands: true,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: InkWell(
                              onTap: () {
                                if (emailRegExp
                                        .hasMatch(toSendController.text) &&
                                    contentSendController.text.isNotEmpty) {
                                  sendNewMessage(
                                      toSendController.text,
                                      contentSendController.text,
                                      "message",
                                      [],
                                      "");
                                }
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
                                    "Send",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
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
        },
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.lightBlueAccent,
            border: Border.all(width: 1, color: Colors.lightBlueAccent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<void> sendNewMessage(String email, String content, String messageType,
      List attachments, String status) async {
    final result = await chatController.sendAddMessage(
        email, content, messageType, attachments, status);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result['message'])));
    toSendController.clear();
    contentSendController.clear();
  }
}
