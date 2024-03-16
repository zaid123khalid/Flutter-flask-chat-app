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
    super.key,
    required this.message,
    required this.username,
    required this.time,
    this.isMe = false,
    this.isSelected = false,
    this.alignment = Alignment.centerLeft,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isSelected
          ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
          : Colors.transparent,
      child: Align(
        alignment: alignment,
        child: GestureDetector(
          onLongPress: onLongPress,
          child: IntrinsicWidth(
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
                    ? Theme.of(context).brightness == Brightness.light
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withOpacity(0.7)
                    : Theme.of(context).brightness == Brightness.light
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.7),
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
        ),
      ),
    );
  }
}
