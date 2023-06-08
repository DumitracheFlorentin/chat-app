import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/screens/chat.dart';

final _firebaseAuth = FirebaseAuth.instance;
final _firebaseFs = FirebaseFirestore.instance;

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  Map<String, dynamic> getCurrentUser(users) {
    for (final user in users) {
      if (user['uid'] == _firebaseAuth.currentUser!.uid) {
        return user;
      }
    }

    return {};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: _firebaseFs.collection('users').get(),
      builder: (context, snapshot) {
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

        final filteredUsers = users
            .where(
              (userData) =>
                  userData['uid'] != currentUser['uid'] &&
                  userData['role'] == 'teacher',
            )
            .toList();

        if (users.isEmpty) {
          return const Center(
            child: Text('No teachers found.'),
          );
        }

        return ListView.builder(
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final userData = filteredUsers[index];

            return ListTile(
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
    );
  }
}
