import 'dart:convert';

import 'package:app_chat/config/format_time.dart';
import 'package:app_chat/controllers/chat_controller.dart';
import 'package:app_chat/screens/chat_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomeChat extends StatefulWidget {
  const HomeChat({super.key});

  @override
  State<HomeChat> createState() => _HomeChatState();
}

class _HomeChatState extends State<HomeChat> {
  ChatController chatController = ChatController();
  List dataChats = [];
  late WebSocketChannel channel;
  String myselftID = "";
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadData();
      connectWS();
    });
    super.initState();
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myselftID = prefs.getString("idUser")!;
    dataChats = await chatController.getChats();
    setState(() {});
  }

  Future<void> connectWS() async {
    channel = WebSocketChannel.connect(Uri.parse(dotenv.env['WEBSOCKET_URL']!));
    try {
      await channel.ready;
      channel.sink.add(jsonEncode({'type': 'status', 'chat_id': myselftID}));
    } catch (e) {
      debugPrint("Error");
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: dataChats.length,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.all(10),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatSection(
                  myselftID: myselftID,
                  dataUserChat: dataChats[index],
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dataChats[index]['partner']['name'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            dataChats[index]['last_message']['content'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    FormatTime().coverTimeFromIso(
                        dataChats[index]['last_message']['timestamp']),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[400],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
