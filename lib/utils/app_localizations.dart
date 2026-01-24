import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// We will define SettingsProvider in main.dart or a separate file.
// For now, let's assume it's in main.dart or we'll move it to a proper provider file later.
import '../main.dart';

class AppLocalizations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Journal',
      'home': 'Home',
      'journal': 'Journal',
      'task': 'Task',
      'report': 'Report',
      'setting': 'Setting',
      'todo': 'Todo',
      'note': 'Note',
      'download_share': 'Download Journal now!',
      'app_description':
          'Journal is a custom daily logging app designed to help you track habits, trading, or any activity with fully customizable templates.',
      'font_size_small': 'Small',
      'font_size_medium': 'Medium',
      'font_size_large': 'Large',
      'color_theme': 'Color Theme',
    },
    'id': {
      'app_title': 'Journal',
      'home': 'Beranda',
      'journal': 'Jurnal',
      'task': 'Catatan',
      'report': 'Laporan',
      'setting': 'Pengaturan',
      'todo': 'Todo',
      'note': 'Catatan',
      'download_share': 'Unduh Journal sekarang!',
      'app_description':
          'Journal adalah aplikasi pencatatan harian kustom yang dirancang untuk membantu Anda melacak progres habit, trading, atau aktivitas apa pun dengan template yang dapat disesuaikan sepenuhnya.',
      'font_size_small': 'Kecil',
      'font_size_medium': 'Sederhana',
      'font_size_large': 'Besar',
      'color_theme': 'Tema Warna',
    },
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
