class OrderItem {
  String name;
  String unit;
  double rate;
  double qty;

  OrderItem({
    required this.name,
    required this.rate,
    required this.unit,
    required this.qty,
  });

  factory OrderItem.fromJson(Map json) {
    return OrderItem(
      name: json['name'] ?? '',
      rate: json['rate'].toDouble() ?? 0.0,
      unit: json['perUnit'] ?? '',
      qty: json['qty'].toDouble() ?? 0
    );
  }

  factory OrderItem.initial() {
    return OrderItem(name: '', rate: 0, unit: '', qty: 0);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'qty': qty,
      'rate': rate,
      'perUnit': unit
    };
  }
}
