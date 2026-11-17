import 'package:flutter/material.dart';
import 'shell_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF0F766E);
    return Scaffold(
      backgroundColor: teal,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Logbook Lab IoT Berbasis Blockchain',
                      style: TextStyle(color: Color(0xFFCCFBF1))),
                  const SizedBox(height: 16),
                  const Text('Welcome to PinjaminDong',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 16),
                  const Text(
                      'Catat peminjaman alat lab IoT secara transparan, aman, dan anti-manipulasi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: teal),
                      onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ShellScreen())),
                      child: const Text('Masuk'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}