import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sackmman_cart_b2b/controller/order_controller.dart';
import 'package:sackmman_cart_b2b/services/data_services.dart';

class ConsolidatedReport extends StatefulWidget {
  const ConsolidatedReport({super.key});

  @override
  State<ConsolidatedReport> createState() => _ConsolidatedReportState();
}

class _ConsolidatedReportState extends State<ConsolidatedReport> {
  DateTime? selectedDate;
  OrderController? orderController;
  DataServices dataServices = DataServices();
  bool isLoading = true;

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
      orderController!.getStores();
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
      appBar: AppBar(title: Text("Get Consolidated Report")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Order date : \n${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: pickDate,
                  child: const Text('Change Date'),
                ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              width: size.width * 0.8,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: () async {
                  orderController!.getConsolidatedReport(date: selectedDate!);
                },
                child: Text('Get Report'),
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Obx(() {
                if (orderController!.consolidateReport.isEmpty) {
                  return Text('No data');
                }

                Map<String, Map<String, dynamic>> itemMap = {};
                List<String> stores = [];

                // Build data maps
                for (var order in orderController!.orderDataList) {
                  String store = order.store ?? '';
                  if (!stores.contains(store)) {
                    stores.add(store);
                  }

                  for (var item in order.items) {
                    String name = item.name;
                    double qty = item.qty;
                    double rate = item.rate;
                    String unit = item.unit;

                    if (!itemMap.containsKey(name)) {
                      itemMap[name] = {
                        "rate": rate,
                        "unit": unit,
                        "overallQty": 0.0,
                        "storeQty": {},
                      };
                    }

                    itemMap[name]!["overallQty"] += qty;
                    itemMap[name]!["storeQty"][store] =
                        (itemMap[name]!["storeQty"][store] ?? 0) + qty;
                  }
                }

                double grandTotal = 0;

                return SizedBox(
                  height: 400, // adjust based on layout
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: [
                          Divider(),
                          // Table header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(
                                  'Item',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  'Unit',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              ...stores.map(
                                (store) => SizedBox(
                                  width: 80,
                                  child: Text(
                                    store,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  'Qty',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  'Rate',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  'Total',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          // Table rows
                          ...itemMap.entries.map((entry) {
                            String name = entry.key;
                            var data = entry.value;
                            double overallQty = data['overallQty'];
                            double rate = data['rate'];
                            String unit = data['unit'];
                            double total = overallQty * rate;
                            grandTotal += total;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 100, child: Text(name)),
                                SizedBox(width: 60, child: Text(unit)),
                                ...stores.map((store) {
                                  double storeQty =
                                      data['storeQty'][store] ?? 0;
                                  return SizedBox(
                                    width: 80,
                                    child: Text(
                                      storeQty > 0 ? '$storeQty' : '-',
                                    ),
                                  );
                                }).toList(),
                                SizedBox(width: 60, child: Text('$overallQty')),
                                SizedBox(
                                  width: 60,
                                  child: Text(rate.toStringAsFixed(0)),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: Text('₹ ${total.toStringAsFixed(0)}'),
                                ),
                              ],
                            );
                          }).toList(),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Grand Total: ₹${grandTotal.toStringAsFixed(0)}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: size.width * 0.8,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              onPressed: () {
                                orderController!
                                    .previewPdf(context, isIndividual: false);
                              },
                              child: Text('Get PDF'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
