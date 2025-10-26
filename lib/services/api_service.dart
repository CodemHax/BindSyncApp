import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../services/user_preferences_service.dart';

class ApiAuthException implements Exception {
  final String message;
  ApiAuthException(this.message);

  @override
  String toString() => message;
}

class ApiTokenMissingException implements Exception {
  final String message = 'API token is required. Please add your token in Settings.';

  @override
  String toString() => message;
}

class ApiTokenInvalidException implements Exception {
  final String message = 'API token is invalid or expired. Please check your token in Settings.';

  @override
  String toString() => message;
}

class ApiService {
  final UserPreferencesService prefs_service = UserPreferencesService();

  Future<String> get base_url async {
    return await prefs_service.get_api_base_url();
  }

  Future<Map<String, String>> get_headers() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    final token = await prefs_service.get_api_token();
    if (token != null && token.isNotEmpty) {
      headers['X-API-Token'] = token;
    }

    return headers;
  }

  Future<bool> is_token_configured() async {
    final token = await prefs_service.get_api_token();
    return token != null && token.isNotEmpty;
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
        headers: await get_headers(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        final token = await prefs_service.get_api_token();
        if (token == null || token.isEmpty) {
          throw ApiTokenMissingException();
        } else {
          throw ApiTokenInvalidException();
        }
      }

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
        headers: await get_headers(),
      );

      if (response.statusCode == 401) {
        final token = await prefs_service.get_api_token();
        if (token == null || token.isEmpty) {
          throw ApiTokenMissingException();
        } else {
          throw ApiTokenInvalidException();
        }
      }

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
      final requestBody = json.encode(request.toJson());

      final response = await http.post(
        Uri.parse('$server_url/messages'),
        headers: await get_headers(),
        body: requestBody,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        final token = await prefs_service.get_api_token();
        if (token == null || token.isEmpty) {
          throw ApiTokenMissingException();
        } else {
          throw ApiTokenInvalidException();
        }
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MessageResponse.fromJson(data);
      } else if (response.statusCode == 500) {
        // Parse error details from server
        String errorDetails = 'Internal server error';
        try {
          final errorData = json.decode(response.body);
          errorDetails = errorData['detail'] ?? response.body;
        } catch (_) {
          errorDetails = response.body;
        }
        throw Exception('Server error (500): $errorDetails');
      } else {
        throw Exception('Server returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  Future<MessageResponse> reply_to_message(String message_id, String text, String username, {String? target}) async {
    try {
      final server_url = await base_url;
      final payload = {
        'text': text,
        'username': username,
        if (target != null) 'target': target,
      };

      final response = await http.post(
        Uri.parse('$server_url/messages/$message_id/reply'),
        headers: await get_headers(),
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        final token = await prefs_service.get_api_token();
        if (token == null || token.isEmpty) {
          throw ApiTokenMissingException();
        } else {
          throw ApiTokenInvalidException();
        }
      }

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
        Uri.parse('$server_url/admin/status'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return data.containsKey('admin_exists') || data.containsKey('registration_required');
        } catch (e) {
          return false;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
