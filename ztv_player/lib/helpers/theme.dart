import 'package:flutter/material.dart';

// Klasa koja čuva sve boje za lakšu kontrolu u svim screen-ima
class ThemeColors {
  // AppBar boje
  final Color appBarBackground;
  final Color appBarText;
  final Color appBarIcon;
  final Color appBarSelectedIcon;

  // BottomNavigationBar boje
  final Color bottomNavBackground;
  final Color bottomNavIcon;
  final Color bottomNavSelectedIcon;

  // Background aplikacije
  final Color scaffoldBackground;

  ThemeColors({
    required this.appBarBackground,
    required this.appBarText,
    required this.appBarIcon,
    required this.appBarSelectedIcon,
    required this.bottomNavBackground,
    required this.bottomNavIcon,
    required this.bottomNavSelectedIcon,
    required this.scaffoldBackground,
  });
}

enum AppThemeType { dark, light, netflix, discord, spotify, dracula, nord }

class AppTheme {
  static final ValueNotifier<AppThemeType> notifier = ValueNotifier(
    AppThemeType.dark,
  );

  static final ValueNotifier<ThemeColors> colorsNotifier = ValueNotifier(
    getColors(AppThemeType.dark),
  );

  static String getThemeName(AppThemeType type) {
    switch (type) {
      case AppThemeType.dark:
        return 'Dark';
      case AppThemeType.light:
        return 'Light';
      case AppThemeType.netflix:
        return 'Netflix';
      case AppThemeType.discord:
        return 'Discord';
      case AppThemeType.spotify:
        return 'Spotify';
      case AppThemeType.dracula:
        return 'Dracula';
      case AppThemeType.nord:
        return 'Nord';
    }
  }

  // Čuva boje za trenutni theme
  static ThemeColors getColors(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return ThemeColors(
          appBarBackground: const Color(0xFFF8FAFC),
          appBarText: Color(0xFF1976D2),
          appBarIcon: Colors.white,
          appBarSelectedIcon: Colors.white,
          bottomNavBackground: const Color(0xFFF8FAFC),
          bottomNavIcon: const Color(0xFF6B7280),
          bottomNavSelectedIcon: const Color(0xFF1976D2),
          scaffoldBackground: const Color(0xFFF0F2F5),
        );
      // Netflix Red Theme
      case AppThemeType.netflix:
        return ThemeColors(
          appBarBackground: const Color(0xFF000000),
          appBarText: const Color(0xFFE50914),
          appBarIcon: Colors.white,
          appBarSelectedIcon: const Color(0xFFE50914),
          bottomNavBackground: const Color(0xFF0F0F0F),
          bottomNavIcon: const Color(0xFF808080),
          bottomNavSelectedIcon: const Color(0xFFE50914),
          scaffoldBackground: const Color(0xFF141414),
        );
      // Discord Purple Theme
      case AppThemeType.discord:
        return ThemeColors(
          appBarBackground: const Color(0xFF2C2F33),
          appBarText: Colors.white,
          appBarIcon: Colors.white,
          appBarSelectedIcon: const Color(0xFF7289DA),
          bottomNavBackground: const Color(0xFF23272A),
          bottomNavIcon: const Color(0xFF72767D),
          bottomNavSelectedIcon: const Color(0xFF7289DA),
          scaffoldBackground: const Color(0xFF36393F),
        );
      // Spotify Green Theme
      case AppThemeType.spotify:
        return ThemeColors(
          appBarBackground: const Color(0xFF191414),
          appBarText: const Color(0xFF1DB954),
          appBarIcon: Colors.white,
          appBarSelectedIcon: const Color(0xFF1DB954),
          bottomNavBackground: const Color(0xFF0F0F0F),
          bottomNavIcon: const Color(0xFF6A6A6A),
          bottomNavSelectedIcon: const Color(0xFF1DB954),
          scaffoldBackground: const Color(0xFF121212),
        );
      // Dracula Dark Theme
      case AppThemeType.dracula:
        return ThemeColors(
          appBarBackground: const Color(0xFF282A36),
          appBarText: const Color(0xFFF8F8F2),
          appBarIcon: const Color(0xFF50FA7B),
          appBarSelectedIcon: const Color(0xFF50FA7B),
          bottomNavBackground: const Color(0xFF21222C),
          bottomNavIcon: const Color(0xFF6272A4),
          bottomNavSelectedIcon: const Color(0xFF50FA7B),
          scaffoldBackground: const Color(0xFF282A36),
        );
      // Nord Arctic Theme
      case AppThemeType.nord:
        return ThemeColors(
          appBarBackground: const Color(0xFF2E3440),
          appBarText: const Color(0xFF88C0D0),
          appBarIcon: const Color(0xFF88C0D0),
          appBarSelectedIcon: const Color(0xFF81A1C1),
          bottomNavBackground: const Color(0xFF3B4252),
          bottomNavIcon: const Color(0xFF4C566A),
          bottomNavSelectedIcon: const Color(0xFF88C0D0),
          scaffoldBackground: const Color(0xFF2E3440),
        );
      // Dark (Default)
      case AppThemeType.dark:
        return ThemeColors(
          appBarBackground: const Color(0xFF141414),
          appBarText: Color(0xFF8590F5),
          appBarIcon: Colors.white,
          appBarSelectedIcon: const Color(0xFF8590F5),
          bottomNavBackground: const Color(0xFF141414),
          bottomNavIcon: const Color(0xFFB3B3B3),
          bottomNavSelectedIcon: const Color(0xFF8590F5),
          scaffoldBackground: const Color(0xFF0F0F0F),
        );
    }
  }

  static ThemeData getTheme(AppThemeType themeType) {
    final colors = getColors(themeType);
    colorsNotifier.value = colors;
    final brightness = themeType == AppThemeType.light
        ? Brightness.light
        : Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.scaffoldBackground,
      primaryColor: colors.bottomNavSelectedIcon,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.appBarBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.appBarIcon),
        titleTextStyle: TextStyle(
          color: colors.appBarText,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.bottomNavBackground,
        selectedItemColor: colors.bottomNavSelectedIcon,
        unselectedItemColor: colors.bottomNavIcon,
      ),
      colorScheme: brightness == Brightness.light
          ? ColorScheme.light(
              primary: colors.bottomNavSelectedIcon,
              surface: colors.scaffoldBackground,
            )
          : ColorScheme.dark(
              primary: colors.bottomNavSelectedIcon,
              surface: colors.scaffoldBackground,
            ),
    );
  }
}
