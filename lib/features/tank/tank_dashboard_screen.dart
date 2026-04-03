import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'add_fuel_screen.dart';

class TankDashboardScreen extends StatelessWidget {
  const TankDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tank Management')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _TankStatusCard(
              fuelType: 'Petrol',
              current: 15000,
              capacity: 20000,
              color: AppTheme.fuelGold,
            ),
            const SizedBox(height: 20),
            _TankStatusCard(
              fuelType: 'Diesel',
              current: 8500,
              capacity: 20000,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            _TankStatusCard(
              fuelType: 'CNG',
              current: 1200,
              capacity: 5000,
              color: AppTheme.successGreen,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddFuelScreen()),
                );
              },
              icon: const Icon(Icons.add_shopping_cart, size: 20),
              label: const Text('Record Fuel Purchase'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TankStatusCard extends StatelessWidget {
  final String fuelType;
  final double current;
  final double capacity;
  final Color color;

  const _TankStatusCard({
    required this.fuelType,
    required this.current,
    required this.capacity,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = (current / capacity) * 100;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                fuelType,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(
                label: 'Current',
                value: '${current.toStringAsFixed(0)} L',
              ),
              _StatItem(
                label: 'Remaining',
                value: '${(capacity - current).toStringAsFixed(0)} L',
              ),
              _StatItem(
                label: 'Total',
                value: '${capacity.toStringAsFixed(0)} L',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
