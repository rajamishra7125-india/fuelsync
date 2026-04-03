import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

/// 🔌 SUPABASE SERVICE - Core API Layer
/// Provides generic CRUD operations with shop filtering and sync support
class SupabaseService {
  static const supabaseUrl = 'https://lpkircyqajvfkxomrsgt.supabase.co';
  static const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxwa2lyY3lxYWp2Zmt4b21yc2d0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyMTg4NTEsImV4cCI6MjA4OTc5NDg1MX0.1OqVMet-XCxo6k9ttRbDEQ_sMs6ao4JnBd1NhpBRyhU';

  // Current shop ID for filtering (set after login)
  String? _currentShopId;

  String? get currentShopId => _currentShopId;

  void setCurrentShop(String shopId) {
    _currentShopId = shopId;
  }

  void clearCurrentShop() {
    _currentShopId = null;
  }

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    } catch (e) {
      debugPrint('Supabase Init error: $e');
    }
  }

  SupabaseClient get client => Supabase.instance.client;
  GoTrueClient get auth => client.auth;
  PostgrestClient get database => client.rest;
  SupabaseStorageClient get storage => client.storage;

  // ============================================
  // 🟣 GENERIC CRUD OPERATIONS
  // ============================================

  /// Insert a new record
  Future<Map<String, dynamic>?> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await client.from(table).insert(data).select().single();
      return response;
    } catch (e) {
      debugPrint('Supabase insert error on $table: $e');
      return null;
    }
  }

  /// Update an existing record by ID
  Future<bool> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await client.from(table).update(data).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Supabase update error on $table: $e');
      return false;
    }
  }

  /// Delete a record by ID
  Future<bool> delete(String table, String id) async {
    try {
      await client.from(table).delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Supabase delete error on $table: $e');
      return false;
    }
  }

  /// Fetch all records from a table
  Future<List<Map<String, dynamic>>> fetch(String table) async {
    try {
      final response = await client.from(table).select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Supabase fetch error on $table: $e');
      return [];
    }
  }

  /// Fetch a single record by ID
  Future<Map<String, dynamic>?> fetchById(String table, String id) async {
    try {
      final response = await client.from(table).select().eq('id', id).single();
      return response;
    } catch (e) {
      debugPrint('Supabase fetchById error on $table: $e');
      return null;
    }
  }

  // ============================================
  // 🔍 FILTER BY SHOP (Multi-Company Support)
  // ============================================

  /// Fetch all records filtered by shop_id
  Future<List<Map<String, dynamic>>> fetchByShop(
    String table,
    String shopId,
  ) async {
    try {
      final response = await client.from(table).select().eq('shop_id', shopId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Supabase fetchByShop error on $table: $e');
      return [];
    }
  }

  // ============================================
  // 🔄 SMART SYNC - Delta Sync (Only Changed Data)
  // ============================================

  /// Fetch records updated after a specific timestamp (delta sync)
  Future<List<Map<String, dynamic>>> fetchUpdatedSince(
    String table,
    DateTime since, {
    String? shopId,
  }) async {
    try {
      var query = client
          .from(table)
          .select()
          .gt('updated_at', since.toIso8601String());

      if (shopId != null) {
        query = query.eq('shop_id', shopId);
      }

      return List<Map<String, dynamic>>.from(await query);
    } catch (e) {
      debugPrint('Supabase fetchUpdatedSince error on $table: $e');
      return [];
    }
  }

  /// Fetch records with sync_status = 'pending'
  Future<List<Map<String, dynamic>>> fetchPending(String table) async {
    try {
      final response = await client
          .from(table)
          .select()
          .eq('sync_status', 'pending');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Supabase fetchPending error on $table: $e');
      return [];
    }
  }

  /// Mark record as synced
  Future<bool> markSynced(String table, String id) async {
    return update(table, id, {
      'sync_status': 'synced',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Mark multiple records as synced
  Future<void> markMultipleSynced(String table, List<String> ids) async {
    for (var id in ids) {
      await markSynced(table, id);
    }
  }

  // ============================================
  // 📡 REAL-TIME SYNC - Listen to Changes
  // ============================================

  /// Subscribe to real-time changes on a table
  Stream<List<Map<String, dynamic>>> streamTable(
    String table, {
    String? shopId,
  }) {
    var stream = client.from(table).stream(primaryKey: ['id']);

    if (shopId != null) {
      return stream.map((data) {
        return data
            .where((item) => item['shop_id'] == shopId)
            .toList()
            .cast<Map<String, dynamic>>();
      });
    }

    return stream.map((data) => List<Map<String, dynamic>>.from(data));
  }

  /// Subscribe to changes on fuel_sales (for dashboard live updates)
  Stream<List<Map<String, dynamic>>> streamSales({String? shopId}) {
    return streamTable('fuel_sales', shopId: shopId);
  }

  // ============================================
  // 📸 FILE UPLOAD - Proof System
  // ============================================

  /// Upload proof image to storage
  Future<String?> uploadProof(String path, List<int> bytes) async {
    try {
      final uint8Bytes = Uint8List.fromList(bytes);
      await client.storage
          .from('fuelsync_proofs')
          .uploadBinary(path, uint8Bytes);

      final urlResponse = client.storage
          .from('fuelsync_proofs')
          .getPublicUrl(path);
      return urlResponse;
    } catch (e) {
      debugPrint('Supabase upload error: $e');
      return null;
    }
  }

  /// Upload customer/vehicle proof during sale
  Future<String?> uploadSaleProof(String saleId, List<int> imageBytes) async {
    return uploadProof('sales/$saleId.jpg', imageBytes);
  }

  // ============================================
  // 🔐 AUTH OPERATIONS
  // ============================================

  /// Login with email/password (Admin)
  Future<AuthResponse?> loginWithEmail(String email, String password) async {
    try {
      return await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Supabase login error: $e');
      return null;
    }
  }

  /// Sign up new user
  Future<AuthResponse?> signUp(String email, String password) async {
    try {
      return await client.auth.signUp(email: email, password: password);
    } catch (e) {
      debugPrint('Supabase signup error: $e');
      return null;
    }
  }

  /// Logout
  Future<void> logout() async {
    await client.auth.signOut();
    clearCurrentShop();
  }

  /// Get current user
  User? get currentUser => client.auth.currentUser;

  // ============================================
  // 🏪 SHOP OPERATIONS
  // ============================================

  /// Get shop by shop_code
  Future<Map<String, dynamic>?> getShopByCode(String shopCode) async {
    try {
      final response = await client
          .from('shops')
          .select()
          .eq('shop_code', shopCode)
          .single();
      return response;
    } catch (e) {
      debugPrint('Supabase getShopByCode error: $e');
      return null;
    }
  }

  /// Create new shop
  Future<Map<String, dynamic>?> createShop(
    Map<String, dynamic> shopData,
  ) async {
    return insert('shops', shopData);
  }

  // ============================================
  // 💰 FUEL SALES OPERATIONS
  // ============================================

  /// Create a new fuel sale
  Future<Map<String, dynamic>?> createFuelSale(
    Map<String, dynamic> saleData,
  ) async {
    return insert('fuel_sales', saleData);
  }

  /// Get today's sales for a shop
  Future<List<Map<String, dynamic>>> getTodaySales(String shopId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    try {
      final response = await client
          .from('fuel_sales')
          .select()
          .eq('shop_id', shopId)
          .gte('created_at', startOfDay.toIso8601String());
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Supabase getTodaySales error: $e');
      return [];
    }
  }

  /// Get sales summary for a date range
  Future<Map<String, dynamic>> getSalesSummary(
    String shopId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = client
          .from('fuel_sales')
          .select('amount, litres, fuel_type')
          .eq('shop_id', shopId);

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final sales = await query;
      final salesList = List<Map<String, dynamic>>.from(sales);

      double totalAmount = 0;
      double totalLitres = 0;
      Map<String, double> byFuelType = {};

      for (var sale in salesList) {
        final amount = (sale['amount'] as num?)?.toDouble() ?? 0;
        final litres = (sale['litres'] as num?)?.toDouble() ?? 0;
        final fuelType = sale['fuel_type'] as String? ?? 'Unknown';

        totalAmount += amount;
        totalLitres += litres;
        byFuelType[fuelType] = (byFuelType[fuelType] ?? 0) + amount;
      }

      return {
        'total_amount': totalAmount,
        'total_litres': totalLitres,
        'by_fuel_type': byFuelType,
        'count': salesList.length,
      };
    } catch (e) {
      debugPrint('Supabase getSalesSummary error: $e');
      return {
        'total_amount': 0,
        'total_litres': 0,
        'by_fuel_type': {},
        'count': 0,
      };
    }
  }

  // ============================================
  // ⛽ TANK OPERATIONS
  // ============================================

  /// Get all tanks for a shop
  Future<List<Map<String, dynamic>>> getTanks(String shopId) async {
    return fetchByShop('tanks', shopId);
  }

  /// Update tank stock
  Future<bool> updateTankStock(String tankId, double newStock) async {
    return update('tanks', tankId, {
      'current_stock': newStock,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ============================================
  // 👥 CUSTOMER OPERATIONS
  // ============================================

  /// Get all customers for a shop
  Future<List<Map<String, dynamic>>> getCustomers(String shopId) async {
    return fetchByShop('customers', shopId);
  }

  /// Update customer balance
  Future<bool> updateCustomerBalance(
    String customerId,
    double newBalance,
  ) async {
    return update('customers', customerId, {
      'current_balance': newBalance,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ============================================
  // 📊 DASHBOARD DATA
  // ============================================

  /// Get dashboard data for a shop
  Future<Map<String, dynamic>> getDashboardData(String shopId) async {
    try {
      final results = await Future.wait<List<Map<String, dynamic>>>([
        getTodaySales(shopId),
        getTanks(shopId),
        fetchByShop('customers', shopId),
        fetchByShop('daily_reconciliation', shopId),
      ]);

      final todaySales = results[0];
      final tanks = results[1];
      final customers = results[2];
      final reconciliations = results[3];

      double todayTotal = 0;
      for (var sale in todaySales) {
        todayTotal += (sale['amount'] as num?)?.toDouble() ?? 0;
      }

      final lowStockTanks = tanks.where((tank) {
        final current = (tank['current_stock'] as num?)?.toDouble() ?? 0;
        final alert = (tank['low_stock_alert'] as num?)?.toDouble() ?? 50;
        return current < alert;
      }).toList();

      final pendingCredit = customers
          .where((c) => ((c['current_balance'] as num?)?.toDouble() ?? 0) > 0)
          .length;

      final pendingRecons = reconciliations
          .where((r) => r['status'] == 'pending' || r['status'] == 'theft')
          .length;

      return {
        'today_sales_total': todayTotal,
        'today_sales_count': todaySales.length,
        'tanks': tanks,
        'low_stock_tanks': lowStockTanks,
        'customers_with_pending_credit': pendingCredit,
        'pending_reconciliations': pendingRecons,
        'open_issues': 0,
      };
    } catch (e) {
      debugPrint('Supabase getDashboardData error: $e');
      return {
        'today_sales_total': 0.0,
        'today_sales_count': 0,
        'tanks': <Map<String, dynamic>>[],
        'low_stock_tanks': <Map<String, dynamic>>[],
        'customers_with_pending_credit': 0,
        'pending_reconciliations': 0,
        'open_issues': 0,
      };
    }
  }
}

/// Provider for SupabaseService
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});
