import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/widgets/chat/chat_messages.dart';
import 'package:chat_app/widgets/chat/new_message.dart';

final _firebaseFs = FirebaseFirestore.instance;

// Functions
Future<Map<String, dynamic>?> getRoomData(groupId) async {
  DocumentSnapshot<Map<String, dynamic>> roomSnapshot =
      await _firebaseFs.collection('rooms').doc(groupId).get();

  final roomData = roomSnapshot.data();

  return roomData;
}

// Widgets
Widget buildChatContent(Map<String, dynamic>? room) {
  return Column(
    children: [
      Expanded(
        child: ChatMessages(roomName: room!['id']),
      ),
      NewMessage(roomName: room['id']),
    ],
  );
}
