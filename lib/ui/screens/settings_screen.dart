import 'package:flutter/material.dart';

import '../../Data/service/settings_service.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: SettingsService.isDarkMode,
                  builder: (context, isDark, _) => SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Dark mode'),
                    value: isDark,
                    onChanged: SettingsService.setDarkMode,
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About Echorithm'),
                  subtitle: Text('Personalised news. Headlines from NewsAPI.org'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
