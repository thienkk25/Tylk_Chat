import 'dart:async';
import 'dart:math';

import 'package:app_chat/controllers/chat_controller.dart';
import 'package:app_chat/controllers/user_controller.dart';
import 'package:app_chat/screens/chat_section.dart';
import 'package:app_chat/screens/home_chat.dart';
import 'package:app_chat/screens/login.dart';
import 'package:app_chat/screens/my_profile.dart';
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
  String profilePicture = "";
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
      profilePicture = prefs.getString("profilePicture")!;
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
                          CircleAvatar(
                            backgroundImage: NetworkImage(profilePicture),
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
                      onTap: () {
                        Navigator.push(
                            context,
                            DialogRoute(
                              context: context,
                              builder: (context) => const MyProfile(),
                            ));
                      },
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
                                    dataUserChat: searchList[index])),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: searchList[index]['partner']
                                            ['profile_picture'] !=
                                        ""
                                    ? NetworkImage(searchList[index]['partner']
                                        ['profile_picture'])
                                    : const NetworkImage(
                                        "https://res.cloudinary.com/dksr7si4o/image/upload/v1737961456/flutter/avatar/6_cnm2fb.jpg"),
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
