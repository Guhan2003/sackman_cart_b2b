import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:sackmman_cart_b2b/model/order_data.dart';
import 'package:sackmman_cart_b2b/model/order_item.dart';
import 'package:sackmman_cart_b2b/services/data_services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class OrderController extends GetxController {
  DataServices dataServices = DataServices();
  RxList<String> stores = <String>[].obs;
  String selectedStore = '';
  RxString selectedItem = ''.obs;
  RxList<OrderItem> orderItemList = <OrderItem>[].obs;
  Rxn<OrderItem> currentItem = Rxn<OrderItem>();

  // Report
  String selectedStoreReport = '';
  var report = <String, dynamic>{}.obs;
  RxList<Map<String, dynamic>> consolidateReport = <Map<String, dynamic>>[].obs;
  Rxn<OrderData?> individualOrderData = Rxn<OrderData?>();
  RxList<OrderData> orderDataList = <OrderData>[].obs;

  Future<List<DropdownMenuItem<String>>> getStores() async {
    List<String> storeList = await dataServices.getStoreList();
    stores.value = storeList;
    return stores.map((value) {
      return DropdownMenuItem(value: value, child: Text(value));
    }).toList();
  }

  Future getIndividualReport({
    required DateTime date,
    required String store,
  }) async {
    report.value = {};
    individualOrderData.value = OrderData.initial();
    report.value =
        await dataServices.getIndividualReport(date: date, store: store) ?? {};
    if (report.value.isNotEmpty) {
      individualOrderData.value = OrderData.fromJson(report);
    }
  }

  Future getConsolidatedReport({required DateTime date}) async {
    report.value = {};
    orderDataList.value = [];
    consolidateReport.value =
        await dataServices.getConsolidatedReport(date: date) ?? [];
    if (consolidateReport.value.isNotEmpty) {
      orderDataList.value = consolidateReport.value.map((element) {
        return OrderData.fromJson(element);
      }).toList();
    }
  }

  Future<Uint8List> getPDF(
    BuildContext context, {
    required bool isIndividual,
  }) async {
    final pdf = pw.Document();
    if (isIndividual) {
      double totalAmount = individualOrderData.value?.totalAmount ?? 0;
      double receivedAmount = individualOrderData.value?.received ?? 0;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            final List<pw.Widget> content = [];

            content.addAll([
              pw.SizedBox(height: 15),
              pw.Text(
                selectedStoreReport,
                style: pw.TextStyle(
                  fontSize: 17,
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text('Order ID : ${individualOrderData.value?.id ?? ''}'),
              pw.SizedBox(height: 2),
              pw.Text(
                'Date : ${individualOrderData.value?.createdAt ?? DateTime.now()}',
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Total Item : ${individualOrderData.value?.items.length ?? 0}',
              ),
              pw.SizedBox(height: 5),
              pw.Divider(),
              pw.Text(
                'Total Amount : $totalAmount',
                style: pw.TextStyle(
                  fontSize: 17,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Received Amount : $receivedAmount',
                style: pw.TextStyle(
                  fontSize: 17,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Balance Amount : ${totalAmount - receivedAmount}',
                style: pw.TextStyle(
                  fontSize: 17,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Divider(),

              // Table headers
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.SizedBox(
                    width: 80,
                    child: pw.Text(
                      "Items",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.SizedBox(
                    width: 100,
                    child: pw.Text(
                      "Quantity",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.SizedBox(
                    width: 60,
                    child: pw.Text(
                      "Rate(Rs.)",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.SizedBox(
                    width: 80,
                    child: pw.Text(
                      "Total(Rs.)",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              pw.Divider(),
            ]);

            for (var orderData in individualOrderData.value?.items ?? []) {
              content.add(
                pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        pw.SizedBox(width: 80, child: pw.Text(orderData.name)),
                        pw.SizedBox(
                          width: 100,
                          child: pw.Text("${orderData.qty} ${orderData.unit}"),
                        ),
                        pw.SizedBox(
                          width: 60,
                          child: pw.Text("${orderData.rate}"),
                        ),
                        pw.SizedBox(
                          width: 80,
                          child: pw.Text("${orderData.rate * orderData.qty}"),
                        ),
                      ],
                    ),
                    pw.Divider(),
                  ],
                ),
              );
            }

            return content;
          },
        ),
      );
    } else {
      // Consolidated report PDF generation
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            Map<String, Map<String, dynamic>> itemMap = {};
            List<String> storeList = [];

            for (var order in orderDataList) {
              String store = order.store ?? '';
              if (!storeList.contains(store)) {
                storeList.add(store);
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

            return [
              pw.Text(
                'Consolidated Report',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FixedColumnWidth(100),
                  1: pw.FixedColumnWidth(60),
                  for (int i = 0; i < storeList.length; i++)
                    i + 2: pw.FixedColumnWidth(80),
                  storeList.length + 2: pw.FixedColumnWidth(60),
                  storeList.length + 3: pw.FixedColumnWidth(60),
                  storeList.length + 4: pw.FixedColumnWidth(80),
                },
                children: [
                  // Table header
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Item',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Unit',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      ...storeList.map(
                        (store) => pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(
                            store,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Qty',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Rate',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Total',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  // Table rows
                  ...itemMap.entries.map((entry) {
                    String name = entry.key;
                    var data = entry.value;
                    double overallQty = data['overallQty'];
                    double rate = data['rate'];
                    String unit = data['unit'];
                    double total = overallQty * rate;
                    grandTotal += total;

                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(name),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(unit),
                        ),
                        ...storeList.map((store) {
                          double storeQty = data['storeQty'][store] ?? 0;
                          return pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text(storeQty > 0 ? '$storeQty' : '-'),
                          );
                        }),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('$overallQty'),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(rate.toStringAsFixed(0)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('₹ ${total.toStringAsFixed(0)}'),
                        ),
                      ],
                    );
                  }).toList(),
                  // Grand Total row
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Grand Total',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Container(),
                      for (int i = 0; i < storeList.length; i++) pw.Container(),
                      pw.Container(),
                      pw.Container(),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          '₹ ${grandTotal.toStringAsFixed(0)}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ];
          },
        ),
      );
    }

    return pdf.save();
  }

  void previewPdf(BuildContext context, {required bool isIndividual}) {
    Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        return await getPDF(context, isIndividual: isIndividual);
      },
    );
  }
}
