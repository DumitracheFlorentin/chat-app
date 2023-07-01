import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/utils/users.dart';

final _firebaseAuth = FirebaseAuth.instance;

class UpdateUsernameModal extends StatefulWidget {
  const UpdateUsernameModal({super.key});

  @override
  State<UpdateUsernameModal> createState() => _UpdateUsernameModalState();
}

class _UpdateUsernameModalState extends State<UpdateUsernameModal> {
  String newUsername = '';
  bool isInvalid = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Username'),
      content: TextField(
        onChanged: (value) {
          setState(() {
            newUsername = value;
            isInvalid = value.length < 3;
          });
        },
        decoration: const InputDecoration(
          labelText: 'New Username - at least 3 characters',
        ),
      ),
      actions: [
        TextButton(
          onPressed: isInvalid
              ? null
              : () async {
                  updateUsernameByUid(
                      _firebaseAuth.currentUser!.uid, newUsername);

                  Navigator.of(context).pop();
                },
          child: const Text('Save'),
        ),
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
