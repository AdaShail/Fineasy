import 'package:flutter/material.dart';
import '../../web/screens/web_dashboard_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Force web layout - always use web dashboard on web
    return const WebDashboardScreen();
  }
}
