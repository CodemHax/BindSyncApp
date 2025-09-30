import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginGoogle extends StatefulWidget {
  const LoginGoogle({super.key});

  @override
  State<LoginGoogle> createState() => _LoginGoogleState();
}

class _LoginGoogleState extends State<LoginGoogle> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111B21),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF075E54),
                      Color(0xFF25D366),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo_bind.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Text(
                                '💬',
                                style: TextStyle(fontSize: 50),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'BindSync',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bridge your conversations',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF0B141A),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.6 - 48,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),

                        const Text(
                          'Welcome Back!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Connect Telegram and Discord\nwith a single tap',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),

                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(28),
                              onTap: () async {
                                bool is_signed_in = await sign_in_with_google();
                                if (is_signed_in && context.mounted) {
                                  Navigator.pushReplacementNamed(context, "/chat-selection");
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        'https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png',
                                        width: 24,
                                        height: 24,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.g_mobiledata,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Text(
                                      'Continue with Google',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2C34),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'What you get:',
                                style: TextStyle(
                                  color: Color(0xFF25D366),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              build_feature_item(Icons.telegram, 'Telegram Chat', 'Direct messaging'),
                              const SizedBox(height: 8),
                              build_feature_item(Icons.discord, 'Discord Chat', 'Gaming communities'),
                              const SizedBox(height: 8),
                              build_feature_item(Icons.hub, 'Mixed Bridge', 'Cross-platform sync'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        const SizedBox(height: 20),

                        Text(
                          'Access • cross platform • Real-time',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget build_feature_item(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF25D366).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(icon, color: const Color(0xFF25D366), size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> sign_in_with_google() async {
    try {
      final google_sign_in = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      await google_sign_in.signOut();

      final google_user = await google_sign_in.signIn();

      if (google_user == null) {
        return false;
      }

      final google_auth = await google_user.authentication;

      if (google_auth.accessToken == null || google_auth.idToken == null) {
        return false;
      }

      final auth_credential = GoogleAuthProvider.credential(
        accessToken: google_auth.accessToken,
        idToken: google_auth.idToken,
      );

      final user_credential = await FirebaseAuth.instance.signInWithCredential(auth_credential);

      if (user_credential.user != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // void show_error_dialog(String title, String message) {
  //   if (mounted) {
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: Text(title),
  //         content: Text(message),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }
}
