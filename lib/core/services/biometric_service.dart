import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Checks if the device has biometric hardware and if the user has enrolled any biometrics.
  Future<bool> canUseBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      if (!canAuthenticate) return false;

      // Check if user has actually enrolled biometrics
      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) return false;

      // Ensure fingerprint is among available biometrics (or strong biometrics)
      // Since local_auth might return strong/weak, checking if it's empty is usually enough,
      // but we can be explicit if we only want fingerprint.
      // For general purposes, checking if any biometric is available is sufficient.
      return true;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Authenticates the user with biometrics.
  Future<bool> authenticate({String reason = 'Gunakan fingerprint untuk masuk'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (_) {
      return false;
    }
  }
}
