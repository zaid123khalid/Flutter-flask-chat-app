import 'package:socket_io_client/socket_io_client.dart';

class SocketService {
  static Socket? socket;
  static const String _url = 'http://192.168.100.8:5000';

  static connect(String username, String roomCode) {
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

  static sendMessage(String username, String message, String roomCode) {
    socket!.emit('message', {
      "username": username,
      "msg": message,
      "room_code": roomCode,
    });
  }
}
