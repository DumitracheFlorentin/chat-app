import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/screens/chat.dart';

final _firebaseAuth = FirebaseAuth.instance;
final _firebaseFs = FirebaseFirestore.instance;

class ContactsList extends StatelessWidget {
  Map<String, dynamic> getCurrentUser(users) {
    for (final user in users) {
      if (user['uid'] == _firebaseAuth.currentUser!.uid) {
        return user;
      }
    }

    return {};
  }

  List<Map<String, dynamic>> getFilteredUsers(
      List<Map<String, dynamic>> users) {
    final currentUser = getCurrentUser(users);

    if (currentUser['role'] == 'teacher') {
      return users
          .where((userData) => userData['uid'] != currentUser['uid'])
          .toList();
    }

    return users
        .where((userData) =>
            userData['uid'] != currentUser['uid'] &&
            userData['role'] == 'teacher')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero, // Remove horizontal margin
      child: FutureBuilder<QuerySnapshot>(
        future: _firebaseFs.collection('users').get(),
        builder: (context, snapshot) {
          // Rest of the code for building the contacts list
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Error retrieving users'),
            );
          }

          final List<Map<String, dynamic>> users = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          final currentUser = getCurrentUser(users);

          final filteredUsers = getFilteredUsers(users);

          if (users.isEmpty) {
            return const Center(
              child: Text('No teachers found.'),
            );
          }

          return ListView.builder(
            shrinkWrap:
                true, // Allow the ListView to occupy only the necessary space
            padding: EdgeInsets.zero, // Remove default padding
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final userData = filteredUsers[index];

              return ListTile(
                contentPadding: EdgeInsets.zero, // Remove horizontal margin
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    userData['image_url'],
                  ),
                ),
                title: Text(
                  userData['username'],
                ),
                trailing: IconButton(
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
          );
        },
      ),
    );
  }
}
