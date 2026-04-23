// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'models/podcast_model.dart';

// class PodcastPlayerScreen extends StatefulWidget {
//   final PodcastModel podcast;

//   const PodcastPlayerScreen({super.key, required this.podcast});

//   @override
//   State<PodcastPlayerScreen> createState() => _PodcastPlayerScreenState();
// }

// class _PodcastPlayerScreenState extends State<PodcastPlayerScreen> {
//   final AudioPlayer _player = AudioPlayer();

//   @override
//   void initState() {
//     super.initState();
//     _initPlayer();
//   }

//   Future<void> _initPlayer() async {
//     try {
//       await _player.setUrl(widget.podcast.audioUrl);
//     } catch (e) {
//       debugPrint('Audio load error: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _player.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(),

//       /// ================= BODY =================
//       body: SafeArea(
//         child: Column(
//           children: [
//             const SizedBox(height: 10),

//             /// ===== TOP BAR =====
//             // Padding(
//             //   padding: const EdgeInsets.symmetric(horizontal: 16),
//             //   child: Row(
//             //     children: [
//             //       IconButton(
//             //         icon: const Icon(
//             //           Icons.arrow_back,
//             //           color: Color(0xff0DA5FE),
//             //         ),
//             //         onPressed: () => Navigator.pop(context),
//             //       ),
//             //       const Spacer(),
//             //       Image.asset('assets/images/name.png', width: 120),
//             //       const Spacer(),
//             //       IconButton(
//             //         icon: const Icon(
//             //           Icons.notifications,
//             //           color: Color(0xff0DA5FE),
//             //         ),
//             //         onPressed: () {},
//             //       ),
//             //     ],
//             //   ),
//             // ),
//             const SizedBox(height: 30),

//             /// ===== COVER IMAGE =====
//             // ClipRRect(
//             //   borderRadius: BorderRadius.circular(20),
//             //   child: Image.asset(
//             //     'assets/images/anxiety.jpg', // نفس الصورة
//             //     width: 260,
//             //     height: 260,
//             //     fit: BoxFit.cover,
//             //   ),
//             // ),
//             const SizedBox(height: 20),

//             /// ===== TITLE =====
//             Text(
//               widget.podcast.title,
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
//             ),

//             const SizedBox(height: 30),

//             /// ===== TIME + WAVE =====
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: const [
//                       Text('07:00', style: TextStyle(color: Colors.grey)),
//                       Text('15:00', style: TextStyle(color: Colors.grey)),
//                     ],
//                   ),
//                   const SizedBox(height: 12),

//                   /// Fake waveform (UI)
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: List.generate(22, (i) {
//                       final active = i < 10;
//                       return Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 2),
//                         width: 4,
//                         height: active ? 26 : 16,
//                         decoration: BoxDecoration(
//                           color: active
//                               ? const Color(0xff0DA5FE)
//                               : Colors.grey.shade300,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       );
//                     }),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 40),

//             /// ===== CONTROLS =====
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 const Icon(Icons.swap_horiz, color: Colors.grey),
//                 const Icon(Icons.timer_outlined, color: Colors.grey),

//                 /// PLAY / PAUSE
//                 StreamBuilder<PlayerState>(
//                   stream: _player.playerStateStream,
//                   builder: (context, snapshot) {
//                     final playing = snapshot.data?.playing ?? false;
//                     return CircleAvatar(
//                       radius: 34,
//                       backgroundColor: const Color(0xff0DA5FE),
//                       child: IconButton(
//                         iconSize: 40,
//                         icon: Icon(
//                           playing ? Icons.pause : Icons.play_arrow,
//                           color: Colors.white,
//                         ),
//                         onPressed: () {
//                           playing ? _player.pause() : _player.play();
//                         },
//                       ),
//                     );
//                   },
//                 ),

//                 const Icon(Icons.repeat, color: Colors.grey),
//                 const Icon(Icons.playlist_play, color: Colors.grey),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'models/podcast_model.dart';

class PodcastPlayerScreen extends StatefulWidget {
  final PodcastModel podcast;

  const PodcastPlayerScreen({super.key, required this.podcast});

  @override
  State<PodcastPlayerScreen> createState() => _PodcastPlayerScreenState();
}

class _PodcastPlayerScreenState extends State<PodcastPlayerScreen> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadAudio();
  }

  Future<void> _loadAudio() async {
    try {
      await _player.setUrl(widget.podcast.audioUrl);
    } catch (e) {
      debugPrint('Error loading audio: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  /// ===== FORMAT TIME =====
  String _format(Duration d) {
    final minutes = d.inMinutes;
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
          // backgroundColor: Colors.white,
          ),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// ===== TOP BAR =====
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Row(
            //     children: [
            //       IconButton(
            //         icon: const Icon(
            //           Icons.arrow_back,
            //           color: Color(0xff0DA5FE),
            //         ),
            //         onPressed: () => Navigator.pop(context),
            //       ),
            //       const Spacer(),
            //       Image.asset('assets/images/image_started.png', width: 120),
            //       const Spacer(),
            //       IconButton(
            //         icon: const Icon(
            //           Icons.notifications,
            //           color: Color(0xff0DA5FE),
            //         ),
            //         onPressed: () {},
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 30),

            /// ===== IMAGE =====
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/image_started.png',
                width: 260,
                height: 260,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            /// ===== TITLE =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                widget.podcast.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 30),

            /// ===== PROGRESS BAR =====
            StreamBuilder<Duration>(
              stream: _player.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final total = _player.duration ?? Duration.zero;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Slider(
                        value: position.inSeconds.toDouble(),
                        max: total.inSeconds.toDouble() == 0
                            ? 1
                            : total.inSeconds.toDouble(),
                        onChanged: (value) {
                          _player.seek(Duration(seconds: value.toInt()));
                        },
                        activeColor: const Color(0xff0DA5FE),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _format(position),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            _format(total),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const Spacer(),

            /// ===== CONTROLS =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                /// BACK 10s
                IconButton(
                  icon: const Icon(
                    Icons.replay_10,
                    size: 28,
                    color: Colors.grey,
                  ),
                  onPressed: () async {
                    final p = _player.position;
                    _player.seek(p - const Duration(seconds: 10));
                  },
                ),

                /// PLAY / PAUSE
                StreamBuilder<PlayerState>(
                  stream: _player.playerStateStream,
                  builder: (context, snapshot) {
                    final playing = snapshot.data?.playing ?? false;

                    return CircleAvatar(
                      radius: 36,
                      backgroundColor: const Color(0xff0DA5FE),
                      child: IconButton(
                        iconSize: 42,
                        icon: Icon(
                          playing ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          playing ? _player.pause() : _player.play();
                        },
                      ),
                    );
                  },
                ),

                /// FORWARD 10s
                IconButton(
                  icon: const Icon(
                    Icons.forward_10,
                    size: 28,
                    color: Colors.grey,
                  ),
                  onPressed: () async {
                    final p = _player.position;
                    _player.seek(p + const Duration(seconds: 10));
                  },
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
