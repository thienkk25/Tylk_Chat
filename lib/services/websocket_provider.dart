import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final dataMessages = StateProvider<Map<String, dynamic>?>((ref) => null);

class WebsocketStateNotifier extends StateNotifier<WebSocketChannel?> {
  WebsocketStateNotifier() : super(null);
  void connection(String url, WidgetRef ref) {
    if (state != null) {
      return;
    }

    final channel = WebSocketChannel.connect(Uri.parse(url));
    state = channel;
    final dataMessagesNotifier = ref.read(dataMessages.notifier);
    state!.stream.listen(
      (message) {
        final decodedMessage = jsonDecode(message);
        dataMessagesNotifier.state = decodedMessage;
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
