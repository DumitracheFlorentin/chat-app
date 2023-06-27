import 'package:flutter/material.dart';

import 'package:chat_app/widgets/contacts/contacts_list.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        right: 4,
      ),
      child: const ContactsList(isEnabledCreatedGroup: false),
    );
  }
}
