class Item {
  String id;
  String name;
  String unit;
  double rate;

  Item({
    required this.id,
    required this.name,
    required this.rate,
    required this.unit,
  });

  factory Item.fromJson(Map json) {
    return Item(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      rate: json['rate'].toDouble() ?? 0.0,
      unit: json['perUnit'] ?? '',
    );
  }

  factory Item.initial() {
    return Item(id: '', name: '', rate: 0, unit: '');
  }
}
