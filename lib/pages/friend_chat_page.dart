import 'package:chat_app/Widgets/message.dart';
import 'package:chat_app/controllers/chat_controller.dart';
import 'package:chat_app/controllers/home_controller.dart';
import 'package:chat_app/controllers/socket_controller.dart';
import 'package:chat_app/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendChatPage extends StatefulWidget {
  final int friend_id;
  final String friendUsername;
  const FriendChatPage(
      {super.key, required this.friend_id, required this.friendUsername});

  @override
  State<FriendChatPage> createState() => _FriendChatPageState();
}

class _FriendChatPageState extends State<FriendChatPage> {
  final ChatController _chatController = Get.put(ChatController());
  final SocketController _socketController = Get.put(SocketController());
  final HomeController _homeController = Get.put(HomeController());
  final UserController _userController = Get.put(UserController());

  @override
  void initState() {
    _chatController.joinFriend(widget.friend_id, widget.friendUsername);
    _socketController.listen((data) {
      if (data['friend_id'] != '' && data['friend_id'] == widget.friend_id) {
        _chatController.addMessage(data);
      }
      _homeController.updateFriendChats(data);
    });
    _socketController.deleteListener((data) {
      _chatController.removeMessage(data['id']);
      _homeController.updateFriendChats(data);
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
        title: Text(widget.friendUsername),
        leading: IconButton(
          icon: const Icon(
            color: Colors.white,
            Icons.arrow_back,
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
              child: IconButton(
                onPressed: () {
                  int messageId = _chatController.selectedMessage['id'];
                  _socketController.deleteFriendMessage(
                    messageId: messageId,
                    friend_id: widget.friend_id,
                  );
                  _chatController.removeMessage(messageId);
                  _chatController.selectMessage(null);
                },
                icon: const Icon(Icons.delete),
              ),
            ),
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
                          _chatController.messages[index]['sender'] ==
                                  _userController.username.value
                              ? _chatController.selectMessage(
                                  _chatController.messages[index])
                              : _chatController.selectMessage(null);
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
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              if (_chatController
                                  .messageController.text.isNotEmpty) {
                                _socketController.sendFriendMessage(
                                  message:
                                      _chatController.messageController.text,
                                  username: _userController.username.value,
                                  friendUsername: widget.friendUsername,
                                  friend_id: widget.friend_id,
                                );
                                _chatController.messageController.clear();
                                scrollToBottom();
                              }
                            },
                          ),
                          contentPadding: const EdgeInsets.only(left: 20),
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
