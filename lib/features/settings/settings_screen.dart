import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../tank/tank_dashboard_screen.dart';
import '../auth/staff_login_screen.dart';
import 'manage_nozzles_screen.dart';
import 'staff_users_screen.dart';
import 'role_permissions_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Pump Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _SettingSection(
            title: 'Infrastructure',
            items: [
              _SettingTile(
                icon: Icons.local_gas_station,
                title: 'Manage Nozzles',
                subtitle: 'Add, remove or edit fuel nozzles',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageNozzlesScreen()));
                },
              ),
              _SettingTile(
                icon: Icons.storage,
                title: 'Manage Tanks',
                subtitle: 'Configure fuel storage tanks',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TankDashboardScreen()));
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SettingSection(
            title: 'Staff Management',
            items: [
              _SettingTile(
                icon: Icons.people_outline,
                title: 'Staff Users',
                subtitle: 'Create operators and managers',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffUsersScreen()));
                },
              ),
              _SettingTile(
                icon: Icons.security,
                title: 'Role Permissions',
                subtitle: 'Define what staff can access',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RolePermissionsScreen()));
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SettingSection(
            title: 'General',
            items: [
              _SettingTile(
                icon: Icons.info_outline,
                title: 'App Version',
                subtitle: 'FuelSync v1.0.4 Premium',
                onTap: null,
              ),
              _SettingTile(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Exit current session',
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Logout', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    try {
                      await Supabase.instance.client.auth.signOut();
                    } catch (e) {
                      debugPrint('Logout Error: $e');
                    }
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const StaffLoginScreen()),
                        (route) => false,
                      );
                    }
                  }
                },
                color: AppTheme.dangerRed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _SettingSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? color;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? AppTheme.primaryColor).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color ?? AppTheme.primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
      ),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, size: 20)
          : null,
    );
  }
}
