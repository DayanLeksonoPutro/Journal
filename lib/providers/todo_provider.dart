import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class TodoItem {
  final String id;
  String text;
  bool isDone;
  final DateTime createdAt;
  int priority; // 1: Low, 2: Medium, 3: High
  String? category;

  TodoItem({
    required this.id,
    required this.text,
    this.isDone = false,
    required this.createdAt,
    this.priority = 1,
    this.category,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isDone': isDone,
        'createdAt': createdAt.toIso8601String(),
        'priority': priority,
        'category': category,
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        id: json['id'],
        text: json['text'],
        isDone: json['isDone'],
        createdAt: DateTime.parse(json['createdAt']),
        priority: json['priority'] ?? 1,
        category: json['category'],
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

  int get doneTodayCount {
    final now = DateTime.now();
    return _todos
        .where((t) =>
            t.isDone &&
            t.createdAt.day == now.day &&
            t.createdAt.month == now.month &&
            t.createdAt.year == now.year)
        .length;
  }

  int get streak {
    // Very simple streak logic: based on 'last completed' date
    // For now we just return a placeholder or implement if we have more historical data
    // Let's just track 'Total Selesai' for now as a badge
    return _todos.where((t) => t.isDone).length;
  }

  void _loadData() {
    final todosJson = _prefs.getString('task_todos');
    if (todosJson != null) {
      final List<dynamic> decoded = jsonDecode(todosJson);
      _todos = decoded.map((item) => TodoItem.fromJson(item)).toList();
      // Sort by priority (high to low) then by date
      _sortTodos();
    }
    notifyListeners();
  }

  void _sortTodos() {
    _todos.sort((a, b) {
      if (a.isDone != b.isDone) {
        return a.isDone ? 1 : -1;
      }
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority);
      }
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  void _saveTodos() {
    final encoded = jsonEncode(_todos.map((t) => t.toJson()).toList());
    _prefs.setString('task_todos', encoded);
  }

  void addTodo(String text, {int? priority, String? category}) {
    String finalTitle = text;
    int finalPriority = priority ?? 1;
    String? finalCategory = category;

    // Smart parsing for prefix
    // ! for high priority
    if (finalTitle.startsWith('! ')) {
      finalPriority = 3;
      finalTitle = finalTitle.substring(2);
    } else if (finalTitle.startsWith('!! ')) {
      finalPriority = 3;
      finalTitle = finalTitle.substring(3);
    }

    // # for category
    final categoryRegex = RegExp(r'#(\w+)\s*');
    final match = categoryRegex.firstMatch(finalTitle);
    if (match != null) {
      finalCategory = match.group(1);
      finalTitle = finalTitle.replaceFirst(match.group(0)!, '').trim();
    }

    _todos.insert(
        0,
        TodoItem(
          id: _uuid.v4(),
          text: finalTitle,
          createdAt: DateTime.now(),
          priority: finalPriority,
          category: finalCategory,
        ));
    _sortTodos();
    _saveTodos();
    notifyListeners();
  }

  void toggleTodo(String id) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      _todos[index].isDone = !_todos[index].isDone;
      _sortTodos();
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
