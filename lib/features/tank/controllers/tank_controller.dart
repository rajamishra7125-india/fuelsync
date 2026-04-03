import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../core/services/storage_service.dart';
import '../../../core/services/local_database_service.dart';

class TankController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> recordPurchase({
    required String supplier,
    required double quantity,
    required double rate,
    File? invoiceImage,
  }) async {
    state = const AsyncValue.loading();
    try {
      final storageService = StorageService();
      final localDb = LocalDatabaseService();

      String? imageUrl;
      if (invoiceImage != null) {
        imageUrl = await storageService.uploadProof(
          file: invoiceImage,
          bucket: 'fuelsync_proofs',
          folder: 'purchases',
        );
      }

      final purchaseData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'supplier': supplier,
        'quantity': quantity,
        'rate': rate,
        'image_path': imageUrl ?? invoiceImage?.path ?? '',
        'is_synced': imageUrl != null ? 1 : 0,
        'created_at': DateTime.now().toIso8601String(),
      };

      await localDb.saveOfflinePurchase(purchaseData);
      state = const AsyncValue.data(null);
      return imageUrl != null;
    } catch (e, st) {
      debugPrint('Purchase Error: $e');
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final tankControllerProvider =
    NotifierProvider<TankController, AsyncValue<void>>(TankController.new);
