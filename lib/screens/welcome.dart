import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 4,
              width: double.infinity,
              child: const Center(
                child: Text(
                  "Welcome to Chat",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                    border: Border(top: BorderSide(width: 1)),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black, Colors.blue])),
                child: const Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "We are thrilled to have you join our community. Start a conversation, connect with new friends, share, and discover exciting things. We're always here to support you!",
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
            bottom: 0,
            child: Row(
              children: [
                InkWell(
                  onTap: () {},
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width / 2,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        // topRight: Radius.circular(30),
                      ),
                    ),
                    child: const Center(
                        child: Text(
                      "Login",
                      style: TextStyle(fontSize: 18),
                    )),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width / 2,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        // topRight: Radius.circular(30),
                      ),
                    ),
                    child: const Center(
                        child: Text(
                      "Register",
                      style: TextStyle(fontSize: 18),
                    )),
                  ),
                ),
              ],
            ))
      ]),
    );
  }
}
