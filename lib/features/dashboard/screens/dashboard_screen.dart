import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../shared/models/post_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: const CPAppBar(title: 'Analytics', showBack: true),
      body: StreamBuilder<List<PostModel>>(
          stream: PostRepository().streamGlobalFeed(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.steelBlue));
            }
            final posts = snapshot.data ?? [];
            final totalViews =
                posts.fold<int>(0, (sum, post) => sum + post.viewsCount);
            final totalLikes =
                posts.fold<int>(0, (sum, post) => sum + post.likesCount);
            final onChainCount = posts.where((p) => p.isOnChain).length;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow(
                          posts.length, totalViews, totalLikes, onChainCount)
                      .animate()
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 24),
                  Text('Views Over Time', style: AppTextStyles.headlineSmall)
                      .animate(delay: 100.ms)
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 12),
                  _buildLineChart()
                      .animate(delay: 150.ms)
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 24),
                  Text('Content Breakdown', style: AppTextStyles.headlineSmall)
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 12),
                  _buildBreakdown(posts)
                      .animate(delay: 250.ms)
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 24),
                  Text('Proof Stats', style: AppTextStyles.headlineSmall)
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 12),
                  _buildProofStats(onChainCount)
                      .animate(delay: 350.ms)
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 24),
                  Text('Top Works', style: AppTextStyles.headlineSmall)
                      .animate(delay: 400.ms)
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 12),
                  ...posts.take(3).toList().asMap().entries.map((e) =>
                      _buildTopWorkTile(e.value, e.key + 1)
                          .animate(
                              delay: Duration(milliseconds: 400 + 60 * e.key))
                          .fadeIn(duration: 350.ms)),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }),
    );
  }

  Widget _buildSummaryRow(int totalWorks, int views, int likes, int onChain) {
    String fmt(int c) =>
        c >= 1000 ? '${(c / 1000).toStringAsFixed(1)}K' : c.toString();
    final items = [
      (
        'Total Works',
        fmt(totalWorks),
        Icons.folder_copy_rounded,
        AppColors.steelBlue
      ),
      (
        'Total Views',
        fmt(views),
        Icons.remove_red_eye_outlined,
        AppColors.imageType
      ),
      ('Engagements', fmt(likes), Icons.favorite_rounded, AppColors.error),
      ('On-Chain', fmt(onChain), Icons.verified_rounded, AppColors.success),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: items
          .map((item) => _SummaryCard(
                label: item.$1,
                value: item.$2,
                icon: item.$3,
                color: item.$4,
              ))
          .toList(),
    );
  }

  Widget _buildLineChart() {
    final values = [
      40.0,
      65.0,
      50.0,
      85.0,
      72.0,
      90.0,
      78.0,
      110.0,
      95.0,
      130.0,
      115.0,
      140.0
    ];
    final labels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.silver.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: _LineChartPainter(values: values),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels
                .map((l) => Text(l,
                    style: AppTextStyles.labelSmall.copyWith(fontSize: 9)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdown(List<PostModel> posts) {
    int img = posts.where((p) => p.contentType == ContentType.image).length;
    int vid = posts.where((p) => p.contentType == ContentType.video).length;
    int aud = posts.where((p) => p.contentType == ContentType.audio).length;
    int doc = posts.where((p) => p.contentType == ContentType.document).length;
    final items = [
      ('Images', img, AppColors.imageType),
      ('Documents', doc, AppColors.documentType),
      ('Audio', aud, AppColors.audioType),
      ('Video', vid, AppColors.videoType),
    ];
    final total = items.fold<int>(0, (s, i) => s + i.$2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.silver.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: items.map((item) {
          final pct = item.$2 / total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration:
                        BoxDecoration(color: item.$3, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                SizedBox(
                    width: 80,
                    child: Text(item.$1, style: AppTextStyles.labelMedium)),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: item.$3.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(item.$3),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 28,
                  child: Text('${item.$2}',
                      style: AppTextStyles.labelMedium,
                      textAlign: TextAlign.right),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProofStats(int onChain) {
    return Row(
      children: [
        Expanded(
            child: _ProofStatCard(
                label: 'Registered',
                value: '$onChain',
                icon: Icons.link_rounded,
                color: AppColors.steelBlue)),
        const SizedBox(width: 12),
        const Expanded(
            child: _ProofStatCard(
                label: 'Pending',
                value: '1',
                icon: Icons.pending_rounded,
                color: AppColors.warning)),
        const SizedBox(width: 12),
        Expanded(
            child: _ProofStatCard(
                label: 'Certificates',
                value: '$onChain',
                icon: Icons.workspace_premium_rounded,
                color: AppColors.success)),
      ],
    );
  }

  Widget _buildTopWorkTile(PostModel post, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.silver.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rank == 1
                  ? AppColors.steelBlue
                  : AppColors.silver.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text('$rank',
                style: TextStyle(
                  color: rank == 1 ? Colors.white : AppColors.charcoalLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title,
                    style: AppTextStyles.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(
                    '${post.viewsCount >= 1000 ? '${(post.viewsCount / 1000).toStringAsFixed(1)}K' : post.viewsCount} views · ${post.likesCount >= 1000 ? '${(post.likesCount / 1000).toStringAsFixed(1)}K' : post.likesCount} likes',
                    style: AppTextStyles.labelSmall),
              ],
            ),
          ),
          if (post.isOnChain)
            const Icon(Icons.verified_rounded,
                color: AppColors.steelBlue, size: 18),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _SummaryCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.silver.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style: AppTextStyles.headlineMedium
                      .copyWith(color: AppColors.charcoalDark)),
              Text(label, style: AppTextStyles.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProofStatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _ProofStatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value,
              style: AppTextStyles.headlineMedium
                  .copyWith(color: AppColors.charcoalDark)),
          Text(label,
              style: AppTextStyles.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  _LineChartPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal == 0 ? 1 : maxVal - minVal;
    final step = size.width / (values.length - 1);

    final path = Path();
    final fillPath = Path();

    final points = values.asMap().entries.map((e) {
      final x = e.key * step;
      final y = size.height - ((e.value - minVal) / range) * size.height;
      return Offset(x, y);
    }).toList();

    path.moveTo(points.first.dx, points.first.dy);
    fillPath.moveTo(points.first.dx, size.height);
    fillPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      final cp1 =
          Offset((points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
      final cp2 = Offset((points[i - 1].dx + points[i].dx) / 2, points[i].dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
      fillPath.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }

    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    // Fill gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.steelBlue.withValues(alpha: 0.2),
          AppColors.steelBlue.withValues(alpha: 0.0)
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = AppColors.steelBlue
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // Dots
    final dotPaint = Paint()..color = AppColors.steelBlue;
    final dotBgPaint = Paint()..color = Colors.white;
    for (final pt in points) {
      canvas.drawCircle(pt, 4, dotBgPaint);
      canvas.drawCircle(pt, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
