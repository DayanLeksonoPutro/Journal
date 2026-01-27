import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int _selectedPriority = 1;
  String? _selectedCategory;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addItem() {
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

  void _showAddDialog() {
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
                  hintText: 'Apa yang ingin dikerjakan? (Gunakan ! atau #)',
                  hintStyle: TextStyle(color: Theme.of(context).hintColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                onSubmitted: (_) => _addItem(),
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
                  onPressed: _addItem,
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context);
    final todos = provider.todos;
    final doneCount = todos.where((t) => t.isDone).length;
    final totalCount = todos.length;
    final double progress = totalCount == 0 ? 0 : doneCount / totalCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context, 'todo')),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(progress == 1.0
                ? Colors.green
                : Theme.of(context).primaryColor),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: todos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        iconoir.TaskList(
                          width: 100,
                          height: 100,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Belum ada task.',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hidupmu terlalu santai 😌',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
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
                            return false; // Don't remove from list, just toggle
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
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
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
                                            : Theme.of(context)
                                                .colorScheme
                                                .outline),
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
                                      decoration: todo.isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: todo.isDone
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.5)
                                          : null,
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
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.1),
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
                            style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.outline),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        elevation: 4,
        child: iconoir.Plus(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
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
    Color color = Theme.of(context).colorScheme.outline;
    if (value == 2) color = Colors.orange;
    if (value == 3) color = Colors.red;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onSelected(value),
      selectedColor: color.withOpacity(0.2),
      labelStyle: TextStyle(
        color:
            isSelected ? color : Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color:
            isSelected ? color : Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}
