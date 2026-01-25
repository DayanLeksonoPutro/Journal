import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:intl/intl.dart';
import '../providers/journal_provider.dart';
import '../providers/note_provider.dart';
import '../models/category.dart';
import '../models/entry.dart';
import '../utils/tool.dart';
import 'category_detail_screen.dart';
import 'entry_form_screen.dart';
import 'note_editor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);
    final recentEntries = journalProvider.entries.reversed.take(3).toList();
    final categories = journalProvider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          IconButton(
            icon: const iconoir.ShareAndroid(),
            onPressed: () => AppTool.shareApp(context),
          ),
          IconButton(
            icon: const iconoir.Star(),
            onPressed: () => AppTool.rateApp(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Fast Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          _buildFastActions(context, categories),
          const SizedBox(height: 24),
          _buildBookmarkedNotes(context),
          const SizedBox(height: 24),
          Text(
            'Recent Entries',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          recentEntries.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('No entries yet'),
                  ),
                )
              : Column(
                  children: recentEntries
                      .map((e) => _buildRecentEntryTile(context, e, categories))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildBookmarkedNotes(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);
    final bookmarkedNotes =
        noteProvider.notes.where((n) => n.isBookmarked).toList();

    if (bookmarkedNotes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pinned Notes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: bookmarkedNotes.length,
            itemBuilder: (context, index) {
              final note = bookmarkedNotes[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteEditorScreen(note: note),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (note.title.isNotEmpty)
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    note.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const iconoir.Bookmark(
                                  color: Colors.amber,
                                  width: 12,
                                  height: 12,
                                ),
                              ],
                            ),
                          if (note.title.isNotEmpty) const SizedBox(height: 4),
                          Expanded(
                            child: Text(
                              note.content,
                              maxLines: note.title.isEmpty ? 5 : 4,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('MMM dd').format(note.updatedAt),
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFastActions(
      BuildContext context, List<JournalCategory> categories) {
    if (categories.isEmpty) return const Text('Add categories in Journal tab');

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: IconButton(
                    icon: const iconoir.Plus(color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EntryFormScreen(categoryId: cat.id),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Text(cat.name,
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentEntryTile(BuildContext context, JournalEntry entry,
      List<JournalCategory> categories) {
    final categoryResults = categories.where((c) => c.id == entry.categoryId);
    final category = categoryResults.isNotEmpty ? categoryResults.first : null;
    final dateStr = DateFormat('MMM dd, HH:mm').format(entry.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(category?.name ?? 'Unknown'),
        subtitle: Text(dateStr),
        leading: entry.isSuccess
            ? const iconoir.CheckCircle(color: Colors.green)
            : const iconoir.Circle(color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CategoryDetailScreen(categoryId: entry.categoryId),
            ),
          );
        },
      ),
    );
  }
}
