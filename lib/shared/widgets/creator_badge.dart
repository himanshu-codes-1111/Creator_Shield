import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum BadgeSize { small, medium, large }

class CreatorBadge extends StatelessWidget {
  final bool isVerified;
  final BadgeSize size;
  final bool showLabel;

  const CreatorBadge({
    super.key,
    required this.isVerified,
    this.size = BadgeSize.medium,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVerified) return const SizedBox.shrink();

    final double iconSize = switch (size) {
      BadgeSize.small => 12,
      BadgeSize.medium => 15,
      BadgeSize.large => 18,
    };

    if (!showLabel) {
      return Container(
        width: iconSize + 6,
        height: iconSize + 6,
        decoration: const BoxDecoration(
          color: AppColors.steelBlue,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.verified_rounded,
          color: Colors.white,
          size: iconSize,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.verifiedBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.steelBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded,
              color: AppColors.steelBlue, size: iconSize),
          const SizedBox(width: 4),
          Text(
            'Verified Creator',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.steelBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// On-chain proof badge for post cards
class OnChainBadge extends StatelessWidget {
  final bool isOnChain;
  const OnChainBadge({super.key, required this.isOnChain});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOnChain
            ? AppColors.verifiedBg
            : AppColors.silver.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isOnChain
              ? AppColors.steelBlue.withValues(alpha: 0.4)
              : AppColors.silver,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isOnChain ? AppColors.steelBlue : AppColors.silverDark,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isOnChain ? 'On-Chain' : 'Pending',
            style: AppTextStyles.labelSmall.copyWith(
              color: isOnChain ? AppColors.steelBlue : AppColors.silverDark,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
