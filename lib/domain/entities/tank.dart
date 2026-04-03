/// ⛽ Tank Entity (Domain Layer)
class Tank {
  final String id;
  final String shopId;
  final String name;
  final String type; // Petrol, Diesel, CNG
  final double capacity;
  final double currentStock;
  final double lowStockAlert;
  final DateTime? lastDipDate;
  final double? lastDipReading;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Tank({
    required this.id,
    required this.shopId,
    required this.name,
    required this.type,
    required this.capacity,
    required this.currentStock,
    this.lowStockAlert = 50,
    this.lastDipDate,
    this.lastDipReading,
    this.syncStatus = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate stock percentage
  double get stockPercentage => (currentStock / capacity) * 100;

  /// Check if low stock alert
  bool get isLowStock => currentStock < lowStockAlert;

  Tank copyWith({
    String? id,
    String? shopId,
    String? name,
    String? type,
    double? capacity,
    double? currentStock,
    double? lowStockAlert,
    DateTime? lastDipDate,
    double? lastDipReading,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tank(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      type: type ?? this.type,
      capacity: capacity ?? this.capacity,
      currentStock: currentStock ?? this.currentStock,
      lowStockAlert: lowStockAlert ?? this.lowStockAlert,
      lastDipDate: lastDipDate ?? this.lastDipDate,
      lastDipReading: lastDipReading ?? this.lastDipReading,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
