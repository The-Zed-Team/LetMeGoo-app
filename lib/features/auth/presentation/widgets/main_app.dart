import 'package:flutter/material.dart';
import 'package:letmegoo/features/report/presentation/screens/create_report_page.dart';
import 'package:letmegoo/shared/screens/home_page.dart';
import 'package:letmegoo/features/auth/presentation/screens/profile_page.dart';
import 'package:letmegoo/features/parking/presentation/screens/parking_save_page.dart';
import 'package:letmegoo/core/services/analytics_service.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView('main_app');
  }

  void _onNavigate(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onAddPressed() {
    // Navigate to HomePage (which now shows reports)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                HomePage(onNavigate: _onNavigate, onAddPressed: _onAddPressed),
      ),
    );
  }

  void _onParkingPressed() {
    // Navigate to ParkingSavePage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ParkingSavePage(
              onNavigate: _onNavigate,
              onAddPressed: _onAddPressed,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        // CreateReportPage is now the home page
        return CreateReportPage(
          onNavigate: _onNavigate,
          onAddPressed: _onAddPressed,
          onParkingPressed: _onParkingPressed,
        );
      case 1:
        return ProfilePage(
          onNavigate: _onNavigate,
          onAddPressed: _onAddPressed,
          onParkingPressed: _onParkingPressed,
        );
      default:
        return CreateReportPage(
          onNavigate: _onNavigate,
          onAddPressed: _onAddPressed,
          onParkingPressed: _onParkingPressed,
        );
    }
  }
}
