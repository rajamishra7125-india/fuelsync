/// 🛢️ FuelSale Entity (Domain Layer)
/// Core business object - no implementation details
class FuelSale {
  final String id;
  final String shopId;
  final String? nozzleId;
  final String? shiftId;
  final String? vehicleNumber;
  final String? customerName;
  final String fuelType;
  final double rate;
  final double litres;
  final double amount;
  final String paymentMode;
  final String paymentStatus; // pending, confirmed, failed
  final String? referenceNumber;
  final String? customerProofUrl;
  final String syncStatus; // pending, synced, deleted
  final DateTime createdAt;
  final DateTime updatedAt;

  const FuelSale({
    required this.id,
    required this.shopId,
    this.nozzleId,
    this.shiftId,
    this.vehicleNumber,
    this.customerName,
    required this.fuelType,
    required this.rate,
    required this.litres,
    required this.amount,
    required this.paymentMode,
    this.paymentStatus = 'pending',
    this.referenceNumber,
    this.customerProofUrl,
    this.syncStatus = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Copy with method for immutable updates
  FuelSale copyWith({
    String? id,
    String? shopId,
    String? nozzleId,
    String? shiftId,
    String? vehicleNumber,
    String? customerName,
    String? fuelType,
    double? rate,
    double? litres,
    double? amount,
    String? paymentMode,
    String? paymentStatus,
    String? referenceNumber,
    String? customerProofUrl,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FuelSale(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      nozzleId: nozzleId ?? this.nozzleId,
      shiftId: shiftId ?? this.shiftId,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      customerName: customerName ?? this.customerName,
      fuelType: fuelType ?? this.fuelType,
      rate: rate ?? this.rate,
      litres: litres ?? this.litres,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      customerProofUrl: customerProofUrl ?? this.customerProofUrl,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
