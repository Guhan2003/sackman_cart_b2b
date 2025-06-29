import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:sackmman_cart_b2b/firebase_options.dart';
import 'package:sackmman_cart_b2b/screen/main_page.dart';
import 'package:sackmman_cart_b2b/screen/vendor_page/vendor_auth.dart';
import 'package:sackmman_cart_b2b/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  bool isVendor = false;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(isVendorConst, isVendor);
  runApp(MainApp(isVendor: isVendor));
}

class MainApp extends StatelessWidget {
  final bool isVendor;
  const MainApp({super.key, required this.isVendor});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: isVendor ? VendorAuth() : MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
