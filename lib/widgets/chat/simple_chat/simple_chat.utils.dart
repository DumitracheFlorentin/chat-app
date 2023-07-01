import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/widgets/chat/chat_messages.dart';
import 'package:chat_app/widgets/chat/new_message.dart';
import 'package:chat_app/utils/users.dart';

final _firebaseFs = FirebaseFirestore.instance;

// Functions
Future<Map<String, dynamic>> checkAndCreateRoom(currentUser, secondUser) async {
  final QuerySnapshot roomSnapshot = await _firebaseFs
      .collection('rooms')
      .where('usersIds', arrayContains: currentUser['uid'])
      .get();

  final List<DocumentSnapshot> matchingDocs = roomSnapshot.docs
      .where((roomDoc) =>
          (roomDoc.data() as Map<String, dynamic>)['users'].length == 2 &&
          (roomDoc.data() as Map<String, dynamic>)['usersIds']
              .contains(secondUser['uid']))
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
      'users': [currentUser, secondUser],
      'usersIds': [currentUser['uid'], secondUser['uid']],
      'messagesCollection': messagesCollection.doc(),
      'createdAt': Timestamp.now(),
    };

    await newRoomRef.set(newRoomData);
    await addConversationToUser(currentUser, newRoomData['id']);
    await addConversationToUser(secondUser, newRoomData['id']);

    return newRoomData;
  }
}

// Widgets
Widget buildChatContent(Map<String, dynamic> room) {
  return Column(
    children: [
      Expanded(
        child: ChatMessages(roomName: room['id']),
      ),
      NewMessage(roomName: room['id']),
    ],
  );
}
