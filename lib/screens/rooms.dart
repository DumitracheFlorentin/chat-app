import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/screens/chat.dart';

final _firebaseFs = FirebaseFirestore.instance;
final _firebaseAuth = FirebaseAuth.instance;

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key, required this.onSelectContacts});

  final Function(int index) onSelectContacts;

  List<Map<String, dynamic>> _getFilteredRooms(
      List<Map<String, dynamic>> rooms) {
    for (final room in rooms) {
      final bool isCurrentUserRoom =
          room['user1_id'] == _firebaseAuth.currentUser!.uid;

      room['currentUser'] = {
        'uid': isCurrentUserRoom ? room['user1_id'] : room['user2_id'],
        'image_url':
            isCurrentUserRoom ? room['user1_image'] : room['user2_image'],
        'username':
            isCurrentUserRoom ? room['user1_username'] : room['user2_username'],
      };

      room['secondUser'] = {
        'uid': isCurrentUserRoom ? room['user2_id'] : room['user1_id'],
        'image_url':
            isCurrentUserRoom ? room['user2_image'] : room['user1_image'],
        'username':
            isCurrentUserRoom ? room['user2_username'] : room['user1_username'],
      };
    }

    return rooms.toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: _firebaseFs.collection('rooms').get(),
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

        // get all rooms by currentUser's uid
        final List<Map<String, dynamic>> rooms = snapshot.data!.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .where(
              (roomData) =>
                  roomData['user1_id'] == _firebaseAuth.currentUser!.uid ||
                  roomData['user2_id'] == _firebaseAuth.currentUser!.uid,
            )
            .toList();

        final filteredRooms = _getFilteredRooms(rooms);

        if (filteredRooms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No rooms found. Create one!'),
                TextButton.icon(
                  onPressed: () {
                    onSelectContacts(1);
                  },
                  icon: const Icon(
                    Icons.add,
                  ),
                  label: const Text('Create room'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredRooms.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => ChatScreen(
                      currentUser: filteredRooms[index]['currentUser'],
                      secondUser: filteredRooms[index]['secondUser'],
                    ),
                  ),
                );
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    filteredRooms[index]['secondUser']['image_url'],
                  ),
                ),
                title: Text(filteredRooms[index]['secondUser']['username']),
              ),
            );
          },
        );
      },
    );
  }
}
