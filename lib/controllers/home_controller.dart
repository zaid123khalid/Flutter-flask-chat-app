import 'dart:convert';

import 'package:chat_app/Services/http_conn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class HomeController extends GetxController {
  RxList chats = [].obs;
  RxList friends = [].obs;
  RxList friendRequests = [].obs;

  TextEditingController roomNameController = TextEditingController();
  TextEditingController roomCodeController = TextEditingController();

  HttpConnection http = HttpConnection();

  final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  getToken() async {
    var hiveBox = await Hive.openBox('user');
    var token = hiveBox.get('token');
    return token;
  }

  acceptFriendRequest(friendRequestId) async {
    var token = await getToken();
    var response = await http.post(url: "/accept_friend_request", body: {
      "friend_request_id": friendRequestId
    }, headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    });
    var data = jsonDecode(response.body);

    return data;
  }

  getChats() async {
    final token = await getToken();
    final response = await http.get(url: '/chat', headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    });
    friendRequests.value = jsonDecode(response.body)['friends_request'];
    if (response.statusCode == 200) {
      var rooms = jsonDecode(response.body)['rooms'];
      var friends = jsonDecode(response.body)['friends'];
      // Delete messages from the response as they are not needed here
      rooms.forEach((room) {
        room.remove('messages');
      });
      friends.forEach((friend) {
        friend.remove('messages');
      });
      chats.value = rooms;
      this.friends.value = friends;
    }
    return response;
  }

  updateChats(data) async {
    final updatedChats = chats.map((chat) {
      if (chat['room_code'] == data['room_code']) {
        return {
          ...chat,
          'last_message': data['last_message'],
          'last_message_user': data['last_message_user']
        };
      } else {
        return chat;
      }
    }).toList();
    chats.value = updatedChats;
  }

  updateFriendChats(data) async {
    final updatedFriends = friends.map((friend) {
      if (friend['id'] == data['friend_id']) {
        return {
          ...friend,
          'last_message': data['last_message'],
          'last_message_user': data['last_message_user']
        };
      } else {
        return friend;
      }
    }).toList();
    friends.value = updatedFriends;
  }

  createRoom(String username) async {
    final token = await getToken();
    final response = await http.post(
      url: '/create_room',
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token'
      },
      body: ({
        "username": username,
        "room_name": roomNameController.text,
      }),
    );
    if (response.statusCode == 200) {
      chats.add(jsonDecode(response.body)['room']);
    }
    return response;
  }

  logout() async {
    await Hive.deleteBoxFromDisk('user');
  }

  joinRoom() async {
    final token = await getToken();
    final response = await http.post(
      url: '/join_room',
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token'
      },
      body: ({
        "room_code": roomCodeController.text,
      }),
    );
    if (response.statusCode == 200) {
      chats.add(jsonDecode(response.body)['room']);
    }
    return response;
  }

  joinFriend(int friendId, String friendUsername) async {
    var token = await getToken();
    final response = await http.post(url: '/join_friend', body: {
      "friend_username": friendUsername,
      "friend_id": friendId,
    }, headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    });
    if (response.statusCode == 200) {
      friends.add(jsonDecode(response.body)['friend']);
    }
  }

  afterDeleteRoom(data) {
    final updatedChats = chats.where((chat) {
      if (chat['room_code'] == data['room_code']) {
        return false;
      } else {
        return true;
      }
    }).toList();
    chats.value = updatedChats;
  }
}
