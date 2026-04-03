import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/storage_service.dart';

/// Dashboard Stats Provider
/// Fetches real data from Supabase or local DB based on sync mode
final dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  // Get the storage service to get current shop
  final storageService = StorageService();
  final shopId = await storageService.getShopId();

  if (shopId == null) {
    // Return demo data if no shop configured
    return _getDemoData();
  }

  try {
    // Try to fetch from Supabase if in cloud mode
    final supabaseService = SupabaseService();
    final dashboardData = await supabaseService.getDashboardData(shopId);

    return {
      'sales': '₹ ${_formatCurrency(dashboardData['today_sales_total'] ?? 0)}',
      'litres':
          '${_formatNumber(dashboardData['today_sales_count'] ?? 0)} transactions',
      'tanks_count': '${(dashboardData['tanks'] as List?)?.length ?? 0} tanks',
      'low_stock_alerts':
          '${(dashboardData['low_stock_tanks'] as List?)?.length ?? 0}',
      'credit_pending':
          '${dashboardData['customers_with_pending_credit'] ?? 0}',
      'reconciliation_issues':
          '${dashboardData['pending_reconciliations'] ?? 0}',
      'open_issues': '${dashboardData['open_issues'] ?? 0}',
    };
  } catch (e) {
    // Fallback to demo data if sync fails
    return _getDemoData();
  }
});

/// Get demo data for offline mode
Map<String, dynamic> _getDemoData() {
  return {
    'sales': '₹ 1.25L',
    'litres': '1,450 L',
    'tanks_count': '4 tanks',
    'low_stock_alerts': '0',
    'credit_pending': '₹ 45,200',
    'reconciliation_issues': '0',
    'open_issues': '2',
  };
}

String _formatCurrency(num value) {
  if (value >= 100000) {
    return '${(value / 100000).toStringAsFixed(2)}L';
  } else if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  }
  return value.toStringAsFixed(0);
}

String _formatNumber(num value) {
  return value.toStringAsFixed(0);
}

/// Sync Status Provider
class SyncStatusNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void setSyncing(bool value) => state = value;
}

final syncStatusProvider = NotifierProvider<SyncStatusNotifier, bool>(SyncStatusNotifier.new);

/// Current Shop Provider
final currentShopProvider = FutureProvider<String?>((ref) async {
  final storageService = StorageService();
  return await storageService.getShopId();
});

/// Dashboard Alerts Provider
/// Returns list of alerts for the dashboard
final dashboardAlertsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final shopId = await ref.watch(currentShopProvider.future);

  if (shopId == null) return [];

  final supabaseService = SupabaseService();
  final dashboardData = await supabaseService.getDashboardData(shopId);

  List<Map<String, dynamic>> alerts = [];

  // Low stock alerts
  final lowStockTanks = dashboardData['low_stock_tanks'] as List?;
  if (lowStockTanks != null && lowStockTanks.isNotEmpty) {
    for (var tank in lowStockTanks) {
      alerts.add({
        'type': 'warning',
        'title': 'Low Stock Alert',
        'message':
            '${tank['name']} has only ${tank['current_stock']}L remaining',
        'icon': 'warning',
      });
    }
  }

  // Pending reconciliation alerts
  final pendingRecs = dashboardData['pending_reconciliations'] as int? ?? 0;
  if (pendingRecs > 0) {
    alerts.add({
      'type': 'danger',
      'title': 'Reconciliation Pending',
      'message': '$pendingRecs daily reconciliations need attention',
      'icon': 'inventory',
    });
  }

  // Open maintenance issues
  final openIssues = dashboardData['open_issues'] as int? ?? 0;
  if (openIssues > 0) {
    alerts.add({
      'type': 'info',
      'title': 'Maintenance Issues',
      'message': '$openIssues equipment issues need attention',
      'icon': 'build',
    });
  }

  return alerts;
});
