import 'package:chat_app/utils/encryption.dart';
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
  Map<String, dynamic> currentUser = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getUsers();
  }

  void getUsers() async {
    setState(() {
      isLoading = true;
    });

    final List<Map<String, dynamic>> allUsers = await fetchAllUsers();

    final List<Map<String, dynamic>> filteredUsers = allUsers
        .where((user) =>
            EncryptionUtils.decryptData(user['uid']) !=
            _firebaseAuth.currentUser!.uid)
        .toList();

    setState(() {
      users = filteredUsers;
      isLoading = false;
    });
  }

  void getCurrentUser() async {
    final userData = await fetchCurrentUser();

    setState(() {
      currentUser = userData;
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
        currentUser: currentUser,
        isLoading: isLoading,
      ),
    );
  }
}
