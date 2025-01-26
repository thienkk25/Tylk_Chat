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
                      const CircleAvatar(
                        backgroundImage: NetworkImage(
                            "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMwAAADACAMAAAB/Pny7AAAAbFBMVEX///8AAAD+/v77+/sEBAT4+Pjw8PDQ0NCwsLDf39/T09Pz8/Pp6elWVlbt7e1ISEg9PT2bm5ulpaXIyMhPT08mJiZ9fX1iYmJqamq6urp1dXUuLi5vb28MDAwVFRXZ2dk2NjYdHR2GhoaTk5ONV3etAAAJO0lEQVR4nO1diXqrKhBGcNe4LyGbWd7/HS8DmKY2OU0UhX7X/5ymSTSVn4FZYMYgtGLFihUrVqxYseJ/A8wgn+ltiAJwBl+E/jTwk2d/FFweWEJ3YybiCYO/RgrfHwBO5CZxwBAnbuQ8nPE3QKD3CX+WBF5x3VZpxpBW22vhBQkRZDBIiWhu6htgjWRNJXHo7/bWAPXBDxMizvoTbBgXHAV+U98p2N/4NH4XgWjgPN1t/Q2su0lYtPYDC/HLtuUzu81D5y8YH2hhV2wunIL9TSTyJTycqjwwX7XBvKbtZTi0BmDHLi11EDGSDO71MUbx7fwLFYnzNeafwwaqaiwaFW6Pv/MQOG49mDfmiQcLsaBy8y4VEF5FmUUyT6dxRYsITT+gwpBSYuAwI9AkTLO3ZssDnTMlBo4zBkLPb48x0Nucz54a5wVwA+hV73P5QuYhZJiOZkopaMdwsa1NwOYbQeaoASaY5DqGC4y0JsGGaQHHP42iwlycU+GYtUyAu7eV8oAOY5N62CgP2r1+oJQHsmEDzUVmzBlh+8v693a/pGNdSkM8aO7GkO1oLhwtAYWmHxAho7Dv47HwzDA1XDKHaVRsq0UmCAbxGGYCEYnABEPDBZNPpWJbN91EALBghHgQY48WD3ywMkAwoMlQd5kqGRZ2egaMMzAz/nQullUYQAZwU0HmagAXTJA70WIKtIkBosEo+CDAfAXbqo1Qzqh7e3Hpn9CvAXi4rISLVeonwzQzVUOGaqYCUKSZQTebgJXMEzK6p4w6B8AMyShTAL5uJlwypRoy+lUzoJtOBIIA/UYTGhD82CAfg0unnwxhQfP7G0z/QGWAbwYbM40KMjtHPxnwZwoVZHID1jS5OhuzZj7AsdTNhAOjKJ20asaRmRGbsdGhYNLsdBMBYFABENFMEY1tiMkUq/epNYmObaVGbJ2JhJFJ7hl0gn7HTILxcdOxC5o23wnMXCMkg0TWjC/3wEZKxsemkAE28di1M94Bm5hgxxAysBRIx3qbjE0NGTT67X8PTKJxa7Sw2WxdXWzGLqAA69ZgpO8sUjRMSgOATTzvIw/tS1kY4pV9gbvv1PpIpfX5qL45IpGApLEov1hv+wG2JHO6uQYNMA5RhxHf6vdtp80N5kVmnZoESH3BBAGbD0YZC/xvsXkpp32JTJK/b27AwNxiyDUziwuParjH6fi/ZjfZ93mVFpFJxnIAqDUpD32TX6g225YHtqU5hvIp2JAJir0gYtvPtYF4c58HxjiXTyHGv1M2dxm8xK6MDC9xkgl9OClbyeYFnQ1NMDZ4vgC4RoNVAZKU25d70PttGUMxl0mZjBwPxbFY1mfxkjOMXS8/PNHT+0PuuXCWw6u0ejpG8BKNx4RbTT7OCO6LHIgb0isvC5I4ba40dIUKI9wwyXRm+LQRMYDsU8bAke3q6/z4S6hsDCmlZRi70UM0yaVH5FP5XzskFxBNFIdQGYegj0VHPyk67c29+B11XcxERbAoiDQAfNZHYQ62fxc6fW0jP8SPEtK7LN8kQJwOstTT3Iv4NNPR9iGgEW7ZyOKsLA8c3Dtr6FH/4u/KGDtBkUml0JQuMqFmE7Y0nI5Xl4olMDtldOQhsUQoGeBvYmFUKm6IuCWqd52jp/0SoqNZfwbFwPHPCi+5i0OurX89wLuJ10ulR10EWN9SQO/1O+WTUpNj44exQ+6nioCHt5M4Seg3IhGq9w+4eDbU4dVeeshw1RQX50GoLF9UTU67OPk2epwk7mh+3Vi9p2M/fmpfxNqsJx9m4fVi/Yj75UQ4ZZvdraBl6XGUJS1uu012+hLGoA9OTaiNDPsp2+OTqOWhz0/1PkvTiiFNs3196o9/F0v/1rFdfNkJ3+9fQLOnnfwQTL6CPTipf5HRhSVDEDfx2PGVZDM8EoKJ4yw71Ai4LDgq1HKR2BeLGlDCPS8HrMv4lPkXgCWbIlpSNOBEEn/6dvkrFGRBHxrKkETGnHLJ3NksBizkMhMT+LP+/GzuLtaUerm3cKE8CJ01LOgd+zCbbb6INULr7PUB3oxkEE/+r+ab/IIQC9kWSD8DyThKkuX+QYV3VOXMvi4AXPIJe/5vkoF/+dzhGkwYepmXjLjXjm2dFtgf7EbdwuAzOuJX2s0a3sB20m52LoIQY3Rw0Yz7auzP5gpSGN8iw35OOV/1nIkNRt7Isv9xfLJSrA/OQgaRw8wWZoDDfPnBGI1O9xkB6LS9P98mzrgbmExBO4cjIHyyWeKxf6KeI7bhZLrFBcNEM0O9A/fJhsuwS6Au5vBqsIYZA9gG6qkw4+VrEAyL09S7aODI8N39Rac/R5OoJgO1GNnvF1YP2zqXqt1NrKyC8XMUqndwMY4XcpeHsK1df1dHZWRQqGWUAc6e6juGEVprmPwcJ9pnFahClKu5hcEI2DdXsbsZKyn5G4ddrLjuYXTlggJsY4VEAHp8GYFNoHgJbWyq/0rmCRml0D3MlMpGtwJQOsxG3vNzIoSZbhRX1+JxN/1UQueoOtjU6ZtlpWLfDPPbfmoAlKQlqsmw4EzBzbJGUOHBmUImgsxHhUsqWFh8ke7E3EzeApVkMAoOD5dZgg6/1AyrM5xQ2M68AfhApb/OZoZ7n2Kex7TskiYsBLfhHLtn4gtWggW3NOA6h4AnUKnmIrNfk9uCsbN949UciqnIDGs+2rxqKTqpx9PB5s0GoPWDZzPXDsepnvnmDfKbvpCTtz2fYa7lFDyUO9dtHi2TFswuEdMmq581QwWdOmtojGQ6++xkoMcSLz+kx2+NmMhCDNhjus295J5zND8ZoWKI6+XNRsk2R98Zl02Tl4nIzSWL3FYDy6I/uJLT+fmuOl9GLhA+zJLLuTrk/r1WQ1xgiUxNLIt8xKs4LIvrdpPuj4NWvlB0w7eP+3SzvRZlGEv9gvshtnQmvZCQkwRd6efXZludPwhIT+dq21xzv+wCUQChv7hJKh3sRG4ceCX1i/y2a6v95SWHfdXubnnh09IL4q9vDDSg6IxI16Cv/iHEcSL4bsOuC0MozaC+BC3L0gvDroNvPYwiUYkmhhU2gguWHmg/jX6W/4n6OfJVRPf943cS2qkg1FdW9eVyP4/8OL9/cj9pWI6mGS8bYkwLV6xYsWLFihUrVqxYsWLFihUrVqxYsWLFihV/G/8Bwyhxui7epMsAAAAASUVORK5CYII="),
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
