import 'package:flutter/material.dart';

class Message extends StatelessWidget {
  final String message;
  final String username;
  final String time;
  final bool isMe;
  final bool isSelected;
  final AlignmentGeometry alignment;
  final Function()? onLongPress;

  const Message({
    Key? key,
    required this.message,
    required this.username,
    required this.time,
    this.isMe = false,
    this.isSelected = false,
    this.alignment = Alignment.centerLeft,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: IntrinsicWidth(
          child: Row(children: [
            Flexible(
              child: Container(
                margin: isMe
                    ? const EdgeInsets.only(
                        top: 8,
                        bottom: 8,
                        right: 8,
                        left: 40,
                      )
                    : const EdgeInsets.only(
                        top: 8,
                        bottom: 8,
                        left: 8,
                        right: 40,
                      ),
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isMe
                      ? isSelected
                          ? Colors.blueAccent.withOpacity(0.9)
                          : Colors.blueAccent.withOpacity(0.5)
                      : isSelected
                          ? Colors.black26.withOpacity(0.5)
                          : Colors.black26.withOpacity(0.2),
                ),
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isMe ? "You" : username),
                    Text(
                      message,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        time,
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
