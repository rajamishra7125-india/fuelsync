import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/reconciliation.dart';

/// Reconciliation Service - handles reconciliation logic
class ReconciliationService {
  /// Calculate expected stock for a tank
  /// Expected = Opening Stock + Purchase - System Sales
  static double calculateExpectedStock({
    required double openingStock,
    required double purchaseQty,
    required double systemSales,
  }) {
    return openingStock + purchaseQty - systemSales;
  }

  /// Calculate difference between actual and expected
  /// Negative = Loss (possible theft/leak)
  /// Positive = Gain (possible meter error)
  static double calculateDifference({
    required double expectedStock,
    required double actualDip,
  }) {
    return actualDip - expectedStock;
  }

  /// Determine reconciliation status based on difference
  static ReconciliationStatus determineStatus({
    required double expectedStock,
    required double actualDip,
  }) {
    final difference = actualDip - expectedStock;
    final absDiff = difference.abs();

    // Tolerance: 0.5% of expected or 50 liters (whichever is less)
    final tolerancePercent = expectedStock * 0.005;
    final tolerance = tolerancePercent < 50 ? tolerancePercent : 50.0;

    if (absDiff <= tolerance) {
      return ReconciliationStatus.ok;
    } else if (difference < 0 && absDiff > tolerance * 2) {
      // Significant loss - likely theft/leak
      return ReconciliationStatus.theft;
    } else {
      // Warning - minor discrepancy
      return ReconciliationStatus.warning;
    }
  }

  /// Format difference for display
  static String formatDifference(double difference) {
    final sign = difference > 0 ? '+' : '';
    return '$sign${difference.toStringAsFixed(2)} L';
  }

  /// Get status message based on reconciliation status
  static String getStatusMessage(ReconciliationStatus status) {
    switch (status) {
      case ReconciliationStatus.ok:
        return 'Stock matches system records';
      case ReconciliationStatus.warning:
        return 'Minor discrepancy - checkdip required';
      case ReconciliationStatus.theft:
        return 'CRITICAL: Significant stock mismatch - possible theft/leak detected!';
    }
  }
}

/// Reconciliation Controller State
class ReconciliationState {
  final List<Reconciliation> reconciliations;
  final bool isLoading;
  final String? error;
  final DateTime selectedDate;

  ReconciliationState({
    this.reconciliations = const [],
    this.isLoading = false,
    this.error,
    DateTime? selectedDate,
  }) : selectedDate = selectedDate ?? DateTime.now();

  ReconciliationState copyWith({
    List<Reconciliation>? reconciliations,
    bool? isLoading,
    String? error,
    DateTime? selectedDate,
  }) {
    return ReconciliationState(
      reconciliations: reconciliations ?? this.reconciliations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  /// Get all tanks with issues (warning or theft)
  List<Reconciliation> get tanksWithIssues => reconciliations
      .where((r) => r.status != ReconciliationStatus.ok)
      .toList();

  /// Get count of tanks with theft status
  int get theftCount => reconciliations
      .where((r) => r.status == ReconciliationStatus.theft)
      .length;

  /// Get count of tanks with warning status
  int get warningCount => reconciliations
      .where((r) => r.status == ReconciliationStatus.warning)
      .length;

  /// Get count of tanks with OK status
  int get okCount =>
      reconciliations.where((r) => r.status == ReconciliationStatus.ok).length;
}

/// Reconciliation Controller using Riverpod Notifier
class ReconciliationController extends Notifier<ReconciliationState> {
  @override
  ReconciliationState build() => ReconciliationState();

  /// Initialize reconciliation for all tanks
  Future<void> initializeReconciliation({
    required List<Map<String, dynamic>> tanks,
    required DateTime date,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      // Mock implementation - in production, fetch from database
      final mockReconciliations = tanks.map((tank) {
        final openingStock = (tank['current_stock'] as num).toDouble();
        final purchaseQty = (tank['daily_purchase'] as num?)?.toDouble() ?? 0.0;
        final systemSales = (tank['daily_sales'] as num?)?.toDouble() ?? 0.0;

        // For demo, assume actual dip equals expected (OK status)
        final expectedStock = openingStock + purchaseQty - systemSales;
        final actualDip = expectedStock; // Mock actual dip

        return Reconciliation(
          id: tank['id'],
          tankId: tank['id'],
          fuelType: tank['fuel_type'],
          date: date,
          openingStock: openingStock,
          purchaseQty: purchaseQty,
          systemSales: systemSales,
          actualDip: actualDip,
        );
      }).toList();

      state = state.copyWith(
        reconciliations: mockReconciliations,
        selectedDate: date,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update actual dip reading for a tank
  void updateDipReading({required String tankId, required double actualDip}) {
    final updatedList = state.reconciliations.map((r) {
      if (r.tankId == tankId) {
        return Reconciliation(
          id: r.id,
          tankId: r.tankId,
          fuelType: r.fuelType,
          date: r.date,
          openingStock: r.openingStock,
          purchaseQty: r.purchaseQty,
          systemSales: r.systemSales,
          actualDip: actualDip,
          notes: r.notes,
        );
      }
      return r;
    }).toList();

    state = state.copyWith(reconciliations: updatedList);
  }

  /// Save reconciliation to database
  Future<bool> saveReconciliation() async {
    state = state.copyWith(isLoading: true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Change selected date
  void changeDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
    // Would re-fetch data for new date
  }
}

/// Provider for ReconciliationController
final reconciliationControllerProvider =
    NotifierProvider<ReconciliationController, ReconciliationState>(() {
      return ReconciliationController();
    });
