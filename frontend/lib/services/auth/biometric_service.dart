import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  static const String _baseUrl = "http://10.0.2.2:9999"; // Replace if needed

  /// ✅ Used for initial setup after first login
  Future<bool> promptFingerprintSetup() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      return await _auth.authenticate(
        localizedReason: 'Please authenticate to enable fingerprint login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// ✅ Used for déjà logged users to auto-login
  Future<bool> authenticateWithBiometrics({String reason = 'Authenticate to login'}) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// ✅ Shared check method
  Future<bool> isBiometricAvailable() async {
    try {
      return await _auth.canCheckBiometrics && await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  // 🔐 Fetch biometric status from API
  Future<bool> getBiometricStatusFromServer() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final uri = Uri.parse("$_baseUrl/api/cardholders/biometric");

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['enabled'] == true;
    } else {
      throw Exception("❌ Failed to fetch biometric status: ${response.body}");
    }
  }

  // 🔐 Update biometric preference in server
  Future<void> updateBiometricStatusOnServer(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final uri = Uri.parse("$_baseUrl/api/cardholders/biometric");

    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({"enabled": enabled}),
    );

    if (response.statusCode != 200) {
      throw Exception("❌ Failed to update biometric status: ${response.body}");
    }
  }
}
