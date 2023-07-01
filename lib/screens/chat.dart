import 'package:chat_app/utils/users.dart';
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
  late Future<Map<String, dynamic>> roomNameFuture;

  @override
  void initState() {
    super.initState();
    roomNameFuture = checkAndCreateRoom();
  }

  Future<Map<String, dynamic>> checkAndCreateRoom() async {
    final QuerySnapshot roomSnapshot = await _firebaseFs
        .collection('rooms')
        .where('usersIds', arrayContains: widget.currentUser['uid'])
        .get();

    final List<DocumentSnapshot> matchingDocs = roomSnapshot.docs
        .where((roomDoc) =>
            (roomDoc.data() as Map<String, dynamic>)['users'].length == 2 &&
            (roomDoc.data() as Map<String, dynamic>)['usersIds']
                .contains(widget.secondUser['uid']))
        .toList();

    if (matchingDocs.isNotEmpty) {
      final DocumentSnapshot roomDoc = matchingDocs.first;
      final Map<String, dynamic> roomData = {
        ...roomDoc.data() as Map<String, dynamic>,
        'id': roomDoc.id,
      };
      return roomData;
    } else {
      final newRoomRef = _firebaseFs.collection('rooms').doc();
      final messagesCollection = newRoomRef.collection('messages');

      final Map<String, dynamic> newRoomData = {
        'id': newRoomRef.id,
        'users': [widget.currentUser, widget.secondUser],
        'usersIds': [widget.currentUser['uid'], widget.secondUser['uid']],
        'messagesCollection': messagesCollection.doc(),
        'createdAt': Timestamp.now(),
      };

      await newRoomRef.set(newRoomData);
      await addConversationToUser(widget.currentUser, newRoomData['id']);
      await addConversationToUser(widget.secondUser, newRoomData['id']);

      return newRoomData;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.secondUser['username']),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
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
                child: ChatMessages(roomName: room['id']),
              ),
              NewMessage(roomName: room['id']),
            ],
          );
        },
      ),
    );
  }
}
