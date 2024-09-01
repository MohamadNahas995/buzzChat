import 'dart:math';

import 'package:chatty/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

final FirebaseAuth _auth = FirebaseAuth.instance;

class StatusAddScreen extends StatefulWidget {
  const StatusAddScreen({super.key});

  @override
  State<StatusAddScreen> createState() => _StatusAddScreenState();
}

class _StatusAddScreenState extends State<StatusAddScreen> {
  File? _userImageFile;
  final textController = TextEditingController();

  String generateRandomString(int len) {
    var r = Random();
    return String.fromCharCodes(
        List.generate(len, (index) => r.nextInt(33) + 89));
  }

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
        .child('${generateRandomString}.jpg');
    await storageRef.putFile(_userImageFile!);

    final imageUrl = await storageRef.getDownloadURL();
    await FirebaseFirestore.instance.collection('status').add({
      'username': _auth.currentUser!.displayName,
      'userImg': _auth.currentUser!.photoURL,
      'statusText': textController.text,
      'image_url': imageUrl,
      'createdAt': Timestamp.now(),
    });

    textController.clear();

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Status'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Text(
                  'Now you can share your \n status here with other users',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54)),
            ),
            Center(
                child: UserImagePicker(
              radius: 80,
              pickImage: (image) {
                _userImageFile = image;
              },
            )),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: 'whats on your mind?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 30, top: 10, right: 10, left: 10),
              child: Text(
                  'When you submit your status,  it will be displayed for all users',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54)),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: ElevatedButton(
                style: ButtonStyle(
                    padding: WidgetStatePropertyAll(EdgeInsets.only(
                        left: 20, right: 20, top: 10, bottom: 10)),
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25))),
                    minimumSize: WidgetStatePropertyAll(Size(250, 50)),
                    backgroundColor: WidgetStatePropertyAll(
                        const Color.fromARGB(255, 240, 237, 181))),
                onPressed: sumbitImage,
                child: Text(
                  'Submit',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
