import 'package:chatty/widgets/message_bubble.dart';
import 'package:chatty/widgets/new_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage(
      {required this.currentUser,
      required this.status,
      required this.otherUser,
      required this.otherUserImage,
      super.key});
  final String currentUser;
  final String otherUser;
  final String otherUserImage;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(children: [
              Text(otherUser),
              Text(
                status,
                style: const TextStyle(fontSize: 12),
              )
            ]),
            const SizedBox(
              width: 15,
            ),
            ClipOval(
              child: Image.network(
                otherUserImage,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
        actions: const [],
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder(
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
                    final allMessages = snapshot.data!.docs;
                    final List<Map<String, dynamic>> conversations = [];

                    for (var i = 0; i < allMessages.length; i++) {
                      if (allMessages[i].data()['sentFor'] == otherUser &&
                              allMessages[i].data()['username'] ==
                                  currentUser ||
                          allMessages[i].data()['sentFor'] == currentUser &&
                              allMessages[i].data()['username'] == otherUser) {
                        conversations.add(allMessages[i].data());
                      }
                    }
                    print(conversations);

                    return ListView.builder(
                        padding: const EdgeInsets.only(
                            bottom: 40, right: 13, left: 13),
                        reverse: true,
                        itemCount: conversations.length,
                        itemBuilder: (context, index) {
                          final chatMessage = conversations[index];
                          final nextChatMessage =
                              index + 1 < conversations.length
                                  ? conversations[index + 1]
                                  : null;
                          final currentMessageUserid = chatMessage['userId'];
                          final nextMessageUserid = nextChatMessage != null
                              ? nextChatMessage['userId']
                              : null;
                          final nextUserIsSame =
                              nextMessageUserid == currentMessageUserid;

                          if (nextUserIsSame) {
                            return MessageBubble.next(
                                message: chatMessage['text'],
                                isMe: currentUser == chatMessage['username']);
                          } else {
                            return MessageBubble.first(
                              message: chatMessage['text'],
                              isMe: currentUser == chatMessage['username'],
                              userImage: chatMessage['userImage'],
                              username: chatMessage['username'],
                            );
                          }
                        });
                  })),
          NewMessage(sentFor: otherUser),
        ],
      ),
    );
  }
}
