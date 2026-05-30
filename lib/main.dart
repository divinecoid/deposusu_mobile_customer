import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/tracking/presentation/providers/tracking_provider.dart';
import 'features/tracking/presentation/pages/tracking_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TrackingProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deposusu Customer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const TrackingPage(),
    );
  }
}
