import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/creator_badge.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../shared/models/post_model.dart';
import '../../../shared/models/user_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/services/blockchain_wallet_service.dart';

class ProfileScreen extends StatefulWidget {
  final String? uid;
  const ProfileScreen({super.key, this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isFollowing = false;
  bool _checkingFollow = true;

  @override
  void initState() {
    super.initState();
    _initFollowState();
  }

  void _initFollowState() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = auth.currentUser;
    if (currentUser == null || widget.uid == null || widget.uid == currentUser.id) {
      if (mounted) setState(() => _checkingFollow = false);
      return;
    }

    final following = await UserRepository().checkIsFollowing(currentUser.id, widget.uid!);
    if (mounted) {
      setState(() {
        _isFollowing = following;
        _checkingFollow = false;
      });
    }
  }

  void _toggleFollow(UserModel targetUser) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = auth.currentUser;
    if (currentUser == null) return;

    final oldState = _isFollowing;
    setState(() => _isFollowing = !oldState);

    try {
      await UserRepository().toggleFollow(
        currentUserId: currentUser.id,
        targetUserId: targetUser.id,
        isFollowing: oldState,
      );
    } catch (e) {
      if (mounted) setState(() => _isFollowing = oldState);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final currentUser = auth.currentUser;
    final isOwnProfile = widget.uid == null || widget.uid == currentUser?.id;

    if (currentUser == null && isOwnProfile) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder<UserModel?>(
      future: isOwnProfile ? Future.value(currentUser) : UserRepository().getUser(widget.uid!),
      builder: (context, snapshot) {
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        if (user == null) {
          return const Scaffold(body: Center(child: Text('User not found')));
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
                  IconButton(
                    icon: const Icon(Icons.settings_rounded),
                    color: AppColors.charcoal,
                    onPressed: () => context.push('/settings'),
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
                              AppColors.steelBlue.withValues(alpha: 0.5),
                              AppColors.steelBlueDark,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: StreamBuilder<List<PostModel>>(
                    stream: PostRepository().streamUserPosts(user.id),
                    builder: (context, postSnap) {
                      if (postSnap.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final posts = postSnap.data ?? [];
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
                                if (isOwnProfile)
                                  OutlinedButton.icon(
                                    onPressed: () => context.push('/profile/edit'),
                                    icon: const Icon(Icons.edit_rounded, size: 16),
                                    label: const Text('Edit Profile'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                    ),
                                  )
                                else if (!_checkingFollow)
                                  ElevatedButton(
                                    onPressed: () => _toggleFollow(user),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isFollowing ? AppColors.silver : AppColors.steelBlue,
                                      foregroundColor: _isFollowing ? AppColors.charcoal : Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                      ),
                                    ),
                                    child: Text(_isFollowing ? 'Following' : 'Follow'),
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
                                Expanded(
                                  child: StreamBuilder<int>(
                                    stream: UserRepository().streamFollowersCount(user.id),
                                    builder: (context, snap) {
                                      return _StatItem(
                                        label: 'Followers',
                                        value: Formatters.formatCount(snap.data ?? user.followersCount),
                                      );
                                    },
                                  ),
                                ),
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
                                if (isOwnProfile)
                                  Text('My Works', style: AppTextStyles.headlineSmall)
                                else
                                  Text('Works', style: AppTextStyles.headlineSmall),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text('See all'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (posts.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 40),
                                  child: Text('No works found', 
                                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoalLight)),
                                ),
                              )
                            else
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
      },
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
