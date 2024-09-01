import 'package:chatty/noNeed/chat.dart';
import 'package:chatty/screens/chat_page.dart';
import 'package:chatty/screens/chats_screen.dart';
import 'package:chatty/screens/status_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    ChatsScreen(),
    StatusScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(children: [
          Column(
            children: [
              Center(
                  child: SizedBox(
                height: 242,
                child: DrawerHeader(
                  child: Image.asset('assets/chat.png'),
                ),
              )),
            ],
          ),
          TextButton.icon(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              label: Text('Logout'),
              icon: Icon(Icons.exit_to_app)),
        ]),
      ),
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Text(_selectedIndex == 1 ? 'Status' : 'Chats'),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flip_camera_android_sharp),
            label: 'Status',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}
