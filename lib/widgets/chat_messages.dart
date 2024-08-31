import 'package:chatty/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No messages yet!'),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong!'),
            );
          }
          final messages = snapshot.data!.docs;
          return ListView.builder(
            padding: EdgeInsets.only(bottom: 40, right: 13, left: 13),
            reverse: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final chatMessage = messages[index].data();
              final nextChatMessage = index + 1 < messages.length
                  ? messages[index + 1].data()
                  : null;
              final currentMessageUserid = chatMessage['userId'];
              final nextMessageUserid =
                  nextChatMessage != null ? nextChatMessage['userId'] : null;
              final nextUserIsSame = nextMessageUserid == currentMessageUserid;
              if (nextUserIsSame) {
                return MessageBubble.next(
                    message: chatMessage['text'],
                    isMe: currentUser.uid == chatMessage['userId']);
              } else {
                return MessageBubble.first(
                    username: chatMessage['username'],
                    userImage: chatMessage['userImage'],
                    message: chatMessage['text'],
                    isMe: currentUser.uid == chatMessage['userId']);
              }
            },
          );
        });
  }
}
