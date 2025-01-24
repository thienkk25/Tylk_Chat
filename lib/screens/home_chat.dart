import 'package:app_chat/config/format_time.dart';
import 'package:app_chat/controllers/chat_controller.dart';
import 'package:app_chat/screens/chat_section.dart';
import 'package:app_chat/services/websocket_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomeChat extends ConsumerStatefulWidget {
  const HomeChat({super.key});

  @override
  ConsumerState<HomeChat> createState() => _HomeChatState();
}

class _HomeChatState extends ConsumerState<HomeChat> {
  ChatController chatController = ChatController();
  List dataChats = [];
  late WebSocketChannel channel;
  String myselftID = "";
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        ref
            .read(websocketStateNotifierProvider.notifier)
            .connection(dotenv.env['WEBSOCKET_URL']!, ref);
        loadData();
      },
    );
    super.initState();
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myselftID = prefs.getString("idUser")!;
    dataChats = await chatController.getChats();

    ref
        .read(websocketStateNotifierProvider.notifier)
        .sendMessage({'type': 'status', 'chat_id': myselftID});
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataRealTime = ref.watch(dataMessages);

    if (dataRealTime != null) {
      int index = dataChats
          .indexWhere((element) => element['_id'] == dataRealTime['id']);
      if (index != -1) {
        dataChats[index]['last_message']['sender_id'] =
            dataRealTime['sender_id'];
        dataChats[index]['last_message']['content'] = dataRealTime['content'];
        dataChats[index]['last_message']['timestamp'] =
            dataRealTime['timestamp'];
      }
    }
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
                    myselftID: myselftID, dataUserChat: dataChats[index]),
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
