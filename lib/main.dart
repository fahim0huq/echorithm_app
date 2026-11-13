import 'package:flutter/material.dart';

import 'Data/service/preferences_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final interests = await PreferencesService.loadInterests();

  runApp(EchorithmApp(interests: interests));
}
