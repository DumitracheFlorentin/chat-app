import 'dart:io';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:chat_app/widgets/auth/user_image_picker.dart';
import 'package:chat_app/widgets/utils/users.dart';

final _firebaseAuth = FirebaseAuth.instance;

class UpdateProfilePhotoModal extends StatefulWidget {
  const UpdateProfilePhotoModal({super.key});

  @override
  State<UpdateProfilePhotoModal> createState() =>
      _UpdateProfilePhotoModalState();
}

class _UpdateProfilePhotoModalState extends State<UpdateProfilePhotoModal> {
  File? _selectedImage;

  void changeProfileImage(BuildContext context) async {
    if (_selectedImage == null) {
      return;
    }

    // storage user's profile image
    final imageUrl = await uploadImageProfile(
        _firebaseAuth.currentUser!.uid, _selectedImage);

    // Update the user's document with the new image URL
    await updateImageByUid(_firebaseAuth.currentUser!.uid, imageUrl);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Change Profile Image'),
          const SizedBox(
            height: 20,
          ),
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
  }
}
