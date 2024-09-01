import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker(
      {super.key, required this.radius, required this.pickImage});
  final void Function(File image) pickImage;
  final double radius;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? imageFile = null;
  void pickImage() async {
    final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 200,
        maxWidth: 150,
        maxHeight: 150);
    if (image == null) {
      return;
    }

    setState(() {
      imageFile = File(image.path);
    });

    imageFile = null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CircleAvatar(
        radius: widget.radius,
        backgroundColor: Colors.grey,
        foregroundImage: imageFile == null ? null : FileImage(imageFile!),
        child: ClipOval(
          child: Image.asset('assets/profile.png'),
        ),
      ),
      SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: pickImage,
        icon: const Icon(Icons.image),
        label: const Text(
          'Add image',
        ),
      ),
    ]);
  }
}
