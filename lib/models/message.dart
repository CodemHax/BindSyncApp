import 'package:flutter/material.dart';

class Message {
  final String id;
  final String source;
  final String text;
  final String username;
  final double timestamp;
  final int? tg_msg_id;
  final int? dc_msg_id;
  final String? reply_to_id;
  final int? reply_to_tg_id;
  final int? reply_to_dc_id;

  Message({
    required this.id,
    required this.source,
    required this.text,
    required this.username,
    required this.timestamp,
    this.tg_msg_id,
    this.dc_msg_id,
    this.reply_to_id,
    this.reply_to_tg_id,
    this.reply_to_dc_id,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',
      source: json['source']?.toString() ?? 'api',
      text: json['text']?.toString() ?? '',
      username: json['username']?.toString() ?? 'Unknown',
      timestamp: (json['timestamp'] is num)
          ? (json['timestamp'] as num).toDouble()
          : DateTime.now().millisecondsSinceEpoch / 1000.0,
      tg_msg_id: json['tg_msg_id'] as int?,
      dc_msg_id: json['dc_msg_id'] as int?,
      reply_to_id: json['reply_to_id']?.toString(),
      reply_to_tg_id: json['reply_to_tg_id'] as int?,
      reply_to_dc_id: json['reply_to_dc_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'text': text,
      'username': username,
      'timestamp': timestamp,
      'tg_msg_id': tg_msg_id,
      'dc_msg_id': dc_msg_id,
      'reply_to_id': reply_to_id,
      'reply_to_tg_id': reply_to_tg_id,
      'reply_to_dc_id': reply_to_dc_id,
    };
  }

  DateTime get date_time => DateTime.fromMillisecondsSinceEpoch((timestamp * 1000).round());

  bool get is_reply => reply_to_id != null;

  IconData get source_icon {
    switch (source) {
      case 'telegram':
        return Icons.telegram;
      case 'discord':
        return Icons.discord;
      case 'api':
      case 'api_reply':
        return Icons.message;
      default:
        return Icons.reply;
    }
  }

  Widget get_source_logo({double size = 24}) {
    switch (source) {
      case 'telegram':
        return ClipRRect(
          borderRadius: BorderRadius.circular(size / 4),
          child: Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/8/82/Telegram_logo.svg',
            width: size,
            height: size,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: const Color(0xFF0088CC),
                  borderRadius: BorderRadius.circular(size / 4),
                ),
                child: const Icon(
                  Icons.telegram,
                  color: Colors.white,
                  size: 16,
                ),
              );
            },
          ),
        );
      case 'discord':
        return ClipRRect(
          borderRadius: BorderRadius.circular(size / 4),
          child: Image.network(
            'https://assets-global.website-files.com/6257adef93867e50d84d30e2/636e0a6a49cf127bf92de1e2_icon_clyde_blurple_RGB.png',
            width: size,
            height: size,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: const Color(0xFF5865F2),
                  borderRadius: BorderRadius.circular(size / 4),
                ),
                child: const Icon(
                  Icons.gamepad,
                  color: Colors.white,
                  size: 16,
                ),
              );
            },
          ),
        );
      case 'api':
      case 'api_reply':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF25D366),
            borderRadius: BorderRadius.circular(size / 4),
          ),
          child: const Icon(
            Icons.api,
            color: Colors.white,
            size: 16,
          ),
        );
      default:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(size / 4),
          ),
          child: const Icon(
            Icons.message,
            color: Colors.white,
            size: 16,
          ),
        );
    }
  }
}

class CreateMessageRequest {
  final String text;
  final String username;
  final String? reply_to_id;
  final String? target; // 'telegram', 'discord', or 'both' (null defaults to 'both')

  CreateMessageRequest({
    required this.text,
    required this.username,
    this.reply_to_id,
    this.target,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'username': username,
      if (reply_to_id != null) 'reply_to_id': reply_to_id,
      if (target != null) 'target': target,
    };
  }
}

class MessageResponse {
  final String id;
  final int? tg_msg_id;
  final int? dc_msg_id;

  MessageResponse({
    required this.id,
    this.tg_msg_id,
    this.dc_msg_id,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      id: json['id'],
      tg_msg_id: json['tg_msg_id'],
      dc_msg_id: json['dc_msg_id'],
    );
  }
}
