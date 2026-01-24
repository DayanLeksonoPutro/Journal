import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import '../providers/todo_provider.dart';
import '../utils/app_localizations.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addItem() {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    if (_textController.text.isEmpty) return;

    provider.addTodo(_textController.text);
    _textController.clear();
    Navigator.pop(context);
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Add todo...',
              ),
              onSubmitted: (_) => _addItem(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addItem,
              child: const Text('Add'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context);
    final todos = provider.todos;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context, 'todo')),
      ),
      body: todos.isEmpty
          ? const Center(child: Text('Empty list'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  leading: IconButton(
                    icon: todo.isDone
                        ? const iconoir.CheckCircle(color: Colors.green)
                        : const iconoir.Circle(color: Colors.grey),
                    onPressed: () => provider.toggleTodo(todo.id),
                  ),
                  title: Text(
                    todo.text,
                    style: TextStyle(
                      decoration:
                          todo.isDone ? TextDecoration.lineThrough : null,
                      color: todo.isDone ? Colors.grey : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const iconoir.Bin(width: 18, height: 18),
                    onPressed: () => provider.deleteTodo(todo.id),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const iconoir.EditPencil(),
      ),
    );
  }
}
