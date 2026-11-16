import 'package:flutter/material.dart';

import 'Data/service/bookmark_service.dart';
import 'Data/service/personalization_service.dart';
import 'Data/service/preferences_service.dart';
import 'Data/service/settings_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isFirstLaunch = !await PreferencesService.hasChosenInterests();
  final interests = await PreferencesService.loadInterests();
  await BookmarkService.load();
  await SettingsService.load();
  await PersonalizationService.load();

  runApp(EchorithmApp(interests: interests, isFirstLaunch: isFirstLaunch));
}
