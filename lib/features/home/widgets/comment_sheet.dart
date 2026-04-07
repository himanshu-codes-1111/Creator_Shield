import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/repositories/comment_repository.dart';
import '../../../shared/models/comment_model.dart';

class CommentSheet extends StatefulWidget {
  final String postId;
  const CommentSheet({super.key, required this.postId});

  static void show(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentSheet(postId: postId),
    );
  }

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final _txtCtrl = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _txtCtrl.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    if (_txtCtrl.text.trim().isEmpty) return;
    setState(() => _isPosting = true);

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        final comment = CommentModel(
          id: const Uuid().v4(),
          postId: widget.postId,
          userId: user.id,
          userName: user.displayName,
          userAvatarUrl: user.avatarUrl,
          text: _txtCtrl.text.trim(),
          createdAt: DateTime.now(),
        );
        await CommentRepository().addComment(comment);
        _txtCtrl.clear();
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7 + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppConstants.radiusL),
          topRight: Radius.circular(AppConstants.radiusL),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<List<CommentModel>>(
              stream: CommentRepository().streamPostComments(widget.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final comments = snapshot.data ?? [];
                if (comments.isEmpty) {
                  return const Center(child: Text('No comments yet. Be the first!'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final c = comments[index];
                    return _CommentTile(comment: c);
                  },
                );
              },
            ),
          ),
          _buildInputRow(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 24), // Balance
          Text('Comments', style: AppTextStyles.headlineSmall),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.charcoal),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _txtCtrl,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoalLight),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.cream,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                textInputAction: TextInputAction.send,
                onFieldSubmitted: (_) => _postComment(),
              ),
            ),
            const SizedBox(width: 8),
            _isPosting
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.steelBlue),
                    onPressed: _postComment,
                  ),
          ],
        ),
      ),
    );
  }
}

String _timeStr(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  return '${diff.inDays}d';
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: comment.userAvatarUrl != null ? NetworkImage(comment.userAvatarUrl!) : null,
            backgroundColor: AppColors.silver,
            child: comment.userAvatarUrl == null
                ? Text(comment.userName.substring(0, 1), style: const TextStyle(fontSize: 12, color: Colors.white))
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(comment.userName, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    Text(
                      _timeStr(comment.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.charcoalLight, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.text, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

