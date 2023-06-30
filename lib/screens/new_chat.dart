import 'package:chat_app/utils/alerts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/widgets/contacts/contacts_list.dart';
import 'package:chat_app/utils/users.dart';

final _firebaseAuth = FirebaseAuth.instance;
final _firebaseFs = FirebaseFirestore.instance;

class NewChat extends StatefulWidget {
  const NewChat({super.key});

  @override
  State<NewChat> createState() => _NewChatState();
}

class _NewChatState extends State<NewChat> {
  TextEditingController groupNameController = TextEditingController();
  List<Map<String, dynamic>> users = [];
  bool isLoading = false;
  var isEnabled = false;

  void getUsers() async {
    setState(() {
      isLoading = true;
    });

    final List<Map<String, dynamic>> allUsers = await fetchAllUsers();

    final List<Map<String, dynamic>> filteredUsers = allUsers
        .where((user) => user['uid'] != _firebaseAuth.currentUser!.uid)
        .toList();

    setState(() {
      users = filteredUsers;
      isLoading = false;
    });
  }

  Widget showNameOfGroupWidget() {
    if (isEnabled) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: groupNameController,
                decoration: const InputDecoration(
                  labelText: 'Group name',
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox(
      height: 0,
      width: 0,
    );
  }

  Widget showBtnOfGroupWidget() {
    if (isEnabled) {
      return Container(
        margin: const EdgeInsets.only(top: 20.0),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: ElevatedButton(
                  onPressed: createNewGroup,
                  child: const Text('Create group'),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox(
      height: 0,
      width: 0,
    );
  }

  void createNewGroup() async {
    String groupName = groupNameController.text;
    List<Map<String, dynamic>> checkedUsers =
        users.where((user) => user['checked'] == true).toList();

    if (checkedUsers.length < 3) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Alert(
              title: 'Error',
              description: 'You need at least 3 members to create a group');
        },
      );

      return;
    }

    if (groupName.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Alert(
              title: 'Error',
              description: 'You need to assign a name for the group');
        },
      );

      return;
    }

    // create new group
    final newRoom = _firebaseFs.collection('rooms').doc();
    final messagesCollection = newRoom.collection('messages');

    await newRoom.set({
      'users': checkedUsers,
      'messagesCollection': messagesCollection.doc(),
      'image': '',
      'createdAt': Timestamp.now(),
    });

    for (var user in users) {
      await addConversationToUser(user, newRoom.id);
    }

    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Conversation'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      isEnabled = !isEnabled;
                    });
                  },
                  child: Text(isEnabled ? 'Undo' : 'New Group'),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            showNameOfGroupWidget(),
            const Row(
              children: [
                Text(
                  'Contacts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.zero,
                child: ContactsList(
                  isEnabledCreatedGroup: isEnabled,
                  users: users,
                  isLoading: isLoading,
                ),
              ),
            ),
            showBtnOfGroupWidget(),
          ],
        ),
      ),
    );
  }
}
