import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({required this.sentFor, super.key});

  final String sentFor;
  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _messageController.dispose();
  }

  void submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      print(
        FirebaseAuth.instance.currentUser!.displayName,
      );
      print(
        FirebaseAuth.instance.currentUser!.email,
      );
      print(FirebaseAuth.instance.currentUser!.uid);
      return;
    }
    _messageController.clear();
    FocusScope.of(context).unfocus();
    try {
      await FirebaseFirestore.instance.collection('chat').add({
        'text': enteredMessage,
        'createdAt': Timestamp.now(),
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'username': FirebaseAuth.instance.currentUser!.displayName,
        'userImage': FirebaseAuth.instance.currentUser!.photoURL,
        'sentFor': widget.sentFor
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
              child: TextField(
                  controller: _messageController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Send a message...',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ))),
          IconButton(
            onPressed: submitMessage,
            icon: Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
