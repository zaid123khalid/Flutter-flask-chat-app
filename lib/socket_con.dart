import 'package:socket_io_client/socket_io_client.dart';

class SocketService {
  Socket? socket;
  final String _url = 'http://192.168.100.8:5000';

  connect(String username, String roomCode) {
    socket = io(_url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    }).connect();
    socket!.onConnect((_) {
      socket!.emit('join', {
        "username": username,
        "room_code": roomCode,
      });
    });
  }

  sendMessage(String username, String message, String roomCode) {
    socket!.emit('message', {
      "username": username,
      "msg": message,
      "room_code": roomCode,
    });
  }

  disconnectSocket(
    String roomCode,
  ) {
    socket!.emit('leave', {
      "room_code": roomCode,
    });
    socket!.disconnect();
  }
}
