import 'package:flutter/material.dart';

import 'package:chat_app/widgets/profile/user_profile_actions/actions/update-profile-photo-modal.dart';
import 'package:chat_app/widgets/profile/user_profile_actions/actions/update-username-modal.dart';

class UserProfileActions extends StatelessWidget {
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
    return Center(
      child: Column(
        children: [
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
  }
}
