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

  //Report
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

  Future getPDF(context, {required bool isIndividual}) async {
    final pdf = pw.Document();
    if (isIndividual) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            double totalAmount = individualOrderData.value?.totalAmount ?? 0;
            double receivedAmount = individualOrderData.value?.received ?? 0;

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
    } else {}

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
