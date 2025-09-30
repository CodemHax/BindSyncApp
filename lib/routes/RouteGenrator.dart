import 'package:bindsync/services/auth_wrapper.dart';
import 'package:bindsync/screens/chat_selection.dart';
import 'package:bindsync/screens/discord_chat.dart';
import 'package:bindsync/screens/home_page.dart';
import 'package:bindsync/screens/login.dart';
import 'package:bindsync/screens/settings.dart';
import 'package:bindsync/screens/telegram_chat.dart';
import 'package:bindsync/screens/test_login.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generate_route(RouteSettings route_settings) {
    switch (route_settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case '/home':
        return MaterialPageRoute(builder: (_) => const Homepage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginGoogle());
      case '/chat-selection':
        return MaterialPageRoute(builder: (_) => const ChatSelectionPage());
      case '/telegram-chat':
        return MaterialPageRoute(builder: (_) => const TelegramChatPage());
      case '/discord-chat':
        return MaterialPageRoute(builder: (_) => const DiscordChatPage());
      case '/mixed-chat':
        return MaterialPageRoute(builder: (_) => const Homepage());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case '/test-login':
        return MaterialPageRoute(builder: (_) => const TestLoginPage());
      default:
        return error_page();
    }
  }

  static Route<dynamic> error_page() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: const Center(child: Text('ERROR: Route not found!')),
        );
      },
    );
  }
}
