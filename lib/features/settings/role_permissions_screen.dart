import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class RolePermissionsScreen extends StatelessWidget {
  const RolePermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Role Permissions Guide')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Understanding Staff Access',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Users can be assigned different roles to limit what they can view and modify within the application.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          _buildRoleCard(
            title: 'Operator',
            icon: Icons.point_of_sale,
            color: AppTheme.accentColor,
            permissions: [
              'Record daily cash and credit sales',
              'Start and close personal tracking shifts',
              'View their own daily shift report',
              'Cannot access settings or master reports',
            ],
          ),
          const SizedBox(height: 16),
          _buildRoleCard(
            title: 'Manager',
            icon: Icons.admin_panel_settings,
            color: AppTheme.primaryColor,
            permissions: [
              'All Operator permissions',
              'View global pump reports and analytics',
              'Add incoming fuel loads to tanks',
              'Manage and view the Credit (Khata) ledger',
            ],
          ),
          const SizedBox(height: 16),
          _buildRoleCard(
            title: 'Admin (Pump Owner)',
            icon: Icons.business,
            color: Colors.deepPurple,
            permissions: [
              'All Manager permissions',
              'Full access to pump configuration settings',
              'Add, remove, or modify staff users and PINs',
              'Add or remove physical tanks and nozzles',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> permissions,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: permissions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        permissions[index],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
