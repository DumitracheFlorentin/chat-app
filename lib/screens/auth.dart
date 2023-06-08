import 'package:chat_app/widgets/auth/authForm.dart';
import 'package:chat_app/widgets/auth/authTitle.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: const Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AuthTitle(title: 'Chat App'),
              SizedBox(height: 10),
              AuthForm(),
            ],
          ),
        ),
      ),
    );
  }
}
