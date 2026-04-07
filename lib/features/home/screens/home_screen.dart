import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../shared/models/post_model.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollCtrl = ScrollController();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Image', 'Video', 'Audio', 'Document'];

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: CPAppBar(
        showLogo: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            color: AppColors.charcoal,
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          // Filter Header
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _buildFilterBar(),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Stream Global Feed
          StreamBuilder<List<PostModel>>(
              stream: PostRepository().streamGlobalFeed(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.steelBlue)),
                  );
                }
                final allPosts = snapshot.data ?? [];

                // Apply basic UI filter
                final posts = _selectedFilter == 'All'
                    ? allPosts
                    : allPosts
                        .where((p) =>
                            p.contentType.name.toLowerCase() ==
                            _selectedFilter.toLowerCase())
                        .toList();

                if (posts.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                        child: Text("No works anchored yet. Check back soon!")),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return PostCard(post: posts[index], index: index)
                          .animate()
                          .fadeIn(
                              duration: 400.ms,
                              delay: Duration(milliseconds: 100 * (index % 5)));
                    },
                    childCount: posts.length,
                  ),
                );
              }),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = _filters[i];
          final selected = _selectedFilter == f;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.steelBlue : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.steelBlue : AppColors.silver,
                  width: 1.2,
                ),
              ),
              child: Text(
                f,
                style: AppTextStyles.labelMedium.copyWith(
                  color: selected ? Colors.white : AppColors.charcoal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
