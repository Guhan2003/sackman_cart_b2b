import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:sackmman_cart_b2b/firebase_options.dart';
import 'package:sackmman_cart_b2b/screen/main_page.dart';
import 'package:sackmman_cart_b2b/screen/vendor_page/vendor_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});
  bool isVendor = true;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: isVendor ? VendorAuth() : MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
