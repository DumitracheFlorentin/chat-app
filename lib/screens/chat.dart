import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/widgets/chat/new_message.dart';
import 'package:chat_app/widgets/chat/chat_messages.dart';

final _firebaseFs = FirebaseFirestore.instance;

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.currentUser,
    required this.secondUser,
  });

  final Map<String, dynamic> currentUser;
  final Map<String, dynamic> secondUser;

  @override
  State<ChatScreen> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  late Future<String> roomNameFuture;

  @override
  void initState() {
    super.initState();
    roomNameFuture = checkAndCreateRoom(widget.currentUser, widget.secondUser);
  }

  Future<String> checkAndCreateRoom(firstUser, secondUser) async {
    List<String> userIds = [firstUser['uid'], secondUser['uid']];
    userIds.sort();

    String roomId = '${userIds[0]}_${userIds[1]}';

    var roomSnapshot = await _firebaseFs
        .collection('rooms')
        .where(
          'name',
          isEqualTo: roomId,
        )
        .limit(1)
        .get();

    if (!roomSnapshot.docs.isNotEmpty) {
      var newRoom = _firebaseFs.collection('rooms').doc(roomId);

      var messagesCollection = newRoom.collection('messages');

      await newRoom.set({
        'name': roomId,
        'user1_id': firstUser['uid'],
        'user2_id': secondUser['uid'],
        'user1_image': firstUser['image_url'],
        'user2_image': secondUser['image_url'],
        'user1_username': firstUser['username'],
        'user2_username': secondUser['username'],
        'messagesCollection': messagesCollection.doc(),
      });
    }

    return roomId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.secondUser['username']),
      ),
      body: FutureBuilder<String>(
        future: roomNameFuture,
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

          final room = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ChatMessages(roomName: room),
              ),
              NewMessage(roomName: room),
            ],
          );
        },
      ),
    );
  }
}
