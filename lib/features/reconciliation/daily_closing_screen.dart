import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/reconciliation.dart'
    show Reconciliation, ReconciliationStatus;
import 'services/reconciliation_service.dart'
    show
        ReconciliationService,
        reconciliationControllerProvider;

/// Daily Closing Screen - Anti-theft core system
/// Staff enters dip readings at end of day to reconcile stock
class DailyClosingScreen extends ConsumerStatefulWidget {
  const DailyClosingScreen({super.key});

  @override
  ConsumerState<DailyClosingScreen> createState() => _DailyClosingScreenState();
}

class _DailyClosingScreenState extends ConsumerState<DailyClosingScreen> {
  final Map<String, TextEditingController> _dipControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeReconciliation();
  }

  Future<void> _initializeReconciliation() async {
    // Mock tank data - in production, fetch from database
    final mockTanks = [
      {
        'id': 'tank_1',
        'fuel_type': 'Petrol',
        'current_stock': 15000.0,
        'daily_purchase': 5000.0,
        'daily_sales': 8000.0,
      },
      {
        'id': 'tank_2',
        'fuel_type': 'Diesel',
        'current_stock': 12000.0,
        'daily_purchase': 3000.0,
        'daily_sales': 6000.0,
      },
    ];

    await ref
        .read(reconciliationControllerProvider.notifier)
        .initializeReconciliation(tanks: mockTanks, date: DateTime.now());

    // Initialize controllers for each tank
    final state = ref.read(reconciliationControllerProvider);
    for (final rec in state.reconciliations) {
      _dipControllers[rec.tankId] = TextEditingController(
        text: rec.actualDip.toStringAsFixed(2),
      );
    }

    // Initialization complete
  }

  void _updateDip(String tankId, String value) {
    final dip = double.tryParse(value);
    if (dip != null) {
      ref
          .read(reconciliationControllerProvider.notifier)
          .updateDipReading(tankId: tankId, actualDip: dip);
    }
  }

  @override
  void dispose() {
    for (final controller in _dipControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reconciliationControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Closing - Stock Reconciliation'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // Date picker - select different date
            },
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(child: Text('Error: ${state.error}'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Card
                  _SummaryCard(
                    okCount: state.okCount,
                    warningCount: state.warningCount,
                    theftCount: state.theftCount,
                  ),
                  const SizedBox(height: 24),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.accentColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.accentColor),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Enter the actual dip reading from each tank. The system will auto-calculate if there\'s any stock mismatch.',
                            style: TextStyle(color: AppTheme.accentColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tank Cards
                  ...state.reconciliations.map(
                    (rec) => _TankReconciliationCard(
                      reconciliation: rec,
                      controller: _dipControllers[rec.tankId],
                      onDipChanged: (value) => _updateDip(rec.tankId, value),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final success = await ref
                            .read(reconciliationControllerProvider.notifier)
                            .saveReconciliation();
                        if (!context.mounted) return;
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Reconciliation saved successfully!'
                                  : 'Failed to save reconciliation',
                            ),
                            backgroundColor: success
                                ? AppTheme.successGreen
                                : AppTheme.dangerRed,
                          ),
                        );
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save Reconciliation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Summary Card showing overall status
class _SummaryCard extends StatelessWidget {
  final int okCount;
  final int warningCount;
  final int theftCount;

  const _SummaryCard({
    required this.okCount,
    required this.warningCount,
    required this.theftCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatusCount(
            icon: Icons.check_circle,
            label: 'OK',
            count: okCount,
            color: AppTheme.successGreen,
          ),
          _StatusCount(
            icon: Icons.warning,
            label: 'Warning',
            count: warningCount,
            color: AppTheme.fuelGold,
          ),
          _StatusCount(
            icon: Icons.error,
            label: 'Theft',
            count: theftCount,
            color: AppTheme.dangerRed,
          ),
        ],
      ),
    );
  }
}

class _StatusCount extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _StatusCount({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}

/// Individual Tank Reconciliation Card
class _TankReconciliationCard extends StatelessWidget {
  final Reconciliation reconciliation;
  final TextEditingController? controller;
  final Function(String) onDipChanged;

  const _TankReconciliationCard({
    required this.reconciliation,
    required this.controller,
    required this.onDipChanged,
  });

  Color get _statusColor {
    switch (reconciliation.status) {
      case ReconciliationStatus.ok:
        return AppTheme.successGreen;
      case ReconciliationStatus.warning:
        return AppTheme.fuelGold;
      case ReconciliationStatus.theft:
        return AppTheme.dangerRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: _statusColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    reconciliation.fuelType == 'Petrol'
                        ? Icons.local_gas_station
                        : Icons.local_gas_station,
                    color: reconciliation.fuelType == 'Petrol'
                        ? AppTheme.fuelGold
                        : AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${reconciliation.fuelType} Tank',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  reconciliation.statusDisplay,
                  style: TextStyle(
                    color: _statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stock Details
          _DetailRow(
            label: 'Opening Stock',
            value: '${reconciliation.openingStock.toStringAsFixed(0)} L',
          ),
          _DetailRow(
            label: 'Purchase',
            value: '+ ${reconciliation.purchaseQty.toStringAsFixed(0)} L',
          ),
          _DetailRow(
            label: 'System Sales',
            value: '- ${reconciliation.systemSales.toStringAsFixed(0)} L',
          ),
          const Divider(height: 24),
          _DetailRow(
            label: 'Expected Stock',
            value: '${reconciliation.expectedStock.toStringAsFixed(0)} L',
            isBold: true,
          ),
          const SizedBox(height: 16),

          // Dip Entry
          Row(
            children: [
              const Text(
                'Actual Dip Reading: ',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter dip',
                    suffixText: 'L',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: onDipChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Difference
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Difference:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  ReconciliationService.formatDifference(
                    reconciliation.difference,
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _statusColor,
                  ),
                ),
              ],
            ),
          ),

          // Status Message
          if (reconciliation.status != ReconciliationStatus.ok) ...[
            const SizedBox(height: 12),
            Text(
              ReconciliationService.getStatusMessage(reconciliation.status),
              style: TextStyle(
                color: _statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
