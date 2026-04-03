import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';

/// Connection Mode Selection Screen
/// Allows user to choose between Standalone, LAN, or Cloud mode
class ConnectionModeScreen extends StatefulWidget {
  const ConnectionModeScreen({super.key});

  @override
  State<ConnectionModeScreen> createState() => _ConnectionModeScreenState();
}

class _ConnectionModeScreenState extends State<ConnectionModeScreen> {
  String _selectedMode = 'cloud';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentMode();
  }

  Future<void> _loadCurrentMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedMode = prefs.getString('connection_mode') ?? 'cloud';
      _isLoading = false;
    });
  }

  Future<void> _saveMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('connection_mode', mode);
    setState(() => _selectedMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Mode'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.accentColor],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.settings_ethernet,
                          color: Colors.white,
                          size: 40,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Choose Your Connection',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Select how FuelSync connects to data',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Mode Options
                  _ModeCard(
                    mode: 'cloud',
                    title: '☁️ Cloud Mode',
                    subtitle: 'Supabase (Recommended)',
                    description:
                        'Full cloud sync, access from anywhere, real-time data',
                    icon: Icons.cloud,
                    isSelected: _selectedMode == 'cloud',
                    onTap: () => _saveMode('cloud'),
                  ),
                  const SizedBox(height: 16),

                  _ModeCard(
                    mode: 'lan',
                    title: '🏠 LAN Mode',
                    subtitle: 'Local Server',
                    description: 'Connect to local server within your network',
                    icon: Icons.router,
                    isSelected: _selectedMode == 'lan',
                    onTap: () => _saveMode('lan'),
                  ),
                  const SizedBox(height: 16),

                  _ModeCard(
                    mode: 'standalone',
                    title: '📱 Standalone Mode',
                    subtitle: 'Local Database (SQLite)',
                    description:
                        'Work offline, no internet required, local storage',
                    icon: Icons.phone_android,
                    isSelected: _selectedMode == 'standalone',
                    onTap: () => _saveMode('standalone'),
                  ),
                  const SizedBox(height: 32),

                  // Current Status
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.successGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppTheme.successGreen,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Currently using: ${_getModeDisplayName(_selectedMode)}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Section
                  const Text(
                    '💡 Tips',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const _TipItem(
                    icon: Icons.cloud_done,
                    text: 'Cloud mode is best for multiple stations',
                  ),
                  const _TipItem(
                    icon: Icons.wifi,
                    text: 'LAN mode works without internet',
                  ),
                  const _TipItem(
                    icon: Icons.battery_full,
                    text: 'Standalone mode saves data locally',
                  ),
                ],
              ),
            ),
    );
  }

  String _getModeDisplayName(String mode) {
    switch (mode) {
      case 'cloud':
        return 'Cloud (Supabase)';
      case 'lan':
        return 'LAN (Local Server)';
      case 'standalone':
        return 'Standalone (SQLite)';
      default:
        return mode;
    }
  }
}

class _ModeCard extends StatelessWidget {
  final String mode;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentColor.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.accentColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? null : AppTheme.softShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accentColor : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.accentColor : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.accentColor : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }
}
