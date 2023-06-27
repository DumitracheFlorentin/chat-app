import 'package:flutter/material.dart';

import 'package:chat_app/widgets/contacts/contacts_list.dart';

class NewChat extends StatefulWidget {
  NewChat({super.key});

  @override
  State<NewChat> createState() => _NewChatState();
}

class _NewChatState extends State<NewChat> {
  var isEnabled = false;

  Widget showNameOfGroupWidget() {
    if (isEnabled) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        child: const Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Group name',
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container();
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
                  onPressed: () {},
                  child: const Text('Create group'),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container();
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
                  ),
                ),
              ),
              showBtnOfGroupWidget()
            ],
          ),
        ));
  }
}
