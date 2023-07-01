import 'package:flutter/material.dart';

import 'package:chat_app/widgets/chat/group_chat/group_chat.utils.dart';

class GroupChat extends StatefulWidget {
  const GroupChat({super.key, required this.groupId});

  final String? groupId;

  @override
  State<GroupChat> createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  late Future<Map<String, dynamic>?> roomDataFuture;

  @override
  void initState() {
    super.initState();
    roomDataFuture = getRoomData(widget.groupId);
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

            final title = snapshot.data?['name'] ?? 'Group Chat';
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

          final Map<String, dynamic>? room = snapshot.data;

          return buildChatContent(room);
        },
      ),
    );
  }
}
