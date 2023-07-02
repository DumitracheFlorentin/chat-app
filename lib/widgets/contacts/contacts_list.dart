import 'package:chat_app/utils/encryption.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/screens/chat.dart';

class ContactsList extends StatefulWidget {
  const ContactsList({
    Key? key,
    required this.isEnabledCreatedGroup,
    required this.currentUser,
    required this.users,
    required this.isLoading,
  }) : super(key: key);

  final bool isEnabledCreatedGroup;
  final Map<String, dynamic> currentUser;
  final List<Map<String, dynamic>> users;
  final bool isLoading;

  @override
  State<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  @override
  Widget build(BuildContext context) {
    final filteredUsers = widget.users.where((user) {
      final decryptedRole = EncryptionUtils.decryptData(user['role']) ?? '';
      return decryptedRole == 'teacher';
    }).toList();

    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (filteredUsers.isEmpty) {
      return const Center(
        child: Text('No teachers found.'),
      );
    }

    void handleCheckboxChange(int index, bool value) {
      setState(() {
        filteredUsers[index]['checked'] = value;
      });
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final Map<String, dynamic> user = filteredUsers[index];

        final decryptedImageUrl =
            EncryptionUtils.decryptData(user['image_url']);
        final decryptedUsername = EncryptionUtils.decryptData(user['username']);

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundImage: NetworkImage(decryptedImageUrl),
          ),
          title: Text(decryptedUsername),
          trailing:
              EncryptionUtils.decryptData(widget.currentUser['role']) == 'guest'
                  ? const SizedBox(
                      height: 0,
                      width: 0,
                    )
                  : widget.isEnabledCreatedGroup
                      ? Checkbox(
                          value: user['checked'] as bool? ?? false,
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
                                  users: [
                                    widget.currentUser,
                                    user,
                                  ],
                                  groupId: '',
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
