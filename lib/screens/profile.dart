import 'package:chat_app/widgets/auth/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final _firebaseStorage = FirebaseStorage.instance;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _selectedImage;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFs = FirebaseFirestore.instance;
  late Stream<DocumentSnapshot> _userStream;
  Map<String, dynamic> currentUser = {};
  String newNickname = '';

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
  }

  void fetchCurrentUser() async {
    final User? user = _firebaseAuth.currentUser;
    if (user != null) {
      _userStream = _firebaseFs.collection('users').doc(user.uid).snapshots();

      final snapshot =
          await _firebaseFs.collection('users').doc(user.uid).get();
      final userData = snapshot.data() as Map<String, dynamic>;

      setState(() {
        currentUser = userData;
      });
    }
  }

  void openChangeNicknameModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Nickname'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                newNickname = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'New Nickname',
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                try {
                  final userUid = currentUser['uid'];
                  final userDocRef =
                      _firebaseFs.collection('users').doc(userUid);

                  await userDocRef.update({'username': newNickname});
                } catch (error) {
                  print('Error updating username: $error');
                }

                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void changeProfileImage(BuildContext context) async {
    if (_selectedImage == null) {
      return;
    }

    // storage user's profile image
    final storageRef = _firebaseStorage
        .ref()
        .child('user_images')
        .child('${currentUser['uid']}.jpg');

    await storageRef.putFile(_selectedImage!);

    // Get the download URL of the new image
    final imageUrl = await storageRef.getDownloadURL();

    // Update the user's document with the new image URL
    final userDocRef = _firebaseFs.collection('users').doc(currentUser['uid']);
    await userDocRef.update({'image_url': imageUrl});

    Navigator.of(context).pop();
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

          final userData = snapshot.data?.data() as Map<String, dynamic>?;

          if (userData != null) {
            currentUser = userData;
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
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Change Profile Image'),
                              UserImagePicker(
                                onPickImage: (pickedImage) {
                                  _selectedImage = pickedImage;
                                },
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  changeProfileImage(context);
                                },
                                child: const Text('Save this Profile Image'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
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
