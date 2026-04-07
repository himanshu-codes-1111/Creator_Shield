import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

class CPAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showLogo;
  final List<Widget>? actions;
  final bool showBack;
  final Widget? bottom;

  const CPAppBar({
    super.key,
    this.title,
    this.showLogo = false,
    this.actions,
    this.showBack = false,
    this.bottom,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(bottom != null ? kToolbarHeight + 48 : kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.cream,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: AppColors.silver.withValues(alpha: 0.3),
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: AppColors.charcoal,
              onPressed: () => context.pop(),
            )
          : null,
      automaticallyImplyLeading: showBack,
      title: showLogo ? _buildLogo() : _buildTitle(),
      actions: [
        if (actions != null) ...actions!,
        if (!showBack) _buildNotificationButton(context),
        const SizedBox(width: 8),
      ],
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: bottom!,
            )
          : null,
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.steelBlue,
            borderRadius: BorderRadius.circular(9),
          ),
          child:
              const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          AppConstants.appName,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.charcoalDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      title ?? '',
      style: AppTextStyles.headlineMedium,
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          color: AppColors.charcoal,
          onPressed: () => context.push('/notifications'),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.steelBlue,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
