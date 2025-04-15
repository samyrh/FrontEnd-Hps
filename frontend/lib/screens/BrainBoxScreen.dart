import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BrainBoxScreen extends StatefulWidget {
  const BrainBoxScreen({super.key});

  @override
  State<BrainBoxScreen> createState() => _BrainBoxScreenState();
}

class _BrainBoxScreenState extends State<BrainBoxScreen> with TickerProviderStateMixin {
  double _iconScale = 1.0;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _chatStarted = false;
  bool _isTyping = false;

  final List<String> _instructions = [
    "Remembers what user said earlier in the conversation",
    "Allows user to provide follow-up corrections with AI",
    "Has a limited understanding of recent events and trends",
    "May occasionally generate incorrect information",
    "May occasionally produce harmful instructions or biased content",
  ];

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final timestamp = DateTime.now();
    setState(() {
      _chatStarted = true;
      _messages.add({
        'text': text,
        'isUser': true,
        'timestamp': timestamp,
      });
      _controller.clear();
    });

    _scrollToBottom();

    setState(() => _isTyping = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() {
        _isTyping = false;
        _messages.add({
          'text': 'AI: "$text"',
          'isUser': false,
          'timestamp': DateTime.now(),
        });
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Today at ${DateFormat('hh:mm a').format(timestamp)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${DateFormat('hh:mm a').format(timestamp)}';
    } else if (difference.inDays < 7) {
      return '${DateFormat('EEEE').format(timestamp)}, ${DateFormat('MMM d').format(timestamp)} at ${DateFormat('hh:mm a').format(timestamp)}';
    } else {
      return '${DateFormat('MMM d, yyyy').format(timestamp)} at ${DateFormat('hh:mm a').format(timestamp)}';
    }
  }

  Widget _buildAvatar(bool isUser) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.grey.shade300,
      backgroundImage: AssetImage(
        isUser ? 'assets/user_chat.png' : 'assets/ai_chat.png',
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, -12), // Slightly raised avatar for AI
          child: _buildAvatar(false),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            children: [
              Dot(),
              SizedBox(width: 4),
              Dot(delay: 200),
              SizedBox(width: 4),
              Dot(delay: 400),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5EA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5E5EA),
        elevation: 0,
        scrolledUnderElevation: 0, // 💡 this removes scroll shadow
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'BrainBox',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1E2D),
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
          child: Material(
            color: const Color(0xFFE5E5EA), // match AppBar & Scaffold
            child: Column(
              children: [
                const SizedBox(height: 12),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: !_chatStarted
                        ? ListView.builder(
                      key: const ValueKey('instructions'),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _instructions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                            child: Text(
                              _instructions[index],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.55,
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                        : ListView.builder(
                      key: const ValueKey('chat'),
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isTyping && index == _messages.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: _buildTypingIndicator(),
                          );
                        }

                        final message = _messages[index];
                        final isUser = message['isUser'] as bool;
                        final time = message['timestamp'] as DateTime;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isUser) ...[
                                _buildAvatar(false),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.85),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: isUser
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            message['text'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              height: 1.5,
                                              color: Color(0xFF1C1C1E),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            _formatTime(time),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.black.withOpacity(0.4),
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isUser) ...[
                                const SizedBox(width: 8),
                                _buildAvatar(true),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: Colors.white.withOpacity(0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                style: const TextStyle(fontSize: 16, color: Colors.black87),
                                decoration: const InputDecoration(
                                  hintText: "iMessage",
                                  hintStyle: TextStyle(color: Colors.black38),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(bottom: 2),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTapDown: (_) => setState(() => _iconScale = 0.9),
                              onTapUp: (_) {
                                setState(() => _iconScale = 1.0);
                                _handleSend();
                              },
                              onTapCancel: () => setState(() => _iconScale = 1.0),
                              child: AnimatedScale(
                                scale: _iconScale,
                                duration: const Duration(milliseconds: 150),
                                curve: Curves.easeOut,
                                child: Image.asset(
                                  'assets/send.png',
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

    );
  }
}

class Dot extends StatefulWidget {
  final int delay;
  const Dot({super.key, this.delay = 0});

  @override
  State<Dot> createState() => _DotState();
}

class _DotState extends State<Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _scale = Tween(begin: 0.7, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
