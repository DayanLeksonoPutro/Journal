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
            icon: _isSearching ? const iconoir.Xmark() : const iconoir.Search(),
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
            icon: const iconoir.Settings(),
            onPressed: () {
              // Show simple sorting option
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const iconoir.List(),
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
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
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
                  leading: const iconoir.MultiplePages(),
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
                  leading: const iconoir.Plus(),
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
        icon: const iconoir.Plus(),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, JournalCategory category) {
    return Card(
      elevation: 0,
      color: Colors.blue.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CategoryDetailScreen(categoryId: category.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _getCategoryIcon(category.iconName,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              category.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCategoryIcon(String? iconName, {Color? color}) {
    const double size = 40;
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
