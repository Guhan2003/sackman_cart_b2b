import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sackmman_cart_b2b/screen/admin_page/login_page.dart';
import 'package:sackmman_cart_b2b/screen/get_detail_page/consolidated_report.dart';
import 'package:sackmman_cart_b2b/screen/get_detail_page/individual_store.dart';
import 'package:sackmman_cart_b2b/screen/order_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

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
        ),
      ),
    );
  }
}
