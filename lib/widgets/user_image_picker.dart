import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.pickImage});
  final void Function(File image) pickImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? imageFile;
  void pickImage() async {
    final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: 150,
        maxHeight: 150);
    if (image == null) {
      return;
    }

    setState(() {
      imageFile = File(image.path);
    });
    widget.pickImage(imageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey,
        foregroundImage: imageFile == null ? null : FileImage(imageFile!),
      ),
      TextButton.icon(
        onPressed: pickImage,
        icon: const Icon(Icons.image),
        label: const Text(
          'Add image',
          style: TextStyle(color: Color.fromARGB(255, 242, 138, 130)),
        ),
      ),
    ]);
  }
}
