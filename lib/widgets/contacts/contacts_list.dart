import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/screens/chat.dart';

final _firebaseAuth = FirebaseAuth.instance;
final _firebaseFs = FirebaseFirestore.instance;

class ContactsList extends StatefulWidget {
  const ContactsList({super.key, required this.isEnabledCreatedGroup});

  final bool isEnabledCreatedGroup;

  @override
  _ContactsListState createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  List<Map<String, dynamic>> users = [];
  Map<String, dynamic> currentUser = {};

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
    getUsers();
  }

  void fetchCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final DocumentSnapshot snapshot =
            await _firebaseFs.collection('users').doc(user.uid).get();
        final userData = snapshot.data() as Map<String, dynamic>;

        setState(() {
          currentUser = userData;
        });
      }
    } catch (error) {
      print('Error retrieving current user: $error');
    }
  }

  void getUsers() async {
    try {
      final QuerySnapshot snapshot =
          await _firebaseFs.collection('users').get();
      final List<Map<String, dynamic>> fetchedUsers = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        users = fetchedUsers;
      });
    } catch (error) {
      print('Error retrieving users: $error');
    }
  }

  void handleCheckboxChange(int index, bool value) {
    setState(() {
      users[index]['checked'] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(
        child: Text('No users found.'),
      );
    }

    return Container(
      padding: EdgeInsets.zero,
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: users.length,
        itemBuilder: (context, index) {
          final userData = users[index];

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundImage: NetworkImage(userData['image_url']),
            ),
            title: Text(userData['username']),
            trailing: widget.isEnabledCreatedGroup
                ? Checkbox(
                    value: userData['checked'] ?? false,
                    onChanged: (value) => {
                          handleCheckboxChange(index, value ?? false),
                        })
                : IconButton(
                    icon: const Icon(Icons.chat),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => ChatScreen(
                            currentUser: currentUser,
                            secondUser: userData,
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
