import 'dart:async';
import 'dart:math';

import 'package:app_chat/controllers/chat_controller.dart';
import 'package:app_chat/controllers/user_controller.dart';
import 'package:app_chat/screens/chat_section.dart';
import 'package:app_chat/screens/home_chat.dart';
import 'package:app_chat/screens/login.dart';
import 'package:app_chat/screens/people_online.dart';
import 'package:app_chat/services/websocket_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  UserController userController = UserController();
  ChatController chatController = ChatController();
  Timer? timer;
  List<Widget> pages = [
    const HomeChat(),
    const PeopleOnline(),
  ];
  int selectedIndex = 0;
  late SharedPreferences prefs;
  String myselftID = "";
  String myselftEmail = "";
  String userName = "";
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
      myselftID = prefs.getString("idUser")!;
      myselftEmail = prefs.getString("emailUser")!;
      userName = prefs.getString("userName")!;
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
    final dataChats = ref.watch(dataChatsNotifierProvider);
    return Scaffold(
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff353A5F), Color(0xff9EBAF3)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black87, Colors.blueAccent],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundImage: NetworkImage(
                                "data:image/png;base64,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"),
                            radius: 30,
                          ),
                          const SizedBox(width: 20),
                          Text(
                            userName,
                            style: const TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: InkWell(
                      onTap: () {},
                      child: const ListTile(
                        title: Text("My Profile"),
                        leading: Icon(Icons.manage_accounts),
                        trailing: Icon(Icons.arrow_right),
                      ),
                    ),
                  ),
                  Card(
                    child: InkWell(
                      onTap: () {},
                      child: const ListTile(
                        title: Text("Settings"),
                        leading: Icon(Icons.settings),
                        trailing: Icon(Icons.arrow_right),
                      ),
                    ),
                  ),
                  Card(
                    child: InkWell(
                      onTap: () {},
                      child: const ListTile(
                        title: Text("Notification"),
                        leading: Icon(Icons.notifications),
                        trailing: Icon(Icons.arrow_right),
                      ),
                    ),
                  ),
                ],
              ),
              Card(
                child: InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text("Confirm logout?"),
                              actionsAlignment: MainAxisAlignment.spaceAround,
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Cancel")),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => const Login()));

                                      prefs.remove('token');
                                      prefs.remove('idUser');
                                      prefs.remove('emailUser');
                                      prefs.remove('userName');
                                      prefs.remove('profilePicture');
                                      ref
                                          .read(dataRealTimeNotifierProvider
                                              .notifier)
                                          .initState();
                                      ref
                                          .read(websocketStateNotifierProvider
                                              .notifier)
                                          .disconnection();
                                      ref
                                          .read(dataChatsNotifierProvider
                                              .notifier)
                                          .reset();
                                      ref
                                          .read(dataMessagesNotifierProvider
                                              .notifier)
                                          .reset();
                                    },
                                    child: const Text("Confirm"))
                              ],
                            ));
                  },
                  child: const ListTile(
                    title: Text("Logout"),
                    leading: Icon(Icons.exit_to_app),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Text("Chat"),
        actions: [
          SearchAnchor(
            viewHintText: "Search...",
            builder: (context, controller) {
              return Container(
                  margin: const EdgeInsets.only(right: 20),
                  child: InkWell(
                      onTap: () => controller.openView(),
                      child: const Icon(Icons.search)));
            },
            suggestionsBuilder: (context, controller) {
              final String data = controller.text.toLowerCase();

              List searchList = dataChats
                  .where(
                      (e) => e['partner']['name'].toLowerCase().contains(data))
                  .toList();
              return searchList.isNotEmpty
                  ? List.generate(
                      min(searchList.length, 10),
                      (index) => Card(
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => ChatSection(
                                    myselftID: myselftID,
                                    dataUserChat: dataChats[index])),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundImage: NetworkImage(
                                    "data:image/png;base64,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"),
                                radius: 30,
                              ),
                              title: Text(
                                searchList[index]['partner']['name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : [
                      const ListTile(
                        title: Text("No results found"),
                      )
                    ];
            },
          )
        ],
      ),
      body: IndexedStack(
        textDirection: TextDirection.rtl,
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
          indicatorColor: Colors.black,
          overlayColor: WidgetStateProperty.all(Colors.amber),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          backgroundColor: Colors.lightGreen,
          animationDuration: const Duration(milliseconds: 300),
          selectedIndex: selectedIndex,
          onDestinationSelected: (value) => setState(() {
                selectedIndex = value;
              }),
          destinations: const [
            NavigationDestination(
              icon: Icon(
                Icons.chat,
                color: Colors.white,
              ),
              label: "Chat",
            ),
            NavigationDestination(
              icon: Icon(
                Icons.people,
                color: Colors.white,
              ),
              label: "Friends",
            ),
          ]),
      floatingActionButton: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              Map temporaryData = {};
              bool enabledSearch = true;
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
                                  enabledSearch = false;
                                  dataSearch = [];
                                  toSendController.clear();
                                  setDialogState(() {});
                                },
                                child: const Icon(Icons.close)),
                            title: const Center(child: Text("Add message")),
                          ),
                          SizedBox(
                            height: 40,
                            width: MediaQuery.of(context).size.width / 2,
                            child: SearchBar(
                              enabled: enabledSearch,
                              controller: toSendController,
                              leading: const Text("To:"),
                              trailing: [
                                IconButton(
                                  icon: const Icon(Icons.playlist_remove),
                                  onPressed: () {
                                    toSendController.clear();
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
                                    dataSearch = await userController
                                        .getSearchClients(value);
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
                                      toSendController.text =
                                          dataSearch[index]['email'];
                                      temporaryData = dataSearch[index];
                                      dataSearch = [];
                                      enabledSearch = false;
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
                                hintText: "Message...",
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
                                        contentSendController.text.isNotEmpty ||
                                    enabledSearch != true) {
                                  sendNewMessage(
                                      temporaryData['email'],
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
            color: Colors.lightGreenAccent,
            border: Border.all(width: 1, color: Colors.lightGreen),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
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
    await ref.read(dataChatsNotifierProvider.notifier).refresh();
    toSendController.clear();
    contentSendController.clear();
  }
}
