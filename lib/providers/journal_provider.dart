import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../models/entry.dart';

class JournalProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  List<JournalCategory> _categories = [];
  List<JournalEntry> _entries = [];

  JournalProvider(this._prefs) {
    _loadData();
  }

  List<JournalCategory> get categories => _categories;
  List<JournalEntry> get entries => _entries;

  void _loadData() {
    final categoriesJson = _prefs.getString('journal_categories');
    if (categoriesJson != null) {
      final List<dynamic> decoded = jsonDecode(categoriesJson);
      _categories =
          decoded.map((item) => JournalCategory.fromJson(item)).toList();
    } else {
      _loadDefaultCategories();
    }

    final entriesJson = _prefs.getString('journal_entries');
    if (entriesJson != null) {
      final List<dynamic> decoded = jsonDecode(entriesJson);
      _entries = decoded.map((item) => JournalEntry.fromJson(item)).toList();
    }
    notifyListeners();
  }

  void _loadDefaultCategories() {
    _categories = [
      JournalCategory(
        id: 'cat_trading',
        name: 'Trading',
        iconName: 'lineChart',
        fields: [
          FieldDefinition(id: 'pair', label: 'Pair', type: FieldType.text),
          FieldDefinition(
              id: 'profit', label: 'Profit/Loss', type: FieldType.number),
          FieldDefinition(
            id: 'result',
            label: 'Result (Win/Loss)',
            type: FieldType.checkbox,
            isSuccessIndicator: true,
          ),
          FieldDefinition(
              id: 'chart',
              label: 'Chart Screenshot',
              type: FieldType.imagePair),
        ],
      ),
      JournalCategory(
        id: 'cat_sholat',
        name: 'Sholat',
        iconName: 'checkCircle',
        fields: [
          FieldDefinition(
              id: 'subuh',
              label: 'Subuh',
              type: FieldType.checkbox,
              isSuccessIndicator: true),
          FieldDefinition(
              id: 'dzuhur',
              label: 'Dzuhur',
              type: FieldType.checkbox,
              isSuccessIndicator: true),
          FieldDefinition(
              id: 'ashar',
              label: 'Ashar',
              type: FieldType.checkbox,
              isSuccessIndicator: true),
          FieldDefinition(
              id: 'maghrib',
              label: 'Maghrib',
              type: FieldType.checkbox,
              isSuccessIndicator: true),
          FieldDefinition(
              id: 'isya',
              label: 'Isya',
              type: FieldType.checkbox,
              isSuccessIndicator: true),
        ],
      ),
    ];
    _saveCategories();
  }

  void _saveCategories() {
    final encoded = jsonEncode(_categories.map((c) => c.toJson()).toList());
    _prefs.setString('journal_categories', encoded);
  }

  void _saveEntries() {
    final encoded = jsonEncode(_entries.map((e) => e.toJson()).toList());
    _prefs.setString('journal_entries', encoded);
  }

  void addCategory(JournalCategory category) {
    _categories.add(category);
    _saveCategories();
    notifyListeners();
  }

  void updateCategory(JournalCategory category) {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      _saveCategories();
      notifyListeners();
    }
  }

  void deleteCategory(String id) {
    _categories.removeWhere((c) => c.id == id);
    _entries.removeWhere((e) => e.categoryId == id);
    _saveCategories();
    _saveEntries();
    notifyListeners();
  }

  void addEntry(JournalEntry entry) {
    _entries.add(entry);
    _saveEntries();
    notifyListeners();
  }

  void updateEntry(JournalEntry entry) {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = entry;
      _saveEntries();
      notifyListeners();
    }
  }

  void deleteEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
    _saveEntries();
    notifyListeners();
  }

  List<JournalEntry> getEntriesForCategory(String categoryId) {
    return _entries.where((e) => e.categoryId == categoryId).toList();
  }

  double getSuccessRate(String categoryId) {
    final catEntries = getEntriesForCategory(categoryId);
    if (catEntries.isEmpty) return 0;

    int successCount = catEntries.where((e) => e.isSuccess).length;
    return (successCount / catEntries.length) * 100;
  }

  void generateDummyData() {
    final now = DateTime.now();

    // List of common dummy data for different contexts
    final tradingPairs = ['BTC/USDT', 'ETH/USDT', 'EUR/USD', 'GBP/JPY', 'GOLD'];
    final gymExercises = [
      'Bench Press',
      'Deadlift',
      'Squat',
      'Push Ups',
      'Running'
    ];
    final notes = [
      'Good session today',
      'Followed the plan',
      'Need to improve',
      'Feeling great'
    ];

    for (var cat in _categories) {
      // Create 5 entries for each category over the last 5 days
      for (int i = 0; i < 5; i++) {
        final timestamp = now.subtract(Duration(days: i, hours: i * 2));
        final values = <String, dynamic>{};
        bool entrySuccess = true;

        for (var field in cat.fields) {
          final label = field.label.toLowerCase();
          final categoryName = cat.name.toLowerCase();

          if (field.type == FieldType.checkbox) {
            values[field.id] = (i % 2 == 0);
          } else if (field.type == FieldType.number) {
            if (categoryName.contains('trading') || label.contains('profit')) {
              values[field.id] = (100.0 + (i * 25)) * (i % 2 == 0 ? 1 : -0.5);
            } else if (categoryName.contains('gym') ||
                label.contains('weight')) {
              values[field.id] = 60.0 + (i * 2);
            } else {
              values[field.id] = 10.0 + i;
            }
          } else if (field.type == FieldType.text) {
            if (categoryName.contains('trading') || label.contains('pair')) {
              values[field.id] = tradingPairs[i % tradingPairs.length];
            } else if (categoryName.contains('gym') ||
                label.contains('exercise')) {
              values[field.id] = gymExercises[i % gymExercises.length];
            } else {
              values[field.id] = notes[i % notes.length];
            }
          }

          if (field.isSuccessIndicator && values[field.id] == false) {
            entrySuccess = false;
          }
        }

        addEntry(JournalEntry(
          id: 'dummy_${timestamp.millisecondsSinceEpoch}_${cat.id}',
          categoryId: cat.id,
          timestamp: timestamp,
          values: values,
          isSuccess: entrySuccess,
        ));
      }
    }
  }

  String exportData() {
    final Map<String, dynamic> data = {
      'categories': _categories.map((c) => c.toJson()).toList(),
      'entries': _entries.map((e) => e.toJson()).toList(),
      'version': '1.0.0',
      'exportDate': DateTime.now().toIso8601String(),
    };
    return jsonEncode(data);
  }

  bool importData(String jsonString) {
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);

      if (decoded.containsKey('categories')) {
        final List<dynamic> catList = decoded['categories'];
        _categories =
            catList.map((item) => JournalCategory.fromJson(item)).toList();
        _saveCategories();
      }

      if (decoded.containsKey('entries')) {
        final List<dynamic> entryList = decoded['entries'];
        _entries =
            entryList.map((item) => JournalEntry.fromJson(item)).toList();
        _saveEntries();
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error importing data: $e');
      return false;
    }
  }

  void clearAllData() {
    _entries.clear();
    _saveEntries();
    notifyListeners();
  }
}
