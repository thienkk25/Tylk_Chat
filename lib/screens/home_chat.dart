import 'package:app_chat/config/format_time.dart';
import 'package:app_chat/controllers/chat_controller.dart';
import 'package:app_chat/screens/chat_section.dart';
import 'package:flutter/material.dart';

class HomeChat extends StatefulWidget {
  const HomeChat({super.key});

  @override
  State<HomeChat> createState() => _HomeChatState();
}

class _HomeChatState extends State<HomeChat> {
  ChatController chatController = ChatController();
  List dataChats = [];
  @override
  void initState() {
    Future.microtask(() => loadData());
    super.initState();
  }

  Future<void> loadData() async {
    dataChats = await chatController.getChats();
    setState(() {});
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
