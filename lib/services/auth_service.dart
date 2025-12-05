import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _biometricEnabled = true;

  bool get isAuthenticated => _isAuthenticated;
  bool get biometricEnabled => _biometricEnabled;

  AuthService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _biometricEnabled = prefs.getBool('biometric_enabled') ?? true;
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enabled);
    _biometricEnabled = enabled;
    notifyListeners();
  }

  /// Check if device supports biometric authentication
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      debugPrint('Error checking biometrics: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticate() async {
    if (!_biometricEnabled) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }

    try {
      final canCheck = await canCheckBiometrics();
      if (!canCheck) {
        // If biometrics not available, allow access
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access LendLedger',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      _isAuthenticated = authenticated;
      notifyListeners();
      return authenticated;
    } on PlatformException catch (e) {
      debugPrint('Authentication error: $e');
      
      // If there's an error, allow access (fail-open for better UX)
      // In production, you might want to handle this differently
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
  }

  /// Logout
  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Check if biometrics are set up
  Future<bool> isBiometricSetup() async {
    final canCheck = await canCheckBiometrics();
    if (!canCheck) return false;

    final availableBiometrics = await getAvailableBiometrics();
    return availableBiometrics.isNotEmpty;
  }

  /// Get biometric type name for display
  Future<String> getBiometricTypeName() async {
    final biometrics = await getAvailableBiometrics();
    
    if (biometrics.isEmpty) {
      return 'Biometric';
    }
    
    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Iris';
    } else {
      return 'Biometric';
    }
  }
}