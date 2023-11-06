import 'package:chat_app_flask/socket_con.dart';
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/services.dart';

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
  final ScrollController _scrollController = ScrollController();
  final socketService = SocketService();
  List messages = [];
  final TextEditingController _msgController = TextEditingController();
  bool _isMounted = false;
  bool _isTextfieldFocused = false;
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    messages.addAll(widget.messages);
    socketService.connect(widget.username, widget.roomCode);
    socketService.socket!.on(
      "recieved_msg",
      (data) {
        if (_isMounted) {
          messages.add({
            "username": data["username"],
            "msg": data["msg"],
          });
        }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
      );
    });
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    socketService.disconnectSocket(widget.roomCode);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.roomCode),
        leading: BackButton(
          onPressed: () {
            socketService.disconnectSocket(widget.roomCode);
            Navigator.pop(context);
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            _isTextfieldFocused = false;
          });
        },
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return Align(
                      alignment: messages[index]["username"] == widget.username
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: messages[index]["username"] == widget.username
                              ? Colors.blueAccent.withOpacity(0.5)
                              : Colors.black26,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              messages[index]["username"],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.deepPurpleAccent.shade700,
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
                margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.black26,
                  border: Border.all(
                      width: 2,
                      color: _isTextfieldFocused
                          ? Colors.blueAccent
                          : Colors.black38),
                ),
                child: Row(
                  children: <Widget>[
                    IconButton(
                        onPressed: () {
                          setState(() {
                            _showEmojiPicker = !_showEmojiPicker;
                            if (_showEmojiPicker) {
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide');
                            } else {
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.show');
                            }
                          });
                        },
                        icon: Icon(_showEmojiPicker
                            ? Icons.keyboard_alt_outlined
                            : Icons.emoji_emotions_outlined)),
                    Expanded(
                      child: TextField(
                        onSubmitted: (value) {
                          if (_msgController.text.isNotEmpty) {
                            messages.add({
                              "username": widget.username,
                              "msg": _msgController.text,
                            });
                            socketService.sendMessage(widget.username,
                                _msgController.text, widget.roomCode);
                            _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut);
                            setState(() {});
                            _msgController.clear();
                          }
                        },
                        onTap: () {
                          setState(() {
                            _showEmojiPicker = false;
                            _isTextfieldFocused = true;
                          });
                        },
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
                    FloatingActionButton.small(
                      onPressed: () {
                        if (_msgController.text.isNotEmpty) {
                          messages.add({
                            "username": widget.username,
                            "msg": _msgController.text,
                          });
                          socketService.sendMessage(widget.username,
                              _msgController.text, widget.roomCode);
                          _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut);
                          setState(() {});
                          _msgController.clear();
                        }
                      },
                      backgroundColor: Colors.blue,
                      elevation: 0,
                      child: Transform.rotate(
                        angle: -0.8,
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Offstage(
              offstage: !_showEmojiPicker,
              child: SizedBox(
                height: 270,
                child: EmojiPicker(
                  onEmojiSelected: (Category? category, Emoji emoji) {},
                  textEditingController: _msgController,
                  config: Config(
                    columns: 7,
                    emojiSizeMax: 32 *
                        (foundation.defaultTargetPlatform == TargetPlatform.iOS
                            ? 1.30
                            : 1.0),
                    gridPadding: EdgeInsets.zero,
                    initCategory: Category.RECENT,
                    bgColor: Colors.black26,
                    indicatorColor: Colors.blue,
                    iconColor: Colors.grey.shade800,
                    iconColorSelected: Colors.blue,
                    skinToneDialogBgColor: Colors.white,
                    skinToneIndicatorColor: Colors.grey,
                    enableSkinTones: true,
                    recentTabBehavior: RecentTabBehavior.RECENT,
                    recentsLimit: 28,
                    noRecents: const Text(
                      'No Recents',
                      style: TextStyle(fontSize: 20, color: Colors.black26),
                      textAlign: TextAlign.center,
                    ),
                    loadingIndicator: const SizedBox.shrink(),
                    tabIndicatorAnimDuration: kTabScrollDuration,
                    buttonMode: ButtonMode.CUPERTINO,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
