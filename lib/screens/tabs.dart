import 'package:chat_app/utils/encryption.dart';
import 'package:chat_app/utils/users.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:chat_app/screens/new_chat.dart';
import 'package:chat_app/screens/contacts.dart';
import 'package:chat_app/screens/profile.dart';
import 'package:chat_app/screens/rooms.dart';

final _firebase = FirebaseAuth.instance;

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  Map<String, dynamic> currentUser = {};
  int _screenIndex = 0;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    final userData = await fetchCurrentUser();

    setState(() {
      currentUser = userData;
    });
  }

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

    IconData? getAppBarIcon() {
      if (_screenIndex == 1) {
        return Icons.add;
      }

      return Icons.logout;
    }

    void getAppBarAction() {
      if (_screenIndex == 1) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => const NewChat(),
          ),
        );

        return;
      }

      _firebase.signOut();
    }

    Widget buildAppBarActions() {
      if (_screenIndex == 1 && EncryptionUtils.decryptData(currentUser['role']) == 'teacher') {
        return IconButton(
          onPressed: getAppBarAction,
          icon: Icon(getAppBarIcon()),
        );
      }

      if (_screenIndex == 2) {
        return IconButton(
          onPressed: getAppBarAction,
          icon: Icon(getAppBarIcon()),
        );
      }

      return const SizedBox(
        height: 0,
        width: 0,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          activeScreenTitle,
        ),
        actions: [
          buildAppBarActions(),
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
