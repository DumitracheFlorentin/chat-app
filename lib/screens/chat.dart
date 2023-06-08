import 'package:chat_app/widgets/chat/chat_messages.dart';
import 'package:chat_app/widgets/chat/new_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.currentUser,
    required this.secondUser,
  });

  final currentUser;
  final secondUser;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Future<String> roomNameFuture;

  @override
  void initState() {
    super.initState();
    roomNameFuture = checkAndCreateRoom(widget.currentUser, widget.secondUser);
  }

  Future<String> checkAndCreateRoom(user1, user2) async {
    List<String> userIds = [user1['uid'], user2['uid']];
    userIds.sort();

    String roomName = '${userIds[0]}_${userIds[1]}';

    var roomQuery = FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: roomName)
        .limit(1);

    var roomSnapshot = await roomQuery.get();

    if (roomSnapshot.docs.isNotEmpty) {
      // Room exists
      // Perform any additional logic if needed
    } else {
      // Room doesn't exist
      // Create a new room using roomName and the user IDs
      var newRoom =
          FirebaseFirestore.instance.collection('rooms').doc(roomName);

      var messagesCollection = newRoom.collection('messages');

      await newRoom.set({
        'name': roomName,
        'user1_id': user1['uid'],
        'user2_id': user2['uid'],
        'user1_image': user1['image_url'],
        'user2_image': user2['image_url'],
        'user1_username': user1['username'],
        'user2_username': user2['username'],
        'messagesCollection': messagesCollection.doc(),
      });
    }

    return roomName;
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

          final roomName = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ChatMessages(
                  roomName: roomName,
                ),
              ),
              NewMessage(
                roomName: roomName,
              ),
            ],
          );
        },
      ),
    );
  }
}
