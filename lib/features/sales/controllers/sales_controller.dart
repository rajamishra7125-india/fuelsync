import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../core/services/storage_service.dart';
import '../../../core/services/local_database_service.dart';

class SalesController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> saveSale({
    required String nozzleId,
    required double amount,
    required double litres,
    required String paymentType,
    File? proofImage,
  }) async {
    state = const AsyncValue.loading();
    try {
      final storageService = StorageService();
      final localDb = LocalDatabaseService();

      String? imageUrl;
      if (proofImage != null) {
        imageUrl = await storageService.uploadProof(
          file: proofImage,
          bucket: 'fuelsync_proofs',
          folder: 'sales',
        );
      }

      final saleData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'nozzle_id': nozzleId,
        'amount': amount,
        'litres': litres,
        'payment_type': paymentType,
        'image_path': imageUrl ?? proofImage?.path ?? '',
        'is_synced': imageUrl != null ? 1 : 0,
        'created_at': DateTime.now().toIso8601String(),
      };

      await localDb.saveOfflineSale(saleData);
      state = const AsyncValue.data(null);
      return imageUrl != null;
    } catch (e, st) {
      debugPrint('Save Sale Error: $e');
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final salesControllerProvider =
    NotifierProvider<SalesController, AsyncValue<void>>(SalesController.new);
