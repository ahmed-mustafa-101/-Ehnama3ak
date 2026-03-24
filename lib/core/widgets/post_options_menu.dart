import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PostOptionsMenu extends StatelessWidget {
  final String postId;
  final String postContent;
  final bool isOwner;
  final Function(String) onEdit;
  final Function(String) onDelete;

  const PostOptionsMenu({
    super.key,
    required this.postId,
    required this.postContent,
    required this.isOwner,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<String>(
      onSelected: (value) => _handleMenuSelection(context, value),
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_horiz, color: Colors.grey),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        if (isOwner) ...[
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                const Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                const SizedBox(width: 10),
                Text(
                  'Edit Post',
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: const Row(
              children: [
                Icon(Icons.delete_outline, size: 20, color: Colors.red),
                SizedBox(width: 10),
                Text('Delete Post', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
        PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              const Icon(Icons.copy_outlined, size: 20, color: Colors.green),
              const SizedBox(width: 10),
              Text(
                'Copy Text',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          )
        ),
        PopupMenuItem(
          value: 'save',
          child: Row(
            children: [
              const Icon(Icons.bookmark_border, size: 20, color: Colors.amber),
              const SizedBox(width: 10),
              Text(
                'Save Post',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'report',
          child: Row(
            children: [
              const Icon(Icons.report_gmailerrorred,
                  size: 20, color: Colors.grey),
              const SizedBox(width: 10),
              Text(
                'Report',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'edit':
        onEdit(postId);
        break;
      case 'delete':
        _showDeleteConfirmation(context);
        break;
      case 'copy':
        Clipboard.setData(ClipboardData(text: postContent)).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Text copied to clipboard')),
          );
        });
        break;
      case 'save':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post saved')),
        );
        break;
      case 'report':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post reported')),
        );
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Delete Post',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: Text(
          'Are you sure you want to delete this post?',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete(postId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
