import 'package:flutter/foundation.dart';
import '../datasources/remote/fuel_sale_remote_datasource.dart';
import '../models/fuel_sale_model.dart';
import '../../domain/entities/fuel_sale.dart';

/// 🔁 FuelSale Repository (Core Logic)
/// Coordinates between remote and local data sources
class FuelSaleRepository {
  final FuelSaleRemoteDataSource _remote;

  FuelSaleRepository(this._remote);

  /// Add a new sale (saves locally first for offline-first)
  Future<void> addSale(FuelSaleModel sale) async {
    await _remote.insertSale(sale);
  }

  /// Update an existing sale
  Future<void> updateSale(String id, Map<String, dynamic> data) async {
    await _remote.updateSale(id, data);
  }

  /// Delete a sale
  Future<void> deleteSale(String id) async {
    await _remote.deleteSale(id);
  }

  /// Get all sales for a shop
  Future<List<FuelSale>> getSales(String shopId) async {
    final models = await _remote.fetchSales(shopId);
    return models.map((m) => m.toEntity()).toList();
  }

  /// Get today's sales
  Future<List<FuelSale>> getTodaySales(String shopId) async {
    final models = await _remote.fetchTodaySales(shopId);
    return models.map((m) => m.toEntity()).toList();
  }

  /// Get sales summary
  Future<Map<String, dynamic>> getSalesSummary(
    String shopId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _remote.getSalesSummary(
      shopId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Sync pending local sales to remote
  Future<void> syncPending(String shopId) async {
    final pending = await _remote.fetchPending(shopId);

    for (var sale in pending) {
      try {
        await _remote.insertSale(sale);
        await _remote.markSynced(sale.id);
      } catch (e) {
        // Log error but continue with next item
        debugPrint('Failed to sync sale ${sale.id}: $e');
      }
    }
  }

  /// Pull updates from remote (Delta Sync)
  Future<List<FuelSale>> pullUpdates(DateTime lastSync, String shopId) async {
    final models = await _remote.fetchUpdated(lastSync, shopId);
    return models.map((m) => m.toEntity()).toList();
  }

  /// Stream real-time sales updates
  Stream<List<FuelSale>> streamSales(String shopId) {
    return _remote
        .streamSales(shopId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }
}
