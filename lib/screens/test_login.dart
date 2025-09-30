import 'package:flutter/material.dart';

class TestLoginPage extends StatelessWidget {
  const TestLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Temporary bypass for testing'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/chat-selection');
              },
              child: const Text('Skip Login (Test Only)'),
            ),
            
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back to Google Login'),
            ),
          ],
        ),
      ),
    );
  }
}
