import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fuel_sale_model.dart';

/// 🔌 FuelSale Remote DataSource (Supabase)
/// Handles all Supabase database operations for fuel sales
class FuelSaleRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  /// Insert a new fuel sale
  Future<void> insertSale(FuelSaleModel sale) async {
    await _client.from('fuel_sales').insert(sale.toJson());
  }

  /// Update an existing fuel sale
  Future<void> updateSale(String id, Map<String, dynamic> data) async {
    await _client.from('fuel_sales').update(data).eq('id', id);
  }

  /// Delete a fuel sale
  Future<void> deleteSale(String id) async {
    await _client.from('fuel_sales').delete().eq('id', id);
  }

  /// Fetch all sales for a shop
  Future<List<FuelSaleModel>> fetchSales(String shopId) async {
    final data = await _client
        .from('fuel_sales')
        .select()
        .eq('shop_id', shopId)
        .order('created_at', ascending: false);

    return data.map((e) => FuelSaleModel.fromJson(e)).toList();
  }

  /// Fetch sales updated after a specific time (Delta Sync)
  Future<List<FuelSaleModel>> fetchUpdated(
    DateTime lastSync,
    String shopId,
  ) async {
    final data = await _client
        .from('fuel_sales')
        .select()
        .eq('shop_id', shopId)
        .gt('updated_at', lastSync.toIso8601String());

    return data.map((e) => FuelSaleModel.fromJson(e)).toList();
  }

  /// Fetch pending sales (for sync)
  Future<List<FuelSaleModel>> fetchPending(String shopId) async {
    final data = await _client
        .from('fuel_sales')
        .select()
        .eq('shop_id', shopId)
        .eq('sync_status', 'pending');

    return data.map((e) => FuelSaleModel.fromJson(e)).toList();
  }

  /// Fetch today's sales for a shop
  Future<List<FuelSaleModel>> fetchTodaySales(String shopId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final data = await _client
        .from('fuel_sales')
        .select()
        .eq('shop_id', shopId)
        .gte('created_at', startOfDay.toIso8601String());

    return data.map((e) => FuelSaleModel.fromJson(e)).toList();
  }

  /// Get sales summary for a date range
  Future<Map<String, dynamic>> getSalesSummary(
    String shopId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _client
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

    double totalAmount = 0;
    double totalLitres = 0;
    Map<String, double> byFuelType = {};

    for (var sale in sales) {
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
      'count': sales.length,
    };
  }

  /// Mark sale as synced
  Future<void> markSynced(String id) async {
    await _client
        .from('fuel_sales')
        .update({
          'sync_status': 'synced',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  /// Stream real-time sales updates
  Stream<List<FuelSaleModel>> streamSales(String shopId) {
    return _client
        .from('fuel_sales')
        .stream(primaryKey: ['id'])
        .map(
          (data) => data
              .where((item) => item['shop_id'] == shopId)
              .map((e) => FuelSaleModel.fromJson(e))
              .toList(),
        );
  }
}
