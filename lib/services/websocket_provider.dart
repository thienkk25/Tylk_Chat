import 'dart:convert';

import 'package:app_chat/controllers/chat_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DataRealTimeNotifier extends StateNotifier<Map> {
  DataRealTimeNotifier() : super({});
  void initState() {
    state = {};
  }

  void change(Map data) {
    state = data;
  }
}

final dataRealTimeNotifierProvider =
    StateNotifierProvider<DataRealTimeNotifier, Map>(
  (ref) => DataRealTimeNotifier(),
);

class WebsocketStateNotifier extends StateNotifier<WebSocketChannel?> {
  WebsocketStateNotifier() : super(null);
  void connection(String url, WidgetRef ref) {
    if (state != null) {
      return;
    }

    final channel = WebSocketChannel.connect(Uri.parse(url));
    state = channel;
    final dataRealTime = ref.read(dataRealTimeNotifierProvider.notifier);
    state!.stream.listen(
      (message) {
        final decodedMessage = jsonDecode(message);
        dataRealTime.change(decodedMessage);
      },
      onDone: () {
        if (state != null) {
          state!.sink.close();
          state = null;
        }
      },
    );
  }

  void sendMessage(Map<String, dynamic> message) {
    if (state != null) {
      state!.sink.add(jsonEncode(message));
    }
  }

  void disconnection() {
    if (state != null) {
      state!.sink.close();
      state = null;
    }
  }
}

final websocketStateNotifierProvider =
    StateNotifierProvider<WebsocketStateNotifier, WebSocketChannel?>(
        (ref) => WebsocketStateNotifier());

class DataChatsNotifier extends StateNotifier<List> {
  DataChatsNotifier() : super([]);
  void initState(List data) {
    state = data;
  }

  void add(Map data) {
    state = [...state, data];
  }

  void reset() {
    state = [];
  }

  void updateById(int index, String newContent) {
    final updatedState = List<Map<String, dynamic>>.from(state);
    updatedState[index] = {
      ...updatedState[index],
      'last_message': {
        ...updatedState[index]['last_message'],
        'content': newContent,
      },
      'updated_at': DateTime.now().toIso8601String(),
    };
    state = updatedState;
  }

  Future<void> refresh() async {
    final newData = await ChatController().getChats();
    state = newData;
  }
}

final dataChatsNotifierProvider =
    StateNotifierProvider<DataChatsNotifier, List>(
  (ref) => DataChatsNotifier(),
);

class DataMessagesNotifier extends StateNotifier<List> {
  DataMessagesNotifier() : super([]);
  void initState(List data) {
    state = data;
  }

  void add(Map data) {
    state = [...state, data];
  }

  void reset() {
    state = [];
  }
}

final dataMessagesNotifierProvider =
    StateNotifierProvider<DataMessagesNotifier, List>(
  (ref) => DataMessagesNotifier(),
);
