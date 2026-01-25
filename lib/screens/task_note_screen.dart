import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:intl/intl.dart';
import '../providers/todo_provider.dart';
import '../providers/note_provider.dart';
import '../utils/app_localizations.dart';
import 'note_editor_screen.dart';

enum TaskNoteMode { todo, note }

class TaskNoteScreen extends StatefulWidget {
  const TaskNoteScreen({super.key});

  @override
  State<TaskNoteScreen> createState() => _TaskNoteScreenState();
}

class _TaskNoteScreenState extends State<TaskNoteScreen> {
  TaskNoteMode _currentMode = TaskNoteMode.todo;
  final _textController = TextEditingController();
  int _selectedPriority = 1;
  String? _selectedCategory;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addTodoItem() {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    if (_textController.text.isEmpty) return;

    provider.addTodo(
      _textController.text,
      priority: _selectedPriority,
      category: _selectedCategory,
    );
    _textController.clear();
    _selectedPriority = 1;
    _selectedCategory = null;
    Navigator.pop(context);
    HapticFeedback.mediumImpact();
  }

  void _showAddTodoDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tambah Task',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: iconoir.Xmark(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _textController,
                autofocus: true,
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'Apa yang ingin dikerjakan?',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onSubmitted: (_) => _addTodoItem(),
              ),
              const SizedBox(height: 16),
              const Text('Priority',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _PriorityChip(
                    label: 'Low',
                    value: 1,
                    isSelected: _selectedPriority == 1,
                    onSelected: (v) =>
                        setModalState(() => _selectedPriority = 1),
                  ),
                  const SizedBox(width: 8),
                  _PriorityChip(
                    label: 'Medium',
                    value: 2,
                    isSelected: _selectedPriority == 2,
                    onSelected: (v) =>
                        setModalState(() => _selectedPriority = 2),
                  ),
                  const SizedBox(width: 8),
                  _PriorityChip(
                    label: 'High',
                    value: 3,
                    isSelected: _selectedPriority == 3,
                    onSelected: (v) =>
                        setModalState(() => _selectedPriority = 3),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _addTodoItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Simpan Task',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _openNoteEditor([NoteItem? note]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(note: note),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(AppLocalizations.of(context, 'task')),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _ModeToggleButton(
                    icon: iconoir.CheckCircle(
                      color: Theme.of(context).colorScheme.primary,
                      width: 16,
                      height: 16,
                    ),
                    label: 'Todo',
                    isSelected: _currentMode == TaskNoteMode.todo,
                    onTap: () {
                      setState(() => _currentMode = TaskNoteMode.todo);
                      HapticFeedback.selectionClick();
                    },
                  ),
                  _ModeToggleButton(
                    icon: iconoir.Notes(
                      color: Theme.of(context).colorScheme.primary,
                      width: 16,
                      height: 16,
                    ),
                    label: 'Note',
                    isSelected: _currentMode == TaskNoteMode.note,
                    onTap: () {
                      setState(() => _currentMode = TaskNoteMode.note);
                      HapticFeedback.selectionClick();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        elevation: 0,
        bottom: _currentMode == TaskNoteMode.todo
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: Consumer<TodoProvider>(
                  builder: (context, provider, _) {
                    final todos = provider.todos;
                    final doneCount = todos.where((t) => t.isDone).length;
                    final totalCount = todos.length;
                    final double progress =
                        totalCount == 0 ? 0 : doneCount / totalCount;

                    return LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(progress == 1.0
                          ? Colors.green
                          : Theme.of(context).primaryColor),
                    );
                  },
                ),
              )
            : null,
      ),
      body: _currentMode == TaskNoteMode.todo
          ? _buildTodoView()
          : _buildNoteView(),
      floatingActionButton: FloatingActionButton(
        onPressed: _currentMode == TaskNoteMode.todo
            ? _showAddTodoDialog
            : () => _openNoteEditor(),
        child: iconoir.Plus(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTodoView() {
    final provider = Provider.of<TodoProvider>(context);
    final todos = provider.todos;

    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconoir.TaskList(
              width: 100,
              height: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Belum ada task.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hidupmu terlalu santai 😌',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 0),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return Dismissible(
          key: ValueKey(todo.id),
          background: Container(
            color: Colors.green.withOpacity(0.8),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const iconoir.Check(color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.red.withOpacity(0.8),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const iconoir.Bin(color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              provider.toggleTodo(todo.id);
              HapticFeedback.lightImpact();
              return false;
            }
            return true;
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              provider.deleteTodo(todo.id);
              HapticFeedback.mediumImpact();
            }
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: GestureDetector(
              onTap: () {
                provider.toggleTodo(todo.id);
                HapticFeedback.lightImpact();
              },
              child: todo.isDone
                  ? const iconoir.CheckCircle(color: Colors.green)
                  : iconoir.Circle(
                      color: todo.priority == 3
                          ? Colors.red
                          : todo.priority == 2
                              ? Colors.orange
                              : Colors.grey),
            ),
            title: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Row(
                key: ValueKey('${todo.id}_${todo.isDone}'),
                children: [
                  Expanded(
                    child: Text(
                      todo.text,
                      style: TextStyle(
                        decoration:
                            todo.isDone ? TextDecoration.lineThrough : null,
                        color: todo.isDone ? Colors.grey : null,
                        fontWeight: todo.priority == 3
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (todo.category != null)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '#${todo.category}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            subtitle: Text(
              'Dibuat: ${_formatDate(todo.createdAt)}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoteView() {
    final provider = Provider.of<NoteProvider>(context);
    final notes = provider.notes;

    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconoir.Notes(
              width: 100,
              height: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Belum ada catatan.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai catat ide-idemu! 💡',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openNoteEditor(note),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (note.title.isNotEmpty)
                              Text(
                                note.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            if (note.title.isNotEmpty)
                              const SizedBox(height: 4),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          provider.toggleBookmark(note.id);
                        },
                        child: note.isBookmarked
                            ? const iconoir.Bookmark(
                                color: Colors.amber,
                                width: 18,
                                height: 18,
                              )
                            : const iconoir.Bookmark(
                                color: Colors.grey,
                                width: 18,
                                height: 18,
                              ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Text(
                      note.content,
                      maxLines: note.title.isEmpty ? 5 : 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.tags.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: note.tags
                          .take(3)
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 4),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _ModeToggleButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeToggleButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final int value;
  final bool isSelected;
  final Function(int) onSelected;

  const _PriorityChip({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    if (value == 2) color = Colors.orange;
    if (value == 3) color = Colors.red;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onSelected(value),
      selectedColor: color.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? color : Colors.grey[300]!,
      ),
    );
  }
}
