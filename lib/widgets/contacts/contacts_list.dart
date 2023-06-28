import 'package:flutter/material.dart';
import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/utils/users.dart';

class ContactsList extends StatefulWidget {
  const ContactsList({
    super.key,
    required this.isEnabledCreatedGroup,
    required this.users,
    required this.isLoading,
  });

  final bool isEnabledCreatedGroup;
  final List<Map<String, dynamic>> users;
  final bool isLoading;

  @override
  State<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  Map<String, dynamic> currentUser = {};

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    final userData = await fetchCurrentUser();

    setState(() {
      currentUser = userData;
    });
  }

  void handleCheckboxChange(int index, bool value) {
    setState(() {
      widget.users[index]['checked'] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (widget.users.isEmpty) {
      return const Center(
        child: Text('No users found.'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.users.length,
      itemBuilder: (context, index) {
        final Map<String, dynamic> user = widget.users[index];

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user['image_url']),
          ),
          title: Text(user['username']),
          trailing: widget.isEnabledCreatedGroup
              ? Checkbox(
                  value: user['checked'] ?? false,
                  onChanged: (value) {
                    setState(() {
                      handleCheckboxChange(index, value ?? false);
                    });
                  },
                )
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
