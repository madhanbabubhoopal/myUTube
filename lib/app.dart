import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/video_provider.dart';
import 'screens/home_screen.dart';
import 'screens/clips_screen.dart';
import 'screens/library_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/search_screen.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/kidstube_logo.dart';

class KidsTubeApp extends StatelessWidget {
  const KidsTubeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VideoProvider()..init(),
      child: const _ThemeWrapper(),
    );
  }
}

/// Reads isDarkMode from VideoProvider and switches themes accordingly.
class _ThemeWrapper extends StatelessWidget {
  const _ThemeWrapper();

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<VideoProvider>().isDarkMode;

    return MaterialApp(
      title: 'KidsTube',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF0000),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF0000),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF0000),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        cardColor: const Color(0xFF1F1F1F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF0000),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        useMaterial3: true,
      ),
      home: const _MainShell(),
    );
  }
}

class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _selectedIndex = 0;

  // Using IndexedStack keeps all tabs alive — preserves scroll position
  // and avoids re-triggering scans when switching tabs.
  static const List<Widget> _screens = [
    HomeScreen(),
    ClipsScreen(),
    LibraryScreen(),   // Folders
    LibraryScreen(),   // Library (same view, different entry point)
    SettingsScreen(),  // Profile → behind parental PIN
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF0000),
        title: const Row(
          children: [
            KidsTubeLogo(size: 28),
            SizedBox(width: 8),
            Text(
              'KidsTube',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: 'Search',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.folder_open, color: Colors.white),
            tooltip: 'Folders',
            onPressed: () => setState(() => _selectedIndex = 2),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: KidsTubeBottomNav(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}
