import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _SectionHeader(title: 'Scanning Behavior'),
          SwitchListTile(
            title: const Text('Save scan history'),
            subtitle: const Text('Keep a record of all scanned codes'),
            value: settings.saveHistory,
            onChanged: (value) => notifier.toggleSaveHistory(value),
          ),
          SwitchListTile(
            title: const Text('Confirm before opening URLs'),
            subtitle: const Text('Show the scan result sheet instead of jumping straight to the browser'),
            value: settings.confirmBeforeOpenUrl,
            onChanged: (value) => notifier.toggleConfirmBeforeOpenUrl(value),
          ),
          
          _SectionHeader(title: 'Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle app theme (Note: In a full app this might be System/Light/Dark enum)'),
            value: settings.isDarkMode,
            onChanged: (value) => notifier.toggleTheme(value),
          ),
          
          _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Information'),
            subtitle: const Text('Version 1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'QR FlutterDev',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2026 FlutterDev Beginners',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () async {
              const url = 'https://flutter.dev'; // Placeholder
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
