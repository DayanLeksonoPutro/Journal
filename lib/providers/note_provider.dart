import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class NoteItem {
  final String id;
  String title;
  String content;
  List<String> tags;
  DateTime updatedAt;
  bool isBookmarked;

  NoteItem({
    required this.id,
    this.title = '',
    required this.content,
    this.tags = const [],
    required this.updatedAt,
    this.isBookmarked = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'tags': tags,
        'updatedAt': updatedAt.toIso8601String(),
        'isBookmarked': isBookmarked,
      };

  factory NoteItem.fromJson(Map<String, dynamic> json) => NoteItem(
        id: json['id'],
        title: json['title'] ?? '',
        content: json['content'],
        tags: List<String>.from(json['tags'] ?? []),
        updatedAt: DateTime.parse(json['updatedAt']),
        isBookmarked: json['isBookmarked'] ?? false,
      );
}

class NoteProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  List<NoteItem> _notes = [];
  final _uuid = const Uuid();

  NoteProvider(this._prefs) {
    _loadData();
  }

  List<NoteItem> get notes => _notes;

  int get streakCount => _prefs.getInt('note_streak_count') ?? 0;
  DateTime? get lastWriteDate {
    final dateStr = _prefs.getString('note_last_write_date');
    return dateStr != null ? DateTime.parse(dateStr) : null;
  }

  void _updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = lastWriteDate;

    if (lastDate == null) {
      _prefs.setInt('note_streak_count', 1);
    } else {
      final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final difference = today.difference(lastDay).inDays;

      if (difference == 1) {
        _prefs.setInt('note_streak_count', streakCount + 1);
      } else if (difference > 1) {
        _prefs.setInt('note_streak_count', 1);
      }
    }
    _prefs.setString('note_last_write_date', now.toIso8601String());
    notifyListeners();
  }

  void _loadData() {
    final notesJson = _prefs.getString('task_notes');
    if (notesJson != null) {
      final List<dynamic> decoded = jsonDecode(notesJson);
      _notes = decoded.map((item) => NoteItem.fromJson(item)).toList();
    }
    notifyListeners();
  }

  void _saveNotes() {
    final encoded = jsonEncode(_notes.map((n) => n.toJson()).toList());
    _prefs.setString('task_notes', encoded);
  }

  List<String> _parseTags(String content) {
    final regExp = RegExp(r'#(\w+)');
    return regExp.allMatches(content).map((m) => m.group(1)!).toSet().toList();
  }

  void addNote(String title, String content) {
    _notes.insert(
        0,
        NoteItem(
          id: _uuid.v4(),
          title: title,
          content: content,
          tags: _parseTags(content),
          updatedAt: DateTime.now(),
        ));
    _saveNotes();
    _updateStreak();
    notifyListeners();
  }

  void updateNote(String id, String title, String content) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index].title = title;
      _notes[index].content = content;
      _notes[index].tags = _parseTags(content);
      _notes[index].updatedAt = DateTime.now();
      _saveNotes();
      _updateStreak();
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    _saveNotes();
    notifyListeners();
  }

  void toggleBookmark(String id) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index].isBookmarked = !_notes[index].isBookmarked;
      _saveNotes();
      notifyListeners();
    }
  }
}
