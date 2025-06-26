import 'package:get/get.dart';
import 'package:sackmman_cart_b2b/model/item.dart';
import 'package:sackmman_cart_b2b/services/data_services.dart';

class ItemController extends GetxController {
  RxList<Item> itemList = <Item>[].obs;
  DataServices dataServices = DataServices();

  Future getItems() async {
    itemList.value = [];
    final itemsMap = await dataServices.getItems();
    itemList.value = itemsMap.map((element){
      return Item.fromJson(element);
    }).toList();
  }
  
}
