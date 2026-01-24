import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/journal_provider.dart';
import '../models/entry.dart';
import 'entry_form_screen.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _addItem() {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    if (_textController.text.isEmpty) return;

    if (_tabController.index == 0) {
      provider.addTodo(_textController.text);
    } else {
      provider.addNote(_textController.text);
    }
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
              decoration: InputDecoration(
                hintText:
                    _tabController.index == 0 ? 'Add todo...' : 'Add note...',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Notes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Text(
                'Todo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Tab(
              child: Text(
                'Notes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodoList(context),
          _buildNotesList(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const iconoir.EditPencil(),
      ),
    );
  }

  Widget _buildTodoList(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final todos = provider.todos;

    if (todos.isEmpty) return const Center(child: Text('Empty list'));

    return ListView.builder(
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
              decoration: todo.isDone ? TextDecoration.lineThrough : null,
              color: todo.isDone ? Colors.grey : null,
            ),
          ),
          trailing: IconButton(
            icon: const iconoir.Bin(width: 18, height: 18),
            onPressed: () => provider.deleteTodo(todo.id),
          ),
        );
      },
    );
  }

  Widget _buildNotesList(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final notes = provider.notes;

    if (notes.isEmpty) return const Center(child: Text('No notes yet'));

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Card(
          elevation: 0,
          color: Colors.yellow.withOpacity(0.2),
          child: InkWell(
            onTap: () {
              _textController.text = note.content;
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
                        decoration:
                            const InputDecoration(hintText: 'Edit note...'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_textController.text.isNotEmpty) {
                            provider.updateNote(note.id, _textController.text);
                            _textController.clear();
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Save'),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
            onLongPress: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const iconoir.Journal(),
                      title: const Text('Convert to Journal Entry'),
                      onTap: () {
                        Navigator.pop(context);
                        _showCategorySelectionDialog(context, note);
                      },
                    ),
                    ListTile(
                      leading: const iconoir.Bin(color: Colors.red),
                      title: const Text('Delete Note',
                          style: TextStyle(color: Colors.red)),
                      onTap: () {
                        provider.deleteNote(note.id);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.content,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd').format(note.updatedAt),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCategorySelectionDialog(BuildContext context, NoteItem note) {
    final journalProvider =
        Provider.of<JournalProvider>(context, listen: false);
    final categories = journalProvider.categories;

    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please create a journal category first.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Category',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return ListTile(
                title: Text(cat.name),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EntryFormScreen(
                        categoryId: cat.id,
                        entry: JournalEntry(
                          id: 'draft',
                          categoryId: cat.id,
                          timestamp: DateTime.now(),
                          values: {
                            if (cat.fields.isNotEmpty)
                              cat.fields.first.id: note.content
                          },
                          isSuccess: false,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
