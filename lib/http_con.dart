import 'dart:convert';

import 'package:http/http.dart' as http;

class HttpConnection {
  static const String BASE_URL = "http://192.168.100.8:5000";

  static Future joinRoom(String username, String roomCode) async {
    var url = Uri.parse("$BASE_URL/join_room");
    var response = await http.post(
      url,
      body: jsonEncode({
        "username": username,
        "room_code": roomCode,
      }),
      headers: {"Content-Type": "application/json"},
    );
    return response;
  }

  static Future createRoom(String username, String roomCode) async {
    var url = Uri.parse("$BASE_URL/create_room");
    var response = await http.post(
      url,
      body: jsonEncode({
        "username": username,
        "room_code": roomCode,
      }),
      headers: {"Content-Type": "application/json"},
    );
    return response;
  }
}
