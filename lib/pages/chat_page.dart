import 'package:chat_app/Widgets/message.dart';
import 'package:chat_app/controllers/chat_controller.dart';
import 'package:chat_app/controllers/home_controller.dart';
import 'package:chat_app/controllers/socket_controller.dart';
import 'package:chat_app/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatPage extends StatefulWidget {
  final String roomCode;
  final String roomName;
  const ChatPage({super.key, required this.roomCode, required this.roomName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatController _chatController = Get.put(ChatController());
  final SocketController _socketController = Get.put(SocketController());
  final HomeController _homeController = Get.put(HomeController());
  final UserController _userController = Get.put(UserController());

  @override
  void initState() {
    _chatController.joinRoom(widget.roomCode);
    _socketController.listen((data) {
      if (data['room_code'] != '' && data['room_code'] == widget.roomCode) {
        _chatController.addMessage(data);
      }
      _homeController.updateChats(data);
    });
    _socketController.deleteListener((data) {
      _chatController.removeMessage(data['id']);
      _homeController.updateChats(data['id']);
    });
    scrollToBottom();
    super.initState();
  }

  scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _chatController.scrollController.animateTo(
        _chatController.scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            _chatController.dispose_();
            Navigator.pop(context);
          },
        ),
        actions: [
          Obx(
            () => Offstage(
                offstage: !_chatController.selectedMessage.containsKey("id"),
                child: _chatController.selectedMessage['sender'] ==
                        _userController.username.value
                    ? IconButton(
                        onPressed: () {
                          int messageId = _chatController.selectedMessage['id'];
                          _socketController.deleteMessage(
                            messageId: messageId,
                            roomCode: widget.roomCode,
                          );
                          _chatController.removeMessage(messageId);
                          _chatController.selectMessage(null);
                        },
                        icon: const Icon(Icons.delete),
                      )
                    : _homeController.friends
                            .where((p0) =>
                                p0['user1'] ==
                                    _chatController.selectedMessage['sender'] ||
                                p0['user2'] ==
                                    _chatController.selectedMessage['sender'])
                            .isEmpty
                        ? IconButton(
                            onPressed: () async {
                              var resp = await _chatController
                                  .sendFriendRequest(_chatController
                                      .selectedMessage['sender']);

                              if (resp['status'] == 'success') {
                                _socketController.sendFriendRequest(
                                  resp['friend_request']['sender'],
                                  resp['friend_request']['receiver'],
                                );
                              }
                            },
                            icon: Image.asset(
                              'assets/add-friend-80.png',
                              width: 24,
                              height: 24,
                            ))
                        : const SizedBox()),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () {
          _chatController.selectMessage(null);
        },
        child: Column(
          children: [
            Obx(
              () => Expanded(
                child: ListView.builder(
                  controller: _chatController.scrollController,
                  itemCount: _chatController.messages.length,
                  itemBuilder: (context, index) {
                    return Obx(
                      () => Message(
                        alignment: _chatController.messages[index]['sender'] ==
                                _userController.username.value
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        onLongPress: () {
                          _chatController
                              .selectMessage(_chatController.messages[index]);
                        },
                        isSelected: _chatController.selectedMessage ==
                            _chatController.messages[index],
                        message: _chatController.messages[index]['msg'],
                        username: _chatController.messages[index]['sender'],
                        time: _chatController.messages[index]['time'],
                        isMe: _chatController.messages[index]['sender'] ==
                            _userController.username.value,
                      ),
                    );
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        maxLines: 20,
                        minLines: 1,
                        controller: _chatController.messageController,
                        decoration: InputDecoration(
                          hintText: "Write message...",
                          hintStyle: const TextStyle(color: Colors.black54),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          contentPadding: const EdgeInsets.only(left: 20),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              if (_chatController
                                  .messageController.text.isNotEmpty) {
                                _socketController.sendMessage(
                                  message:
                                      _chatController.messageController.text,
                                  roomCode: widget.roomCode,
                                  username: _userController.username.value,
                                );
                                _chatController.messageController.clear();
                                scrollToBottom();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
