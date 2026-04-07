import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/post_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../core/utils/formatters.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  String _filter = 'All';
  String _sort = 'Newest';
  final List<String> _filters = ['All', 'Image', 'Video', 'Audio', 'Document'];
  final List<String> _sorts = ['Newest', 'Most Liked', 'Most Viewed'];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: CPAppBar(
        title: 'My Portfolio',
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            color: AppColors.charcoal,
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<PostModel>>(
          future: PostRepository().getUserPosts(user.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.steelBlue));
            }

            final allPosts = snapshot.data ?? [];
            final filteredPosts = _filter == 'All'
                ? allPosts
                : allPosts
                    .where((p) =>
                        p.contentType.name.toLowerCase() ==
                        _filter.toLowerCase())
                    .toList();

            if (_sort == 'Most Liked') {
              filteredPosts
                  .sort((a, b) => b.likesCount.compareTo(a.likesCount));
            } else if (_sort == 'Most Viewed') {
              filteredPosts
                  .sort((a, b) => b.viewsCount.compareTo(a.viewsCount));
            }

            final views = allPosts.fold<int>(0, (sum, p) => sum + p.viewsCount);
            const followers = 0; // Not implemented globally yet

            return CustomScrollView(
              slivers: [
                // Stats summary
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPortfolioStats(allPosts.length, views, followers)
                            .animate()
                            .fadeIn(duration: 400.ms),
                        const SizedBox(height: 16),
                        // Filter + Sort row
                        Row(
                          children: [
                            Expanded(child: _buildFilterBar()),
                            const SizedBox(width: 8),
                            _buildSortButton(),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) =>
                          _PortfolioItem(post: filteredPosts[i], index: i),
                      childCount: filteredPosts.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            );
          }),
    );
  }

  Widget _buildPortfolioStats(int works, int views, int followers) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.silver.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MiniStat(value: works.toString(), label: 'Works'),
          _vdivider(),
          _MiniStat(value: Formatters.formatCount(views), label: 'Views'),
          _vdivider(),
          const _MiniStat(
              value: '100%',
              label: 'Verified'), // All app uploads are verified natively
          _vdivider(),
          _MiniStat(
              value: Formatters.formatCount(followers), label: 'Followers'),
        ],
      ),
    );
  }

  Widget _vdivider() =>
      Container(height: 30, width: 1, color: AppColors.silver);

  Widget _buildFilterBar() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final f = _filters[i];
          final sel = _filter == f;
          return GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? AppColors.steelBlue : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: sel ? AppColors.steelBlue : AppColors.silver),
              ),
              child: Text(f,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: sel ? Colors.white : AppColors.charcoal,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortButton() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text('Sort by', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 8),
              ..._sorts.map((s) => ListTile(
                    title: Text(s),
                    trailing: _sort == s
                        ? const Icon(Icons.check_rounded,
                            color: AppColors.steelBlue)
                        : null,
                    onTap: () {
                      setState(() => _sort = s);
                      Navigator.pop(context);
                    },
                  )),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.silver),
        ),
        child: Row(
          children: [
            const Icon(Icons.sort_rounded,
                size: 16, color: AppColors.charcoalLight),
            const SizedBox(width: 4),
            Text('Sort', style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _PortfolioItem extends StatelessWidget {
  final PostModel post;
  final int index;
  const _PortfolioItem({required this.post, required this.index});

  @override
  Widget build(BuildContext context) {
    final color = switch (post.contentType) {
      ContentType.image => AppColors.imageType,
      ContentType.video => AppColors.videoType,
      ContentType.audio => AppColors.audioType,
      ContentType.document => AppColors.documentType,
    };
    final icon = switch (post.contentType) {
      ContentType.image => Icons.image_rounded,
      ContentType.video => Icons.play_circle_fill_rounded,
      ContentType.audio => Icons.music_note_rounded,
      ContentType.document => Icons.description_rounded,
    };

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.silver.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppConstants.radiusL)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, color: color, size: 36),
                  if (post.isOnChain)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: AppColors.steelBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified_rounded,
                            size: 12, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title,
                    style: AppTextStyles.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.favorite_border_rounded,
                        size: 12, color: AppColors.charcoalLight),
                    const SizedBox(width: 3),
                    Text(Formatters.formatCount(post.likesCount),
                        style: AppTextStyles.labelSmall),
                    const Spacer(),
                    const Icon(Icons.remove_red_eye_outlined,
                        size: 12, color: AppColors.charcoalLight),
                    const SizedBox(width: 3),
                    Text(Formatters.formatCount(post.viewsCount),
                        style: AppTextStyles.labelSmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn(duration: 350.ms)
        .scale(begin: const Offset(0.9, 0.9), duration: 350.ms);
  }
}

class _MiniStat extends StatelessWidget {
  final String value, label;
  const _MiniStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.headlineSmall
                .copyWith(color: AppColors.charcoalDark)),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}
