import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class StoryBar extends StatelessWidget {
  final List<UserModel> users;
  const StoryBar({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: users.length,
        itemBuilder: (context, i) {
          return _StoryAvatar(user: users[i], index: i);
        },
      ),
    );
  }
}

class _StoryAvatar extends StatelessWidget {
  final UserModel user;
  final int index;
  const _StoryAvatar({required this.user, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Border ring
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: user.isVerified
                      ? const LinearGradient(
                          colors: [
                            AppColors.steelBlue,
                            AppColors.steelBlueDark,
                          ],
                        )
                      : null,
                  border: !user.isVerified
                      ? Border.all(color: AppColors.silver, width: 2)
                      : null,
                ),
                padding: const EdgeInsets.all(2.5),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.silverDark,
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          user.displayName.substring(0, 1),
                          style: AppTextStyles.headlineSmall
                              .copyWith(color: Colors.white),
                        )
                      : null,
                ),
              ),
              if (user.isVerified)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.steelBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.white, blurRadius: 0, spreadRadius: 2)
                      ],
                    ),
                    child: const Icon(Icons.verified_rounded,
                        size: 11, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 64,
            child: Text(
              user.username,
              style: AppTextStyles.labelSmall,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.2, end: 0, duration: 350.ms);
  }
}
