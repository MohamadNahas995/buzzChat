import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker(
      {super.key,
      required this.radius,
      required this.pickImage,
      required this.isStatus});
  final void Function(File image) pickImage;
  final double radius;
  final bool isStatus;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? imageFile;
  var camera = true;
  void pickImage() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick Image'),
          content: const Text('would you like to use camera or gallery?'),
          actions: [
            TextButton(
                onPressed: () {
                  camera = true;
                  Navigator.of(context).pop();
                },
                child: const Text('Camera')),
            TextButton(
                onPressed: () {
                  camera = false;
                  Navigator.of(context).pop();
                },
                child: const Text('Gallery'))
          ],
        );
      },
    );
    final image = await ImagePicker().pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
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
      widget.isStatus
          ? CircleAvatar(
              radius: widget.radius,
              backgroundColor: Colors.grey,
              foregroundImage: imageFile == null ? null : FileImage(imageFile!),
              child: ClipOval(
                child: Image.asset('assets/profile.png'),
              ),
            )
          : Container(
              child: imageFile == null ? null : Image.file(imageFile!),
            ),
      const SizedBox(height: 20),
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
