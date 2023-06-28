import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final _firebaseStorage = FirebaseStorage.instance;
final _firebaseFs = FirebaseFirestore.instance;
final _firebaseAuth = FirebaseAuth.instance;

Future fetchCurrentUser() async {
  try {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final DocumentSnapshot snapshot =
          await _firebaseFs.collection('users').doc(user.uid).get();
      final userData = snapshot.data() as Map<String, dynamic>;

      return userData;
    }
  } catch (error) {
    return error;
  }
}

Future fetchAllUsers() async {
  try {
    final QuerySnapshot snapshot = await _firebaseFs.collection('users').get();
    final List<Map<String, dynamic>> fetchedUsers =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    final filteredUsers = fetchedUsers.toList();

    return filteredUsers;
  } catch (error) {
    return error;
  }
}

Future updateUsernameByUid(userUid, newUsername) async {
  try {
    final userDocRef = _firebaseFs.collection('users').doc(userUid);

    await userDocRef.update({'username': newUsername});
  } catch (error) {
    return error;
  }
}

Future updateImageByUid(userUid, imageUrl) async {
  try {
    final userDocRef = _firebaseFs.collection('users').doc(userUid);

    await userDocRef.update({'image_url': imageUrl});
  } catch (error) {
    return error;
  }
}

Future uploadImageProfile(userUid, selectedImage) async {
  try {
    final storageRef =
        _firebaseStorage.ref().child('user_images').child('$userUid.jpg');

    await storageRef.putFile(selectedImage!);

    // Get the download URL of the new image
    final imageUrl = await storageRef.getDownloadURL();

    return imageUrl;
  } catch (error) {
    return error;
  }
}
