import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/widgets/chat/chat_messages.dart';
import 'package:chat_app/widgets/chat/new_message.dart';

final _firebaseFs = FirebaseFirestore.instance;

class GroupChat extends StatefulWidget {
  const GroupChat({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  final String? groupId;

  @override
  State<GroupChat> createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  late Future<Map<String, dynamic>?> roomDataFuture;

  @override
  void initState() {
    super.initState();
    roomDataFuture = getRoomData();
  }

  Future<Map<String, dynamic>?> getRoomData() async {
    DocumentSnapshot<Map<String, dynamic>> roomSnapshot =
        await _firebaseFs.collection('rooms').doc(widget.groupId).get();

    final roomData = roomSnapshot.data();

    return roomData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>?>(
          future: roomDataFuture,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return const Text('Error retrieving room data');
            }

            final room = snapshot.data;
            final title =
                room?['name'] ?? 'Group Chat'; // Fallback if title is null

            return Text(title);
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: roomDataFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Error retrieving room data'),
            );
          }

          final room = snapshot.data;

          return Column(
            children: [
              Expanded(
                child: ChatMessages(roomName: room!['id']),
              ),
              NewMessage(roomName: room['id']),
            ],
          );
        },
      ),
    );
  }
}
