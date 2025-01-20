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
  List<Widget> pages = [
    const HomeChat(),
    const PeopleOnline(),
  ];
  int selectedIndex = 0;
  late SharedPreferences prefs;
  String myselftEmail = "";
  @override
  void initState() {
    load();
    super.initState();
  }

  Future<void> load() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      myselftEmail = prefs.getString("emailUser")!;
    });
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
              return Dialog(
                child: SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.keyboard_arrow_left),
                        title: Center(child: Text("Add message")),
                      ),
                      TextField(),
                      TextField(),
                      TextField(),
                    ],
                  ),
                ),
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
}
