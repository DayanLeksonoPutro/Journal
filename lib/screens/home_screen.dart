import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:intl/intl.dart';
import '../providers/journal_provider.dart';
import '../models/category.dart';
import '../models/entry.dart';
import '../utils/tool.dart';
import 'category_detail_screen.dart';
import 'entry_form_screen.dart';

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
          _buildSuccessOverview(journalProvider),
          const SizedBox(height: 24),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open adding for first category if available
          if (categories.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    EntryFormScreen(categoryId: categories.first.id),
              ),
            );
          }
        },
        child: const iconoir.Plus(),
      ),
    );
  }

  Widget _buildSuccessOverview(JournalProvider provider) {
    // Determine overall success rate
    double totalRate = 0;
    if (provider.categories.isNotEmpty) {
      for (var cat in provider.categories) {
        totalRate += provider.getSuccessRate(cat.id);
      }
      totalRate = totalRate / provider.categories.length;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Success Rate',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${totalRate.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const iconoir.GraphUp(color: Colors.green),
            ],
          ),
        ],
      ),
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
