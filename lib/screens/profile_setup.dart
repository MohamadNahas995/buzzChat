import 'package:chatty/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({
    super.key,
    required this.userNameController,
    required this.emailController,
    required this.passwordController,
  });
  final userNameController;
  final emailController;
  final passwordController;

  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;

class _ProfileSetupState extends State<ProfileSetup> {
  File? _userImageFile;
  var _isLoading = false;
  final textController = TextEditingController();
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
        .child('user_images')
        .child('${_auth.currentUser!.uid}.jpg');
    await storageRef.putFile(_userImageFile!);

    final imageUrl = await storageRef.getDownloadURL();

    FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .set({
      'username': widget.userNameController,
      'email': widget.emailController,
      'image_url': imageUrl,
      'status': textController.text,
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Profile'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              UserImagePicker(
                pickImage: (image) {
                  _userImageFile = image;
                },
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter your status',
                    border: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.amber, width: 4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  controller: textController,
                  onChanged: (value) {
                    textController.text = value;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  'please complete your profile  \n by set up an image and status to your profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                    minimumSize: WidgetStatePropertyAll(Size(250, 50)),
                    backgroundColor: WidgetStatePropertyAll(
                        const Color.fromARGB(255, 220, 214, 89))),
                onPressed: sumbitImage,
                child: Text(
                  'Submit',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
    ;
  }
}
