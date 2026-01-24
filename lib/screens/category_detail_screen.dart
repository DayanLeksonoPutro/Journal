import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/journal_provider.dart';
import '../models/entry.dart';
import 'entry_form_screen.dart';
import 'template_editor_screen.dart';

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
            icon: const iconoir.EditPencil(),
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
            icon: const iconoir.Bin(),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Category?'),
                  content: const Text(
                      'This will permanently delete this category and all its entries.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        journalProvider.deleteCategory(categoryId);
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Exit detail screen
                      },
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: entries.isEmpty
          ? const Center(child: Text('No entries yet. Click + to add one.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                return _buildEntryCard(context, entries[index]);
              },
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
        child: const iconoir.Plus(),
      ),
    );
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
