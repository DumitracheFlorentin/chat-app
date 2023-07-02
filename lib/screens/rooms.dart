import 'package:chat_app/screens/chat.dart';
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
  Map<String, dynamic> currentUser = {};
  bool isLoading = false;

  Future<List<Map<String, dynamic>>> getAllConversations() async {
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

  Widget getNameOfGroup(conversation, currentUser) {
    if (conversation['users'].length > 2) {
      return Text(conversation['name']);
    }

    final secondUser = conversation['users']
        .where((user) => user['uid'] != currentUser['uid'])
        .toList();

    return Text(secondUser[0]['username']);
  }

  Widget getImageOfGroup(conversation, currentUser) {
    if (conversation['users'].length > 2) {
      return CircleAvatar(
        backgroundImage: NetworkImage(
          conversation['image'],
        ),
      );
    }

    final secondUser = conversation['users']
        .where((user) => user['uid'] != currentUser['uid'])
        .toList();

    return CircleAvatar(
      backgroundImage: NetworkImage(
        secondUser[0]['image_url'],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    setState(() {
      isLoading = true;
    });
    final userData = await fetchCurrentUser();

    setState(() {
      isLoading = false;
      currentUser = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
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

        final conversations = snapshot.data as List<Map<String, dynamic>>;

        if (conversations.isEmpty && !isLoading) {
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
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => ChatScreen(
                      users: conversations[index]['users'],
                      groupId: conversations[index]['id'],
                    ),
                  ),
                );
              },
              child: ListTile(
                leading: getImageOfGroup(conversations[index], currentUser),
                title: getNameOfGroup(conversations[index], currentUser),
              ),
            );
          },
        );
      },
    );
  }
}
