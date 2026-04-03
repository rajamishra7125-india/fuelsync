import '../../domain/entities/fuel_sale.dart';

/// 🛢️ FuelSaleModel (Data Layer)
/// Extends domain entity with JSON serialization
class FuelSaleModel extends FuelSale {
  const FuelSaleModel({
    required super.id,
    required super.shopId,
    super.nozzleId,
    super.shiftId,
    super.vehicleNumber,
    super.customerName,
    required super.fuelType,
    required super.rate,
    required super.litres,
    required super.amount,
    required super.paymentMode,
    super.paymentStatus,
    super.referenceNumber,
    super.customerProofUrl,
    super.syncStatus,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from JSON (Supabase response)
  factory FuelSaleModel.fromJson(Map<String, dynamic> json) {
    return FuelSaleModel(
      id: json['id'] ?? '',
      shopId: json['shop_id'] ?? '',
      nozzleId: json['nozzle_id'],
      shiftId: json['shift_id'],
      vehicleNumber: json['vehicle_number'],
      customerName: json['customer_name'],
      fuelType: json['fuel_type'] ?? 'Petrol',
      rate: (json['rate'] as num?)?.toDouble() ?? 0,
      litres: (json['litres'] as num?)?.toDouble() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentMode: json['payment_mode'] ?? 'Cash',
      paymentStatus: json['payment_status'] ?? 'pending',
      referenceNumber: json['reference_number'],
      customerProofUrl: json['customer_proof_url'],
      syncStatus: json['sync_status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  /// Convert to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'nozzle_id': nozzleId,
      'shift_id': shiftId,
      'vehicle_number': vehicleNumber,
      'customer_name': customerName,
      'fuel_type': fuelType,
      'rate': rate,
      'litres': litres,
      'amount': amount,
      'payment_mode': paymentMode,
      'payment_status': paymentStatus,
      'reference_number': referenceNumber,
      'customer_proof_url': customerProofUrl,
      'sync_status': syncStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from domain entity
  factory FuelSaleModel.fromEntity(FuelSale entity) {
    return FuelSaleModel(
      id: entity.id,
      shopId: entity.shopId,
      nozzleId: entity.nozzleId,
      shiftId: entity.shiftId,
      vehicleNumber: entity.vehicleNumber,
      customerName: entity.customerName,
      fuelType: entity.fuelType,
      rate: entity.rate,
      litres: entity.litres,
      amount: entity.amount,
      paymentMode: entity.paymentMode,
      paymentStatus: entity.paymentStatus,
      referenceNumber: entity.referenceNumber,
      customerProofUrl: entity.customerProofUrl,
      syncStatus: entity.syncStatus,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to domain entity
  FuelSale toEntity() {
    return FuelSale(
      id: id,
      shopId: shopId,
      nozzleId: nozzleId,
      shiftId: shiftId,
      vehicleNumber: vehicleNumber,
      customerName: customerName,
      fuelType: fuelType,
      rate: rate,
      litres: litres,
      amount: amount,
      paymentMode: paymentMode,
      paymentStatus: paymentStatus,
      referenceNumber: referenceNumber,
      customerProofUrl: customerProofUrl,
      syncStatus: syncStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
