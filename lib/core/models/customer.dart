class Customer {
  final String id;
  final String name;
  final String phone;
  final String? vehicle;
  final double balance;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.vehicle,
    this.balance = 0.0,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      vehicle: map['vehicle'],
      balance: (map['balance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'vehicle': vehicle,
      'balance': balance,
    };
  }
}
