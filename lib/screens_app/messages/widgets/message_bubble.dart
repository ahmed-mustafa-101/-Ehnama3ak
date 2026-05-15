import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import '../../../features/messages/data/models/message_model.dart';
import '../../chatbot/voice_message_widget.dart';
import '../../../core/localization/app_localizations.dart';

/// A single chat bubble supporting text, image, voice, and file messages.
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final VoidCallback? onPin;
  final VoidCallback? onUnpin;
  final bool showAvatar;
  final String? senderInitial;
  final String? senderImage;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onPin,
    this.onUnpin,
    this.showAvatar = false,
    this.senderInitial,
    this.senderImage,
  });

  static const _blue = Color(0xFF0DA5FE);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onLongPress: () => _showMenu(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe && showAvatar) ...[
              CircleAvatar(
                radius: 14,
                backgroundColor: _blue.withOpacity(0.2),
                backgroundImage: (senderImage != null && senderImage!.isNotEmpty)
                    ? NetworkImage(senderImage!)
                    : null,
                child: (senderImage == null || senderImage!.isEmpty)
                    ? Text(
                        senderInitial ?? '?',
                        style: const TextStyle(fontSize: 12, color: _blue),
                      )
                    : null,
              ),
              const SizedBox(width: 6),
            ] else if (!isMe) ...[
              const SizedBox(width: 34),
            ],
            _buildBubble(context, isDark),
            if (isMe) const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(BuildContext context, bool isDark) {
    final bg = isMe
        ? _blue
        : (isDark ? const Color(0xFF2A2A2A) : Colors.white);
    final textColor = isMe ? Colors.white : (isDark ? Colors.white : Colors.black87);
    final maxW = MediaQuery.of(context).size.width * 0.72;

    return Container(
      constraints: BoxConstraints(maxWidth: maxW),
      margin: isMe
          ? const EdgeInsets.only(right: 4)
          : const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: message.isImage || message.isVoice ? Colors.transparent : bg,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          _buildContent(context, bg, textColor),
          _buildFooter(context, textColor),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color bg, Color textColor) {
    if (message.isImage && message.fullAttachmentUrl.isNotEmpty) {
      return _ImageBubble(url: message.fullAttachmentUrl, isMe: isMe);
    }
    if (message.isVoice && message.fullAttachmentUrl.isNotEmpty) {
      return _VoiceBubble(url: message.fullAttachmentUrl, isMe: isMe, bg: bg);
    }
    if (message.isFile) {
      return _FileBubble(
        url: message.fullAttachmentUrl,
        name: message.attachmentName ?? message.message,
        isMe: isMe,
        bg: bg,
        textColor: textColor,
      );
    }
    // Text
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      child: Text(
        message.message,
        style: TextStyle(fontSize: 15, color: textColor, height: 1.4),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, Color textColor) {
    final time = DateFormat.jm().format(message.sentAt);
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.isPinned) ...[
            Icon(Icons.push_pin, size: 10,
                color: isMe ? Colors.white70 : Colors.grey),
            const SizedBox(width: 2),
          ],
          Text(time,
              style: TextStyle(
                  fontSize: 10,
                  color: isMe ? Colors.white70 : Colors.grey.shade500)),
          if (isMe) ...[
            const SizedBox(width: 4),
            Icon(
              message.isRead ? Icons.done_all : Icons.done,
              size: 14,
              color: message.isRead
                  ? Colors.lightBlueAccent
                  : Colors.white54,
            ),
          ],
        ],
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (message.isText)
              _menuItem(context, Icons.copy_outlined, AppLocalizations.of(context).translate('copy'), () {
                Clipboard.setData(ClipboardData(text: message.message));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context).copiedToClipboard)),
                );
              }),
            if (!message.isPinned)
              _menuItem(context, Icons.push_pin_outlined, AppLocalizations.of(context).translate('pin_message'), () {
                Navigator.pop(context);
                onPin?.call();
              }),
            if (message.isPinned)
              _menuItem(context, Icons.push_pin, AppLocalizations.of(context).translate('unpin_message'), () {
                Navigator.pop(context);
                onUnpin?.call();
              }),
            _menuItem(context, Icons.delete_outline, AppLocalizations.of(context).delete,
                () => Navigator.pop(context),
                color: Colors.red),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF0DA5FE)),
      title: Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}

// ── Image bubble ──────────────────────────────────────────────────────────────

class _ImageBubble extends StatelessWidget {
  final String url;
  final bool isMe;

  const _ImageBubble({required this.url, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openFullscreen(context),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
        child: Image.network(
          url,
          width: 220,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 220,
            height: 120,
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image_outlined, size: 40),
          ),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Container(
              width: 220,
              height: 180,
              color: Colors.grey.shade100,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }

  void _openFullscreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: PhotoView(
            imageProvider: NetworkImage(url),
            minScale: PhotoViewComputedScale.contained,
          ),
        ),
      ),
    );
  }
}

// ── Voice bubble ──────────────────────────────────────────────────────────────

class _VoiceBubble extends StatelessWidget {
  final String url;
  final bool isMe;
  final Color bg;

  const _VoiceBubble(
      {required this.url, required this.isMe, required this.bg});

  @override
  Widget build(BuildContext context) {
    return VoiceMessageWidget(
      audioPath: url,
      isUser: isMe,
    );
  }
}

// ── File bubble ───────────────────────────────────────────────────────────────

class _FileBubble extends StatelessWidget {
  final String url;
  final String name;
  final bool isMe;
  final Color bg;
  final Color textColor;

  const _FileBubble({
    required this.url,
    required this.name,
    required this.isMe,
    required this.bg,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isMe ? Colors.white : const Color(0xFF0DA5FE))
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.insert_drive_file_outlined,
              color: isMe ? Colors.white : const Color(0xFF0DA5FE),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              name,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
