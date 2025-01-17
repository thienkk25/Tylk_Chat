import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatSection extends StatefulWidget {
  const ChatSection({super.key});

  @override
  State<ChatSection> createState() => _ChatSectionState();
}

class _ChatSectionState extends State<ChatSection> {
  TextEditingController textEditingController = TextEditingController();
  ScrollController scrollController = ScrollController();
  List dataMessage = [];
  late WebSocketChannel channel;
  String myselftID = "";
  @override
  void initState() {
    super.initState();
    connectWS();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    channel.sink.close();
    super.dispose();
  }

  Future<void> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      myselftID = prefs.getString("idUser")!;
    });
  }

  Future<void> connectWS() async {
    channel = WebSocketChannel.connect(Uri.parse(dotenv.env['WEBSOCKET_URL']!));
    try {
      await channel.ready;
      channel.stream.listen(
        (data) {
          setState(() {
            dataMessage.add(jsonDecode(data));
          });
          scrollToBottom();
        },
      );
    } catch (e) {
      debugPrint("Error");
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
      body: ListView.builder(
        controller: scrollController,
        itemCount: dataMessage.length,
        itemBuilder: (context, index) => dataMessage[index]['id_from'] !=
                myselftID
            ? Align(
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
                      Text(
                        dataMessage[index]['content'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        dataMessage[index]['timestamp'],
                        style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              )
            : Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: Colors.lightBlueAccent),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blueAccent),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        dataMessage[index]['content'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        dataMessage[index]['timestamp'],
                        style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ),
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
                    'id_from': myselftID,
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
                    'id_from': myselftID,
                    'id_to': 'b',
                  }));
                },
                icon: const Icon(Icons.send)),
          )
        ],
      ),
    );
  }
}
