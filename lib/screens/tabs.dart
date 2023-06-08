import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/screens/contacts.dart';
import 'package:chat_app/screens/rooms.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = RoomsScreen(
      onSelectContacts: _selectPage,
    );
    var activePageTitle = 'Conversations';

    if (_selectedPageIndex == 1) {
      activePage = const ContactsScreen();
      activePageTitle = 'Contacts';
    }

    return Scaffold(
      appBar: AppBar(title: Text(activePageTitle), actions: [
        IconButton(
          onPressed: () {
            FirebaseAuth.instance.signOut();
          },
          icon: Icon(Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary),
        ),
      ]),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
        ],
      ),
    );
  }
}
