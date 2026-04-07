import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/creator_badge.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../shared/models/post_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/services/blockchain_wallet_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          // Sliver app bar with cover
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.cream,
            elevation: 0,
            scrolledUnderElevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                color: AppColors.charcoal,
                onPressed: () => context.push('/notifications'),
              ),
              IconButton(
                icon: const Icon(Icons.bar_chart_rounded),
                color: AppColors.charcoal,
                onPressed: () => context.push('/dashboard'),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.steelBlue.withValues(alpha: 0.3),
                          AppColors.steelBlueDark.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                  // Bottom fade
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.cream.withValues(alpha: 0.8)
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: FutureBuilder<List<PostModel>>(
                future: PostRepository().getUserPosts(user.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final posts = snapshot.data ?? [];
                  final works = posts.length;
                  final views = posts.fold<int>(0, (s, p) => s + p.viewsCount);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar + Edit
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.steelBlue,
                                    AppColors.steelBlueDark
                                  ],
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: AppColors.silver,
                                backgroundImage: user.avatarUrl != null
                                    ? NetworkImage(user.avatarUrl!)
                                    : null,
                                child: user.avatarUrl == null
                                    ? Text(
                                        user.displayName
                                            .substring(0, 1),
                                        style: AppTextStyles.displayMedium
                                            .copyWith(color: Colors.white))
                                    : null,
                              ),
                            ),
                            const Spacer(),
                            OutlinedButton.icon(
                              onPressed: () => context.push('/profile/edit'),
                              icon: const Icon(Icons.edit_rounded, size: 16),
                              label: const Text('Edit Profile'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Text(user.displayName,
                                style: AppTextStyles.headlineLarge),
                            const SizedBox(width: 8),
                            const CreatorBadge(isVerified: true),
                          ],
                        ),
                        Text('@${user.username.isNotEmpty ? user.username : 'creator'}',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.charcoalLight)),

                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),

                        // Stats
                        Row(
                          children: [
                            Expanded(
                                child: _StatItem(
                                    label: 'Works', value: works.toString())),
                            _divider(),
                            const Expanded(
                                child:
                                    _StatItem(label: 'Followers', value: '0')),
                            _divider(),
                            Expanded(
                                child: _StatItem(
                                    label: 'Views',
                                    value: Formatters.formatCount(views))),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Wallet
                        FutureBuilder<String>(
                            future:
                                BlockchainWalletService().getPublicAddress(),
                            builder: (context, walletSnap) {
                              if (!walletSnap.hasData) return const SizedBox();
                              return _buildIdentityCard(walletSnap.data!);
                            }),

                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('My Works',
                                style: AppTextStyles.headlineSmall),
                            TextButton(
                              onPressed: () {},
                              child: const Text('See all'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildWorksGrid(posts),
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 32, width: 1, color: AppColors.silver);

  Widget _buildIdentityCard(String wallet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.verifiedBg,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.steelBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded,
                  color: AppColors.steelBlue, size: 20),
              const SizedBox(width: 8),
              Text('Verified Creator Identity',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.steelBlue)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.steelBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('ACTIVE',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  color: AppColors.charcoalLight, size: 16),
              const SizedBox(width: 8),
              Text('Wallet: ', style: AppTextStyles.labelMedium),
              Expanded(
                child: Text(wallet,
                    style: AppTextStyles.mono, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.link_rounded,
                  color: AppColors.charcoalLight, size: 16),
              const SizedBox(width: 8),
              Text('Network: ', style: AppTextStyles.labelMedium),
              Text('Polygon Testnet',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.steelBlue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorksGrid(List<PostModel> posts) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: posts.length > 6 ? 6 : posts.length,
      itemBuilder: (context, i) {
        final p = posts[i];
        final color = switch (p.contentType) {
          ContentType.image => AppColors.imageType,
          ContentType.video => AppColors.videoType,
          ContentType.audio => AppColors.audioType,
          ContentType.document => AppColors.documentType,
        };
        final icon = switch (p.contentType) {
          ContentType.image => Icons.image_rounded,
          ContentType.video => Icons.play_circle_fill_rounded,
          ContentType.audio => Icons.music_note_rounded,
          ContentType.document => Icons.description_rounded,
        };

        return Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: color, size: 30),
              if (p.isOnChain)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: AppColors.steelBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_rounded,
                        size: 9, color: Colors.white),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.headlineMedium
                .copyWith(color: AppColors.charcoalDark)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}
