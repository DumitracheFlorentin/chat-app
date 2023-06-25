import 'package:chat_app/screens/new_chat.dart';
import 'package:chat_app/screens/profile.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/screens/rooms.dart';
import 'package:chat_app/screens/contacts.dart';

import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  int _screenIndex = 0;

  void _selectScreen(int index) {
    setState(() {
      _screenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activeScreen = RoomsScreen(onSelectContacts: _selectScreen);
    String activeScreenTitle = 'Conversations';

    if (_screenIndex == 1) {
      activeScreen = const ContactsScreen();
      activeScreenTitle = 'Contacts';
    }

    if (_screenIndex == 2) {
      activeScreen = const ProfileScreen();
      activeScreenTitle = 'Profile';
    }

    IconData _getAppBarIcon() {
      if (_screenIndex == 0) {
        return Icons.search;
      } else if (_screenIndex == 1) {
        return Icons.add; // Use different icon for index 1 (Contacts)
      } else if (_screenIndex == 2) {
        return Icons.logout; // Use different icon for index 2 (Profile)
      } else {
        return Icons.add; // Default to add icon
      }
    }

    void _handleAppBarAction() {
      if (_screenIndex == 0) {
      } else if (_screenIndex == 1) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => const NewChat(),
          ),
        );
      } else if (_screenIndex == 2) {
        _firebase.signOut();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          activeScreenTitle,
        ),
        actions: [
          IconButton(
            onPressed: _handleAppBarAction,
            icon: Icon(_getAppBarIcon()),
          ),
        ],
      ),
      body: activeScreen,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectScreen,
        currentIndex: _screenIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
