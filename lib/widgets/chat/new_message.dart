import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firebaseFs = FirebaseFirestore.instance;
final _firebaseAuth = FirebaseAuth.instance;

class NewMessage extends StatefulWidget {
  const NewMessage({super.key, required this.roomName});

  final String roomName;

  @override
  State<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    _messageController.clear();

    final userData = await _firebaseFs
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .get();
    final messageData = {
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': userData.data()!['uid'],
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
    };

    await _firebaseFs
        .collection('rooms')
        .doc(widget.roomName)
        .collection('messages')
        .add(messageData);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 1,
        bottom: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              enableSuggestions: true,
              decoration: const InputDecoration(
                labelText: 'Send a message...',
              ),
            ),
          ),
          IconButton(
            onPressed: _submitMessage,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
