import 'package:socket_io_client/socket_io_client.dart';

class SocketService {
  static Socket? socket;
  static const String _url = 'http://192.168.100.10:5000';

  static connect(String username) {
    socket = io(_url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    }).connect();
    socket!.onConnect((data) => socket!.emit('join', {
          "username": username,
        }));
  }

  static sendMessage(String username, String message) {
    socket!.emit('message', {
      "username": username,
      "msg": message,
    });
  }
}
