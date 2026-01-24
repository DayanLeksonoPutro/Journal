import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // To access SettingsProvider

class AppLocalizations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {'app_title': 'Journal'},
    'id': {'app_title': 'Journal'},
  };

  static String of(BuildContext context, String key) {
    try {
      final language = Provider.of<SettingsProvider>(context).language;
      return _localizedValues[language]?[key] ??
          _localizedValues['en']?[key] ??
          key;
    } catch (e) {
      // Fallback if provider not found (should not happen in this app structure)
      return _localizedValues['id']?[key] ?? key;
    }
  }
}
