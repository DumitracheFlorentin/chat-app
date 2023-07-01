import 'package:chat_app/widgets/chat/group_chat.dart';
import 'package:chat_app/widgets/chat/simple_chat.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    super.key,
    required this.users,
    required this.groupId,
  });

  final List<dynamic> users;
  final String groupId;

  Widget simpleOrGroupChat() {
    if (users.length > 2) {
      return GroupChat(groupId: groupId);
    }

    return SimpleChat(
      currentUser: users[0],
      secondUser: users[1],
    );
  }

  @override
  Widget build(BuildContext context) {
    return simpleOrGroupChat();
  }
}
