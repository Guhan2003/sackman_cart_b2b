import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sackmman_cart_b2b/controller/item_controller.dart';
import 'package:sackmman_cart_b2b/services/data_services.dart';

class AdminController extends GetxController {
  final TextEditingController itemTextController = TextEditingController();
  final TextEditingController rateTextController = TextEditingController();
  ItemController itemController = Get.put(ItemController());
  DataServices dataServices = DataServices();

  String selectedOption = '';
  final List<String> options = ['Kg', 'Pcs'];

  void showItemDetail(
    context,
    Size size, {
    bool isUpdate = false,
    String item = '',
    String unit = '',
    double rate = 0,
    String id = ''
  }) {

    final formKey = GlobalKey<FormState>();
    itemTextController.text = isUpdate ? item : '';
    rateTextController.text = isUpdate ? rate.toString() : '';
    selectedOption = isUpdate ? unit : '';
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return SizedBox(
              height: 400,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Add Item',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    SizedBox(height: 25),
                    SizedBox(
                      width: size.width * 0.8,
                      child: TextFormField(
                        controller: itemTextController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Product Name',
                        ),
                        validator: (value) {
                          if(value == null || value == '') return 'Enter Item';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: size.width * 0.8,
                      child: DropdownButtonFormField(
                        value: isUpdate ? selectedOption : null,
                        decoration: const InputDecoration(
                          hintText: 'Select Unit',
                          border: OutlineInputBorder(),
                        ),
                        borderRadius: BorderRadius.circular(10),
                        items: options.map((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (onChangeValue) {
                          selectedOption = onChangeValue!;
                        },
                        validator: (value) {
                          if(value == null || value == '') return 'Select unit';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: size.width * 0.8,
                      child: TextFormField(
                        controller: rateTextController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Rate',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if(value == null || value == '') return 'Enter rate';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      spacing: 30,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()){
                            Get.back();
                            isUpdate
                                ? await dataServices.updateItem(
                                    id: id,
                                    name: itemTextController.text.trim(),
                                    unit: selectedOption,
                                    rate: double.parse(
                                      rateTextController.text.trim(),
                                    ),
                                    context: context,
                                  )
                                : await dataServices.addItem(
                                    name: itemTextController.text.trim(),
                                    unit: selectedOption,
                                    rate: double.parse(
                                      rateTextController.text.trim(),
                                    ),
                                    context: context,
                                  );
                            await itemController.getItems();
                            itemTextController.clear();
                            rateTextController.clear();
                          }
                          },
                          child: Text('Submit'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Get.back();
                            itemTextController.clear();
                            rateTextController.clear();
                          },
                          child: Text('Cancel'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
