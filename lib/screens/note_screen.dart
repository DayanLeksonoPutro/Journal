import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:intl/intl.dart';
import '../providers/note_provider.dart';
import '../providers/journal_provider.dart';
import '../models/entry.dart';
import 'entry_form_screen.dart';
import '../utils/app_localizations.dart';

import 'note_editor_screen.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  void _openEditor([NoteItem? note]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(note: note),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NoteProvider>(context);
    final notes = provider.notes;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context, 'note')),
      ),
      body: notes.isEmpty
          ? const Center(child: Text('No notes yet'))
          : GridView.builder(
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
                    onTap: () => _openEditor(note),
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
                          if (note.title.isNotEmpty) const SizedBox(height: 4),
                          Expanded(
                            child: Text(
                              note.content,
                              maxLines: note.title.isEmpty ? 6 : 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd').format(note.updatedAt),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const iconoir.Plus(),
      ),
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
