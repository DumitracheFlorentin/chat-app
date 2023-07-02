import 'package:encrypt/encrypt.dart';

class EncryptionUtils {
  static final key = Key.fromLength(32);
  static final iv = IV.fromLength(16);
  static final encrypter = Encrypter(AES(key));

  static String encryptData(String data) {
    final encryptedData = encrypter.encrypt(data, iv: iv);
    return encryptedData.base64;
  }

  static String decryptData(String encryptedData) {
    final encrypted = Encrypted.fromBase64(encryptedData);
    final decryptedData = encrypter.decrypt(encrypted, iv: iv);
    return decryptedData;
  }
}
