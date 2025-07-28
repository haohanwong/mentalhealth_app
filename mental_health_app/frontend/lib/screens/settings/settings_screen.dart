import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricsEnabled = false;
  bool _analyticsEnabled = true;
  bool _autoBackupEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      _biometricsEnabled = prefs.getBool('biometrics_enabled') ?? false;
      _analyticsEnabled = prefs.getBool('analytics_enabled') ?? true;
      _autoBackupEnabled = prefs.getBool('auto_backup_enabled') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Mental Health App',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.psychology,
        size: 64,
        color: Colors.blue,
      ),
      children: [
        const Text(
          'A comprehensive mental health support application with AI-powered chat, diary features, and emotion tracking.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Built with care to support your mental wellness journey.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  void _showPrivacyInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy & Data'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your privacy is important to us. Here\'s how we handle your data:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('• All personal data is encrypted'),
              Text('• Chat conversations are processed securely'),
              Text('• Diary entries are stored locally with encryption'),
              Text('• Analytics data is anonymized'),
              Text('• You can export or delete your data anytime'),
              SizedBox(height: 12),
              Text(
                'Contact us at privacy@mentalhealth.app for questions.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'Export your diary entries, chat history, and emotion data. This feature is coming soon.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data export feature coming soon!'),
                ),
              );
            },
            child: const Text('Request Export'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyResources() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Colors.red),
            SizedBox(width: 8),
            Text('Emergency Resources'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'If you\'re in immediate danger or having thoughts of self-harm:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('🚨 Emergency: 911'),
              SizedBox(height: 8),
              Text('🆘 Crisis Text Line: Text HOME to 741741'),
              SizedBox(height: 8),
              Text('📞 National Suicide Prevention Lifeline: 988'),
              SizedBox(height: 8),
              Text('💬 Crisis Chat: suicidepreventionlifeline.org'),
              SizedBox(height: 12),
              Text(
                'Remember: You are not alone. Help is available 24/7.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // User Profile Section
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.user;
              return Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          user?.username.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.username ?? 'User',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Member since ${user?.createdAt.year ?? 2024}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // App Preferences
          _buildSectionHeader('App Preferences'),
          _buildSwitchTile(
            'Push Notifications',
            'Get reminders and wellness tips',
            Icons.notifications,
            _notificationsEnabled,
            (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              _saveSetting('notifications_enabled', value);
            },
          ),
          _buildSwitchTile(
            'Dark Mode',
            'Use dark theme (Coming Soon)',
            Icons.dark_mode,
            _darkModeEnabled,
            (value) {
              setState(() {
                _darkModeEnabled = value;
              });
              _saveSetting('dark_mode_enabled', value);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dark mode coming soon!')),
              );
            },
          ),
          _buildSwitchTile(
            'Auto Backup',
            'Automatically backup your data',
            Icons.backup,
            _autoBackupEnabled,
            (value) {
              setState(() {
                _autoBackupEnabled = value;
              });
              _saveSetting('auto_backup_enabled', value);
            },
          ),

          // Privacy & Security
          _buildSectionHeader('Privacy & Security'),
          _buildSwitchTile(
            'Biometric Login',
            'Use fingerprint or face recognition',
            Icons.fingerprint,
            _biometricsEnabled,
            (value) {
              setState(() {
                _biometricsEnabled = value;
              });
              _saveSetting('biometrics_enabled', value);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Biometric login coming soon!')),
              );
            },
          ),
          _buildSwitchTile(
            'Analytics',
            'Help improve the app with usage data',
            Icons.analytics,
            _analyticsEnabled,
            (value) {
              setState(() {
                _analyticsEnabled = value;
              });
              _saveSetting('analytics_enabled', value);
            },
          ),
          _buildTile(
            'Privacy Policy',
            'Learn how we protect your data',
            Icons.privacy_tip,
            _showPrivacyInfo,
          ),
          _buildTile(
            'Export Data',
            'Download your personal data',
            Icons.download,
            _showExportDataDialog,
          ),

          // Support & Resources
          _buildSectionHeader('Support & Resources'),
          _buildTile(
            'Emergency Resources',
            'Crisis hotlines and support',
            Icons.emergency,
            _showEmergencyResources,
            textColor: Colors.red,
          ),
          _buildTile(
            'Help & FAQ',
            'Get answers to common questions',
            Icons.help,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help center coming soon!')),
              );
            },
          ),
          _buildTile(
            'Contact Support',
            'Get help from our team',
            Icons.support_agent,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contact: support@mentalhealth.app')),
              );
            },
          ),
          _buildTile(
            'About',
            'App version and information',
            Icons.info,
            _showAboutDialog,
          ),

          // Account Actions
          _buildSectionHeader('Account'),
          _buildTile(
            'Logout',
            'Sign out of your account',
            Icons.logout,
            _showLogoutDialog,
            textColor: Colors.red,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.grey[600]),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}