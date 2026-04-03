
/// Daily Fuel Reconciliation Model
/// Tracks tank stock reconciliation to detect theft/leakage
class Reconciliation {
  final String id;
  final String tankId;
  final String fuelType;
  final DateTime date;
  final double openingStock; // Tank opening stock (from previous day)
  final double purchaseQty; // Fuel purchased during the day
  final double systemSales; // Auto-calculated from sales
  final double expectedStock; // Opening + Purchase - Sales
  final double actualDip; // Manual dip reading
  final double difference; // Actual - Expected
  final ReconciliationStatus status;
  final String? notes;
  final DateTime createdAt;

  Reconciliation({
    required this.id,
    required this.tankId,
    required this.fuelType,
    required this.date,
    required this.openingStock,
    required this.purchaseQty,
    required this.systemSales,
    required this.actualDip,
    this.notes,
    DateTime? createdAt,
  }) : expectedStock = openingStock + purchaseQty - systemSales,
       difference = (openingStock + purchaseQty - systemSales) - actualDip,
       status = _calculateStatus(
         openingStock + purchaseQty - systemSales,
         actualDip,
       ),
       createdAt = createdAt ?? DateTime.now();

  static ReconciliationStatus _calculateStatus(double expected, double actual) {
    final diff = actual - expected;
    final absDiff = diff.abs();

    // Tolerance: 0.5% or 50 liters (whichever is less)
    final tolerance = expected * 0.005 < 50 ? expected * 0.005 : 50.0;

    if (absDiff <= tolerance) {
      return ReconciliationStatus.ok;
    } else if (diff > 0 && absDiff <= tolerance * 2) {
      // Possible under-reading (more fuel than expected)
      return ReconciliationStatus.warning;
    } else if (diff < 0 && absDiff <= tolerance * 2) {
      // Possible leak or theft
      return ReconciliationStatus.warning;
    } else if (diff < 0 && absDiff > tolerance * 2) {
      // Significant loss - possible theft
      return ReconciliationStatus.theft;
    } else {
      // Significant gain - possible meter issue
      return ReconciliationStatus.warning;
    }
  }

  factory Reconciliation.fromMap(Map<String, dynamic> map) {
    return Reconciliation(
      id: map['id'],
      tankId: map['tank_id'],
      fuelType: map['fuel_type'],
      date: DateTime.parse(map['date']),
      openingStock: (map['opening_stock'] as num).toDouble(),
      purchaseQty: (map['purchase_qty'] as num).toDouble(),
      systemSales: (map['system_sales'] as num).toDouble(),
      actualDip: (map['actual_dip'] as num).toDouble(),
      notes: map['notes'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tank_id': tankId,
      'fuel_type': fuelType,
      'date': date.toIso8601String(),
      'opening_stock': openingStock,
      'purchase_qty': purchaseQty,
      'system_sales': systemSales,
      'expected_stock': expectedStock,
      'actual_dip': actualDip,
      'difference': difference,
      'status': status.name,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get statusDisplay {
    switch (status) {
      case ReconciliationStatus.ok:
        return '✅ OK';
      case ReconciliationStatus.warning:
        return '⚠️ Warning';
      case ReconciliationStatus.theft:
        return '❌ Theft/Leak';
    }
  }

  Color get statusColor {
    switch (status) {
      case ReconciliationStatus.ok:
        return const Color(0xFF22C55E); // Green
      case ReconciliationStatus.warning:
        return const Color(0xFFF59E0B); // Yellow
      case ReconciliationStatus.theft:
        return const Color(0xFFEF4444); // Red
    }
  }
}

enum ReconciliationStatus { ok, warning, theft }

/// Tank dip reading history
class TankDipReading {
  final String id;
  final String tankId;
  final DateTime timestamp;
  final double dipLevel;
  final DipReadingType type; // Opening, Closing, Manual
  final String? notes;

  TankDipReading({
    required this.id,
    required this.tankId,
    required this.timestamp,
    required this.dipLevel,
    required this.type,
    this.notes,
  });

  factory TankDipReading.fromMap(Map<String, dynamic> map) {
    return TankDipReading(
      id: map['id'],
      tankId: map['tank_id'],
      timestamp: DateTime.parse(map['timestamp']),
      dipLevel: (map['dip_level'] as num).toDouble(),
      type: DipReadingType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => DipReadingType.manual,
      ),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tank_id': tankId,
      'timestamp': timestamp.toIso8601String(),
      'dip_level': dipLevel,
      'type': type.name,
      'notes': notes,
    };
  }
}

enum DipReadingType { opening, closing, manual }

// Extension for Color since we can't import Flutter in model
class Color {
  final int value;
  const Color(this.value);
}
