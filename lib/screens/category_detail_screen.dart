import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/journal_provider.dart';
import '../models/entry.dart';
import '../models/category.dart';
import '../widgets/habit_heatmap.dart';
import 'entry_form_screen.dart';
import 'template_editor_screen.dart';
import '../utils/app_localizations.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryId;

  const CategoryDetailScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);
    final category =
        journalProvider.categories.firstWhere((c) => c.id == categoryId);
    final entries = journalProvider.getEntriesForCategory(categoryId);

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        actions: [
          IconButton(
            icon: category.isBookmarked
                ? const iconoir.BookmarkSolid(
                    color: Colors.amber,
                  )
                : iconoir.Bookmark(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            onPressed: () {
              final updatedCategory = JournalCategory(
                id: category.id,
                name: category.name,
                iconName: category.iconName,
                fields: category.fields,
                isBookmarked: !category.isBookmarked,
              );
              journalProvider.updateCategory(updatedCategory);
            },
          ),
          IconButton(
            icon: iconoir.EditPencil(
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TemplateEditorScreen(category: category),
                ),
              );
            },
          ),
          IconButton(
            icon: iconoir.Bin(
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context, 'delete_category')),
                  content: const Text(
                      'This will permanently delete this category and all its entries.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context, 'cancel')),
                    ),
                    TextButton(
                      onPressed: () {
                        journalProvider.deleteCategory(categoryId);
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Exit detail screen
                      },
                      child: Text(AppLocalizations.of(context, 'delete'),
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Show habit heatmap if category has habitCheckbox fields
          if (category.fields.any((f) => f.type == FieldType.habitCheckbox))
            ...category.fields
                .where((f) => f.type == FieldType.habitCheckbox)
                .map((field) {
              // Aggregate habit data from all entries
              final habitData = <String, bool>{};
              for (var entry in entries) {
                final fieldValue = entry.values[field.id];
                if (fieldValue is Map) {
                  fieldValue.forEach((key, value) {
                    if (value is bool) {
                      habitData[key.toString()] = value;
                    }
                  });
                }
              }

              return Card(
                margin: const EdgeInsets.all(16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: HabitHeatmap(
                  habitData: habitData,
                  habitName: field.label,
                  onDayTap: (date, value) {
                    // Toggle habit for this day
                    _toggleHabitDay(context, categoryId, field.id, date, value);
                  },
                ),
              );
            }).toList(),

          // Entry list
          Expanded(
            child: entries.isEmpty
                ? const Center(
                    child: Text('No entries yet. Click + to add one.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      return _buildEntryCard(context, entries[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EntryFormScreen(categoryId: categoryId),
            ),
          );
        },
        child: iconoir.Plus(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _toggleHabitDay(BuildContext context, String categoryId, String fieldId,
      String date, bool value) {
    final journalProvider =
        Provider.of<JournalProvider>(context, listen: false);

    // Find or create entry for today
    final entries = journalProvider.getEntriesForCategory(categoryId);
    final today = DateTime.now();
    final todayKey = DateFormat('yyyy-MM-dd').format(today);

    JournalEntry? todayEntry;
    for (var entry in entries) {
      final entryKey = DateFormat('yyyy-MM-dd').format(entry.timestamp);
      if (entryKey == todayKey) {
        todayEntry = entry;
        break;
      }
    }

    if (todayEntry == null) {
      // Create new entry for today
      final category =
          journalProvider.categories.firstWhere((c) => c.id == categoryId);
      final newValues = <String, dynamic>{};

      // Initialize all fields
      for (var field in category.fields) {
        if (field.type == FieldType.habitCheckbox) {
          newValues[field.id] = {date: value};
        } else if (field.type == FieldType.checkbox) {
          newValues[field.id] = false;
        } else if (field.type == FieldType.number) {
          newValues[field.id] = 0.0;
        } else {
          newValues[field.id] = '';
        }
      }

      final newEntry = JournalEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: categoryId,
        timestamp: today,
        values: newValues,
        isSuccess: false,
      );

      journalProvider.addEntry(newEntry);
    } else {
      // Update existing entry
      final currentHabitData = todayEntry.values[fieldId] as Map? ?? {};
      final updatedHabitData = Map<String, dynamic>.from(currentHabitData);
      updatedHabitData[date] = value;

      final updatedValues = Map<String, dynamic>.from(todayEntry.values);
      updatedValues[fieldId] = updatedHabitData;

      final updatedEntry = JournalEntry(
        id: todayEntry.id,
        categoryId: todayEntry.categoryId,
        timestamp: todayEntry.timestamp,
        values: updatedValues,
        isSuccess: todayEntry.isSuccess,
      );

      journalProvider.updateEntry(updatedEntry);
    }
  }

  Widget _buildEntryCard(BuildContext context, JournalEntry entry) {
    final dateStr = DateFormat('MMM dd, yyyy - HH:mm').format(entry.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          dateStr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        leading: entry.isSuccess
            ? const iconoir.CheckCircle(color: Colors.green)
            : const iconoir.Circle(color: Colors.grey),
        children: entry.values.entries.map((v) {
          return ListTile(
            title: Text(v.key),
            trailing: Text(v.value.toString()),
            dense: true,
          );
        }).toList(),
      ),
    );
  }
}
