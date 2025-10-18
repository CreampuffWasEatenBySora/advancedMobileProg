import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoaded = false;

  Map<String, dynamic>? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoaded => _isLoaded;

  Future<void> loadUser(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _user = jsonDecode(userJson);
    } else {
      print('functname: loaduser else');
      Navigator.pushNamedAndRemoveUntil(context, '/tioLogin', (route) => false);
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setUser(Map<String, dynamic> user) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user));
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> clearUser(BuildContext context) async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    notifyListeners();
    print('functname: clearuser ');

    // 👇 Push login screen and remove all previous routes
    Navigator.pushNamedAndRemoveUntil(context, '/tioLogin', (route) => false);
  }
}

String getFirstTwoInitials(String name) {
  if (name.isEmpty) {
    return '';
  }

  List<String> words = name.trim().split(' ');
  StringBuffer initials = StringBuffer();

  // Take the first character of the first word
  if (words.isNotEmpty && words[0].isNotEmpty) {
    initials.write(words[0][0]);
  }

  // Take the first character of the second word, if it exists
  if (words.length > 1 && words[1].isNotEmpty) {
    initials.write(words[1][0]);
  }

  return initials
      .toString()
      .toUpperCase(); // Return in uppercase for standard initial display
}
