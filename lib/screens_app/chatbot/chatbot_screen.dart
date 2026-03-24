import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatbotScreen extends StatefulWidget {
  final VoidCallback? onClose;
  const ChatbotScreen({super.key, this.onClose});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<_ChatMessage> _messages = [];

  final TextEditingController _inputCtrl = TextEditingController();

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _inputCtrl.clear();

      _messages.add(
        _ChatMessage(
          text:
              "Thank you for sharing this.\nCan you tell me a bit more about how this makes you feel?",
          isUser: false,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              height: 56,
              child: Row(
                children: [
                  const Spacer(),
                  Text(
                    'DoDo AI',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1F2933),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const Divider(height: 1),

            // ===== قائمة الرسائل =====
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            // ===== شريط الإدخال في الأسفل =====
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: Row(
                children: [
                  // حقل الكتابة داخل Container مستطيل
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E1E1E)
                            : const Color(0xFFF5F7FB),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.blueGrey.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _inputCtrl,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Generate a name of ....',
                                hintStyle: TextStyle(
                                  color: Color(0xFF9FB0C0),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.mic_outlined,
                              color: Color(0xFF1E88E5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // زر الإرسال الدائري الأزرق
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E88E5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }

  // =================== WIDGET الرسالة ===================

  Widget _buildMessageBubble(_ChatMessage msg) {
    if (msg.isUser) {
      // رسالة المستخدم (يمين – فقاعة زرقاء)
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5),
                  borderRadius: BorderRadius.circular(
                    22,
                  ).copyWith(bottomRight: const Radius.circular(4)),
                ),
                child: Text(
                  msg.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // رسالة البوت (يسار – نص رمادي + أيقونة Copy)
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                msg.text,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF374957),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.copy_outlined,
                size: 20,
                color: Color(0xFF90A4AE),
              ),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: msg.text));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                }
              },
            ),
          ],
        ),
      );
    }
  }
}

// موديل بسيط للرسالة
class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}
