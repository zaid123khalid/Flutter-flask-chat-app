import 'package:chat_app_flask/socket_con.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String username;
  final String roomCode;
  final List messages;
  const ChatPage(
      {super.key,
      required this.username,
      required this.roomCode,
      this.messages = const []});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List messages = [];
  final TextEditingController _msgController = TextEditingController();
  bool _isMounted = false; // Add a flag to track if the widget is mounted

  @override
  void initState() {
    super.initState();
    messages.addAll(widget.messages);
    SocketService.connect(widget.username, widget.roomCode);
    SocketService.socket!.on(
      "recieved_msg",
      (data) {
        if (_isMounted) {
          // Check if the widget is still mounted
          setState(() {
            messages.add({
              "username": data["username"],
              "msg": data["msg"],
            });
          });
        }
      },
    );
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false; // Update the flag when the widget is disposed
    SocketService.socket!.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.roomCode)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return Align(
                    alignment: messages[index]["username"] == widget.username
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            messages[index]["username"],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            messages[index]["msg"],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.black26,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: const InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      if (_msgController.text.isNotEmpty) {
                        messages.add({
                          "username": widget.username,
                          "msg": _msgController.text,
                        });
                        SocketService.sendMessage(widget.username,
                            _msgController.text, widget.roomCode);
                        setState(() {});
                        _msgController.clear();
                      }
                    },
                    backgroundColor: Colors.blue,
                    elevation: 0,
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
