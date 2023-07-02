import 'package:chat_app/utils/encryption.dart';
import 'package:flutter/material.dart';

class UserProfileInfo extends StatelessWidget {
  const UserProfileInfo({super.key, required this.currentUser});

  final Map<String, dynamic> currentUser;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            EncryptionUtils.decryptData(currentUser['image_url']),
            width: 150,
            height: 150,
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            EncryptionUtils.decryptData(currentUser['username']),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 50,
            endIndent: 50,
          ),
        ],
      ),
    );
  }
}
