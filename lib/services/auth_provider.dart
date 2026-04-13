import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  List<Child> _children = [];
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  List<Child> get children => _children;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  final prefs = SharedPreferences.getInstance();

  /// Login user with optional remember me
  Future<bool> login(String login, String password, {bool rememberMe = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get FCM token if available
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        print('Could not get FCM token: $e');
      }

      final response = await ApiService.login(login, password, fcmToken: fcmToken);

      if (response['success'] == true) {
        try {
          _user = User.fromJson(response['user'] ?? {});
          
          // Parse children from response
          if (response['children'] is List) {
            _children = (response['children'] as List)
                .map((child) => Child.fromJson(child as Map<String, dynamic>))
                .toList();
          }

          // Save credentials locally ONLY if rememberMe is enabled
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', _user!.id);
          await prefs.setInt('parent_id', _user!.id);
          await prefs.setString('user_name', _user!.nomComplet);

          if (fcmToken != null) {
            final saveTokenResponse = await ApiService.saveFcmToken(_user!.id, fcmToken);
            print('Save FCM token after login response: $saveTokenResponse');
          }
          
          if (rememberMe) {
            await prefs.setString('login', login);
            await prefs.setString('password', password);
            await prefs.setBool('remember_me', true);
            print('✓ Login saved with Remember Me enabled');
          } else {
            // Clear old credentials if remember me is unchecked
            await prefs.remove('login');
            await prefs.remove('password');
            await prefs.setBool('remember_me', false);
            print('✓ Login without Remember Me - credentials cleared');
          }

          _isLoading = false;
          notifyListeners();
          return true;
        } catch (parseError) {
          _errorMessage = 'Error parsing response: $parseError';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = response['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login user with Google Sign-In
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        _errorMessage = 'Google sign-in cancelled';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Get FCM token if available
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        print('Could not get FCM token: $e');
      }

      // Use Google email as login, Google display name as password placeholder
      final response = await ApiService.login(
        googleUser.email, 
        googleUser.displayName ?? 'google_user',
        fcmToken: fcmToken
      );

      if (response['success'] == true) {
        try {
          _user = User.fromJson(response['user'] ?? {});
          
          // Parse children from response
          if (response['children'] is List) {
            _children = (response['children'] as List)
                .map((child) => Child.fromJson(child as Map<String, dynamic>))
                .toList();
          }

          // Save user info locally (don't save password for Google sign-in)
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', _user!.id);
          await prefs.setInt('parent_id', _user!.id);
          await prefs.setString('user_name', _user!.nomComplet);
          await prefs.setBool('is_google_signin', true);
          
          if (fcmToken != null) {
            final saveTokenResponse = await ApiService.saveFcmToken(_user!.id, fcmToken);
            print('Save FCM token after Google sign-in response: $saveTokenResponse');
          }

          _isLoading = false;
          notifyListeners();
          return true;
        } catch (parseError) {
          _errorMessage = 'Error parsing response: $parseError';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = response['message'] ?? 'Google sign-in failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Google sign-in error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    _user = null;
    _children = [];
    final prefs = await SharedPreferences.getInstance();
    final isGoogleSignIn = prefs.getBool('is_google_signin') ?? false;
    
    // Sign out from Google if that's how they signed in
    if (isGoogleSignIn) {
      try {
        await GoogleSignIn().signOut();
      } catch (e) {
        print('Error signing out from Google: $e');
      }
    }
    
    await prefs.clear();
    notifyListeners();
  }

  /// Try to restore session from stored credentials
  Future<bool> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final savedLogin = prefs.getString('login');
      final password = prefs.getString('password');

      if (userId != null && savedLogin != null && password != null) {
        return await login(savedLogin, password);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Reload children list from server (called after adding a new child)
  Future<bool> reloadChildren() async {
    try {
      if (_user == null) return false;
      
      final prefs = await SharedPreferences.getInstance();
      final savedLogin = prefs.getString('login');
      final password = prefs.getString('password');

      if (savedLogin != null && password != null) {
        // Re-login to refresh children list
        return await login(savedLogin, password);
      }
      return false;
    } catch (e) {
      print('Error reloading children: $e');
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
