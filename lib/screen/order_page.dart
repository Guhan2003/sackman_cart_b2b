import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:sackmman_cart_b2b/controller/admin_controller.dart';
import 'package:sackmman_cart_b2b/controller/item_controller.dart';
import 'package:sackmman_cart_b2b/controller/order_controller.dart';
import 'package:sackmman_cart_b2b/model/item.dart';
import 'package:sackmman_cart_b2b/model/order_item.dart';
import 'package:sackmman_cart_b2b/services/data_services.dart';
import 'package:sackmman_cart_b2b/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  DateTime? selectedDate;
  OrderController? orderController;
  ItemController itemController = Get.put(ItemController());
  AdminController adminController = Get.put(AdminController());
  bool isLoading = true;
  double qty = 0;
  final _formKey = GlobalKey<FormState>();
  DataServices dataServices = DataServices();
  bool isVendor = false;
  String vendorStoreName = '';

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      orderController = Get.put(OrderController());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      isVendor = prefs.getBool('isVendor') ?? false;

      if (isVendor) {
        vendorStoreName = prefs.getString('storeName') ?? '';
        orderController!.selectedStore = vendorStoreName;
      } else {
        await orderController!.getStores();
      }

      await itemController.getItems();
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text('Order Page')),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(
              width: size.width * 0.9,
              child: isVendor
                  ? Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        vendorStoreName,
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : Obx(() {
                      if (orderController!.stores.isEmpty) {
                        return Center(child: const CircularProgressIndicator());
                      }
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        hint: const Text('Select Store'),
                        value: orderController!.selectedStore == ''
                            ? null
                            : orderController!.selectedStore,
                        items: orderController!.stores
                            .map(
                              (store) => DropdownMenuItem<String>(
                                value: store,
                                child: Text(store),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          orderController!.selectedStore = value!;
                        },
                      );
                    }),
            ),

            const SizedBox(height: 30),
            Row(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Order date : \n${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),

                ElevatedButton(
                  onPressed: pickDate,
                  child: const Text('Change Date'),
                ),
              ],
            ),

            Divider(),
            SizedBox(height: 10),
            Text(
              'Order Details',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                decoration: TextDecoration.underline,
              ),
            ),
            ListTile(
              title: Text(
                'Item Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                'Quantity',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              color: Colors.purple[200],
              height: 1,
              width: size.width * 0.9,
            ),
            Expanded(
              child: Obx(() {
                List<OrderItem> listOfOrderItem =
                    orderController!.orderItemList;
                return ListView.separated(
                  separatorBuilder: (context, index) => Divider(),
                  shrinkWrap: true,
                  itemCount: listOfOrderItem.length,
                  itemBuilder: (context, index) {
                    OrderItem orderItem = listOfOrderItem[index];
                    return GestureDetector(
                      onLongPress: () {
                        listOfOrderItem.removeWhere((obj) {
                          return orderItem.name == obj.name;
                        });
                      },
                      child: ListTile(
                        title: Text(orderItem.name),
                        subtitle: Text(
                          'Rate: ₹${orderItem.rate.toStringAsFixed(2)} x Qty: ${orderItem.qty} ${orderItem.unit}',
                          style: TextStyle(fontSize: 13),
                        ),
                        trailing: Text(
                          'Total: ₹${(orderItem.rate * orderItem.qty).toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            Obx(() {
              double overallTotal = orderController!.orderItemList.fold(
                0,
                (sum, item) => sum + (item.qty * item.rate),
              );
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Overall Total: ₹${overallTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: 5),
          ],
        ),
      ),
      persistentFooterButtons: [
        ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(
                    'Select Item',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  content: SingleChildScrollView(
                    child: Obx(() {
                      final items = itemController.itemList;
                      if (items.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Form(
                        key: _formKey,
                        child: Column(
                          spacing: 20,
                          children: [
                            DropdownSearch<String>(
                              validator: (value) {
                                if (value == null || value == '') {
                                  return 'Select Item';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                orderController!.selectedItem.value = value!;
                                Item item = items.firstWhere((item) {
                                  return item.name == value;
                                });
                                orderController!.currentItem.value = OrderItem(
                                  name: item.name,
                                  rate: item.rate,
                                  unit: item.unit,
                                  qty: qty,
                                );
                              },
                              items: (f, cs) =>
                                  items.map((e) => e.name).toList(),
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                                fit: FlexFit.loose,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width: size.width * 0.26,
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null ||
                                          value == '' ||
                                          value == '0') {
                                        return 'Enter Quantity';
                                      }

                                      return null;
                                    },
                                    onChanged: (value) {
                                      if (value != '') {
                                        qty = double.parse(value);
                                      }
                                      Item item = items.firstWhere((item) {
                                        return item.name ==
                                            orderController!.selectedItem.value;
                                      });
                                      orderController!.currentItem.value =
                                          OrderItem(
                                            name: item.name,
                                            rate: item.rate,
                                            unit: item.unit,
                                            qty: qty,
                                          );
                                    },
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      hintText: 'Qty',
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * 0.26,
                                  child: DropdownButtonFormField(
                                    value:
                                        orderController!.selectedItem.value ==
                                            ''
                                        ? null
                                        : items
                                              .where(
                                                (value) =>
                                                    value.name ==
                                                    orderController!
                                                        .selectedItem
                                                        .value,
                                              )
                                              .first
                                              .unit,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value == '') {
                                        return 'Select Unit';
                                      }
                                      return null;
                                    },
                                    items: adminController.options.map((
                                      element,
                                    ) {
                                      return DropdownMenuItem(
                                        value: element,
                                        child: Text(element),
                                      );
                                    }).toList(),
                                    onChanged: (value) {},
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  actions: [
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final orderControl =
                              orderController!.currentItem.value!;
                          orderController!.orderItemList.add(
                            OrderItem(
                              name: orderControl.name,
                              rate: orderControl.rate,
                              unit: orderControl.unit,
                              qty: orderControl.qty,
                            ),
                          );
                          orderController!.currentItem.value =
                              OrderItem.initial();
                          Navigator.pop(context);
                        }
                      },
                      label: Text('Add', style: TextStyle(color: green)),
                      icon: Icon(Icons.add, color: green),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      label: Text('Cancel', style: TextStyle(color: red)),
                      icon: Icon(Icons.close, color: red),
                    ),
                  ],
                );
              },
            );
          },
          label: Text('Add Item'),
          icon: Icon(Icons.add_shopping_cart_rounded),
        ),
        ElevatedButton.icon(
          onPressed: () {
            if (orderController!.selectedStore != '' &&
                orderController!.orderItemList.isNotEmpty) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Order Confirmation'),
                    content: Text("Would you like to confirm this order?"),
                    actions: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                Center(child: CircularProgressIndicator()),
                          );
                          await dataServices.placeOrder(
                            store: orderController!.selectedStore,
                            orderItems: orderController!.orderItemList,
                            date: selectedDate!,
                            context: context,
                            orderController: orderController!,
                          );
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        label: Text('Confirm', style: TextStyle(color: green)),
                        icon: Icon(Icons.check_circle, color: green),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        label: Text('Cancel', style: TextStyle(color: red)),
                        icon: Icon(Icons.close, color: red),
                      ),
                    ],
                  );
                },
              );
            } else {
              Fluttertoast.showToast(
                msg: 'Select Store and Order list is empty',
              );
            }
          },
          label: Text('Place Order'),
          icon: Icon(Icons.check_circle_outline),
        ),
      ],
    );
  }
}
