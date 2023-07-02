import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/widgets/profile/user_profile_actions/user_profile_actions.utils.dart';
import 'package:chat_app/widgets/profile/user_profile_info.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;
          return SingleChildScrollView(
            child: StreamBuilder<DocumentSnapshot>(
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
                      SizedBox(
                        height: isPortrait ? 175 : 0,
                      ),
                      UserProfileInfo(currentUser: currentUser),
                      const SizedBox(height: 8),
                      const UserProfileActions(),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
