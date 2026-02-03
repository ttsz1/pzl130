import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> savePin(String pin) async {
    await _storage.write(key: "user_pin", value: pin);
  }

  static Future<String?> getPin() async {
    return await _storage.read(key: "user_pin");
  }

  static Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: "email", value: email);
    await _storage.write(key: "password", value: password);
  }

  static Future<Map<String, String?>> getCredentials() async {
    final email = await _storage.read(key: "email");
    final password = await _storage.read(key: "password");
    return {"email": email, "password": password};
  }
}
