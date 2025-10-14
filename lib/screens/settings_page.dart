import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../core/service_locator.dart';
import 'api_key_setup_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _authService = ServiceLocator().authService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Account'),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            subtitle: Text(_authService.currentUser?.displayName ?? 'Unknown'),
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(_authService.currentUser?.email ?? 'Unknown'),
          ),

          const _SectionHeader(title: 'Movie Database'),
          ListTile(
            leading: const Icon(Icons.key),
            title: const Text('TMDB API Key'),
            subtitle: Text(
              ApiConfig.hasApiKey ? 'Configured' : 'Not configured',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ApiKeySetupPage(),
                ),
              );
              setState(() {});
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About TMDB'),
            subtitle: const Text('Powered by The Movie Database'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTmdbInfo(context),
          ),

          const _SectionHeader(title: 'App'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About'),
            subtitle: Text('Movie Collection v1.0.0'),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () => _showSignOutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showTmdbInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About TMDB'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This product uses the TMDB API but is not endorsed or certified by TMDB.',
            ),
            SizedBox(height: 16),
            Text(
              'The Movie Database (TMDB) is a community built movie and TV database.',
            ),
            SizedBox(height: 16),
            Text(
              'Visit themoviedb.org to learn more and get your free API key.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _authService.signOut();
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
