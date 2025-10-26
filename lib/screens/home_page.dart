import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/user_preferences_service.dart';
import 'token_setup_guide.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final ApiService api_service = ApiService();
  final UserPreferencesService prefs_service = UserPreferencesService();
  final TextEditingController message_controller = TextEditingController();
  final ScrollController scroll_controller = ScrollController();

  List<Message> messages = [];
  bool is_loading = false;
  bool is_server_connected = false;
  bool token_configured = false;
  String? username;
  Message? replying_to;
  Timer? refresh_timer;

  @override
  void initState() {
    super.initState();
    check_token_configuration();
    load_user_data();
    check_server_connection();
    load_messages();
    start_auto_refresh();
  }

  Future<void> check_token_configuration() async {
    final isConfigured = await api_service.is_token_configured();
    setState(() {
      token_configured = isConfigured;
    });
  }

  @override
  void dispose() {
    refresh_timer?.cancel();
    message_controller.dispose();
    scroll_controller.dispose();
    super.dispose();
  }

  Future<void> load_user_data() async {
    final user = FirebaseAuth.instance.currentUser;
    username = await prefs_service.get_username() ?? user?.displayName ?? 'You';
    setState(() {});
  }

  Future<void> check_server_connection() async {
    final isConnected = await api_service.check_server_status();
    setState(() {
      is_server_connected = isConnected;
    });
  }

  Future<void> load_messages() async {
    if (is_loading) return;

    setState(() {
      is_loading = true;
    });

    try {
      final messages = await api_service.get_messages(
        limit: 100,
        source_filter: 'mixed'
      );

      if (!is_server_connected) {
        setState(() {
          is_server_connected = true;
        });


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connected to server!'),
            backgroundColor: Color(0xFF25D366),
            duration: Duration(seconds: 2),
          ),
        );
      }

      setState(() {
        this.messages = messages;
      });
      scroll_to_bottom();
    } on ApiTokenMissingException catch (e) {
      setState(() {
        is_server_connected = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('⚠️ API Token Required!\nPlease add your API token in Settings to continue.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'Go to Settings',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ),
        );
      }
    } on ApiTokenInvalidException catch (e) {
      setState(() {
        is_server_connected = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🔒 Invalid API Token!\nYour token is invalid or expired. Please update it in Settings.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'Update Token',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        is_server_connected = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot connect to server. Check settings and ensure server is running.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ),
        );
      }
    } finally {
      setState(() {
        is_loading = false;
      });
    }
  }

  void start_auto_refresh() {
    refresh_timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && is_server_connected) {
        load_messages();
      }
    });
  }

  void scroll_to_bottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll_controller.hasClients) {
        scroll_controller.animateTo(
          scroll_controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> send_message() async {
    final text = message_controller.text.trim();
    final username = this.username?.trim() ?? '';

    if (text.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both message and username')),
      );
      return;
    }

    try {
      await prefs_service.set_username(username);

      if (replying_to != null) {

        await api_service.reply_to_message(replying_to!.id, text, username);
      } else {
        final request = CreateMessageRequest(
          text: text,
          username: username,

        );
        await api_service.send_message(request);
      }

      message_controller.clear();
      set_replying_to(null);
      await load_messages();
    } on ApiTokenMissingException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('⚠️ API Token Required!\nPlease add your API token in Settings to send messages.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'Go to Settings',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ),
        );
      }
    } on ApiTokenInvalidException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🔒 Invalid API Token!\nYour token is invalid or expired. Please update it in Settings.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'Update Token',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: ${e.toString()}')),
        );
      }
    }
  }

  void set_replying_to(Message? message) {
    setState(() {
      replying_to = message;
    });
  }

  void sign_out() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5DDD5),
      appBar: build_mixed_app_bar(),
      body: Column(
        children: [
          if (!is_server_connected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: const Color(0xFFFFF2CC),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber, color: Color(0xFFD32F2F), size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Connecting to BindSync...',
                    style: TextStyle(color: Color(0xFFD32F2F), fontSize: 12),
                  ),
                ],
              ),
            ),

          if (replying_to != null) build_reply_banner(),

          Expanded(
            child: !token_configured
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const TokenSetupGuide(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  )
                : is_loading && messages.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF25D366)),
                        ),
                      )
                    : ListView.builder(
                        controller: scroll_controller,
                        padding: const EdgeInsets.all(8),
                        itemCount: messages.length,
                        itemBuilder: (context, index) => build_mixed_message(messages[index]),
                      ),
          ),

          build_mixed_message_input(),
        ],
      ),
    );
  }

  PreferredSizeWidget build_mixed_app_bar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF075E54),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF25D366),
            child: const Icon(
              Icons.hub,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mixed Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  is_server_connected
                      ? 'Bridge Online • ${messages.length} messages'
                      : 'Connecting...',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            check_server_connection();
            load_messages();
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            switch (value) {
              case 'settings':
                Navigator.pushNamed(context, '/settings');
                break;
              case 'logout':
                sign_out();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.grey),
                  SizedBox(width: 12),
                  Text('Settings'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Sign Out', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget build_reply_banner() {
    return Container(
      color: const Color(0xFFF0F8FF),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF25D366),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  replying_to!.username,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF25D366),
                  ),
                ),
                Text(
                  replying_to!.text,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => set_replying_to(null),
          ),
        ],
      ),
    );
  }

  Widget build_mixed_message(Message message) {
    final isMe = message.username == username;
    final dateFormat = DateFormat('HH:mm');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Slidable(
        key: ValueKey(message.id),
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (context) {
                set_replying_to(message);
                HapticFeedback.lightImpact();
              },
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              icon: Icons.reply,
              label: 'Reply',
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isMe) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: message.source == 'discord'
                      ? const Color(0xFF5865F2)
                      : message.source == 'telegram'
                          ? const Color(0xFF0088CC)
                          : const Color(0xFF25D366),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  message.source_icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: GestureDetector(
                onLongPress: () => show_message_options(message),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMe
                        ? const Color(0xFFDCF8C6)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMe)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                message.source_icon,
                                size: 12,
                                color: message.source == 'discord'
                                    ? const Color(0xFF5865F2)
                                    : message.source == 'telegram'
                                        ? const Color(0xFF0088CC)
                                        : const Color(0xFF25D366),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  message.username,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: message.source == 'discord'
                                        ? const Color(0xFF5865F2)
                                        : message.source == 'telegram'
                                            ? const Color(0xFF0088CC)
                                            : const Color(0xFF25D366),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (message.is_reply) ...[
                        Builder(
                          builder: (context) {
                            final originalMessage = message.reply_to_id != null
                                ? find_original_message(message.reply_to_id!)
                                : null;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF25D366).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border(
                                  left: BorderSide(
                                    color: const Color(0xFF25D366),
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.reply,
                                        size: 14,
                                        color: Color(0xFF25D366),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        originalMessage?.username ?? 'Unknown',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF25D366),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      if (originalMessage != null)
                                        Icon(
                                          originalMessage.source_icon,
                                          size: 10,
                                          color: const Color(0xFF25D366),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    originalMessage?.text ?? 'Message not found',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontStyle: originalMessage != null ? FontStyle.normal : FontStyle.italic,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],

                      Text(
                        message.text,
                        style: const TextStyle(fontSize: 16),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              dateFormat.format(message.date_time),
                              style: TextStyle(
                                fontSize: 11,
                                color: isMe ? const Color(0xFF25D366) : Colors.grey[600],
                              ),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.done_all,
                                size: 16,
                                color: Color(0xFF25D366),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.hub,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void show_message_options(Message message) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2C34),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.reply, color: Color(0xFF25D366)),
              title: const Text(
                'Reply',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                set_replying_to(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: Color(0xFF25D366)),
              title: const Text(
                'Copy',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: message.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message copied to clipboard'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Message? find_original_message(String replyToId) {
    try {
      return messages.firstWhere((msg) => msg.id == replyToId);
    } catch (e) {
      return null;
    }
  }

  Widget build_mixed_message_input() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: message_controller,
                      decoration: const InputDecoration(
                        hintText: 'Send to all platforms...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      maxLines: null,
                      onSubmitted: (_) => send_message(),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF25D366),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: send_message,
            ),
          ),
        ],
      ),
    );
  }
}
