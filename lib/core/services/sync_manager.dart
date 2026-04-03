import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_database_service.dart';

/// 🔄 SYNC MANAGER - Smart Sync System
/// Handles delta sync, conflict resolution, background sync
class SyncManager {
  final SupabaseClient _supabase = Supabase.instance.client;
  final LocalDatabaseService _localDb = LocalDatabaseService();

  // Auto-sync timer (every 30 seconds)
  Timer? _autoSyncTimer;

  // Last sync timestamp
  DateTime? _lastSyncTime;

  // Sync status
  bool _isSyncing = false;
  final ValueNotifier<bool> syncingStatus = ValueNotifier<bool>(false);
  final ValueNotifier<String> syncError = ValueNotifier<String>('');

  // Sync mode
  SyncMode _currentMode = SyncMode.offline;

  // Current shop ID
  String? _currentShopId;

  bool get isSyncing => _isSyncing;
  SyncMode get currentMode => _currentMode;
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Initialize sync manager
  void init(String shopId) {
    _currentShopId = shopId;
    _initConnectivityListener();
    _loadLastSyncTime();
    _startAutoSync();
  }

  /// Clean up resources
  void dispose() {
    _autoSyncTimer?.cancel();
  }

  /// Set current shop
  void setCurrentShop(String shopId) {
    _currentShopId = shopId;
  }

  // ============================================
  // 🌐 CONNECTIVITY LISTENER
  // ============================================

  void _initConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        // Network available - run sync
        runSync();
      } else {
        // No network - switch to offline mode
        _currentMode = SyncMode.offline;
      }
    });
  }

  // ============================================
  // 🔄 AUTO BACKGROUND SYNC (Every 30 sec)
  // ============================================

  void _startAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_currentMode != SyncMode.offline) {
        runSync();
      }
    });
  }

  // ============================================
  // 💾 LOAD LAST SYNC TIME FROM LOCAL DB
  // ============================================

  Future<void> _loadLastSyncTime() async {
    final timestamp = await _localDb.getLastSyncTime();
    if (timestamp != null) {
      _lastSyncTime = DateTime.parse(timestamp);
    }
  }

  // ============================================
  // 🔁 MAIN SYNC OPERATION
  // ============================================

  /// Run full sync - push local → server, pull server → local
  Future<void> runSync() async {
    if (_isSyncing || _currentShopId == null) return;
    if (_currentMode == SyncMode.offline) return;

    _isSyncing = true;
    syncingStatus.value = true;
    syncError.value = '';

    try {
      // Step 1: Push local pending data to server
      await _pushLocalToServer();

      // Step 2: Pull server updates to local
      await _pullServerToLocal();

      // Step 3: Update last sync time
      _lastSyncTime = DateTime.now();
      await _localDb.setLastSyncTime(_lastSyncTime!.toIso8601String());

      debugPrint('✅ Sync completed at $_lastSyncTime');
    } catch (e) {
      debugPrint('❌ Sync Error: $e');
      syncError.value = e.toString();
    } finally {
      _isSyncing = false;
      syncingStatus.value = false;
    }
  }

  // ============================================
  // 📤 STEP 1: PUSH LOCAL → SUPABASE
  // ============================================

  Future<void> _pushLocalToServer() async {
    if (_currentShopId == null) return;

    // Sync fuel sales
    await _syncPendingSales();

    // Sync inventory/purchases
    await _syncPendingPurchases();

    // Sync customers
    await _syncPendingCustomers();

    // Sync shifts
    await _syncPendingShifts();

    // Sync nozzle readings
    await _syncPendingNozzleReadings();

    // Sync reconciliations
    await _syncPendingReconciliations();

    // Sync maintenance logs
    await _syncPendingMaintenance();
  }

  Future<void> _syncPendingSales() async {
    final sales = await _localDb.getUnsyncedSales();
    for (var sale in sales) {
      try {
        await _supabase.from('fuel_sales').insert({
          'shop_id': _currentShopId,
          'nozzle_id': sale['nozzle_id'],
          'fuel_type': sale['fuel_type'],
          'rate': sale['rate'],
          'litres': sale['litres'],
          'amount': sale['amount'],
          'payment_mode': sale['payment_type'],
          'vehicle_number': sale['vehicle_number'],
          'customer_proof_url': sale['image_path'],
          'sync_status': 'synced',
          'created_at': sale['created_at'],
        });
        await _localDb.markSynced('offline_sales', sale['id']);
        debugPrint('✅ Sale synced: ${sale['id']}');
      } catch (e) {
        debugPrint('❌ Sale sync failed: $e');
      }
    }
  }

  Future<void> _syncPendingPurchases() async {
    final purchases = await _localDb.getUnsyncedPurchases();
    for (var p in purchases) {
      try {
        await _supabase.from('inventory_logs').insert({
          'shop_id': _currentShopId,
          'tank_id': p['tank_id'],
          'supplier': p['supplier'],
          'invoice_number': p['invoice_number'],
          'quantity': p['quantity'],
          'rate': p['rate'],
          'total_amount': p['quantity'] * p['rate'],
          'type': 'PURCHASE',
          'proof_url': p['image_path'],
          'sync_status': 'synced',
          'created_at': p['created_at'],
        });
        await _localDb.markSynced('offline_purchases', p['id']);
        debugPrint('✅ Purchase synced: ${p['id']}');
      } catch (e) {
        debugPrint('❌ Purchase sync failed: $e');
      }
    }
  }

  Future<void> _syncPendingCustomers() async {
    final customers = await _localDb.getUnsyncedCustomers();
    for (var customer in customers) {
      try {
        await _supabase.from('customers').insert({
          'shop_id': _currentShopId,
          'name': customer['name'],
          'phone': customer['phone'],
          'vehicle_numbers': customer['vehicle_numbers'],
          'credit_limit': customer['credit_limit'],
          'current_balance': customer['balance'],
          'sync_status': 'synced',
          'created_at': customer['created_at'],
        });
        await _localDb.markSynced('offline_customers', customer['id']);
        debugPrint('✅ Customer synced: ${customer['id']}');
      } catch (e) {
        debugPrint('❌ Customer sync failed: $e');
      }
    }
  }

  Future<void> _syncPendingShifts() async {
    final shifts = await _localDb.getUnsyncedShifts();
    for (var shift in shifts) {
      try {
        await _supabase.from('shifts').insert({
          'shop_id': _currentShopId,
          'user_id': shift['user_id'],
          'opening_cash': shift['opening_cash'],
          'closing_cash': shift['closing_cash'],
          'status': shift['status'],
          'start_time': shift['start_time'],
          'end_time': shift['end_time'],
          'sync_status': 'synced',
          'created_at': shift['created_at'],
        });
        await _localDb.markSynced('offline_shifts', shift['id']);
      } catch (e) {
        debugPrint('❌ Shift sync failed: $e');
      }
    }
  }

  Future<void> _syncPendingNozzleReadings() async {
    final readings = await _localDb.getUnsyncedNozzleReadings();
    for (var reading in readings) {
      try {
        await _supabase.from('nozzle_readings').insert({
          'shop_id': _currentShopId,
          'nozzle_id': reading['nozzle_id'],
          'shift_id': reading['shift_id'],
          'opening_reading': reading['opening_reading'],
          'closing_reading': reading['closing_reading'],
          'total_sales': reading['total_sales'],
          'sync_status': 'synced',
          'created_at': reading['created_at'],
        });
        await _localDb.markSynced('offline_nozzle_readings', reading['id']);
      } catch (e) {
        debugPrint('❌ Nozzle reading sync failed: $e');
      }
    }
  }

  Future<void> _syncPendingReconciliations() async {
    final recs = await _localDb.getUnsyncedReconciliations();
    for (var rec in recs) {
      try {
        await _supabase.from('daily_reconciliation').insert({
          'shop_id': _currentShopId,
          'tank_id': rec['tank_id'],
          'date': rec['date'],
          'opening_stock': rec['opening_stock'],
          'purchases': rec['purchases'],
          'sales': rec['sales'],
          'expected_stock': rec['expected_stock'],
          'closing_stock': rec['closing_stock'],
          'difference': rec['difference'],
          'status': rec['status'],
          'dip_image_url': rec['dip_image_url'],
          'notes': rec['notes'],
          'sync_status': 'synced',
          'created_at': rec['created_at'],
        });
        await _localDb.markSynced('offline_reconciliations', rec['id']);
      } catch (e) {
        debugPrint('❌ Reconciliation sync failed: $e');
      }
    }
  }

  Future<void> _syncPendingMaintenance() async {
    final logs = await _localDb.getUnsyncedMaintenanceLogs();
    for (var log in logs) {
      try {
        await _supabase.from('maintenance_logs').insert({
          'shop_id': _currentShopId,
          'equipment_type': log['equipment_type'],
          'equipment_id': log['equipment_id'],
          'issue_description': log['issue_description'],
          'status': log['status'],
          'priority': log['priority'],
          'reported_by': log['reported_by'],
          'assigned_to': log['assigned_to'],
          'resolution_notes': log['resolution_notes'],
          'resolved_at': log['resolved_at'],
          'sync_status': 'synced',
          'created_at': log['created_at'],
        });
        await _localDb.markSynced('offline_maintenance_logs', log['id']);
      } catch (e) {
        debugPrint('❌ Maintenance log sync failed: $e');
      }
    }
  }

  // ============================================
  // 📥 STEP 2: PULL SERVER → LOCAL (Delta Sync)
  // ============================================

  Future<void> _pullServerToLocal() async {
    if (_lastSyncTime == null || _currentShopId == null) return;

    // Only fetch records updated since last sync (Delta Sync)
    final tables = [
      'fuel_sales',
      'inventory_logs',
      'customers',
      'tanks',
      'shifts',
      'nozzle_readings',
      'daily_reconciliation',
      'maintenance_logs',
      'invoices',
    ];

    for (var table in tables) {
      await _syncTableFromServer(table);
    }
  }

  Future<void> _syncTableFromServer(String table) async {
    if (_lastSyncTime == null || _currentShopId == null) return;

    try {
      // Delta sync: fetch only records updated after last sync
      final response = await _supabase
          .from(table)
          .select()
          .eq('shop_id', _currentShopId!)
          .gt('updated_at', _lastSyncTime!.toIso8601String());

      final records = List<Map<String, dynamic>>.from(response);

      for (var record in records) {
        // Conflict resolution: "Last Updated Wins"
        await _resolveConflict(table, record);
      }

      debugPrint('✅ Synced $table: ${records.length} records');
    } catch (e) {
      debugPrint('❌ Pull $table failed: $e');
    }
  }

  // ============================================
  // ⚔️ CONFLICT RESOLUTION SYSTEM
  // Rule: "Last Updated Wins"
  // ============================================

  Future<void> _resolveConflict(
    String table,
    Map<String, dynamic> serverRecord,
  ) async {
    final localRecord = await _localDb.getRecordById(table, serverRecord['id']);

    if (localRecord == null) {
      // Record doesn't exist locally - insert it
      await _localDb.upsert(table, serverRecord);
    } else {
      // Compare updated_at timestamps
      final localUpdated = localRecord['updated_at'] != null
          ? DateTime.parse(localRecord['updated_at'])
          : DateTime(2000);

      final serverUpdated = serverRecord['updated_at'] != null
          ? DateTime.parse(serverRecord['updated_at'])
          : DateTime(2000);

      if (serverUpdated.isAfter(localUpdated)) {
        // Server is newer - update local
        await _localDb.upsert(table, serverRecord);
        debugPrint(
          '🔄 Conflict resolved: Server wins for ${serverRecord['id']}',
        );
      } else {
        // Local is newer - will be pushed on next sync
        debugPrint(
          '🔄 Conflict resolved: Local wins for ${serverRecord['id']}',
        );
      }
    }
  }

  // ============================================
  // 🎯 SYNC MODE CONTROL
  // ============================================

  /// Set sync mode (offline, local, cloud)
  void setMode(SyncMode mode) {
    _currentMode = mode;

    if (mode == SyncMode.cloud) {
      // Start auto sync when in cloud mode
      _startAutoSync();
      runSync();
    } else {
      // Stop auto sync in offline mode
      _autoSyncTimer?.cancel();
    }

    debugPrint('📡 Sync mode changed to: $mode');
  }

  /// Manual sync trigger
  Future<void> forceSync() async {
    if (_currentMode == SyncMode.offline) {
      debugPrint('⚠️ Cannot sync in offline mode');
      return;
    }
    await runSync();
  }
}

/// Sync Modes
enum SyncMode {
  offline, // SQLite only - no sync
  local, // LAN server sync (future)
  cloud, // Supabase sync
}

/// Provider for SyncManager
final syncManagerProvider = Provider<SyncManager>((ref) {
  return SyncManager();
});
