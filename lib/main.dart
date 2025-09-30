import 'package:bindsync/routes/RouteGenrator.dart';
import 'package:bindsync/services/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BindSyncApp());
}

class BindSyncApp extends StatelessWidget {
  const BindSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      onGenerateRoute: RouteGenerator.generate_route,
    );
  }
}
