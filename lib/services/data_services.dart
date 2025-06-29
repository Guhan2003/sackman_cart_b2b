import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sackmman_cart_b2b/controller/order_controller.dart';
import 'package:sackmman_cart_b2b/model/order_item.dart';

class DataServices {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  final CollectionReference utilsCollection = FirebaseFirestore.instance
      .collection('utils');
  final CollectionReference itemCollection = FirebaseFirestore.instance
      .collection('items');
  final CollectionReference ordersCollection = FirebaseFirestore.instance
      .collection('orders');

  Future<List<String>> getStoreList() async {
    final DocumentSnapshot stores = await utilsCollection.doc('stores').get();
    final data = stores.data() as Map<String, dynamic>;
    final rawList = data['storeList'];

    if (rawList == null) return [];

    return List<String>.from(rawList);
  }

  Future<List<Map>> getItems() async {
    QuerySnapshot rawItems = await itemCollection.get();
    final items = rawItems.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();
    return items;
  }

  Future addItem({
    required name,
    required String unit,
    required double rate,
    required context,
  }) async {
    try {
      Map<String, dynamic> empty = {};
      final docRef = await itemCollection.add(empty);
      Map<String, dynamic> item = {
        'id': docRef.id,
        'name': name,
        'perUnit': unit,
        'rate': rate,
      };
      await docRef.set(item);
      Fluttertoast.showToast(msg: 'Item added successfully');
    } catch (e) {
      print('error: $e');
      Fluttertoast.showToast(msg: 'Failed to add item');
    }
  }

  Future updateItem({
    required String id,
    required String name,
    required String unit,
    required double rate,
    required context,
  }) async {
    try {
      Map<String, dynamic> item = {
        'id': id,
        'name': name,
        'perUnit': unit,
        'rate': rate,
      };
      await itemCollection.doc(id).update(item);
      Fluttertoast.showToast(msg: 'Item updated successfully');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to update the item');
    }
  }

  Future placeOrder({
    required String store,
    required List<OrderItem> orderItems,
    required DateTime date,
    required context,
    required OrderController orderController,
  }) async {
    try {
      Map<String, dynamic> empty = {};
      final orderId = await ordersCollection.add(empty);
      double total = 0;
      List<Map<String, dynamic>> items = orderItems.map((element) {
        total += element.qty * element.rate;
        return {
          "name": element.name,
          "qty": element.qty,
          "rate": element.rate,
          "perUnit": element.unit,
        };
      }).toList();

      Map<String, dynamic> data = {
        "id": orderId.id,
        "items": items,
        "store": store,
        "createdAt": Timestamp.fromDate(date),
        "totalAmount": total,
        "received": 0,
      };
      await orderId.set(data);
      orderController.orderItemList.clear();
      orderController.selectedStore = '';
      Fluttertoast.showToast(msg: 'Order Placed successfully');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to place order');
    }
  }

  Future getIndividualReport({
    required DateTime date,
    required String store,
  }) async {
    final DateTime startOfDay = DateTime(date.year, date.month, date.day);
    final DateTime endOfDay = startOfDay.add(Duration(days: 1));

    QuerySnapshot reportQuery = await ordersCollection
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
        .where('store', isEqualTo: store)
        .get();
    if (reportQuery.docs.isNotEmpty) {
      Map<String, dynamic> report =
          reportQuery.docs.first.data() as Map<String, dynamic>;

      return report;
    }
    Fluttertoast.showToast(msg: "No Data Found!!");
    return null;
  }

  Future getConsolidatedReport({required DateTime date}) async {
    final DateTime startOfDay = DateTime(date.year, date.month, date.day);
    final DateTime endOfDay = startOfDay.add(Duration(days: 1));

    QuerySnapshot reportQuery = await ordersCollection
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    if (reportQuery.docs.isNotEmpty) {
      List<Map<String, dynamic>> report = reportQuery.docs.map((element) {
        return element.data() as Map<String, dynamic>;
      }).toList();
      return report;
    }
    Fluttertoast.showToast(msg: "No Data Found!!");
    return null;
  }

  Future updateReceivedAmount({
    required double amount,
    required String orderId,
  }) async {
    await ordersCollection.doc(orderId).update({'received': amount});
    Fluttertoast.showToast(msg: 'Received amount update successfully');
  }

  Future<Map<String, dynamic>?> fetchVendorUser(String userId) async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: userId)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        return userSnapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching vendor user: $e');
      return null;
    }
  }

  Future<int> getMaxDue() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('utils')
        .doc('configs')
        .get();

    if (snapshot.exists && snapshot.data()!.containsKey('maxDue')) {
      return snapshot.data()!['maxDue'];
    } else {
      return 0;
    }
  }

  Future<double> getStorePendingDue(String store) async {
    double pendingDue = 0;

    var snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('store', isEqualTo: store)
        .get();

    for (var doc in snapshot.docs) {
      var data = doc.data();
      double totalAmount = (data['totalAmount'] ?? 0).toDouble();
      double received = (data['received'] ?? 0).toDouble();
      pendingDue += (totalAmount - received);
    }

    return pendingDue;
  }
}
