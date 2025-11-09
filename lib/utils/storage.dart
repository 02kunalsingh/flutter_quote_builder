import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static const _kLastQuoteKey = 'last_saved_quote';

  static Future<void> saveQuote(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastQuoteKey, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> loadQuote() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_kLastQuoteKey)) return null;
    final raw = prefs.getString(_kLastQuoteKey)!;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded;
  }
}
