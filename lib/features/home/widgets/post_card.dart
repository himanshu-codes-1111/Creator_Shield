import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/models/post_model.dart';
import '../../../shared/widgets/creator_badge.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'video_preview_widget.dart';
import 'audio_preview_widget.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final int index;
  const PostCard({super.key, required this.post, required this.index});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _liked;
  late int _likes;

  @override
  void initState() {
    super.initState();
    _liked = widget.post.isLiked;
    _likes = widget.post.likesCount;
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likes += _liked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.silver.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCreatorRow(),
          _buildMediaPreview(),
          _buildContent(),
          _buildTags(),
          const Divider(height: 1),
          _buildActions(),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 80 * widget.index))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildCreatorRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.silver,
            backgroundImage: widget.post.creatorAvatarUrl != null
                ? NetworkImage(widget.post.creatorAvatarUrl!)
                : null,
            child: widget.post.creatorAvatarUrl == null
                ? Text(
                    widget.post.creatorName.substring(0, 1),
                    style: const TextStyle(color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(widget.post.creatorName,
                        style: AppTextStyles.labelLarge),
                    const SizedBox(width: 4),
                    CreatorBadge(isVerified: widget.post.creatorVerified),
                  ],
                ),
                Text(
                  '@${widget.post.creatorUsername} • ${Formatters.timeAgo(widget.post.createdAt)}',
                  style: AppTextStyles.labelSmall,
                ),
              ],
            ),
          ),
          // Content type chip
          _ContentTypeChip(type: widget.post.contentType),
          const SizedBox(width: 8),
          const Icon(Icons.more_horiz_rounded,
              color: AppColors.charcoalLight, size: 20),
        ],
      ),
    );
  }

  Widget _buildMediaPreview() {
    if (widget.post.previewUrl != null && widget.post.previewUrl!.isNotEmpty) {
      if (widget.post.contentType == ContentType.image) {
        return Container(
          color: AppColors.imageType.withValues(alpha: 0.1),
          child: CachedNetworkImage(
            imageUrl: widget.post.previewUrl!,
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: AppColors.imageType))),
            errorWidget: (context, url, error) => const SizedBox(height: 200, child: Center(child: Icon(Icons.broken_image_rounded, color: AppColors.imageType, size: 32))),
          ),
        );
      } else if (widget.post.contentType == ContentType.video) {
        return VideoPreviewWidget(videoUrl: widget.post.previewUrl!);
      } else if (widget.post.contentType == ContentType.audio) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: AudioPreviewWidget(audioUrl: widget.post.previewUrl!, title: widget.post.title),
        );
      }
    }

    final color = switch (widget.post.contentType) {
      ContentType.image => AppColors.imageType,
      ContentType.video => AppColors.videoType,
      ContentType.audio => AppColors.audioType,
      ContentType.document => AppColors.documentType,
    };

    final icon = switch (widget.post.contentType) {
      ContentType.image => Icons.image_rounded,
      ContentType.video => Icons.play_circle_fill_rounded,
      ContentType.audio => Icons.music_note_rounded,
      ContentType.document => Icons.description_rounded,
    };

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.20)
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pattern dots
          for (int i = 0; i < 12; i++)
            Positioned(
              left: (i * 47.0) % 300,
              top: (i * 31.0) % 200,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          // Central icon
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: color.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 10),
              Text(
                widget.post.category,
                style: AppTextStyles.labelMedium
                    .copyWith(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          // On-chain badge
          Positioned(
            top: 12,
            right: 12,
            child: OnChainBadge(isOnChain: widget.post.isOnChain),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.post.title,
              style: AppTextStyles.headlineSmall, maxLines: 2),
          if (widget.post.description != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.post.description!,
              style: AppTextStyles.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          // Hash row
          GestureDetector(
            onTap: () => context.push('/proof/${widget.post.id}'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.verifiedBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded,
                      size: 13, color: AppColors.steelBlue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${widget.post.fileHash.substring(0, 24)}...',
                      style: AppTextStyles.mono,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'View Proof â†’',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.steelBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: widget.post.tags
            .take(4)
            .map((tag) => Text(
                  '#$tag',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.steelBlue.withValues(alpha: 0.8),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          _ActionButton(
            icon:
                _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            label: Formatters.formatCount(_likes),
            color: _liked ? AppColors.error : AppColors.charcoalLight,
            onTap: _toggleLike,
          ),
          _ActionButton(
            icon: Icons.mode_comment_outlined,
            label: Formatters.formatCount(widget.post.commentsCount),
            onTap: () {},
          ),
          _ActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: () {},
          ),
          const Spacer(),
          _ActionButton(
            icon: Icons.remove_red_eye_outlined,
            label: Formatters.formatCount(widget.post.viewsCount),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.charcoalLight,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon, size: 18, color: color),
      label:
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
    );
  }
}

class _ContentTypeChip extends StatelessWidget {
  final ContentType type;
  const _ContentTypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final label = switch (type) {
      ContentType.image => 'Image',
      ContentType.video => 'Video',
      ContentType.audio => 'Audio',
      ContentType.document => 'Doc',
    };
    final color = switch (type) {
      ContentType.image => AppColors.imageType,
      ContentType.video => AppColors.videoType,
      ContentType.audio => AppColors.audioType,
      ContentType.document => AppColors.documentType,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: AppTextStyles.labelSmall
              .copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }
}
