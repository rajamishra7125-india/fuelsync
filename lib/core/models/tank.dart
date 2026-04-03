class Tank {
  final String id;
  final String fuelType;
  final double capacity;
  final double currentStock;

  Tank({
    required this.id,
    required this.fuelType,
    required this.capacity,
    required this.currentStock,
  });

  factory Tank.fromMap(Map<String, dynamic> map) {
    return Tank(
      id: map['id'],
      fuelType: map['fuel_type'],
      capacity: (map['capacity'] as num).toDouble(),
      currentStock: (map['current_stock'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fuel_type': fuelType,
      'capacity': capacity,
      'current_stock': currentStock,
    };
  }
}

class Purchase {
  final String id;
  final String tankId;
  final double quantity;
  final double rate;
  final String? supplier;
  final String? invoiceImage;
  final DateTime createdAt;

  Purchase({
    required this.id,
    required this.tankId,
    required this.quantity,
    required this.rate,
    this.supplier,
    this.invoiceImage,
    required this.createdAt,
  });
}
