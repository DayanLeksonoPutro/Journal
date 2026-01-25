import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'utils/app_localizations.dart';

// Screens - will be moved to separate files later
import 'screens/home_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/note_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';

// Providers
import 'providers/journal_provider.dart';
import 'providers/todo_provider.dart';
import 'providers/note_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(prefs)),
        ChangeNotifierProvider(create: (_) => JournalProvider(prefs)),
        ChangeNotifierProvider(create: (_) => TodoProvider(prefs)),
        ChangeNotifierProvider(create: (_) => NoteProvider(prefs)),
      ],
      child: MyApp(showOnboarding: !onboardingDone),
    ),
  );
}

class SettingsProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  String _language = 'id';
  ThemeMode _themeMode = ThemeMode.system;
  String _fontFamily = 'Inter';
  double _fontSizeMultiplier = 1.0;
  int _themeColorIndex = 0;

  static const List<Color> themeColors = [
    Colors.black,
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.indigo
  ];

  SettingsProvider(this._prefs) {
    _language = _prefs.getString('language') ?? 'id';
    _fontFamily = _prefs.getString('fontFamily') ?? 'Inter';
    _fontSizeMultiplier = _prefs.getDouble('fontSizeMultiplier') ?? 1.0;
    _themeColorIndex = _prefs.getInt('themeColorIndex') ?? 0;
    _themeMode = ThemeMode.values[_prefs.getInt('themeMode') ?? 0];
  }

  String get language => _language;
  ThemeMode get themeMode => _themeMode;
  String get fontFamily => _fontFamily;
  double get fontSizeMultiplier => _fontSizeMultiplier;
  int get themeColorIndex => _themeColorIndex;
  Color get themeColor => themeColors[_themeColorIndex];

  void setLanguage(String lang) {
    _language = lang;
    _prefs.setString('language', lang);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  void setThemeColorIndex(int index) {
    _themeColorIndex = index;
    _prefs.setInt('themeColorIndex', index);
    notifyListeners();
  }

  void setFontFamily(String font) {
    _fontFamily = font;
    _prefs.setString('fontFamily', font);
    notifyListeners();
  }

  void setFontSizeMultiplier(double multiplier) {
    _fontSizeMultiplier = multiplier;
    _prefs.setDouble('fontSizeMultiplier', multiplier);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      title: 'Journal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: settings.themeColor,
        fontFamily: GoogleFonts.getFont(settings.fontFamily).fontFamily,
        textTheme: GoogleFonts.getTextTheme(settings.fontFamily),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: settings.themeColor,
        fontFamily: GoogleFonts.getFont(settings.fontFamily).fontFamily,
        textTheme: GoogleFonts.getTextTheme(settings.fontFamily),
      ),
      themeMode: settings.themeMode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.fontSizeMultiplier),
          ),
          child: child!,
        );
      },
      home: showOnboarding == true
          ? const OnboardingScreen()
          : const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      const JournalScreen(),
      const NoteScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex < screens.length
          ? _selectedIndex
          : screens.length - 1],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex < screens.length
            ? _selectedIndex
            : screens.length - 1,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: iconoir.Home(
              color: Theme.of(context).colorScheme.primary,
            ),
            label: AppLocalizations.of(context, 'home'),
          ),
          NavigationDestination(
            icon: iconoir.Journal(
              color: Theme.of(context).colorScheme.primary,
            ),
            label: AppLocalizations.of(context, 'journal'),
          ),
          NavigationDestination(
            icon: iconoir.Notes(
              color: Theme.of(context).colorScheme.primary,
            ),
            label: AppLocalizations.of(context, 'note'),
          ),
          NavigationDestination(
            icon: iconoir.Settings(
              color: Theme.of(context).colorScheme.primary,
            ),
            label: AppLocalizations.of(context, 'setting'),
          ),
        ],
      ),
    );
  }
}
