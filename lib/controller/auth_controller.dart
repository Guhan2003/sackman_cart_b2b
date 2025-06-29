import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sackmman_cart_b2b/services/data_services.dart';

class AuthController extends GetxController {
  DataServices dataServices = DataServices();
  Future<void> loginVendor(
    BuildContext context,
    String userId,
    String password,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final userData = await dataServices.fetchVendorUser(userId);

      Navigator.pop(context); // Close loading dialog

      if (userData != null) {
        if (userData['passcode'] == password) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login Successful')));
          // Navigate to next page or dashboard here if needed
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Invalid password')));
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not found')));
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
