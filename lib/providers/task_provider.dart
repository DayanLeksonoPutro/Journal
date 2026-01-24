import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class TodoItem {
  final String id;
  String text;
  bool isDone;

  TodoItem({required this.id, required this.text, this.isDone = false});

  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'isDone': isDone};
  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        id: json['id'],
        text: json['text'],
        isDone: json['isDone'],
      );
}

class NoteItem {
  final String id;
  String content;
  DateTime updatedAt;

  NoteItem({required this.id, required this.content, required this.updatedAt});

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory NoteItem.fromJson(Map<String, dynamic> json) => NoteItem(
        id: json['id'],
        content: json['content'],
        updatedAt: DateTime.parse(json['updatedAt']),
      );
}

class TaskProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  List<TodoItem> _todos = [];
  List<NoteItem> _notes = [];
  final _uuid = const Uuid();

  TaskProvider(this._prefs) {
    _loadData();
  }

  List<TodoItem> get todos => _todos;
  List<NoteItem> get notes => _notes;

  void _loadData() {
    final todosJson = _prefs.getString('task_todos');
    if (todosJson != null) {
      final List<dynamic> decoded = jsonDecode(todosJson);
      _todos = decoded.map((item) => TodoItem.fromJson(item)).toList();
    }

    final notesJson = _prefs.getString('task_notes');
    if (notesJson != null) {
      final List<dynamic> decoded = jsonDecode(notesJson);
      _notes = decoded.map((item) => NoteItem.fromJson(item)).toList();
    }
    notifyListeners();
  }

  void _saveTodos() {
    final encoded = jsonEncode(_todos.map((t) => t.toJson()).toList());
    _prefs.setString('task_todos', encoded);
  }

  void _saveNotes() {
    final encoded = jsonEncode(_notes.map((n) => n.toJson()).toList());
    _prefs.setString('task_notes', encoded);
  }

  void addTodo(String text) {
    _todos.add(TodoItem(id: _uuid.v4(), text: text));
    _saveTodos();
    notifyListeners();
  }

  void toggleTodo(String id) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      _todos[index].isDone = !_todos[index].isDone;
      _saveTodos();
      notifyListeners();
    }
  }

  void deleteTodo(String id) {
    _todos.removeWhere((t) => t.id == id);
    _saveTodos();
    notifyListeners();
  }

  void addNote(String content) {
    _notes.add(
        NoteItem(id: _uuid.v4(), content: content, updatedAt: DateTime.now()));
    _saveNotes();
    notifyListeners();
  }

  void updateNote(String id, String content) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
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
