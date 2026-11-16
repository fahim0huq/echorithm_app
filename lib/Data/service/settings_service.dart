import 'package:flutter/foundation.dart';

import 'preferences_service.dart';

class SettingsService {
  static final ValueNotifier<bool> isDarkMode = ValueNotifier(false);

  static Future<void> load() async {
    isDarkMode.value = await PreferencesService.loadDarkMode();
  }

  static Future<void> setDarkMode(bool isDark) async {
    isDarkMode.value = isDark;
    await PreferencesService.saveDarkMode(isDark);
  }
}
