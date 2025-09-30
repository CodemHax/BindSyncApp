import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatSelectionPage extends StatelessWidget {
  const ChatSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: const Color(0xFF111B21), // WhatsApp dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2C34),
        elevation: 0,
        title: const Text(
          'BindSync',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: const Color(0xFF1F2C34),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF25D366),
                  backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                  child: user?.photoURL == null
                      ? Text(
                          (user?.displayName ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.displayName ?? 'User',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Chat options
          Expanded(
            child: Container(
              color: const Color(0xFF0B141A),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  buls_chat(
                    context,
                    title: 'Telegram Chat',
                    subtitle: 'Connect to Telegram messages only',
                    iconData: Icons.telegram,
                    color: const Color(0xFF0088CC),
                    route: '/telegram-chat',
                  ),
                  const SizedBox(height: 12),
                  buls_chat(
                    context,
                    title: 'Discord Chat',
                    subtitle: 'Connect to Discord messages only',
                    iconData: Icons.discord,
                    color: const Color(0xFF5865F2),
                    route: '/discord-chat',
                  ),
                  const SizedBox(height: 12),
                  buls_chat(
                    context,
                    title: 'Mixed Chat',
                    subtitle: 'All platforms in one conversation',
                    iconData: Icons.hub,
                    color: const Color(0xFF25D366),
                    route: '/mixed-chat',
                  ),


                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2C34),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Color(0xFF25D366), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'How it works',
                              style: TextStyle(
                                color: Color(0xFF25D366),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          '• Telegram Chat: See and send messages to your Telegram group\n'
                          '• Discord Chat: See and send messages to your Discord server\n'
                          '• Mixed Chat: Bridge between both platforms in real-time',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buls_chat(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData iconData,
    required Color color,
    required String route,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F2C34),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamed(context, route);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      iconData,
                      color: color,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white54,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
