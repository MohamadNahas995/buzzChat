import 'package:chatty/screens/chats_screen.dart';
import 'package:chatty/screens/status_add_screen.dart';
import 'package:chatty/screens/status_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const ChatsScreen(),
    const StatusScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _selectedIndex == 0
          ? null
          : FloatingActionButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const StatusAddScreen())),
              child: const Icon(Icons.add)),
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
              label: const Text('Logout'),
              icon: const Icon(Icons.exit_to_app)),
        ]),
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 245, 211, 161),
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
