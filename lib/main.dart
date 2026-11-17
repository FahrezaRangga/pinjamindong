import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/config.env');
  runApp(const PinjaminDongApp());
}

class PinjaminDongApp extends StatelessWidget {
  const PinjaminDongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PinjaminDong',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
      ),
      home: const WelcomeScreen(),
    );
  }
}