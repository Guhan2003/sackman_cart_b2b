import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sackmman_cart_b2b/screen/admin_page/login_page.dart';
import 'package:sackmman_cart_b2b/screen/get_detail_page/consolidated_report.dart';
import 'package:sackmman_cart_b2b/screen/get_detail_page/individual_store.dart';
import 'package:sackmman_cart_b2b/screen/order_page.dart';
import 'package:sackmman_cart_b2b/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isVendor = false;

  @override
  void initState() {
    super.initState();
    _loadIsVendor();
  }

  Future<void> _loadIsVendor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isVendor = prefs.getBool(isVendorConst) ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sackmman Cart Business'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 15,
          children: [
            ElevatedButton.icon(
              label: Text('Place Order'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderPage()),
              ),
              icon: Icon(Icons.store),
            ),
            if (!isVendor) ...[
              ElevatedButton.icon(
                label: Text('Get Details'),
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: SingleChildScrollView(
                        child: Column(
                          spacing: 20,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => IndividualStore(),
                                ),
                              ),
                              label: Text('Individual Store'),
                              icon: Icon(Icons.store),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConsolidatedReport(),
                                ),
                              ),
                              label: Text('Consolidated Report'),
                              icon: Icon(Icons.document_scanner),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => Get.back(),
                              label: Text('Cancel'),
                              icon: Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.receipt),
              ),
              ElevatedButton.icon(
                label: Text('Admin Page'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminLoginPage()),
                ),
                icon: Icon(Icons.admin_panel_settings_rounded),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
