import 'package:chat_app/screens/chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var currentUserData;

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('users').get(),
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

        final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
        final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
        final List<Map<String, dynamic>> users =
            documents.map((doc) => doc.data() as Map<String, dynamic>).toList();

        for (final user in users) {
          if (user['uid'] == currentUserUid) {
            currentUserData = user;
          }
        }

        final filteredUsers = users
            .where((userData) =>
                userData['uid'] != currentUserUid &&
                userData['role'] == 'teacher')
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
              title: Text(userData['username']),
              trailing: IconButton(
                icon: const Icon(Icons.chat),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => ChatScreen(
                        currentUser: currentUserData,
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
