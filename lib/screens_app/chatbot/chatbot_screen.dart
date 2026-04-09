import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';

class ChatbotScreen extends StatefulWidget {
  final VoidCallback? onClose;
  const ChatbotScreen({super.key, this.onClose});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _inputCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      try {
        bool available = await _speech.initialize(
          onStatus: (val) {
            if (val == 'done' || val == 'notListening') {
              setState(() => _isListening = false);
            }
          },
          onError: (val) => setState(() => _isListening = false),
        );
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            onResult: (val) => setState(() {
              _inputCtrl.text = val.recognizedWords;
              _inputCtrl.selection = TextSelection.fromPosition(
                TextPosition(offset: _inputCtrl.text.length),
              );
            }),
          );
        }
      } catch (e) {
        setState(() => _isListening = false);
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _messages.add(
            _ChatMessage(text: "", isUser: true, image: File(pickedFile.path)),
          );
          _messages.add(
            _ChatMessage(
              text: AppLocalizations.of(context).imageReceived,
              isUser: false,
            ),
          );
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).selectImageSource,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOption(
                  icon: Icons.camera_alt,
                  label: AppLocalizations.of(context).camera,
                  onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
                ),
                _buildOption(
                  icon: Icons.photo_library,
                  label: AppLocalizations.of(context).gallery,
                  onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1E88E5), size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _inputCtrl.clear();
      _messages.add(
        _ChatMessage(
          text: AppLocalizations.of(context).botReply,
          isUser: false,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            height: 56,
            child: Row(
              children: [
                const Spacer(),
                Center(
                  child: Text(
                    'Depo',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1F2933),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          const Divider(height: 1),

          // ===== قائمة الرسائل =====
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // ===== شريط الإدخال في الأسفل =====
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 5, 10, 10),
            child: Row(
              children: [
                // زر إضافة صورة على اليسار
                IconButton(
                  onPressed: _showImageSourceBottomSheet,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Color(0xFF1E88E5),
                    size: 46,
                  ),
                ),
                const SizedBox(width: 4),

                // حقل الكتابة داخل Container مستطيل
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFFF5F7FB),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _isListening
                            ? Colors.blue.withValues(alpha: 0.5)
                            : Colors.blueGrey.withValues(alpha: 0.25),
                        width: _isListening ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputCtrl,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: AppLocalizations.of(context).askDepo,
                              hintStyle: TextStyle(
                                color: Color(0xFF9FB0C0),
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _listen,
                          icon: Icon(
                            _isListening ? Icons.mic : Icons.mic_outlined,
                            color: const Color(0xFF1E88E5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // زر الإرسال الدائري الأزرق
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 40,
                    height: 40,
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
      ),
    );
  }

  // =================== WIDGET الرسالة ===================

  Widget _buildMessageBubble(_ChatMessage msg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (msg.isUser) {
      // رسالة المستخدم
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
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
                    20,
                  ).copyWith(bottomRight: const Radius.circular(4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (msg.image != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          msg.image!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (msg.image != null && msg.text.isNotEmpty)
                      const SizedBox(height: 8),
                    if (msg.text.isNotEmpty)
                      Text(
                        msg.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.35,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // رسالة البوت
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                msg.text,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  color: isDark ? Colors.white : const Color(0xFF374957),
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
                    SnackBar(content: Text(AppLocalizations.of(context).copiedToClipboard)),
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
  final File? image;

  _ChatMessage({required this.text, required this.isUser, this.image});
}
