import 'package:chat_app/screens/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RoomsScreen extends StatelessWidget {
  RoomsScreen({super.key, required this.onSelectContacts});

  void Function(int index) onSelectContacts;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('rooms').get(),
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

            final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
            final List<Map<String, dynamic>> rooms = documents
                .map((doc) => doc.data() as Map<String, dynamic>)
                .where((roomData) =>
                    roomData['user1_id'] ==
                        FirebaseAuth.instance.currentUser!.uid ||
                    roomData['user2_id'] ==
                        FirebaseAuth.instance.currentUser!.uid)
                .toList();

            if (rooms.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No rooms found. Create one!'),
                    TextButton.icon(
                      onPressed: () {
                        onSelectContacts(1);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create room'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final roomData = rooms[index];
                var currentUser;
                var secondUser;

                if (roomData['user1_id'] ==
                    FirebaseAuth.instance.currentUser!.uid) {
                  currentUser = {
                    'uid': roomData['user1_id'],
                    'image_url': roomData['user1_image'],
                    'username': roomData['user1_username'],
                  };

                  secondUser = {
                    'uid': roomData['user2_id'],
                    'image_url': roomData['user2_image'],
                    'username': roomData['user2_username'],
                  };
                } else {
                  currentUser = {
                    'uid': roomData['user2_id'],
                    'image_url': roomData['user2_image'],
                    'username': roomData['user2_username'],
                  };

                  secondUser = {
                    'uid': roomData['user1_id'],
                    'image_url': roomData['user1_image'],
                    'username': roomData['user1_username'],
                  };
                }

                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => ChatScreen(
                          currentUser: currentUser,
                          secondUser: secondUser,
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        roomData['user1_id'] ==
                                FirebaseAuth.instance.currentUser!.uid
                            ? roomData['user2_image']
                            : roomData['user1_image'],
                      ),
                    ),
                    title: Text(
                      roomData['user1_id'] ==
                              FirebaseAuth.instance.currentUser!.uid
                          ? roomData['user2_username']
                          : roomData['user1_username'],
                    ),
                  ),
                );
              },
            );
          }),
    );
  }
}
