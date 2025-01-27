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
  late WebSocketChannel channel;
  String myselftID = "";
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        loadData();
      },
    );
    super.initState();
  }

  Future<void> loadData() async {
    ref
        .read(websocketStateNotifierProvider.notifier)
        .connection(dotenv.env['WEBSOCKET_URL']!, ref);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myselftID = prefs.getString("idUser")!;
    ref
        .read(dataChatsNotifierProvider.notifier)
        .initState(await chatController.getChats());
    ref
        .read(websocketStateNotifierProvider.notifier)
        .sendMessage({'type': 'status', 'sender_id': myselftID});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataChats = ref.watch(dataChatsNotifierProvider);
    final dataRealTime = ref.watch(dataRealTimeNotifierProvider);
    if (dataRealTime.isNotEmpty && dataChats.isNotEmpty) {
      int index = dataChats
          .indexWhere((element) => element['_id'] == dataRealTime['id']);
      if (index != -1) {
        dataChats[index]['last_message']['receiver_id'] =
            dataRealTime['receiver_id'];
        dataChats[index]['last_message']['content'] = dataRealTime['content'];
        dataChats[index]['last_message']['timestamp'] =
            dataRealTime['timestamp'];
      }
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(dataChatsNotifierProvider.notifier).refresh(),
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff18A5A7), Color(0xffBFFFC7)],
            ),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: dataChats.length,
            itemBuilder: (context, index) => Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadiusDirectional.all(Radius.circular(10)),
                gradient: LinearGradient(
                  colors: [Color(0xffCCFFAA), Color(0xff1E5B53)],
                ),
              ),
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
                      CircleAvatar(
                        backgroundImage: dataChats[index]['partner']
                                    ['profile_picture'] !=
                                ""
                            ? NetworkImage(
                                dataChats[index]['partner']['profile_picture'])
                            : const NetworkImage(
                                "https://res.cloudinary.com/dksr7si4o/image/upload/v1737961456/flutter/avatar/6_cnm2fb.jpg"),
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
        ),
      ),
    );
  }
}
