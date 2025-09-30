import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../services/user_preferences_service.dart';

class ApiService {
  final UserPreferencesService prefs_service = UserPreferencesService();

  Future<String> get base_url async {
    return await prefs_service.get_api_base_url();
  }

  Future<List<Message>> get_messages({
    int limit = 100,
    int offset = 0,
    String? source_filter,
  }) async {
    try {
      final server_url = await base_url;
      String url = '$server_url/messages?limit=$limit&offset=$offset';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['messages'] == null) {
          return [];
        }

        final List<dynamic> messages_list = data['messages'];
        List<Message> messages = messages_list
            .map((json) {
              try {
                return Message.fromJson(json);
              } catch (e) {
                return null;
              }
            })
            .where((msg) => msg != null)
            .cast<Message>()
            .toList();

        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        if (source_filter != null) {
          switch (source_filter) {
            case 'telegram':
              messages = messages.where((msg) =>
                msg.source.contains('telegram') ||
                msg.source == 'api' ||
                msg.source == 'api_reply'
              ).toList();
              break;
            case 'discord':
              messages = messages.where((msg) =>
                msg.source.contains('discord') ||
                msg.source == 'api' ||
                msg.source == 'api_reply'
              ).toList();
              break;
            case 'mixed':
              break;
          }
        }

        return messages;
      } else {
        throw Exception('Server returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  Future<Message> get_message(String message_id) async {
    try {
      final server_url = await base_url;
      final response = await http.get(
        Uri.parse('$server_url/messages/$message_id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Message.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Message not found');
      } else {
        throw Exception('Failed to load message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching message: $e');
    }
  }

  Future<MessageResponse> send_message(CreateMessageRequest request) async {
    try {
      final server_url = await base_url;
      final response = await http.post(
        Uri.parse('$server_url/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MessageResponse.fromJson(data);
      } else {
        throw Exception('Server returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  Future<MessageResponse> reply_to_message(String message_id, String text, String username) async {
    try {
      final server_url = await base_url;
      final payload = {
        'text': text,
        'username': username,
      };

      final response = await http.post(
        Uri.parse('$server_url/messages/$message_id/reply'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MessageResponse.fromJson(data);
      } else {
        throw Exception('Server returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending reply: $e');
    }
  }

  Future<bool> check_server_status() async {
    try {
      final server_url = await base_url;
      final response = await http.get(
        Uri.parse('$server_url/messages?limit=1'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
