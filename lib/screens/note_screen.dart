import 'package:flutter/material.dart';
import 'package:journal/main.dart';
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
        title: Row(
          children: [
            Text(AppLocalizations.of(context, 'note')),
            if (provider.streakCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: iconoir.Search(
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NoteSearchDelegate(
                  notes: notes,
                  onNoteTap: _openEditor,
                ),
              );
            },
          ),
        ],
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

                Color backgroundColor = Theme.of(context).cardColor;
                if (note.colorIndex > 0) {
                  final color = SettingsProvider.themeColors[note.colorIndex];
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  backgroundColor = isDark
                      ? Color.lerp(Theme.of(context).cardColor, color, 0.2)!
                      : Color.lerp(
                          Theme.of(context).colorScheme.surface, color, 0.15)!;
                }

                return Card(
                  color: backgroundColor,
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
                                      Hero(
                                        tag: 'title_${note.id}',
                                        child: Material(
                                          color: Colors.transparent,
                                          child: Text(
                                            note.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
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
                                    ? iconoir.BookmarkSolid(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      )
                                    : iconoir.Bookmark(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Hero(
                              tag: 'content_${note.id}',
                              child: Material(
                                color: Colors.transparent,
                                child: note.isChecklist
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: note.checklistItems
                                            .take(note.title.isEmpty ? 5 : 4)
                                            .map((item) => Row(
                                                  children: [
                                                    Icon(
                                                      item.isDone
                                                          ? Icons.check_box
                                                          : Icons
                                                              .check_box_outline_blank,
                                                      size: 12,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .outlineVariant,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        item.text,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          decoration: item
                                                                  .isDone
                                                              ? TextDecoration
                                                                  .lineThrough
                                                              : null,
                                                          color: item.isDone
                                                              ? Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onSurface
                                                                  .withOpacity(
                                                                      0.5)
                                                              : Theme.of(
                                                                  context,
                                                                )
                                                                  .colorScheme
                                                                  .secondary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ))
                                            .toList(),
                                      )
                                    : Text(
                                        note.content,
                                        maxLines: note.title.isEmpty ? 5 : 4,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                              ),
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
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '#$tag',
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
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
                            style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.outline),
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

class NoteSearchDelegate extends SearchDelegate {
  final List<NoteItem> notes;
  final Function(NoteItem) onNoteTap;

  NoteSearchDelegate({required this.notes, required this.onNoteTap});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const iconoir.Xmark(),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const iconoir.NavArrowLeft(),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final filtered = notes
        .where((n) =>
            n.title.toLowerCase().contains(query.toLowerCase()) ||
            n.content.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No matches found'));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final note = filtered[index];
        return ListTile(
          title: Text(note.title.isEmpty ? 'Untitled' : note.title),
          subtitle:
              Text(note.content, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () {
            close(context, null);
            onNoteTap(note);
          },
        );
      },
    );
  }
}
