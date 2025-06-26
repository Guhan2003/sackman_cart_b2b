import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:sackmman_cart_b2b/controller/order_controller.dart';
import 'package:sackmman_cart_b2b/services/data_services.dart';
import 'package:sackmman_cart_b2b/utils/constant.dart';

class IndividualStore extends StatefulWidget {
  const IndividualStore({super.key});

  @override
  State<IndividualStore> createState() => _IndividualStoreState();
}

class _IndividualStoreState extends State<IndividualStore> {
  DateTime? selectedDate;
  OrderController? orderController;
  DataServices dataServices = DataServices();
  bool isLoading = true;
  TextEditingController receivedTextEditingController = TextEditingController();

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
  void dispose() {
    super.dispose();
    receivedTextEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text("Get Individual store detail")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: size.width * 0.9,
              child: Obx(() {
                if (orderController!.stores.isEmpty) {
                  return Center(child: const CircularProgressIndicator());
                }
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Select Store'),
                  items: orderController!.stores
                      .map(
                        (store) => DropdownMenuItem<String>(
                          value: store,
                          child: Text(store),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    orderController!.selectedStoreReport = value!;
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
                  if (orderController!.selectedStoreReport != '') {
                    orderController!.getIndividualReport(
                      date: selectedDate!,
                      store: orderController!.selectedStoreReport,
                    );
                  } else {
                    Fluttertoast.showToast(msg: "Select Store");
                  }
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
                            .individualOrderData
                            .value
                            ?.items
                            .isNotEmpty ??
                        false),
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
      persistentFooterButtons: [
        SizedBox(
          width: size.width * 0.4,
          child: TextFormField(
            controller: receivedTextEditingController,
            decoration: InputDecoration(border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(
          width: size.width * 0.45,
          child: ElevatedButton.icon(
            onPressed: () {
              if (receivedTextEditingController.text.isNotEmpty &&
                  receivedTextEditingController.text != '0') {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        'Received Amount is Rs.${receivedTextEditingController.text}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      actions: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  Center(child: CircularProgressIndicator()),
                            );
                            await dataServices.updateReceivedAmount(
                              amount: double.parse(
                                receivedTextEditingController.text,
                              ),
                              orderId: orderController!
                                  .individualOrderData
                                  .value!
                                  .id,
                            );
                            receivedTextEditingController.clear();
                            await orderController!.getIndividualReport(
                              date: selectedDate!,
                              store: orderController!.selectedStoreReport,
                            );
                            Get.back();
                            Get.back();
                          },
                          label: Text(
                            'Confirm',
                            style: TextStyle(color: green),
                          ),
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
                Fluttertoast.showToast(msg: 'Enter Amount');
              }
            },
            label: Text('Update Recevied Amount', textAlign: TextAlign.center),
          ),
        ),
      ],
    );
  }
}
