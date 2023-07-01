import 'package:flutter/material.dart';

import 'package:chat_app/utils/alerts.dart';

// Functions
void showImageProfileAlert(context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const Alert(
        title: 'Image not selected',
        description: 'Please select an image.',
      );
    },
  );
}
