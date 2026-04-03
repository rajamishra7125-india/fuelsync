class PetrolPump {
  final String id;
  final String name;
  final String ownerId;
  final String? address;
  final String? gst;

  PetrolPump({
    required this.id,
    required this.name,
    required this.ownerId,
    this.address,
    this.gst,
  });

  factory PetrolPump.fromMap(Map<String, dynamic> map) {
    return PetrolPump(
      id: map['id'],
      name: map['name'],
      ownerId: map['owner_id'],
      address: map['address'],
      gst: map['gst'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'owner_id': ownerId,
      'address': address,
      'gst': gst,
    };
  }
}
