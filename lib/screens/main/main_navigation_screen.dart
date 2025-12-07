import 'package:flutter/material.dart';
import '../dashboard/dashboard_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simply return the DashboardScreen which has all the navigation built-in
    return const DashboardScreen();
  }
}
