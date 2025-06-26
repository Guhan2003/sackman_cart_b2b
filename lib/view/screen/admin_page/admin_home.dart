import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:sackmman_cart_b2b/controller/admin_controller.dart';
import 'package:sackmman_cart_b2b/controller/item_controller.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    final adminController = Get.put(AdminController());
    final itemController = Get.put(ItemController()); 
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          adminController.showItemDetail(context, size);
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(
              "Item",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            trailing: Text(
              'Rate',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          Divider(),
          SizedBox(
            height: size.height * 0.8,
            child: Obx(() {
              if(itemController.itemList.isEmpty){
                return Center(child: Text("No Item Found"));
              }
                return ListView.separated(
                  separatorBuilder: (context, index){
                    return Divider();
                  },
                  shrinkWrap: true,
                  itemCount: itemController.itemList.length,
                  itemBuilder: (context, index) {
                    final value = itemController.itemList[index];
                    return GestureDetector(
                      onTap: () => adminController.showItemDetail(context, size,isUpdate: true,item: value.name ,rate: value.rate,unit: value.unit,id: value.id),
                      child: ListTile(
                        title: Text(value.name,style: TextStyle(fontSize: 16),),
                        subtitle: Text(value.unit,style: TextStyle(fontSize: 16),),
                        trailing: Text(value.rate.toString(),style: TextStyle(fontSize: 15),),
                      ),
                    );
                  },
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
