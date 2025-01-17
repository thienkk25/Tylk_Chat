import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatSection extends StatefulWidget {
  const ChatSection({super.key});

  @override
  State<ChatSection> createState() => _ChatSectionState();
}

class _ChatSectionState extends State<ChatSection> {
  TextEditingController textEditingController = TextEditingController();
  late WebSocketChannel channel;
  @override
  void initState() {
    super.initState();
    connectWS();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  Future<void> connectWS() async {
    channel = WebSocketChannel.connect(Uri.parse(dotenv.env['WEBSOCKET_URL']!));
    try {
      await channel.ready;
    } catch (e) {
      debugPrint("Error");
    }
  }

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
          StreamBuilder(
            stream: channel.stream,
            builder: (context, snapshot) {
              return Text(
                snapshot.hasData
                    ? 'Tin nhắn từ server: ${snapshot.data}'
                    : 'Đang chờ tin nhắn...',
              );
            },
          )
        ],
      ),
      bottomNavigationBar: Row(
        children: [
          Expanded(
              child: TextField(
            controller: textEditingController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)))),
          )),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: IconButton(
                onPressed: () {
                  // channel.sink.add(textEditingController.text);
                  channel.sink.add(jsonEncode({
                    'type': 'message',
                    'id_from': 'a',
                    'id_to': 'b',
                    'content': textEditingController.text,
                  }));
                  textEditingController.clear();
                },
                icon: const Icon(Icons.send)),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: IconButton(
                onPressed: () {
                  channel.sink.add(jsonEncode({
                    'type': 'join',
                    'id_from': 'a',
                    'id_to': 'b',
                  }));
                },
                icon: const Icon(Icons.send)),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: IconButton(
                onPressed: () {
                  channel.sink.close();
                },
                icon: const Icon(Icons.send)),
          )
        ],
      ),
    );
  }
}
