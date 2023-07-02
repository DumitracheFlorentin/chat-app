import 'dart:io';
import 'package:flutter/material.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:chat_app/widgets/auth/user_image_picker.dart';
import 'package:chat_app/widgets/contacts/contacts_list.dart';
import 'package:chat_app/utils/alerts.dart';
import 'package:chat_app/utils/users.dart';

final _firebaseAuth = FirebaseAuth.instance;
final _firebaseFs = FirebaseFirestore.instance;
final _firebaseStorage = FirebaseStorage.instance;

class NewChat extends StatefulWidget {
  const NewChat({super.key});

  @override
  State<NewChat> createState() => _NewChatState();
}

class _NewChatState extends State<NewChat> {
  File? _selectedImage;
  bool isLoading = false;
  bool isEnabled = false;

  TextEditingController groupNameController = TextEditingController();
  List<Map<String, dynamic>> allUsersWithoutCurrent = [];
  Map<String, dynamic> currentUser = {};

  void getUsers() async {
    setState(() {
      isLoading = true;
    });

    final List<Map<String, dynamic>> allUsers = await fetchAllUsers();

    final List<Map<String, dynamic>> filteredUsers = allUsers
        .where((user) => user['uid'] != _firebaseAuth.currentUser!.uid)
        .toList();

    setState(() {
      allUsersWithoutCurrent = filteredUsers;
      isLoading = false;
    });
  }

  void getCurrentUser() async {
    setState(() {
      isLoading = true;
    });

    final userData = await fetchCurrentUser();

    setState(() {
      currentUser = userData;
      isLoading = false;
    });
  }

  Widget showImageOfGroupWidget() {
    if (isEnabled) {
      return UserImagePicker(
        onPickImage: (pickedImage) {
          _selectedImage = pickedImage;
        },
      );
    }

    return const SizedBox(
      height: 0,
      width: 0,
    );
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
    List<Map<String, dynamic>> checkedUsers = allUsersWithoutCurrent
        .where((user) => user['checked'] == true)
        .toList();

    if (checkedUsers.length < 2) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Alert(
              title: 'Error',
              description:
                  'You have to add at least 2 members to create a group');
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

    // add the current user to checkUsers array
    checkedUsers.add(currentUser);

    // create new group
    final newRoom = _firebaseFs.collection('rooms').doc();
    final messagesCollection = newRoom.collection('messages');

    for (var user in checkedUsers) {
      await addConversationToUser(user, newRoom.id);
    }

    // storage user's profile image
    final storageRef =
        _firebaseStorage.ref().child('group_images').child('${newRoom.id}.jpg');

    await storageRef.putFile(_selectedImage!);

    // storage user's profile
    final imageUrl = await storageRef.getDownloadURL();

    await newRoom.set({
      'id': newRoom.id,
      'users': checkedUsers,
      'messagesCollection': messagesCollection.doc(),
      'image': imageUrl,
      'name': groupName,
      'createdAt': Timestamp.now(),
    });

    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    getUsers();
    getCurrentUser();
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
            showImageOfGroupWidget(),
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
                  currentUser: currentUser,
                  isEnabledCreatedGroup: isEnabled,
                  users: allUsersWithoutCurrent,
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
