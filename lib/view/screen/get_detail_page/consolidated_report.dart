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
                    orderController!.getConsolidatedReport(
                      date: selectedDate!
                    );
                },
                child: Text('Get Report'),
              ),
            ),
            Divider(),
            Obx(() {
              double totalAmount =
                  orderController!.individualOrderData.value?.totalAmount ?? 0;
              double receivedAmount =
                  orderController!.individualOrderData.value?.received ?? 0;
              return Visibility(
                visible:
                    orderController!.report.isNotEmpty &&
                    (orderController!
                            .consolidateReport
                            .value
                            .isNotEmpty),
                child: Column(
                  children: [
                    ElevatedButton(onPressed: (){
                      orderController!.previewPdf(context, isIndividual: true);
                    }, child: Text('Get PDF')),
                    SizedBox(height: 15,),
                    Text(
                      orderController!.selectedStoreReport,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Order ID : ${orderController!.individualOrderData.value?.id ?? ''}',
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Date : ${orderController!.individualOrderData.value?.createdAt ?? DateTime.now()}',
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Total Item : ${orderController!.individualOrderData.value?.items.length ?? 0}',
                    ),
                    SizedBox(height: 5),
                    Divider(),
                    Text(
                      'Total Amount : $totalAmount',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Received Amount : ${orderController!.individualOrderData.value?.received ?? 0}',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Balance Amount : ${totalAmount - receivedAmount}',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Divider(),
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            width: size.width * 0.17,
                            child: Text(
                              "Items",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.2,
                            child: Text(
                              "Quantity",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.1,
                            child: Text(
                              "Rate(Rs.)",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.2,
                            child: Center(
                              child: Text(
                                "Total(Rs.)",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final orderData = orderController!
                            .individualOrderData
                            .value!
                            .items[index];
                        return ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width: size.width * 0.17,
                                child: Text(orderData.name),
                              ),
                              SizedBox(
                                width: size.width * 0.2,
                                child: Text(
                                  "${orderData.qty} ${orderData.unit}",
                                ),
                              ),
                              SizedBox(
                                width: size.width * 0.1,
                                child: Text("${orderData.rate}"),
                              ),
                              SizedBox(
                                width: size.width * 0.2,
                                child: Center(
                                  child: Text(
                                    "${orderData.rate * orderData.qty}",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => Divider(),
                      itemCount:
                          orderController!
                              .individualOrderData
                              .value
                              ?.items
                              .length ??
                          0,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
