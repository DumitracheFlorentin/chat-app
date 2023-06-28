import 'package:flutter/material.dart';

import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/widgets/utils/users.dart';

class ContactsList extends StatefulWidget {
  const ContactsList({super.key, required this.isEnabledCreatedGroup});

  final bool isEnabledCreatedGroup;

  @override
  State<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  List<Map<String, dynamic>> users = [];
  Map<String, dynamic> currentUser = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getUsers();
  }

  void getCurrentUser() async {
    final userData = await fetchCurrentUser();

    setState(() {
      currentUser = userData;
    });
  }

  void getUsers() async {
    isLoading = true;

    final List<Map<String, dynamic>> allUsers = await fetchAllUsers();

    final List<Map<String, dynamic>> filteredUsers =
        allUsers.where((user) => user['uid'] != currentUser['uid']).toList();

    setState(() {
      users = filteredUsers;
      isLoading = false;
    });
  }

  void handleCheckboxChange(int index, bool value) {
    setState(() {
      users[index]['checked'] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (users.isEmpty) {
      return const Center(
        child: Text('No users found.'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: users.length,
      itemBuilder: (context, index) {
        final Map<String, dynamic> user = users[index];

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user['image_url']),
          ),
          title: Text(user['username']),
          trailing: widget.isEnabledCreatedGroup
              ? Checkbox(
                  value: user['checked'] ?? false,
                  onChanged: (value) => {
                        handleCheckboxChange(index, value ?? false),
                      })
              : IconButton(
                  icon: const Icon(Icons.chat),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => ChatScreen(
                          currentUser: currentUser,
                          secondUser: user,
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
