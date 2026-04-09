import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const ShopifyDashboardApp());
}

class ShopifyDashboardApp extends StatelessWidget {
  const ShopifyDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopifyPro Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const DashboardScreen(),
    );
  }
}
