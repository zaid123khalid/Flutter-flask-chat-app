import 'dart:convert';

import 'package:chat_app_flask/chat.dart';
import 'package:chat_app_flask/http_con.dart';
import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _userController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                  hintText: 'Enter your username',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Room Code',
                  hintText: 'Enter room code',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a room code';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                  child: const Text("Continue"),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      var req = await HttpConnection.joinRoom(
                          _userController.text, _roomController.text);
                      if (req.statusCode == 200) {
                        print(req.body);
                        print(jsonDecode(req.body)["messages"]);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              username: _userController.text,
                              roomCode: _roomController.text,
                              messages: jsonDecode(req.body)["messages"],
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Error joining room"),
                          ),
                        );
                      }
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
