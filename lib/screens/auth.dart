import 'package:chatty/screens/chat.dart';
import 'package:chatty/screens/profile_setup.dart';
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

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    print(isValid.toString());
    print(_isLogin.toString());
    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();

    if (_isLogin) {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
    } else {
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      userCredential.user!.updateDisplayName(_userNameController.text);

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProfileSetup(
                emailController: _emailController.text,
                passwordController: _passwordController.text,
                userNameController: _userNameController.text,
              )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
          255, 255, 246, 84), //const Color.fromARGB(255, 255, 246, 84),
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
                color: const Color.fromARGB(255, 250, 244, 198),
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
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                        Color.fromRGBO(244, 221, 180, 1))),
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
