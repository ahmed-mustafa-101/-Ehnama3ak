import 'package:flutter/material.dart';
import '../../../features/messages/data/models/message_model.dart';

/// Collapsible pinned-messages bar shown at the top of the chat.
class PinnedMessagesBar extends StatefulWidget {
  final List<MessageModel> pinned;
  final void Function(int messageId) onUnpin;
  final void Function(int messageId) onNavigate;

  const PinnedMessagesBar({
    super.key,
    required this.pinned,
    required this.onUnpin,
    required this.onNavigate,
  });

  @override
  State<PinnedMessagesBar> createState() => _PinnedMessagesBarState();
}

class _PinnedMessagesBarState extends State<PinnedMessagesBar> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.pinned.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      color: isDark ? const Color(0xFF1E2A35) : const Color(0xFFE8F4FE),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header tap to expand / collapse
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.push_pin, size: 14, color: Color(0xFF0DA5FE)),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.pinned.length} Pinned Message${widget.pinned.length > 1 ? "s" : ""}',
                    style: const TextStyle(
                      color: Color(0xFF0DA5FE),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF0DA5FE),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            ...widget.pinned.map(
              (msg) => InkWell(
                onTap: () => widget.onNavigate(msg.id),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0DA5FE),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          msg.isText
                              ? msg.message
                              : msg.isImage
                                  ? '📷 Image'
                                  : msg.isVoice
                                      ? '🎤 Voice message'
                                      : '📎 ${msg.attachmentName ?? "File"}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                        onPressed: () => widget.onUnpin(msg.id),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
