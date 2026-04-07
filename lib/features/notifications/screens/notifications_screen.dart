import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../shared/models/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: CPAppBar(
        title: 'Notifications',
        showBack: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Mark all read',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.steelBlue)),
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: NotificationRepository().streamGlobalNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notifs = snapshot.data ?? [];
          if (notifs.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          final unread = notifs.where((n) => !n.isRead).toList();
          final read = notifs.where((n) => n.isRead).toList();

          return ListView(
            children: [
              if (unread.isNotEmpty) ...[
                _SectionHeader(label: 'New', count: unread.length),
                ...unread
                    .asMap()
                    .entries
                    .map((e) => _NotifTile(n: e.value, index: e.key)),
                const SizedBox(height: 8),
              ],
              if (read.isNotEmpty) ...[
                const _SectionHeader(label: 'Earlier'),
                ...read.asMap().entries.map((e) => _NotifTile(
                    n: e.value, index: e.key + unread.length, isRead: true)),
              ],
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int? count;
  const _SectionHeader({required this.label, this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.labelLarge),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.steelBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$count',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotificationModel n;
  final int index;
  final bool isRead;
  const _NotifTile({required this.n, required this.index, this.isRead = false});

  IconData get _icon => switch (n.type) {
        'proof' => Icons.verified_rounded,
        'like' => Icons.favorite_rounded,
        'comment' => Icons.mode_comment_rounded,
        'follow' => Icons.person_add_rounded,
        _ => Icons.info_rounded,
      };

  Color get _color => switch (n.type) {
        'proof' => AppColors.steelBlue,
        'like' => AppColors.error,
        'comment' => AppColors.imageType,
        'follow' => AppColors.success,
        _ => AppColors.charcoalLight,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isRead
            ? AppColors.white
            : AppColors.verifiedBg.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: isRead
              ? AppColors.silver.withValues(alpha: 0.3)
              : AppColors.steelBlue.withValues(alpha: 0.15),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(_icon, color: _color, size: 22),
        ),
        title: Text(n.title,
            style: AppTextStyles.labelLarge.copyWith(
                fontWeight: isRead ? FontWeight.w500 : FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(n.subtitle, style: AppTextStyles.bodySmall, maxLines: 2),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(_timeStr(n.time), style: AppTextStyles.labelSmall),
            if (!isRead) ...[
              const SizedBox(height: 6),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.steelBlue,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
        onTap: () {},
      ),
    )
        .animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.1, end: 0, duration: 350.ms);
  }

  String _timeStr(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
