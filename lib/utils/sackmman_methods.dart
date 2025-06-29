import 'package:sackmman_cart_b2b/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SackmmanMethods {
  Future<bool> getIsVendor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isVendorConst) ?? false;
  }
}