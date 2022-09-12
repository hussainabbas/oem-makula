import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  static const String TOKEN = "com.app.makula.TOKEN";
  static const String REFRESH_TOKEN = "com.app.makula.REFRESH_TOKEN";
  static const String LOGGED_IN = "com.app.makula.LOGGED_IN";
  static const String USER = "com.app.makula.USER";
  static const String CHAT_CHANNEL_WITH_TOKEN = "com.app.makula.CHAT_CHANNEL_WITH_TOKEN";
  setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }
  getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }
  getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  setData(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return json.decode(prefs.getString(key) ?? "");
  }

  clear() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}