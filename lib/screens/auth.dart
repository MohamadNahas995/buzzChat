import 'package:chatty/screens/chat.dart';
import 'package:chatty/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _isLogin = true;
  File? _userImageFile;
  var _isLoading = false;

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || !_isLogin && _userImageFile == null) {
      return;
    }

    _formKey.currentState!.save();
    try {
      setState(() {
        _isLoading = true;
      });
      if (_isLogin) {
        final userCredential = await _auth.signInWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text);
      } else {
        final userCredential = await _auth.createUserWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text);

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredential.user!.uid}.jpg');

        await storageRef.putFile(_userImageFile!);

        final imageUrl = await storageRef.getDownloadURL();

        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': _userNameController.text,
          'email': _emailController.text,
          'image_url': imageUrl,
        });
        if (_auth.currentUser != null) {
          _auth.currentUser!.updateProfile(
              displayName: _userNameController.text, photoURL: imageUrl);

          _auth.currentUser!.sendEmailVerification();
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The password provided is too weak.')),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('The account already exists for that email.')),
        );
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message ?? 'An unknown error occurred.'),
        ));
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 162, 162),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin:
                    EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
                width: 200,
                child: Image.asset('assets/chat.png'),
              ),
              Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            !_isLogin
                                ? UserImagePicker(
                                    pickImage: (image) {
                                      _userImageFile = image;
                                    },
                                  )
                                : const SizedBox(),
                            !_isLogin
                                ? TextFormField(
                                    onChanged: (value) {
                                      _emailController.text = value;
                                    },
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty ||
                                          value.length < 4) {
                                        return 'Please enter valid username with at least 4 characters';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        label: Text('Username')),
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    onSaved: (value) {
                                      _userNameController.text = value!;
                                    },
                                  )
                                : const SizedBox(),
                            TextFormField(
                              onChanged: (value) {
                                _emailController.text = value;
                              },
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Please enter valid email';
                                }
                                return null;
                              },
                              decoration: InputDecoration(label: Text('Email')),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              onSaved: (value) {
                                _emailController.text = value!;
                              },
                            ),
                            !_isLogin
                                ? TextFormField(
                                    validator: (value) {
                                      if (value != _emailController.text) {
                                        return 'Please enter valid confirm email';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        label: Text('Confirm email')),
                                    keyboardType: TextInputType.emailAddress,
                                    autocorrect: false,
                                    textCapitalization: TextCapitalization.none,
                                    onSaved: (value) {},
                                  )
                                : const SizedBox(),
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter valid password at least 6 characters';
                                }
                                return null;
                              },
                              decoration:
                                  InputDecoration(label: Text('password')),
                              obscureText: true,
                              onSaved: (value) {
                                _passwordController.text = value!;
                              },
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            if (_isLoading)
                              CircularProgressIndicator()
                            else
                              ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                          Color.fromARGB(255, 240, 162, 162))),
                                  onPressed: _submit,
                                  child: Text(_isLogin ? 'Login' : 'Sign up')),
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(_isLogin
                                    ? 'Create new account'
                                    : 'Already have an account'))
                          ],
                        )),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
