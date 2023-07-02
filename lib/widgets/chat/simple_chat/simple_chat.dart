import 'package:chat_app/utils/encryption.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/widgets/chat/simple_chat/simple_chat.utils.dart';

class SimpleChat extends StatefulWidget {
  const SimpleChat({
    super.key,
    required this.currentUser,
    required this.secondUser,
  });

  final Map<String, dynamic> currentUser;
  final Map<String, dynamic> secondUser;

  @override
  State<SimpleChat> createState() => _SimpleChatState();
}

class _SimpleChatState extends State<SimpleChat> {
  late Future<Map<String, dynamic>> roomNameFuture;

  @override
  void initState() {
    super.initState();
    roomNameFuture = checkAndCreateRoom(
      widget.currentUser,
      widget.secondUser,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String secondUserUsername =
        EncryptionUtils.decryptData(widget.secondUser['username']);
    return Scaffold(
      appBar: AppBar(
        title: Text(secondUserUsername),
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

          return buildChatContent(room);
        },
      ),
    );
  }
}
