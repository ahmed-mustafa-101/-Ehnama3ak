import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class VoiceMessageWidget extends StatefulWidget {
  final String audioPath;
  final bool isUser;

  const VoiceMessageWidget({
    super.key,
    required this.audioPath,
    required this.isUser,
  });

  @override
  State<VoiceMessageWidget> createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget> {
  late PlayerController controller;
  bool isPrepared = false;
  bool isPlaying = false;
  Duration currentDuration = Duration.zero;
  Duration maxDuration = Duration.zero;
  
  @override
  void initState() {
    super.initState();
    controller = PlayerController();
    _preparePlayer();
  }

  void _preparePlayer() async {
    try {
      await controller.preparePlayer(
        path: widget.audioPath,
        shouldExtractWaveform: true,
        noOfSamples: 100,
        volume: 1.0,
      );
      
      controller.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            isPlaying = state == PlayerState.playing;
            if (state == PlayerState.stopped) {
              isPlaying = false;
              controller.seekTo(0);
            }
          });
        }
      });
      
      controller.onCurrentDurationChanged.listen((duration) {
        if (mounted) {
          setState(() {
            currentDuration = Duration(milliseconds: duration);
          });
        }
      });

      final duration = await controller.getDuration(DurationType.max);
      if (mounted) {
        setState(() {
          maxDuration = Duration(milliseconds: duration);
          isPrepared = true;
        });
      }
    } catch (e) {
      debugPrint("Error preparing player: $e");
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    if (!isPrepared) return;
    if (isPlaying) {
      await controller.pausePlayer();
    } else {
      await controller.startPlayer();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = widget.isUser
        ? const Color(0xFF1E88E5)
        : isDark
            ? const Color(0xFF263238)
            : const Color(0xFFF1F5F9);

    final textColor = widget.isUser
        ? Colors.white
        : isDark
            ? Colors.white
            : const Color(0xFF374957);

    final waveformColor = widget.isUser
        ? Colors.white.withValues(alpha: 0.5)
        : const Color(0xFF9FB0C0);

    final activeWaveformColor = widget.isUser
        ? Colors.white
        : const Color(0xFF1E88E5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24).copyWith(
          bottomRight: widget.isUser ? const Radius.circular(4) : null,
          topLeft: !widget.isUser ? const Radius.circular(4) : null,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 5,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _togglePlay,
              customBorder: const CircleBorder(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.isUser
                      ? Colors.white.withValues(alpha: 0.2)
                      : const Color(0xFF1E88E5).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: isPrepared
                    ? Icon(
                        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: activeWaveformColor,
                        size: 28,
                      )
                    : Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: activeWaveformColor,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Waveform
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isPrepared)
                AudioFileWaveforms(
                  size: Size(MediaQuery.of(context).size.width * 0.45, 30),
                  playerController: controller,
                  enableSeekGesture: true,
                  waveformType: WaveformType.fitWidth,
                  playerWaveStyle: PlayerWaveStyle(
                    fixedWaveColor: waveformColor,
                    liveWaveColor: activeWaveformColor,
                    spacing: 4,
                    waveThickness: 2.5,
                    showSeekLine: false,
                  ),
                )
              else
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  height: 30,
                  child: Center(
                    child: LinearProgressIndicator(
                      color: activeWaveformColor,
                      backgroundColor: waveformColor,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              // Duration
              Text(
                _formatDuration(isPlaying ? currentDuration : maxDuration),
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
