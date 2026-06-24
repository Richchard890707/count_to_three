import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

@Riverpod(keepAlive: true)
class AppThemeModeNotifier extends _$AppThemeModeNotifier {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    // SharedPreferences is already initialised in main.dart, so this resolves
    // from the in-process cache — effectively synchronous on first read.
    SharedPreferences.getInstance().then((prefs) {
      state = _parse(prefs.getString(_key));
    });
    return ThemeMode.system;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _serialize(mode));
  }

  static ThemeMode _parse(String? s) => switch (s) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static String _serialize(ThemeMode m) => switch (m) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        _ => 'system',
      };
}
