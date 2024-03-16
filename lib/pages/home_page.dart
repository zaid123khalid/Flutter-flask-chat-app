import 'dart:convert';

import 'package:chat_app/Widgets/app_button.dart';
import 'package:chat_app/controllers/socket_controller.dart';
import 'package:chat_app/controllers/user_controller.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/friend_chat_page.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/setting_page.dart';
import 'package:get/get.dart';
import 'package:chat_app/controllers/home_controller.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _homeController = Get.put(HomeController());
  SocketController socketController = Get.put(SocketController());

  final UserController _userController = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    initializeSocket();

    loadChats();
  }

  initializeSocket() async {
    await socketController.initSocket();
    socketController.listen((data) {
      _homeController.updateChats(data);
      _homeController.updateFriendChats(data);
    });
    socketController.deleteListener((data) {
      _homeController.updateChats(data);
      _homeController.updateFriendChats(data);
    });
    socketController.updateAfterDeleteRoom(
      (data) {
        _homeController.afterDeleteRoom(data);
      },
    );
  }

  loadChats() async {
    final resp = await _homeController.getChats();
    if (resp.statusCode == 401 && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Session expired, please login again"),
        ),
      );
      _homeController.logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      children: [
                        const Center(
                          child: Text(
                            "Notifications",
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                              maxHeight: 250, minHeight: 100),
                          child: _homeController.friendRequests.isNotEmpty
                              ? ListView.builder(
                                  itemCount:
                                      _homeController.friendRequests.length,
                                  itemBuilder: (context, index) => ListTile(
                                    title: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: _homeController
                                                    .friendRequests[index]
                                                ['sender'],
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const TextSpan(
                                              text:
                                                  " sent you a Friend Request"),
                                        ],
                                      ),
                                    ),
                                    subtitle: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                          child: AppButton(
                                            height: 30,
                                            width: 80,
                                            text: "Accept",
                                            onPressed: () async {
                                              var resp = await _homeController
                                                  .acceptFriendRequest(
                                                _homeController
                                                        .friendRequests[index]
                                                    ['id'],
                                              );
                                              if (resp['status'] == 'success' &&
                                                  context.mounted) {
                                                Navigator.pop(context);
                                                _homeController.joinFriend(
                                                    resp['friend']['id'],
                                                    _userController.username
                                                                .value ==
                                                            resp['friend']
                                                                ['user1']
                                                        ? resp['friend']
                                                            ['user2']
                                                        : resp['friend']
                                                            ['user1']);
                                                socketController
                                                    .acceptFriendRequest(
                                                        resp['friend']['id']);
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: AppButton(
                                            width: 80,
                                            height: 30,
                                            text: "Reject",
                                            onPressed: () {},
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Text("No New Notifications"),
                                ),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.notifications)),
          PopupMenuButton(
              position: PopupMenuPosition.under,
              tooltip: "Menu",
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Join Room"),
                              content: TextField(
                                autofocus: true,
                                controller: _homeController.roomCodeController,
                                decoration: const InputDecoration(
                                  hintText: "Room Code",
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final resp =
                                        await _homeController.joinRoom();
                                    if (resp.statusCode == 200 &&
                                        context.mounted) {
                                      var room = json.decode(resp.body)["room"];
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                            roomCode: room["room_code"],
                                            roomName: room["room_name"],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text("Join"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/join-48.png",
                            width: 24,
                            height: 24,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          const Text("Join Room"),
                        ],
                      )),
                  PopupMenuItem(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Create Room"),
                            content: TextField(
                              autofocus: true,
                              controller: _homeController.roomNameController,
                              decoration: const InputDecoration(
                                hintText: "Room Name",
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final resp = await _homeController.createRoom(
                                      _userController.username.value);
                                  if (resp.statusCode == 200 &&
                                      context.mounted) {
                                    var room = json.decode(resp.body)["room"];
                                    socketController.joinRoom(room["room_code"],
                                        _userController.username.value);
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatPage(
                                          roomCode: room["room_code"],
                                          roomName: room["room_name"],
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: const Text("Create"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.add_circle_outline_outlined),
                        SizedBox(width: 10),
                        Text("Create Room"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsPage()),
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 10),
                        Text("Settings"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      _homeController.logout();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 10),
                        Text("Logout"),
                      ],
                    ),
                  ),
                ];
              })
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await loadChats();
          await initializeSocket();
        },
        child: Obx(
          () => ListView.builder(
            itemCount:
                _homeController.chats.length + _homeController.friends.length,
            itemBuilder: (context, index) {
              if (index < _homeController.chats.length) {
                var room = _homeController.chats[index];
                return ListTile(
                  onLongPress: () {
                    _homeController.chats[index]["admin"] ==
                            _userController.username.value
                        ? showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Delete Room"),
                                content: const Text(
                                    "Are you sure you want to delete this room?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      socketController
                                          .deleteRoom(room["room_code"]);
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Delete"),
                                  ),
                                ],
                              );
                            },
                          )
                        : null;
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          roomCode: room["room_code"],
                          roomName: room["room_name"],
                        ),
                      ),
                    );
                  },
                  title: Text(room["room_name"]),
                  subtitle: Text(
                    overflow: TextOverflow.ellipsis,
                    room["last_message"] == null
                        ? "No messages yet"
                        : "${room["last_message_user"] == _userController.username.value ? "You" : room["last_message_user"]}: ${room["last_message"]}",
                  ),
                );
              } else {
                var friend = _homeController
                    .friends[index - _homeController.chats.length];
                return friend['status'] == 'accepted'
                    ? ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FriendChatPage(
                                friend_id: friend["id"],
                                friendUsername: friend["user1"] ==
                                        _userController.username.value
                                    ? friend['user2']
                                    : friend["user1"],
                              ),
                            ),
                          );
                        },
                        title: Text(
                            friend["user1"] == _userController.username.value
                                ? friend['user2']
                                : friend["user1"]),
                        subtitle: Text(
                          friend["last_message"] == null ||
                                  friend["last_message"] == ""
                              ? "No messages yet"
                              : friend["last_message_user"] ==
                                      _userController.username.value
                                  ? "You: ${friend["last_message"]}"
                                  : friend["last_message_user"] +
                                      ": ${friend["last_message"]}",
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : Container();
              }
            },
          ),
        ),
      ),
    );
  }
}
