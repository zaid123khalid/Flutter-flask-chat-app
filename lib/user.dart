import 'package:chat_app_flask/chat.dart';
import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username',
                hintText: 'Enter your username',
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          username: _controller.text,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a username"),
                      ),
                    );
                  }
                },
                child: const Text("Continue")),
          ],
        ),
      ),
    );
  }
}
