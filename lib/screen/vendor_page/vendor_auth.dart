import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sackmman_cart_b2b/controller/auth_controller.dart';
import 'package:sackmman_cart_b2b/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorAuth extends StatefulWidget {
  const VendorAuth({super.key});

  @override
  State<VendorAuth> createState() => _VendorAuthState();
}

class _VendorAuthState extends State<VendorAuth> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final itemController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    _setVendorFlag();
  }

  Future<void> _setVendorFlag() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isVendorConst, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // User ID Field
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Password Field
            TextField(
              controller: passwordController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            // Login Button
            ElevatedButton(
              onPressed: () {
                String userId = userIdController.text.trim();
                String password = passwordController.text.trim();
                itemController.loginVendor(context, userId, password);
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
