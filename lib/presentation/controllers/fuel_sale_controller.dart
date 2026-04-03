import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../data/datasources/remote/fuel_sale_remote_datasource.dart';
import '../../data/repositories/fuel_sale_repository.dart';
import '../../data/models/fuel_sale_model.dart';
import '../../domain/entities/fuel_sale.dart';
import '../../core/services/storage_service.dart';

/// ⚡ Repository Provider
final fuelSaleRemoteDataSourceProvider = Provider<FuelSaleRemoteDataSource>((
  ref,
) {
  return FuelSaleRemoteDataSource();
});

final fuelSaleRepositoryProvider = Provider<FuelSaleRepository>((ref) {
  final remote = ref.read(fuelSaleRemoteDataSourceProvider);
  return FuelSaleRepository(remote);
});

/// ⚡ Notifier Controller for Fuel Sales
class FuelSaleController extends Notifier<AsyncValue<List<FuelSale>>> {
  late final FuelSaleRepository _repo;
  late final String _shopId;

  @override
  AsyncValue<List<FuelSale>> build() {
    _repo = ref.read(fuelSaleRepositoryProvider);
    _shopId = 'default-shop'; // Or fetch from storage service
    return const AsyncValue.loading();
  }

  /// Load all sales
  Future<void> loadSales() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getSales(_shopId));
  }

  /// Add a new sale
  Future<void> addSale(FuelSaleModel sale) async {
    state = const AsyncValue.loading();
    try {
      await _repo.addSale(sale);
      await loadSales(); // Refresh list
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update a sale
  Future<void> updateSale(String id, Map<String, dynamic> data) async {
    try {
      await _repo.updateSale(id, data);
      await loadSales();
    } catch (e) {
      debugPrint('Failed to update sale: $e');
    }
  }

  /// Delete a sale
  Future<void> deleteSale(String id) async {
    try {
      await _repo.deleteSale(id);
      await loadSales();
    } catch (e) {
      debugPrint('Failed to delete sale: $e');
    }
  }

  /// Sync pending sales
  Future<void> syncPending() async {
    try {
      await _repo.syncPending(_shopId);
    } catch (e) {
      debugPrint('Sync failed: $e');
    }
  }
}

/// ⚡ Main Provider for FuelSaleController
final fuelSaleControllerProvider =
    NotifierProvider<FuelSaleController, AsyncValue<List<FuelSale>>>(
      FuelSaleController.new,
    );

/// ⚡ Today's Sales Provider
final todaySalesProvider = FutureProvider<List<FuelSale>>((ref) async {
  final repo = ref.watch(fuelSaleRepositoryProvider);
  final storage = StorageService();
  final shopId = await storage.getShopId() ?? 'default-shop';

  return await repo.getTodaySales(shopId);
});

/// ⚡ Sales Summary Provider
final salesSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(fuelSaleRepositoryProvider);
  final storage = StorageService();
  final shopId = await storage.getShopId() ?? 'default-shop';

  return await repo.getSalesSummary(shopId);
});
