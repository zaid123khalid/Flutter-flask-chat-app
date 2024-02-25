import 'dart:convert';

import 'package:chat_app/Services/http_conn.dart';
import 'package:chat_app/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  HttpConnection http = HttpConnection();

  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  RxList messages = [].obs;

  RxMap<String, dynamic> selectedMessage = <String, dynamic>{}.obs;

  final HomeController _homeController = Get.find();

  joinRoom(String roomCode) async {
    var token = await _homeController.getToken();
    final response = await http.post(url: '/join_room', body: {
      "room_code": roomCode,
    }, headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      messages.value = data['room']['messages'];
    } else {}
  }

  joinFriend(int friendId, String friendUsername) async {
    var token = await _homeController.getToken();
    final response = await http.post(url: '/join_friend', body: {
      "friend_username": friendUsername,
      "friend_id": friendId,
    }, headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      messages.value = data['friend']['messages'];
    } else {}
  }

  addMessage(data) async {
    if (messages.isNotEmpty && data['id'] == messages.last['id']) return;
    messages.add(data);
    Future.delayed(const Duration(milliseconds: 500), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  sendFriendRequest(String? receiver) async {
    var token = await _homeController.getToken();
    var response = await http.post(url: "/send_friend_request", body: {
      "receiver": receiver
    }, headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    });
    var data = jsonDecode(response.body);

    return data;
  }

  removeMessage(int messageId) async {
    var messagesList = messages.where((p0) {
      return p0['id'] != messageId;
    }).toList();
    messages.value = messagesList;
  }

  selectMessage(Map<String, dynamic>? message) {
    if (message == null) {
      selectedMessage.value = {};
      return;
    }
    selectedMessage.value = message;
  }

  void dispose_() {
    selectMessage(null);
    messageController.clear();
    messages.clear();
  }
}
