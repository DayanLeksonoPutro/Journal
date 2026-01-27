import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import '../providers/journal_provider.dart';
import '../models/category.dart';
import 'category_detail_screen.dart';
import 'template_editor_screen.dart';
import 'template_jurnal.dart';

import '../utils/app_localizations.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);
    final allCategories = journalProvider.categories;
    final categories = allCategories
        .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context, 'search_journals'),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : Text(AppLocalizations.of(context, 'my_journals')),
        actions: [
          IconButton(
            icon: _isSearching
                ? iconoir.Xmark(
                    color: Theme.of(context).colorScheme.primary,
                  )
                : iconoir.Search(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          IconButton(
            icon: iconoir.Settings(
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              // Show simple sorting option
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: iconoir.List(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(AppLocalizations.of(context, 'sort_az')),
                      onTap: () {
                        // In a real app, you might want to call a provider method
                        // but for now we'll just close
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: categories.isEmpty
          ? Center(child: Text(AppLocalizations.of(context, 'no_journals')))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 3.5, // Adjusted for taller habit-style cards
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryCard(context, categories[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: iconoir.MultiplePages(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title:
                      Text(AppLocalizations.of(context, 'pilih_dari_template')),
                  subtitle:
                      Text(AppLocalizations.of(context, 'gunakan_template')),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TemplateJurnalScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: iconoir.Plus(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title:
                      Text(AppLocalizations.of(context, 'buat_template_baru')),
                  subtitle: Text(AppLocalizations.of(context, 'buat_field')),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TemplateEditorScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        label: Text(AppLocalizations.of(context, 'add_template')),
        icon: iconoir.Plus(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, JournalCategory category) {
    // Determine if "completed" today (has any entry)
    final journalProvider = Provider.of<JournalProvider>(context);
    final now = DateTime.now();
    final isCompleted = journalProvider.entries.any((e) =>
        e.categoryId == category.id &&
        e.timestamp.year == now.year &&
        e.timestamp.month == now.month &&
        e.timestamp.day == now.day);

    return GestureDetector(
      onLongPress: () {
        // Simple delete on long press
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context, 'delete_journal') ??
                'Delete Journal?'),
            content:
                Text('Are you sure you want to delete "${category.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<JournalProvider>().deleteCategory(category.id);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onTap: () {
        // Navigate to detail on tap
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailScreen(categoryId: category.id),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.grey[850], // Use requested dark color
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _getCategoryIcon(
                      category.iconName,
                      size: 24, // Smaller icon for the card header
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${category.fields.length} Fields', // Simplified description
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Also navigate to detail for now, or could trigger quick add
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CategoryDetailScreen(categoryId: category.id),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Theme.of(context).primaryColor
                            : Colors.white.withOpacity(0.2),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _buildContributionGrid(category),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionGrid(JournalCategory category) {
    return Consumer<JournalProvider>(
      builder: (context, journalProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 2,
            runSpacing: 2,
            children: List.generate(160, (index) {
              final date = DateTime.now().subtract(Duration(days: 160 - index));
              // Check if entry exists for this date
              final hasEntry = journalProvider.entries.any((e) =>
                  e.categoryId == category.id &&
                  e.timestamp.year == date.year &&
                  e.timestamp.month == date.month &&
                  e.timestamp.day == date.day);

              // Use primary color or a specific color for the category if available
              final activeColor = Theme.of(context).primaryColor;

              return Container(
                width: 6, // Slightly smaller to fit 2 columns better
                height: 6,
                decoration: BoxDecoration(
                  color: hasEntry ? activeColor : activeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _getCategoryIcon(String? iconName, {Color? color, double size = 40}) {
    switch (iconName) {
      case 'lineChart':
        return iconoir.GraphUp(width: size, height: size, color: color);
      case 'checkCircle':
        return iconoir.CheckCircle(width: size, height: size, color: color);
      case 'shoppingCart':
        return iconoir.Cart(width: size, height: size, color: color);
      case 'dumbbell':
        return iconoir.Gym(width: size, height: size, color: color);
      case 'book':
        return iconoir.Book(width: size, height: size, color: color);
      case 'airplane':
        return iconoir.Airplane(width: size, height: size, color: color);
      case 'settings':
        return iconoir.Settings(width: size, height: size, color: color);
      case 'leaf':
        return iconoir.Flower(width: size, height: size, color: color);
      default:
        return iconoir.Journal(width: size, height: size, color: color);
    }
  }
}
