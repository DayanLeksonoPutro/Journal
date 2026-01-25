import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import '../main.dart';
import '../utils/tool.dart';
import '../providers/journal_provider.dart';
import '../utils/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tutorial_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context, 'setting'))),
      body: ListView(
        children: [
          _buildSectionHeader(
              context, AppLocalizations.of(context, 'info_app')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              AppLocalizations.of(context, 'app_description'),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          _buildSectionHeader(
              context, AppLocalizations.of(context, 'appearance')),
          ListTile(
            leading: iconoir.Translate(
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(AppLocalizations.of(context, 'language')),
            subtitle: Text(
              settings.language == 'id' ? 'Bahasa Indonesia' : 'English',
            ),
            onTap: () {
              _showLanguagePicker(context, settings);
            },
          ),
          SwitchListTile(
            secondary: iconoir.HalfMoon(
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(AppLocalizations.of(context, 'dark_mode')),
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (val) {
              settings.setThemeMode(
                val ? ThemeMode.dark : ThemeMode.light,
              );
            },
          ),
          ListTile(
            leading: iconoir.Palette(
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(AppLocalizations.of(context, 'color_theme')),
            subtitle: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: SettingsProvider.themeColors.length,
                itemBuilder: (context, index) {
                  final color = SettingsProvider.themeColors[index];
                  final isSelected = settings.themeColorIndex == index;
                  return GestureDetector(
                    onTap: () => settings.setThemeColorIndex(index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8, top: 8),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? iconoir.Check(
                              width: 16,
                              height: 16,
                              color: color.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
          ListTile(
            leading: iconoir.Type(
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(AppLocalizations.of(context, 'font_style')),
            subtitle: Text(settings.fontFamily),
            onTap: () {
              _showFontPicker(context, settings);
            },
          ),
          ListTile(
            leading: iconoir.Type(
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(AppLocalizations.of(context, 'font_size')),
            subtitle:
                Text(_getFontSizeLabel(context, settings.fontSizeMultiplier)),
            onTap: () {
              _showFontSizePicker(context, settings);
            },
          ),
          const Divider(),
          _buildSectionHeader(
              context, AppLocalizations.of(context, 'data_support')),
          ListTile(
            leading: iconoir.Database(
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(AppLocalizations.of(context, 'backup_restore')),
            onTap: () {
              _showBackupRestoreDialog(context);
            },
          ),
          ListTile(
            leading: iconoir.Star(
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(AppLocalizations.of(context, 'rate_app')),
            onTap: () => AppTool.rateApp(),
          ),
          ListTile(
            leading: iconoir.ShareAndroid(
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(AppLocalizations.of(context, 'share_app')),
            onTap: () => AppTool.shareApp(context),
          ),
          ListTile(
            leading: iconoir.QuestionMark(
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(AppLocalizations.of(context, 'tutorial')),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TutorialScreen()),
              );
            },
          ),
          ListTile(
            leading: iconoir.Code(
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(AppLocalizations.of(context, 'developer_options')),
            onTap: () {
              _showDeveloperOptions(context);
            },
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              '${AppLocalizations.of(context, 'version')} 1.0.0 (Build 1)',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, SettingsProvider settings) {
    final langs = {
      'en': 'English',
      'id': 'Bahasa Indonesia',
    };
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: langs.entries
            .map((e) => ListTile(
                  title: Text(e.value),
                  trailing: settings.language == e.key
                      ? const iconoir.Check(color: Colors.blue)
                      : null,
                  onTap: () {
                    settings.setLanguage(e.key);
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }

  void _showFontSizePicker(BuildContext context, SettingsProvider settings) {
    final sizes = {
      0.8: 'font_size_small',
      1.0: 'font_size_medium',
      1.2: 'font_size_large',
    };
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: sizes.entries
            .map((e) => ListTile(
                  title: Text(AppLocalizations.of(context, e.value)),
                  trailing: settings.fontSizeMultiplier == e.key
                      ? const iconoir.Check(color: Colors.blue)
                      : null,
                  onTap: () {
                    settings.setFontSizeMultiplier(e.key);
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }

  String _getFontSizeLabel(BuildContext context, double multiplier) {
    if (multiplier <= 0.8)
      return AppLocalizations.of(context, 'font_size_small');
    if (multiplier >= 1.2)
      return AppLocalizations.of(context, 'font_size_large');
    return AppLocalizations.of(context, 'font_size_medium');
  }

  void _showFontPicker(BuildContext context, SettingsProvider settings) {
    final popularFonts = [
      'Inter',
      'Montserrat',
      'Poppins',
      'Open Sans',
      'Space Grotesk',
      'Roboto',
      'Nunito',
    ];

    final allFonts = GoogleFonts.asMap().keys.toList()..sort();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    AppLocalizations.of(context, 'select_font'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _FontList(
                    scrollController: scrollController,
                    popularFonts: popularFonts,
                    allFonts: allFonts,
                    settings: settings,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPlaceholderDialog(BuildContext context, String title, String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context, 'cancel'),
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeveloperOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: iconoir.Database(
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(AppLocalizations.of(context, 'generate_dummy_data')),
            onTap: () {
              Provider.of<JournalProvider>(context, listen: false)
                  .generateDummyData();
              Navigator.pop(context);
              _showPlaceholderDialog(
                  context,
                  AppLocalizations.of(context, 'success'),
                  AppLocalizations.of(context, 'dummy_data_generated'));
            },
          ),
          ListTile(
            leading: const iconoir.Bin(color: Colors.red),
            title: Text(AppLocalizations.of(context, 'clear_all_data'),
                style: TextStyle(color: Colors.red)),
            onTap: () {
              Provider.of<JournalProvider>(context, listen: false)
                  .clearAllData();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showBackupRestoreDialog(BuildContext context) {
    final journalProvider =
        Provider.of<JournalProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppLocalizations.of(context, 'backup_restore'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: iconoir.Download(
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(AppLocalizations.of(context, 'export_data')),
            subtitle: Text(AppLocalizations.of(context, 'export_subtitle')),
            onTap: () {
              final jsonString = journalProvider.exportData();
              Clipboard.setData(ClipboardData(text: jsonString));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(AppLocalizations.of(context, 'data_copied'))),
              );
            },
          ),
          ListTile(
            leading: iconoir.Upload(
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(AppLocalizations.of(context, 'import_data')),
            subtitle: Text(AppLocalizations.of(context, 'import_subtitle')),
            onTap: () {
              Navigator.pop(context);
              _showImportDialog(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context, 'import_data'),
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context, 'paste_json'),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context, 'cancel')),
          ),
          TextButton(
            onPressed: () {
              final success =
                  Provider.of<JournalProvider>(context, listen: false)
                      .importData(controller.text);
              Navigator.pop(context);
              if (success) {
                _showPlaceholderDialog(
                    context,
                    AppLocalizations.of(context, 'success'),
                    AppLocalizations.of(context, 'import_success'));
              } else {
                _showPlaceholderDialog(
                    context,
                    AppLocalizations.of(context, 'import_error'),
                    AppLocalizations.of(context, 'import_error'));
              }
            },
            child: Text(
              AppLocalizations.of(context, 'import'),
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _FontList extends StatefulWidget {
  final ScrollController scrollController;
  final List<String> popularFonts;
  final List<String> allFonts;
  final SettingsProvider settings;

  const _FontList({
    required this.scrollController,
    required this.popularFonts,
    required this.allFonts,
    required this.settings,
  });

  @override
  State<_FontList> createState() => _FontListState();
}

class _FontListState extends State<_FontList> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredFonts = [];

  @override
  void initState() {
    super.initState();
    _filteredFonts = widget.allFonts;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _filteredFonts = widget.allFonts
          .where((font) =>
              font.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12.0),
                child: iconoir.Search(
                  width: 20,
                  height: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              hintText: AppLocalizations.of(context, 'search_fonts'),
              filled: true,
              fillColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            itemCount: _filteredFonts.length +
                (_searchController.text.isEmpty
                    ? widget.popularFonts.length + 2
                    : 0),
            itemBuilder: (context, index) {
              if (_searchController.text.isEmpty) {
                if (index == 0) {
                  return _buildSectionHeader(
                      AppLocalizations.of(context, 'popular_fonts'));
                }
                if (index <= widget.popularFonts.length) {
                  final font = widget.popularFonts[index - 1];
                  return _buildFontTile(font);
                }
                if (index == widget.popularFonts.length + 1) {
                  return _buildSectionHeader(
                      AppLocalizations.of(context, 'all_fonts'));
                }
                final font =
                    _filteredFonts[index - widget.popularFonts.length - 2];
                return _buildFontTile(font);
              } else {
                final font = _filteredFonts[index];
                return _buildFontTile(font);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildFontTile(String font) {
    final isSelected = widget.settings.fontFamily == font;
    return ListTile(
      title: Text(
        font,
        style: GoogleFonts.getFont(font, fontSize: 16),
      ),
      trailing: isSelected ? const iconoir.Check(color: Colors.blue) : null,
      selected: isSelected,
      onTap: () {
        widget.settings.setFontFamily(font);
        Navigator.pop(context);
      },
    );
  }
}
