import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences sharedPreferences;
  static const String themeKey = 'THEME_MODE_KEY';

  ThemeCubit({required this.sharedPreferences}) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final savedTheme = sharedPreferences.getString(themeKey);
    if (savedTheme == 'light') {
      emit(ThemeMode.light);
    } else if (savedTheme == 'dark') {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.system);
    }
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.dark) {
      await sharedPreferences.setString(themeKey, 'light');
      emit(ThemeMode.light);
    } else {
      await sharedPreferences.setString(themeKey, 'dark');
      emit(ThemeMode.dark);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String value = 'system';
    if (mode == ThemeMode.light) value = 'light';
    if (mode == ThemeMode.dark) value = 'dark';

    await sharedPreferences.setString(themeKey, value);
    emit(mode);
  }
}
