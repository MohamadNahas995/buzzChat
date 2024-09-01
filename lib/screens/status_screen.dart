import 'package:chatty/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

final FirebaseAuth _auth = FirebaseAuth.instance;

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  File? _userImageFile;
  void sumbitImage() async {
    if (_userImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick an image.'),
        ),
      );
      return;
    }
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('status_images')
        .child('${_auth.currentUser!.displayName}.jpg');
    await storageRef.putFile(_userImageFile!);

    final imageUrl = await storageRef.getDownloadURL();
    FirebaseFirestore.instance
        .collection('status')
        .doc(_auth.currentUser!.displayName)
        .set({
      'username': _auth.currentUser!.displayName,
      'image_url': imageUrl,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
            child: UserImagePicker(
          radius: 80,
          pickImage: (image) {
            _userImageFile = image;
          },
        )),
        StreamBuilder(
            stream: FirebaseFirestore.instance.collection('status').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No status yet!'),
                );
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Something went wrong!'),
                );
              }
              final status = snapshot.data!.docs;
              return Expanded(
                child: ListView.builder(
                  itemCount: status.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(status[index]['username']),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          status[index]['image_url'],
                        ),
                      ),
                    );
                  },
                ),
              );
            })
      ],
    );
  }
}
