import 'package:chatty/screens/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No users yet!'),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong!'),
          );
        }

        final users = snapshot.data!.docs;

        return ListView.builder(
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return ChatPage(
                        currentUser:
                            FirebaseAuth.instance.currentUser!.displayName!,
                        otherUser: users[index]['username'],
                        otherUserImage: users[index]['image_url'],
                        status: users[index]['status'],
                      );
                    },
                  ));
                },
                child: ListTile(
                    title: Text(
                      users[index]['username'],
                      textAlign: TextAlign.right,
                    ),
                    subtitle: Text(
                      users[index]['status'],
                      textAlign: TextAlign.right,
                    ),
                    trailing: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(users[index]['image_url']),
                    )),
              );
            },
            itemCount: users.length);
      },
    );
  }
}
