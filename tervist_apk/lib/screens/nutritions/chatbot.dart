import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tervist_apk/api/api_config.dart';
import 'package:tervist_apk/api/chatbot_service.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        text: json['text'],
        isUser: json['isUser'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class TervyChatScreen extends StatefulWidget {
  const TervyChatScreen({super.key});

  @override
  State<TervyChatScreen> createState() => _TervyChatScreenState();
}

class _TervyChatScreenState extends State<TervyChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final GlobalKey _faqIconKey = GlobalKey();
  OverlayEntry? _faqOverlay;
  bool _isTyping = false;
  bool _isFAQActive = false;
  List<Map<String, String>> _conversationHistory = [];

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    await _loadMessages();
    final prefs = await SharedPreferences.getInstance();
    final hasShownGreeting = prefs.getBool('tervy_greeting_shown') ?? false;
    if (!hasShownGreeting) {
      _addBotMessage(
        "Hello, I'm Tervy!👋 I'm your personal nutrition assistant. I can help you track calories, protein, carbs, and fats in your food. How can I assist you today?\n\nNew to Tervy or unsure what to ask? Check out the FAQ above on the right!",
      );
      prefs.setBool('tervy_greeting_shown', true);
    }
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getStringList('tervy_messages') ?? [];
    setState(() {
      _messages.clear();
      _messages.addAll(messagesJson
          .map((jsonStr) => ChatMessage.fromJson(json.decode(jsonStr))));
    });
    _conversationHistory = await ChatbotService.loadConversationHistory();
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = _messages.map((m) => json.encode(m.toJson())).toList();
    await prefs.setStringList('tervy_messages', messagesJson);
  }

  void _addMessage(String text, bool isUser) {
    final message =
        ChatMessage(text: text, isUser: isUser, timestamp: DateTime.now());
    setState(() => _messages.add(message));
    _saveMessages();
    _conversationHistory
        .add({'role': isUser ? 'user' : 'assistant', 'content': text});
    ChatbotService.saveConversationHistory(_conversationHistory);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addBotMessage(String text) => _addMessage(text, false);
  void _addUserMessage(String text) => _addMessage(text, true);

  Future<void> _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;
    final userMessage = _textController.text;
    _addUserMessage(userMessage);
    _textController.clear();
    setState(() => _isTyping = true);
    try {
      final response = await ChatbotService.getChatGPTResponse(
          userMessage, _conversationHistory);
      _addBotMessage(response);
    } catch (e) {
      _addBotMessage("Maaf, aku mengalami kendala. Silakan coba lagi nanti.");
    } finally {
      setState(() => _isTyping = false);
    }
  }

  void _toggleFAQOverlay() {
    setState(() {
      _isFAQActive = !_isFAQActive;
    });

    if (_faqOverlay != null) {
      _faqOverlay!.remove();
      _faqOverlay = null;
      return;
    }

    final RenderBox box =
        _faqIconKey.currentContext!.findRenderObject() as RenderBox;
    final Offset pos = box.localToGlobal(Offset.zero);
    final Size size = box.size;

    _faqOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: pos.dy + size.height - 35,
        left: pos.dx - 300,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 350,
            height: 460,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Frequently Asked Questions',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                _buildFAQItem('1. How accurate are the calorie estimates?',
                    'The estimates are based on average portions and general ingredients. For precise measurements, please consult nutritional labels or a dietitian.'),
                const SizedBox(height: 12),
                _buildFAQItem('2. Can I ask about specific dishes?',
                    'Yes! You can describe any dish and get an estimated calorie count. The more details you provide, the more accurate the estimate will be.'),
                const SizedBox(height: 12),
                _buildFAQItem('3. What information should I include?',
                    "Include portion size, main ingredients, and cooking method (e.g., 'large bowl of creamy pasta with chicken and mushrooms')."),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _faqOverlay?.remove();
                      _faqOverlay = null;
                      setState(() {
                        _isFAQActive = false;
                      });
                    },
                    child: Text("Close", style: GoogleFonts.poppins()),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_faqOverlay!);
  }

  Widget _buildFAQItem(String q, String a) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q,
              style: GoogleFonts.poppins(
                  color: Color(0XFF425E8E), fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(a, style: GoogleFonts.poppins(fontSize: 14, height: 1.5)),
        ],
      );

  Widget _buildMessage(ChatMessage msg) {
    final isUser = msg.isUser;
    final bubbleColor = isUser
        ? const Color(0xFFAEB3BE).withOpacity(0.2)
        : Color(0xFFAEB3BE).withOpacity(0.4);
    final borderRadius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(28),
          )
        : const BorderRadius.only(
            topRight: Radius.circular(28),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Transform.translate(
              offset: const Offset(0, -14),
              child: Container(
                margin: const EdgeInsets.only(left: 4, right: 6),
                child: CircleAvatar(
                  backgroundColor: Color.fromRGBO(174, 179, 190, 0.4),
                  radius: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/aitervy.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          Flexible(
            child: Container(
              margin: isUser
                  ? const EdgeInsets.only(left: 48)
                  : const EdgeInsets.only(right: 48),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: borderRadius,
              ),
              child: Text(
                msg.text,
                textAlign: isUser ? TextAlign.right : TextAlign.left,
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7F6),
      appBar: AppBar(
        backgroundColor: Color(0xFFF1F7F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Center(
          child: Text('Tervy',
              style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 20)),
        ),
        actions: [
          Container(
            key: _faqIconKey,
            margin: const EdgeInsets.only(right: 12),
            decoration: _isFAQActive
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Color(0xFFE9EBF8), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFE9EBF8).withOpacity(0.3),
                        blurRadius: 5,
                        spreadRadius: 12,
                        offset: Offset(0, 0),
                      ),
                    ],
                  )
                : null,
            child: IconButton(
              onPressed: _toggleFAQOverlay,
              icon: Image.asset(
                'assets/images/faqicon.png',
                width: 40,
                height: 40,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('Tervy is typing...',
                  style: GoogleFonts.poppins(color: Colors.grey)),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    offset: Offset(0, -2), blurRadius: 4, color: Colors.black12)
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: Color(0xFFEDF3F7),
                        borderRadius: BorderRadius.circular(100)),
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.poppins()),
                      style: GoogleFonts.poppins(),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Image.asset("assets/images/icon_send.png",
                        width: 24, height: 24),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _faqOverlay?.remove();
    super.dispose();
  }
}
