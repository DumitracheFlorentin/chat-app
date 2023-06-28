import 'package:chat_app/widgets/utils/profile/update-profile-photo-modal.dart';
import 'package:chat_app/widgets/utils/profile/update-username-modal.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firebaseFs = FirebaseFirestore.instance;
final _firebaseAuth = FirebaseAuth.instance;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Stream<DocumentSnapshot> _userStream;
  Map<String, dynamic> currentUser = {};
  String newNickname = '';

  @override
  void initState() {
    super.initState();
    _userStream = _firebaseFs
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .snapshots();
  }

  void openChangeNicknameModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const UpdateUsernameModal();
      },
    );
  }

  void openChangeProfilePhotoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const UpdateProfilePhotoModal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching user data'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data?.data() as Map<String, dynamic>?;

          if (user != null) {
            currentUser = user;
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  currentUser['image_url'] ?? '',
                  width: 200,
                  height: 200,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  currentUser['username'] ?? '',
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
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    openChangeNicknameModal(context);
                  },
                  child: const Text('Change Nickname'),
                ),
                TextButton(
                  onPressed: () {
                    openChangeProfilePhotoModal(context);
                  },
                  child: const Text('Change Profile Image'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
