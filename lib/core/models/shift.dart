class Shift {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final double openingCash;
  final double? closingCash;
  final String? cashPhoto;
  final Map<String, double> nozzleOpenings;
  final Map<String, double>? nozzleClosings;

  Shift({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.openingCash,
    this.closingCash,
    this.cashPhoto,
    required this.nozzleOpenings,
    this.nozzleClosings,
  });

  factory Shift.fromMap(Map<String, dynamic> map) {
    return Shift(
      id: map['id'],
      userId: map['user_id'],
      startTime: DateTime.parse(map['start_time']),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      openingCash: (map['opening_cash'] as num).toDouble(),
      closingCash: map['closing_cash'] != null
          ? (map['closing_cash'] as num).toDouble()
          : null,
      cashPhoto: map['cash_photo'],
      nozzleOpenings: Map<String, double>.from(map['nozzle_openings'] ?? {}),
      nozzleClosings: map['nozzle_closings'] != null
          ? Map<String, double>.from(map['nozzle_closings'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'opening_cash': openingCash,
      'closing_cash': closingCash,
      'cash_photo': cashPhoto,
      'nozzle_openings': nozzleOpenings,
      'nozzle_closings': nozzleClosings,
    };
  }
}
