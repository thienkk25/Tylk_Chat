import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  String myselftEmail = "";
  String userName = "";
  String profilePicture = "";
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        load();
      },
    );
    super.initState();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      myselftEmail = prefs.getString("emailUser")!;
      userName = prefs.getString("userName")!;
      profilePicture = prefs.getString("profilePicture")!;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Text("My Profile"),
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xffCBE7E3), Color(0xff05999E)],
        )),
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: profilePicture != ""
                            ? NetworkImage(profilePicture)
                            : const NetworkImage(
                                "https://res.cloudinary.com/dksr7si4o/image/upload/v1737961456/flutter/avatar/6_cnm2fb.jpg"),
                        radius: 30,
                      ),
                      InkWell(
                          onTap: () {},
                          child: Icon(
                            Icons.photo_camera,
                            color: Colors.grey[400],
                          ))
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(userName), Text(myselftEmail)],
                  )
                ],
              ),
              const SizedBox(height: 10),
              Divider(
                height: 1,
                color: Colors.grey[400],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Name"),
                  SizedBox(
                    width: 150,
                    child: TextField(
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      cursorColor: Colors.lightGreen,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(
                              borderSide: BorderSide.none),
                          hintText: userName,
                          hintStyle: TextStyle(color: Colors.grey[400])),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(
                height: 1,
                color: Colors.grey[400],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Email account"),
                  SizedBox(
                    width: 150,
                    child: TextField(
                      enabled: false,
                      controller: TextEditingController(text: myselftEmail),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      cursorColor: Colors.lightGreen,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(
                height: 1,
                color: Colors.grey[400],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Mobile number"),
                  SizedBox(
                    width: 150,
                    child: TextField(
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      cursorColor: Colors.lightGreen,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(
                              borderSide: BorderSide.none),
                          hintText: "Add number",
                          hintStyle: TextStyle(color: Colors.grey[400])),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(
                height: 1,
                color: Colors.grey[400],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Location"),
                  SizedBox(
                    width: 150,
                    child: TextField(
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      cursorColor: Colors.lightGreen,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(
                              borderSide: BorderSide.none),
                          hintText: "VN",
                          hintStyle: TextStyle(color: Colors.grey[400])),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {},
                child: Container(
                  height: 35,
                  width: 100,
                  decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius:
                          BorderRadiusDirectional.all(Radius.circular(5))),
                  child: const Center(
                    child: Text(
                      "Save change",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
        )),
      ),
    );
  }
}
