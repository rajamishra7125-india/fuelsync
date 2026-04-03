import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui';

import '../../core/theme/app_theme.dart';
import '../sales/add_sale_screen.dart';
import '../tank/tank_dashboard_screen.dart';
import '../reports/reports_hub_screen.dart';
import '../shift/shift_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/connection_mode_screen.dart';
import '../customer/customer_list_screen.dart';
import '../reconciliation/daily_closing_screen.dart';
import '../maintenance/maintenance_screen.dart';
import 'controllers/dashboard_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const _PremiumSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Live Performance'),
                  const SizedBox(height: 16),
                  statsAsync.when(
                    data: (stats) => _buildStatsRow(context, stats),
                    loading: () => _buildShimmerStats(),
                    error: (e, st) => Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.dangerRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.dangerRed.withValues(alpha: 0.3)),
                      ),
                      child: const Center(
                        child: Text(
                          'Failed to load live data',
                          style: TextStyle(color: AppTheme.dangerRed, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  _buildSectionHeader('Core Operations'),
                  const SizedBox(height: 20),
                  const _ActionGrid(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.accentColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, Map stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _GlassyStatCard(
                title: 'Revenue Today',
                value: stats['sales']!,
                icon: Icons.currency_rupee,
                gradientColors: [AppTheme.successGreen, const Color(0xFF047857)],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsHubScreen())),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _GlassyStatCard(
                title: 'Fuel Dispensed',
                value: stats['litres']!,
                icon: Icons.water_drop,
                gradientColors: [AppTheme.fuelGold, const Color(0xFFD97706)],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsHubScreen())),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _GlassyStatCard(
                title: 'Active Tanks',
                value: stats['tanks_count']!,
                icon: Icons.ev_station,
                gradientColors: [AppTheme.accentColor, const Color(0xFF1D4ED8)],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TankDashboardScreen())),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _GlassyStatCard(
                title: 'Credit Pending',
                value: stats['credit_pending']!,
                icon: Icons.account_balance_wallet,
                gradientColors: [AppTheme.dangerRed, const Color(0xFFB91C1C)],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerListScreen())),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmerStats() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildShimmerBox(130)),
              const SizedBox(width: 16),
              Expanded(child: _buildShimmerBox(130)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildShimmerBox(130)),
              const SizedBox(width: 16),
              Expanded(child: _buildShimmerBox(130)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}

class _PremiumSliverAppBar extends StatelessWidget {
  const _PremiumSliverAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Base Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Decorative shapes
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentColor.withValues(alpha: 0.15),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 60, 28, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, Admin',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Reliance Petroleum',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.accentColor, Color(0xFF60A5FA)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentColor.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _LiveSyncIndicator(),
                          const SizedBox(width: 12),
                          Text(
                            'System Synced',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          tooltip: 'Notifications',
        ),
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          tooltip: 'Settings',
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _LiveSyncIndicator extends StatefulWidget {
  const _LiveSyncIndicator();

  @override
  State<_LiveSyncIndicator> createState() => _LiveSyncIndicatorState();
}

class _LiveSyncIndicatorState extends State<_LiveSyncIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _opacityAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: AppTheme.successGreen,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.successGreen.withValues(alpha: 0.6),
              blurRadius: 6,
              spreadRadius: 2,
            )
          ],
        ),
      ),
    );
  }
}

class _GlassyStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _GlassyStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: gradientColors.first.withValues(alpha: 0.1),
        highlightColor: gradientColors.first.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              const BoxShadow(
                color: Color(0x05000000),
                blurRadius: 2,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.first.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  letterSpacing: -0.5,
                  color: AppTheme.primaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.0, // Resized for a better balanced square view
      children: [
        _ModernActionTile(
          icon: Icons.power_settings_new,
          label: 'Start Shift',
          subtitle: 'Initialize pumps',
          gradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShiftScreen())),
        ),
        _ModernActionTile(
          icon: Icons.point_of_sale,
          label: 'Add Sale',
          subtitle: 'Record transaction',
          gradient: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSaleScreen())),
        ),
        _ModernActionTile(
          icon: Icons.local_shipping,
          label: 'Refill Tanks',
          subtitle: 'Restock inventory',
          gradient: const [AppTheme.fuelGold, Color(0xFFD97706)],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TankDashboardScreen())),
        ),
        _ModernActionTile(
          icon: Icons.insert_chart_outlined,
          label: 'Insights',
          subtitle: 'View reports',
          gradient: const [Color(0xFF10B981), Color(0xFF047857)],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsHubScreen())),
        ),
        _ModernActionTile(
          icon: Icons.rule,
          label: 'Reconcile',
          subtitle: 'Daily closing',
          gradient: const [Color(0xFFF43F5E), Color(0xFFE11D48)],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyClosingScreen())),
        ),
        _ModernActionTile(
          icon: Icons.build_circle_outlined,
          label: 'Maintenance',
          subtitle: 'Fix equipment',
          gradient: const [Color(0xFF64748B), Color(0xFF475569)],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MaintenanceScreen())),
        ),
        _ModernActionTile(
          icon: Icons.people_alt_outlined,
          label: 'Customers',
          subtitle: 'Manage credit',
          gradient: const [Color(0xFF0EA5E9), Color(0xFF0284C7)],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerListScreen())),
        ),
        _ModernActionTile(
          icon: Icons.wifi_protected_setup,
          label: 'Connection',
          subtitle: 'Network mode',
          gradient: const [Color(0xFFF97316), Color(0xFFEA580C)],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConnectionModeScreen())),
        ),
      ],
    );
  }
}

class _ModernActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ModernActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: gradient.first.withValues(alpha: 0.1),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100, width: 1.5),
            boxShadow: AppTheme.softShadow,
          ),
          child: Stack(
            children: [
              // Subtle background gradient artifact
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.05,
                  child: Icon(icon, size: 100, color: gradient.last),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            gradient.first.withValues(alpha: 0.15),
                            gradient.last.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: gradient.first, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: -0.3,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
