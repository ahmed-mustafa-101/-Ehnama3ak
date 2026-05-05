import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';
import 'package:ehnama3ak/screens_app/chatbot/chat_cubit.dart';
import 'package:ehnama3ak/screens_app/chatbot/chat_state.dart';
import 'package:ehnama3ak/screens_app/chatbot/chat_message.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:ehnama3ak/screens_app/chatbot/voice_message_widget.dart';

class ChatbotScreen extends StatefulWidget {
  final VoidCallback? onClose;
  const ChatbotScreen({super.key, this.onClose});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  late stt.SpeechToText _speech;
  bool _isListening = false;

  late AudioRecorder _audioRecorder;
  bool _isRecording = false;
  String? _audioPath;
  double _amplitude = 0.0;
  List<double> _amplitudeHistory = List.filled(20, -60.0);
  StreamSubscription<Amplitude>? _amplitudeSub;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _startRecording() async {
    dev.log('Attempting to start recording...', name: 'ChatbotScreen');
    try {
      if (await _audioRecorder.hasPermission()) {
        dev.log('Permission granted', name: 'ChatbotScreen');
        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.wav';

        const config = RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        );

        dev.log('Starting recorder with path: $path', name: 'ChatbotScreen');
        await _audioRecorder.start(config, path: path);

        _amplitudeSub = _audioRecorder
            .onAmplitudeChanged(const Duration(milliseconds: 100))
            .listen((amp) {
              if (mounted) {
                setState(() {
                  _amplitude = amp.current;
                  _amplitudeHistory.removeAt(0);
                  _amplitudeHistory.add(amp.current);
                });
              }
            });

        setState(() {
          _isRecording = true;
          _audioPath = path;
        });
        dev.log('Recording started successfully', name: 'ChatbotScreen');
      } else {
        dev.log('Permission denied', name: 'ChatbotScreen');
      }
    } catch (e) {
      dev.log('Error starting recording: $e', name: 'ChatbotScreen', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    dev.log('Stopping recording...', name: 'ChatbotScreen');
    try {
      await _amplitudeSub?.cancel();
      final path = await _audioRecorder.stop();
      dev.log('Recorder stopped. Path: $path', name: 'ChatbotScreen');

      setState(() {
        _isRecording = false;
        _amplitude = 0.0;
        _amplitudeHistory = List.filled(20, -60.0);
      });

      if (path != null) {
        if (mounted) {
          dev.log('Sending voice message to cubit', name: 'ChatbotScreen');
          context.read<ChatCubit>().sendVoiceMessage(path);
        }
      }
    } catch (e) {
      dev.log('Error stopping recording: $e', name: 'ChatbotScreen', error: e);
    }
  }

  Future<void> _cancelRecording() async {
    dev.log('Canceling recording...', name: 'ChatbotScreen');
    try {
      await _amplitudeSub?.cancel();
      final path = await _audioRecorder.stop();
      dev.log('Recorder canceled. Path: $path', name: 'ChatbotScreen');

      setState(() {
        _isRecording = false;
        _amplitude = 0.0;
        _amplitudeHistory = List.filled(20, -60.0);
        _audioPath = null;
      });

      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      dev.log('Error canceling recording: $e', name: 'ChatbotScreen', error: e);
    }
  }

  void _listen() async {
    // Keeping speech to text as an option or replacing it?
    // Let's use tap for speech-to-text and long press for recording voice message.
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

      if (pickedFile != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).imageReceived)),
        );
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        if (mounted) {
          context.read<ChatCubit>().sendVoiceMessage(path);
        }
      }
    } catch (e) {
      debugPrint("Error picking audio: $e");
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
              AppLocalizations.of(context).selectSource,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOption(
                  icon: Icons.camera_alt,
                  label: AppLocalizations.of(context).camera,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildOption(
                  icon: Icons.photo_library,
                  label: AppLocalizations.of(context).gallery,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                _buildOption(
                  icon: Icons.audiotrack,
                  label: 'Audio',
                  onTap: () {
                    Navigator.pop(context);
                    _pickAudioFile();
                  },
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
              color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
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

    context.read<ChatCubit>().sendMessage(text);
    _inputCtrl.clear();
    _scrollToBottom();
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.smart_toy_outlined,
                        color: Color(0xFF1E88E5),
                        size: 35,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Depo',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1F2933),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          const Divider(height: 1),

          // ===== قائمة الرسائل =====
          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listener: (context, state) {
                if (state is ChatLoaded ||
                    state is ChatLoading ||
                    state is ChatError) {
                  _scrollToBottom();
                }
                if (state is ChatError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final messages = state.messages;
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: messages.length + (state is ChatLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length && state is ChatLoading) {
                      return _buildTypingIndicator();
                    }
                    final msg = messages[index];
                    return _buildMessageBubble(msg);
                  },
                );
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
                    padding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: _isRecording ? 0 : 4,
                    ),
                    constraints: BoxConstraints(
                      minHeight: _isRecording ? 40 : 45,
                      maxHeight: _isRecording ? 60 : 150,
                    ),
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
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (_isRecording)
                          Expanded(
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: _cancelRecording,
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 28,
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: VoiceWaveform(
                                      amplitudes: _amplitudeHistory,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Expanded(
                            child: TextField(
                              controller: _inputCtrl,
                              maxLines: null,
                              minLines: 1,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                border: InputBorder.none,
                                hintText: AppLocalizations.of(context).askDepo,
                                hintStyle: const TextStyle(
                                  color: Color(0xFF9FB0C0),
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        IconButton(
                          onPressed: () {
                            if (_isRecording) {
                              _stopRecording();
                            } else {
                              _startRecording();
                            }
                          },
                          icon: Icon(
                            _isRecording
                                ? Icons.stop_circle
                                : Icons.mic_outlined,
                            color: const Color(0xFF1E88E5),
                            size: 32,
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

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : const Color(0xFFF5F7FB),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TypingDot(delay: Duration(milliseconds: 0)),
                SizedBox(width: 4),
                _TypingDot(delay: Duration(milliseconds: 200)),
                SizedBox(width: 4),
                _TypingDot(delay: Duration(milliseconds: 400)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _getValidEmotionText(String? emotion) {
    if (emotion == null ||
        emotion.trim().isEmpty ||
        emotion.toLowerCase() == 'string') {
      return null;
    }
    // Capitalize first letter
    return '${emotion[0].toUpperCase()}${emotion.substring(1).toLowerCase()}';
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      constraints: const BoxConstraints(),
      icon: Icon(icon, size: 18, color: const Color(0xFF90A4AE)),
      onPressed: onPressed,
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (msg.isUser) {
      // رسالة المستخدم
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: msg.audioPath != null
                  ? VoiceMessageWidget(audioPath: msg.audioPath!, isUser: true)
                  : Container(
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
                          if (msg.message.isNotEmpty)
                            Text(
                              msg.message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
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
      final emotionText = _getValidEmotionText(msg.emotion);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: Color(0xFF1E88E5),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: msg.audioPath != null
                  ? VoiceMessageWidget(audioPath: msg.audioPath!, isUser: false)
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF263238)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(
                          20,
                        ).copyWith(topLeft: const Radius.circular(4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (emotionText != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  emotionText,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ),
                          Text(
                            msg.message,
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.35,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF374957),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildActionButton(
                                icon: Icons.thumb_up_outlined,
                                tooltip: 'Good response',
                                onPressed: () {},
                              ),
                              _buildActionButton(
                                icon: Icons.thumb_down_outlined,
                                tooltip: 'Bad response',
                                onPressed: () {},
                              ),
                              _buildActionButton(
                                icon: Icons.ios_share_outlined,
                                tooltip: 'Share',
                                onPressed: () {
                                  Share.share(msg.message);
                                },
                              ),
                              _buildActionButton(
                                icon: Icons.refresh_rounded,
                                tooltip: AppLocalizations.of(context).tryAgain,
                                onPressed: () {
                                  final chatCubit = context.read<ChatCubit>();
                                  final lastUserMsg = chatCubit
                                      .state
                                      .messages
                                      .reversed
                                      .where((m) => m.isUser)
                                      .firstOrNull;
                                  if (lastUserMsg != null) {
                                    chatCubit.sendMessage(lastUserMsg.message);
                                  }
                                },
                              ),
                              _buildActionButton(
                                icon: Icons.copy_outlined,
                                tooltip: AppLocalizations.of(
                                  context,
                                ).copiedToClipboard,
                                onPressed: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: msg.message),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      );
    }
  }
}

// =================== Voice Waveform Widget ===================
class VoiceWaveform extends StatelessWidget {
  final List<double> amplitudes;
  const VoiceWaveform({super.key, required this.amplitudes});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(amplitudes.length, (index) {
          double amp = amplitudes[index];
          double scale = (amp + 50).clamp(0, 50) / 50;
          if (scale < 0.1) scale = 0.1;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 5,
            height: 8 + (40 * scale),
            decoration: BoxDecoration(
              color: const Color(
                0xFF1E88E5,
              ).withValues(alpha: 0.3 + (scale * 0.7)),
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }),
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final Duration delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: Color.lerp(Colors.blueGrey, Colors.blue, _animation.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
