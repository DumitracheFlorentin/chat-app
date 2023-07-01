import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/utils/users.dart';

final _firebaseFs = FirebaseFirestore.instance;

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key, required this.onSelectContacts});

  final Function(int index) onSelectContacts;

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  Future<List<Map<String, dynamic>>> getAllConversations() async {
    final currentUser = await fetchCurrentUser();

    if (currentUser['conversations'] == null) {
      return [];
    }

    final QuerySnapshot roomSnapshot =
        await _firebaseFs.collection('rooms').get();

    final List<Map<String, dynamic>> matchingRooms = roomSnapshot.docs
        .where((roomDoc) => currentUser['conversations'].contains(roomDoc.id))
        .map(
          (roomDoc) => {
            ...roomDoc.data() as Map<String, dynamic>,
            'id': roomDoc.id,
          },
        )
        .toList();

    return matchingRooms;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAllConversations(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Error retrieving room name'),
          );
        }

        final conversations = snapshot.data!;

        if (conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No rooms found. Create one!'),
                TextButton.icon(
                  onPressed: () {
                    widget.onSelectContacts(1);
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
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {},
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    conversations[index]['image'],
                  ),
                ),
                title: Text(conversations[index]['name']),
              ),
            );
          },
        );
      },
    );
  }
}
