import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sackmman_cart_b2b/model/order_item.dart';

class OrderData {
  final String id;
  final String store;
  final double totalAmount;
  final double received;
  final DateTime createdAt;
  final List<OrderItem> items;

  OrderData({
    required this.id,
    required this.store,
    required this.totalAmount,
    required this.received,
    required this.createdAt,
    required this.items,
  });

  factory OrderData.fromJson(Map<String, dynamic> map) {
    return OrderData(
      id: map['id'],
      store: map['store'],
      totalAmount: (map['totalAmount'] as num).toDouble(),
      received: (map['received'] as num).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      items: List<Map<String, dynamic>>.from(
        map['items'],
      ).map((item) => OrderItem.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store': store,
      'totalAmount': totalAmount,
      'received': received,
      'createdAt': Timestamp.fromDate(createdAt),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory OrderData.initial() {
    return OrderData(
      id: '',
      store: '',
      totalAmount: 0.0,
      received: 0.0,
      createdAt: DateTime.now(),
      items: [],
    );
  }
}
