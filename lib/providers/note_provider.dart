import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class NoteItem {
  final String id;
  String title;
  String content;
  DateTime updatedAt;

  NoteItem({
    required this.id,
    this.title = '',
    required this.content,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory NoteItem.fromJson(Map<String, dynamic> json) => NoteItem(
        id: json['id'],
        title: json['title'] ?? '',
        content: json['content'],
        updatedAt: DateTime.parse(json['updatedAt']),
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

  void addNote(String title, String content) {
    _notes.add(NoteItem(
      id: _uuid.v4(),
      title: title,
      content: content,
      updatedAt: DateTime.now(),
    ));
    _saveNotes();
    notifyListeners();
  }

  void updateNote(String id, String title, String content) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index].title = title;
      _notes[index].content = content;
      _notes[index].updatedAt = DateTime.now();
      _saveNotes();
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    _saveNotes();
    notifyListeners();
  }
}
