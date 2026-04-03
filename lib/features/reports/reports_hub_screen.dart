import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'daily_report_screen.dart';
import 'nozzle_report_screen.dart';
import 'stock_report_screen.dart';
import 'credit_report_screen.dart';
import 'shift_history_screen.dart';

class ReportsHubScreen extends StatelessWidget {
  const ReportsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Reports & Insights')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _ReportTile(
              title: 'Daily Report',
              subtitle: 'Sales, Revenue & Profit summary',
              icon: Icons.today_outlined,
              color: AppTheme.accentColor,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DailyReportScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _ReportTile(
              title: 'Nozzle Report',
              subtitle: 'Performance per nozzle & fuel type',
              icon: Icons.gas_meter_outlined,
              color: AppTheme.fuelGold,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NozzleReportScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _ReportTile(
              title: 'Stock Report',
              subtitle: 'Inventory analysis & refill history',
              icon: Icons.storage_outlined,
              color: AppTheme.successGreen,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StockReportScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _ReportTile(
              title: 'Credit Report',
              subtitle: 'Pending khata & aging summary',
              icon: Icons.credit_card_outlined,
              color: AppTheme.dangerRed,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreditReportScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _ReportTile(
              title: 'Shift History',
              subtitle: 'Detailed logs of operator shifts',
              icon: Icons.history_outlined,
              color: AppTheme.primaryColor,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShiftHistoryScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ReportTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
