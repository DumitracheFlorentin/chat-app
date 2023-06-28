import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:chat_app/widgets/contacts/contacts_list.dart';
import 'package:chat_app/utils/users.dart';

final _firebaseAuth = FirebaseAuth.instance;

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  void getUsers() async {
    setState(() {
      isLoading = true;
    });

    final List<Map<String, dynamic>> allUsers = await fetchAllUsers();

    final List<Map<String, dynamic>> filteredUsers = allUsers
        .where((user) => user['uid'] != _firebaseAuth.currentUser!.uid)
        .toList();

    setState(() {
      users = filteredUsers;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        right: 4,
      ),
      child: ContactsList(
        isEnabledCreatedGroup: false,
        users: users,
        isLoading: isLoading,
      ),
    );
  }
}
