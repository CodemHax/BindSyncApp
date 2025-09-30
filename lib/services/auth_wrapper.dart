import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bindsync/screens/login.dart';
import 'package:bindsync/screens/chat_selection.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, auth_snapshot) {
        if (auth_snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF111B21),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF25D366),
              ),
            ),
          );
        }
        if (auth_snapshot.hasData && auth_snapshot.data != null) {
          return const ChatSelectionPage();
        }
        return const LoginGoogle();
      },
    );
  }
}
