import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const _prefKey = 'is_dark_mode';
  final SharedPreferences prefs;

  ThemeCubit({required this.prefs}) : super(ThemeMode.system) {
    final isDark = prefs.getBool(_prefKey);
    if (isDark != null) {
      emit(isDark ? ThemeMode.dark : ThemeMode.light);
    } else {
      emit(ThemeMode.system);
    }
  }

  Future<void> setDarkMode(bool enabled) async {
    await prefs.setBool(_prefKey, enabled);
    emit(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setSystemMode() async {
    await prefs.remove(_prefKey);
    emit(ThemeMode.system);
  }
}

