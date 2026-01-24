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

class TodoProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  List<TodoItem> _todos = [];
  final _uuid = const Uuid();

  TodoProvider(this._prefs) {
    _loadData();
  }

  List<TodoItem> get todos => _todos;

  void _loadData() {
    final todosJson = _prefs.getString('task_todos');
    if (todosJson != null) {
      final List<dynamic> decoded = jsonDecode(todosJson);
      _todos = decoded.map((item) => TodoItem.fromJson(item)).toList();
    }
    notifyListeners();
  }

  void _saveTodos() {
    final encoded = jsonEncode(_todos.map((t) => t.toJson()).toList());
    _prefs.setString('task_todos', encoded);
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
}
