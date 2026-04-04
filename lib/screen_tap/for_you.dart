import 'dart:io';
import 'package:ehnama3ak/core/storage/pref_manager.dart';
import 'package:ehnama3ak/core/widgets/post_options_menu.dart';
import 'package:ehnama3ak/core/utils/responsive.dart';
import 'package:ehnama3ak/core/network/dio_client.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';
import 'package:ehnama3ak/features/feed/data/models/comment_model.dart';
import 'package:ehnama3ak/features/feed/data/models/post_model.dart';
import 'package:ehnama3ak/features/feed/domain/repositories/feed_repository.dart';
import 'package:ehnama3ak/features/feed/presentation/cubit/comments_cubit.dart';
import 'package:ehnama3ak/features/feed/presentation/cubit/comments_state.dart';
import 'package:ehnama3ak/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:ehnama3ak/features/feed/presentation/cubit/feed_state.dart';
import 'package:ehnama3ak/features/settings/presentation/controllers/settings_cubit.dart';
import 'package:ehnama3ak/features/settings/presentation/controllers/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

class ForYouPage extends StatefulWidget {
  const ForYouPage({super.key});

  @override
  State<ForYouPage> createState() => _ForYouPageState();
}

class _ForYouPageState extends State<ForYouPage> {
  @override
  Widget build(BuildContext context) {
    return const ForYouView();
  }
}

class ForYouView extends StatefulWidget {
  const ForYouView({super.key});

  @override
  State<ForYouView> createState() => _ForYouViewState();
}

class _ForYouViewState extends State<ForYouView> {
  final TextEditingController _postController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  XFile? _selectedImage;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _scrollController.addListener(_onScroll);
    context.read<FeedCubit>().loadFeed();
    context.read<SettingsCubit>().fetchSettings();
  }

  Future<void> _loadUserId() async {
    final id = await PrefManager.getUserId();
    if (mounted) setState(() => _currentUserId = id);
  }

  void _onScroll() {
    final cubit = context.read<FeedCubit>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      cubit.loadMore();
    }
  }

  @override
  void dispose() {
    _postController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      setState(() => _selectedImage = image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FeedCubit, FeedState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<FeedCubit>().clearError();
        }
      },
      child: BlocBuilder<FeedCubit, FeedState>(
        builder: (context, state) {
          final posts = state.posts;
          final maxContentWidth = Responsive.getMaxContentWidth(context);

          return RefreshIndicator(
            onRefresh: () => context.read<FeedCubit>().loadFeed(refresh: true),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    left: Responsive.padding(context, 16),
                    right: Responsive.padding(context, 16),
                    bottom: Responsive.padding(context, 8),
                    top: Responsive.padding(context, 4),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: Responsive.spacing(context, 14),
                      ),
                      child: _buildHeader(context),
                    ),
                    if (state.status == FeedStatus.loading && posts.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: Responsive.spacing(context, 40),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    else if (state.status == FeedStatus.error && posts.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: Responsive.spacing(context, 40),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                state.errorMessage ?? 'حدث خطأ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: Responsive.fontSize(context, 16),
                                ),
                              ),
                              SizedBox(height: Responsive.spacing(context, 16)),
                              ElevatedButton(
                                onPressed: () => context
                                    .read<FeedCubit>()
                                    .loadFeed(refresh: true),
                                child: Text(AppLocalizations.of(context).retry),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (posts.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: Responsive.spacing(context, 40),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.feed_outlined,
                                size: Responsive.iconSize(context, 64),
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: Responsive.spacing(context, 16)),
                              Text(
                                'لا توجد منشورات بعد',
                                style: TextStyle(
                                  fontSize: Responsive.fontSize(context, 18),
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: Responsive.spacing(context, 8)),
                              Text(
                                'كن أول من يشارك!',
                                style: TextStyle(
                                  fontSize: Responsive.fontSize(context, 14),
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...posts.map(
                        (post) => Padding(
                          padding: EdgeInsets.only(
                            bottom: Responsive.spacing(context, 14),
                          ),
                          child: PostCard(
                            post: post,
                            currentUserId: _currentUserId,
                            onEdit: (id) =>
                                _onEditPost(context, id, post.content),
                            onDelete: (id) =>
                                context.read<FeedCubit>().deletePost(id),
                            onLike: () =>
                                context.read<FeedCubit>().likePost(post.id),
                            onComment: () => _showCommentsSheet(
                              context,
                              post.id,
                              post.commentsCount,
                            ),
                            onShare: () {
                              Share.share('${post.userName} posted:\n${post.content}');
                              context.read<FeedCubit>().incrementShareCount(post.id);
                            },
                          ),
                        ),
                      ),
                    if (state.status == FeedStatus.loadingMore)
                      Padding(
                        padding: EdgeInsets.all(
                          Responsive.padding(context, 16),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onEditPost(BuildContext context, String postId, String currentContent) {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: currentContent);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(l10n.editPost,
            style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: TextField(
          controller: controller,
          maxLines: 4,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: l10n.postContent,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                context.read<FeedCubit>().updatePost(postId, text);
                Navigator.pop(ctx);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showCommentsSheet(
    BuildContext context,
    String postId,
    int commentsCount,
  ) {
    final feedRepo = context.read<FeedRepository>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider(
        create: (_) => CommentsCubit(feedRepo, postId)..loadComments(),
        child: _CommentsSheet(
          postId: postId,
          isDark: isDark,
          onCommentAdded: () =>
              context.read<FeedCubit>().incrementCommentCount(postId),
        ),
      ),
    );
  }

  String _getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    String base = DioClient.baseUrl;
    String cleanUrl = url.startsWith('/') ? url : '/$url';
    return '$base$cleanUrl';
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final user = settingsState.userSettings;
        
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(
              Responsive.borderRadius(context, 18),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black38
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(Responsive.padding(context, 12)),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: Responsive.iconSize(context, 22),
                    backgroundImage: buildUserProfileImageProvider(user?.profileImageUrl ?? ''),
                  ),
                  SizedBox(width: Responsive.spacing(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _postController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).whatsOnYourMind,
                        hintStyle: TextStyle(
                          fontSize: Responsive.fontSize(context, 16),
                          color: isDark
                              ? Colors.white54
                              : const Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: Responsive.padding(context, 8),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 16),
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      minLines: 1,
                      maxLines: 5,
                    ),
                    if (_selectedImage != null) ...[
                      SizedBox(height: Responsive.spacing(context, 10)),
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              Responsive.borderRadius(context, 12),
                            ),
                            child: Image.file(
                              File(_selectedImage!.path),
                              height: Responsive.height(context, 0.25),
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: Responsive.spacing(context, 8),
                            right: Responsive.spacing(context, 8),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedImage = null),
                              child: Container(
                                padding: EdgeInsets.all(
                                  Responsive.padding(context, 4),
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: Responsive.iconSize(context, 18),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          Divider(height: Responsive.spacing(context, 20), thickness: 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 6,
                child: TextButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(
                    Icons.image_outlined,
                    color: const Color(0xFF1E88E5),
                    size: Responsive.iconSize(context, 18),
                  ),
                  label: Text(
                    _selectedImage == null
                        ? AppLocalizations.of(context).photo
                        : AppLocalizations.of(context).change,
                    style: TextStyle(
                      color: const Color(0xFF1E88E5),
                      fontWeight: FontWeight.w500,
                      fontSize: Responsive.fontSize(context, 12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: Responsive.spacing(context, 3)),
              // Custom compact Post button
              Material(
                color: const Color(0xFF0DA5FE),
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  onTap: () {
                    final text = _postController.text.trim();
                    if (text.isNotEmpty || _selectedImage != null) {
                      context.read<FeedCubit>().createPost(
                        text,
                        imagePath: _selectedImage?.path,
                      );
                      _postController.clear();
                      setState(() => _selectedImage = null);
                      FocusScope.of(context).unfocus();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context).pleaseEnterText),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.padding(context, 7),
                      vertical: Responsive.padding(context, 3),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 35,
                      maxWidth: 48,
                      minHeight: 22,
                      maxHeight: 26,
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).post,
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 8),
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
        );
      },
    );
  }
}

class PostCard extends StatelessWidget {
  final PostModel post;
  final String? currentUserId;
  final void Function(String) onEdit;
  final void Function(String) onDelete;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.onEdit,
    required this.onDelete,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  String _formatTime(DateTime time) {
    // API times are usually in UTC, so we compare with toUtc() for accuracy
    final diff = DateTime.now().toUtc().difference(time.toUtc());
    
    if (diff.inSeconds < 10) return 'Just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds} sec';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins';
    if (diff.inHours < 24) return '${diff.inHours} hours';
    if (diff.inDays < 7) return '${diff.inDays} days';
    
    // Fallback for older posts
    return '${time.day}/${time.month}/${time.year}';
  }

  Widget _buildPostImage(BuildContext context, String imagePath) {
    // Basic validation
    final trimmedPath = imagePath.trim();
    if (trimmedPath.isEmpty ||
        trimmedPath.toLowerCase() == 'string' ||
        trimmedPath.toLowerCase() == 'null') {
      return const SizedBox.shrink();
    }

    if (trimmedPath.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, 12),
        ),
        child: Image.asset(trimmedPath, fit: BoxFit.cover),
      );
    }

    if (trimmedPath.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, 12),
        ),
        child: Container(
          constraints: BoxConstraints(
            minHeight: 100,
            maxHeight: Responsive.height(context, 0.4),
          ),
          width: double.infinity,
          child: Image.network(
            trimmedPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 200,
                color: Colors.grey.shade100,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    // fallback for local files (from fresh posts)
    final file = File(trimmedPath);
    if (file.existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, 12),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: Responsive.height(context, 0.4),
          ),
          width: double.infinity,
          child: Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Center(child: Icon(Icons.error)),
          ),
        ),
      );
    }

    // If it's a relative path from server, prepend base URL
    const String baseUrl = 'http://e7nama3ak.runasp.net';
    final fullUrl = trimmedPath.startsWith('/')
        ? '$baseUrl$trimmedPath'
        : '$baseUrl/$trimmedPath';

    return ClipRRect(
      borderRadius: BorderRadius.circular(Responsive.borderRadius(context, 12)),
      child: Container(
        constraints: BoxConstraints(
          minHeight: 100,
          maxHeight: Responsive.height(context, 0.4),
        ),
        width: double.infinity,
        child: Image.network(
          fullUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            // If it still fails, it's likely a bad relative path or missing file
            return Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }

  // Moved to top-level helper function for reuse in _CommentTile
  ImageProvider? _buildUserProfileImageProvider(String path) {
    return buildUserProfileImageProvider(path);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOwner = post.isOwnedBy(currentUserId);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(
          Responsive.borderRadius(context, 18),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black38
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.padding(context, 14),
        vertical: Responsive.padding(context, 14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: Responsive.iconSize(context, 18),
                backgroundColor: isDark
                    ? const Color(0xFF2C2C2C)
                    : const Color(0xFFCFD8DC),
                backgroundImage: buildUserProfileImageProvider(post.userProfileImage),
              ),
              SizedBox(width: Responsive.spacing(context, 10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: Responsive.fontSize(context, 15),
                        color: isDark ? Colors.white : const Color(0xFF1F2933),
                      ),
                    ),
                    Text(
                      _formatTime(post.createdAt),
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 11),
                        color: isDark
                            ? Colors.white54
                            : const Color(0xFF90A4AE),
                      ),
                    ),
                  ],
                ),
              ),
              PostOptionsMenu(
                postId: post.id,
                postContent: post.content,
                isOwner: isOwner,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, 10)),
          Text(
            post.content,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 16),
              height: 1.35,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
            SizedBox(height: Responsive.spacing(context, 10)),
            _buildPostImage(context, post.imageUrl!),
          ],
          SizedBox(height: Responsive.spacing(context, 12)),
          Row(
            children: [
              InkWell(
                onTap: onLike,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      post.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                      color: post.isLikedByMe
                          ? Colors.red
                          : Colors.grey.shade700,
                      size: Responsive.iconSize(context, 22),
                    ),
                    SizedBox(width: Responsive.spacing(context, 4)),
                    Text(
                      '${post.likesCount}',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: Responsive.fontSize(context, 14),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: Responsive.spacing(context, 18)),
              InkWell(
                onTap: onComment,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mode_comment_outlined,
                      size: Responsive.iconSize(context, 22),
                      color: Colors.grey,
                    ),
                    SizedBox(width: Responsive.spacing(context, 4)),
                    Text(
                      '${post.commentsCount}',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: Responsive.fontSize(context, 14),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: Responsive.spacing(context, 18)),
              InkWell(
                onTap: onShare,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.reply_all_outlined,
                      size: Responsive.iconSize(context, 22),
                      color: Colors.grey,
                    ),
                    SizedBox(width: Responsive.spacing(context, 4)),
                    Text(
                      '${post.sharesCount}',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: Responsive.fontSize(context, 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final String postId;
  final bool isDark;
  final VoidCallback? onCommentAdded;

  const _CommentsSheet({
    required this.postId,
    required this.isDark,
    this.onCommentAdded,
  });

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final id = await PrefManager.getUserId();
    if (mounted) setState(() => _currentUserId = id);
  }

  void _onScroll() {
    final cubit = context.read<CommentsCubit>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      cubit.loadMore();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context).comments,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: widget.isDark ? Colors.white : Colors.black,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: widget.isDark ? Colors.white70 : Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocConsumer<CommentsCubit, CommentsState>(
              listener: (context, state) {
                if (state.errorMessage != null &&
                    state.errorMessage!.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: Colors.red,
                    ),
                  );
                  context.read<CommentsCubit>().clearError();
                }
              },
              builder: (context, state) {
                if (state.status == CommentsStatus.loading &&
                    state.comments.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final comments = state.comments;
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount:
                      comments.length +
                      (state.status == CommentsStatus.loadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == comments.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return _CommentTile(
                      comment: comments[index],
                      isDark: widget.isDark,
                      currentUserId: _currentUserId,
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              top: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(
                      color: widget.isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).writeAComment,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF1E88E5)),
                  onPressed: () async {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) {
                      await context.read<CommentsCubit>().addComment(text);
                      widget.onCommentAdded?.call();
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final bool isDark;
  final String? currentUserId;

  const _CommentTile({
    required this.comment, 
    required this.isDark,
    this.currentUserId,
  });

  void _showEditDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: comment.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editComment),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(hintText: l10n.enterCommentText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final newText = controller.text.trim();
              if (newText.isNotEmpty && newText != comment.text) {
                context.read<CommentsCubit>().updateComment(comment.id, newText);
              }
              Navigator.pop(ctx);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteComment),
        content: Text(l10n.deleteCommentConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<CommentsCubit>().deleteComment(comment.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMyComment = currentUserId != null && currentUserId == comment.userId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isDark
                ? const Color(0xFF2C2C2C)
                : const Color(0xFFCFD8DC),
            backgroundImage: buildUserProfileImageProvider(comment.userProfileImage),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comment.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (isMyComment)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          size: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditDialog(context);
                          } else if (value == 'delete') {
                            _confirmDelete(context);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit, size: 18),
                                const SizedBox(width: 8),
                                Text(AppLocalizations.of(context).edit),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete, size: 18, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(AppLocalizations.of(context).delete,
                                    style: const TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  comment.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to build ImageProvider for user profile pictures
ImageProvider buildUserProfileImageProvider(String path) {
  if (path.isEmpty || path.toLowerCase() == 'null' || path.toLowerCase() == 'string') {
    return const AssetImage('assets/images/user_avatar.png');
  }
  
  // Normalize path if it contains backslashes (common in some backends) or is malformed
  String normalizedPath = path.trim().replaceAll('\\', '/');
  
  if (normalizedPath.startsWith('assets/')) return AssetImage(normalizedPath);
  if (normalizedPath.startsWith('http')) return NetworkImage(normalizedPath);

  const String baseUrl = 'http://e7nama3ak.runasp.net';
  // Ensure we don't have double slashes if the path already starts with one
  final cleanPath = normalizedPath.startsWith('/') ? normalizedPath : '/$normalizedPath';
  return NetworkImage('$baseUrl$cleanPath');
}
