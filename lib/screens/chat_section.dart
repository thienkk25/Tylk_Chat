import 'dart:convert';

import 'package:app_chat/config/format_time.dart';
import 'package:app_chat/controllers/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatSection extends StatefulWidget {
  final String myselftID;
  final dynamic dataUserChat;
  const ChatSection(
      {super.key, required this.dataUserChat, required this.myselftID});

  @override
  State<ChatSection> createState() => _ChatSectionState();
}

class _ChatSectionState extends State<ChatSection> {
  ChatController chatController = ChatController();
  TextEditingController textEditingController = TextEditingController();
  ScrollController scrollController = ScrollController();
  List dataMessage = [];
  late WebSocketChannel channel;
  int limit = 10;
  int page = 1;
  @override
  void initState() {
    load();
    connectWS();
    super.initState();
  }

  Future<void> load() async {
    dataMessage = await chatController.getMessages(
        widget.myselftID, widget.dataUserChat['partner']['id'], limit, page);
    scrollToBottom();
    setState(() {});
  }

  Future<void> connectWS() async {
    channel = WebSocketChannel.connect(Uri.parse(dotenv.env['WEBSOCKET_URL']!));
    try {
      await channel.ready;
      channel.sink.add(jsonEncode({
        'type': 'join',
        'chat_id': widget.myselftID,
        'sender_id': widget.dataUserChat['partner']['id'],
      }));
      channel.stream.listen((data) {
        setState(() {
          dataMessage.add(jsonDecode(data));
        });
        scrollToBottom();
      });
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
  void dispose() {
    textEditingController.dispose();
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Text(
                  widget.dataUserChat['partner']['name'],
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
          itemBuilder: (context, index) {
            return dataMessage[index]['chat_id'] == widget.myselftID
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1, color: Colors.lightBlueAccent),
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
                            FormatTime().coverTimeFromIso(
                                dataMessage[index]['timestamp']),
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                  )
                : Align(
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
                            FormatTime().coverTimeFromIso(
                                dataMessage[index]['timestamp']),
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                  );
          }),
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
                  sendMessage(textEditingController.text);
                },
                icon: const Icon(Icons.send)),
          )
        ],
      ),
    );
  }

  Future<void> sendMessage(String content) async {
    final resultChat = await chatController.chats(
        [widget.myselftID, widget.dataUserChat['partner']['id']],
        content,
        widget.dataUserChat['partner']['id']);
    final resultMessage = await chatController.messages(
        widget.dataUserChat['partner']['id'], content, "message", [], "");
    channel.sink.add(jsonEncode({
      'type': 'message',
      'chat_id': widget.myselftID,
      'sender_id': widget.dataUserChat['partner']['id'],
      'content': content,
    }));
    textEditingController.clear();
  }
}
