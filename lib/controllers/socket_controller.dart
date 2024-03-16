import 'package:chat_app/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketController extends GetxController {
  Socket? socket;
  HomeController homeController = Get.find();

  initSocket() async {
    final token = await homeController.getToken();
    socket = io("http://192.168.100.7:5000", <String, dynamic>{
      'transports': ['websocket'],
      'query': {
        'token': token,
      },
    }).connect();
  }

  joinRoom(String roomCode, String username) async {
    socket!.emit("join", {
      "room_code": roomCode,
      "username": username,
    });
  }

  listen(Function callback) async {
    socket!.on(("recieved_msg"), (data) {
      callback(data);
    });

    socket!.on(("friend_message_received"), (data) {
      callback(data);
    });
  }

  deleteListener(Function callback) async {
    socket!.on(("message_deleted"), (data) {
      callback(data);
    });

    socket!.on(("friend_message_deleted"), (data) {
      callback(data);
    });
  }

  deleteRoom(String roomCode) {
    socket!.emit("delete_room", {
      "room_code": roomCode,
    });
  }

  updateAfterDeleteRoom(Function callback) async {
    socket!.on(("room_deleted"), (data) {
      callback(data);
    });
  }

  sendFriendMessage(
      {String? message,
      String? username,
      String? friendUsername,
      int? friend_id}) {
    print({
      "friend_id": friend_id,
      "user2": friendUsername,
      "user1": username,
      "msg": message,
    });
    socket!.emit("friend_message", {
      "friend_id": friend_id,
      "user2": friendUsername,
      "user1": username,
      "msg": message,
    });
  }

  sendMessage({String? message, String? username, String? roomCode}) {
    socket!.emit("message", {
      "room_code": roomCode,
      "username": username,
      "msg": message,
    });
  }

  deleteMessage({int? messageId, String? roomCode}) {
    socket!.emit("delete_message", {
      "room_code": roomCode,
      "id": messageId,
    });
  }

  deleteFriendMessage(
      {int? messageId,
      String? friendUsername,
      String? username,
      int? friend_id}) {
    socket!.emit("delete_friend_message", {
      "friend_id": friend_id,
      "id": messageId,
    });
  }

  sendFriendRequest(String? sender, String? receiver) {
    socket!.emit("friend_request_sent", {
      "user1": sender,
      "user2": receiver,
    });
  }

  acceptFriendRequest(friendId) {
    socket!.emit("friend_request_accepted", {"friend_id": friendId});
  }
}
