import 'package:chatty/widgets/chat_messages.dart';
import 'package:chatty/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

final _auth = FirebaseAuth.instance;

class ChatScreen extends StatelessWidget {
  static const routeName = '/chat';

  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                _auth.signOut();
              },
              icon: const Icon(Icons.exit_to_app))
        ],
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(child: ChatMessages()),
          NewMessage(),
        ],
      ),
    );
  }
}
