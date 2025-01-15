import 'package:flutter/material.dart';

class ChatSection extends StatelessWidget {
  const ChatSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              radius: 20,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Text(
                  "Name",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Icon(Icons.call),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Icon(Icons.videocam),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Icon(Icons.info),
          ),
        ],
      ),
      body: Column(
        children: [
          Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.lightBlueAccent),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blueAccent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Message 1",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      "10.2 A.M",
                      style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                    ),
                  ],
                ),
              )),
          Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Message 2",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      "10.2 A.M",
                      style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                    ),
                  ],
                ),
              )),
        ],
      ),
      bottomNavigationBar: Row(
        children: [
          const Expanded(
              child: TextField(
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)))),
          )),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: IconButton(onPressed: () {}, icon: const Icon(Icons.send)),
          )
        ],
      ),
    );
  }
}
