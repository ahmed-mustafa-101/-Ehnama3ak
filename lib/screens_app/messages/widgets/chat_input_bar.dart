import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import '../../../core/localization/app_localizations.dart';

/// Full-featured bottom input bar.
/// Calls callbacks for send/image/file/voice so the screen can
/// delegate to ChatCubit without this widget knowing about Bloc.
class ChatInputBar extends StatefulWidget {
  final void Function(String text) onSendText;
  final void Function(File file) onSendImage;
  final void Function(File file) onSendFile;
  final void Function(File file) onSendVoice;

  const ChatInputBar({
    super.key,
    required this.onSendText,
    required this.onSendImage,
    required this.onSendFile,
    required this.onSendVoice,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar>
    with TickerProviderStateMixin {
  final TextEditingController _ctrl = TextEditingController();
  final AudioRecorder _recorder = AudioRecorder();
  late final RecorderController _recorderController;
  bool _hasText = false;
  bool _isRecording = false;
  Timer? _recordTimer;
  int _recordSeconds = 0;

  static const _blue = Color(0xFF0DA5FE);

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final has = _ctrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    _recorderController = RecorderController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _recorder.dispose();
    _recorderController.dispose();
    _recordTimer?.cancel();
    super.dispose();
  }

  // ── Send text ────────────────────────────────────────────────────────────
  void _send() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    _ctrl.clear();
    widget.onSendText(t);
  }

  // ── Pick image ───────────────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final xf = await picker.pickImage(source: source, imageQuality: 80);
    if (xf != null) widget.onSendImage(File(xf.path));
  }

  // ── Pick file ────────────────────────────────────────────────────────────
  Future<void> _pickFile() async {
    Navigator.pop(context);
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      widget.onSendFile(File(result.files.single.path!));
    }
  }

  // ── Voice recording ──────────────────────────────────────────────────────
  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _recorder.start(const RecordConfig(), path: path);
        await _recorderController.record(path: path);

        setState(() {
          _isRecording = true;
          _recordSeconds = 0;
        });

        _recordTimer?.cancel();
        _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() => _recordSeconds++);
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('mic_permission_denied'),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    _recordTimer?.cancel();
    await _recorderController.stop();
    final path = await _recorder.stop();
    setState(() => _isRecording = false);
    if (path != null) widget.onSendVoice(File(path));
  }

  // ── Attachment sheet ─────────────────────────────────────────────────────
  void _showAttachmentSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _attachBtn(
                    icon: Icons.photo_library_outlined,
                    label: AppLocalizations.of(context).gallery,
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                  _attachBtn(
                    icon: Icons.camera_alt_outlined,
                    label: AppLocalizations.of(context).camera,
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  _attachBtn(
                    icon: Icons.attach_file_outlined,
                    label: AppLocalizations.of(context).translate('file'),
                    onTap: _pickFile,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attachBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _blue, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: _isRecording
            ? _buildRecordingRow(isDark)
            : _buildNormalRow(isDark),
      ),
    );
  }

  Widget _buildNormalRow(bool isDark) {
    return Row(
      children: [
        _iconBtn(
          icon: Icons.add_rounded,
          onTap: _showAttachmentSheet,
          bg: _blue.withOpacity(0.1),
          color: _blue,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.07)
                  : const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(26),
            ),
            child: TextField(
              controller: _ctrl,
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).messageLabel,
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _hasText
            ? _iconBtn(
                icon: Icons.send_rounded,
                onTap: _send,
                bg: _blue,
                color: Colors.white,
              )
            : GestureDetector(
                onTap: () {
                  if (_isRecording) {
                    _stopRecording();
                  } else {
                    _startRecording();
                  }
                },
                onLongPressStart: (_) => _startRecording(),
                onLongPressEnd: (_) => _stopRecording(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: _blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic, color: Colors.white, size: 22),
                ),
              ),
      ],
    );
  }

  Widget _buildRecordingRow(bool isDark) {
    final mins = _recordSeconds ~/ 60;
    final secs = _recordSeconds % 60;
    return Row(
      children: [
        const Icon(Icons.circle, color: Colors.red, size: 12),
        const SizedBox(width: 8),
        Text(
          '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AudioWaveforms(
            size: Size(MediaQuery.of(context).size.width, 40),
            recorderController: _recorderController,
            enableGesture: false,
            waveStyle: const WaveStyle(
              waveColor: _blue,
              showMiddleLine: false,
              spacing: 4,
              waveThickness: 2,
              extendWaveform: true,
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            _recordTimer?.cancel();
            await _recorderController.stop();
            await _recorder.stop();
            setState(() => _isRecording = false);
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _stopRecording,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: _blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required VoidCallback onTap,
    required Color bg,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
