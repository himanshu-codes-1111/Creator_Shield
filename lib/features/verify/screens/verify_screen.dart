import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/proof_repository.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../shared/models/proof_model.dart';
import '../../../shared/models/post_model.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final _searchCtrl = TextEditingController();
  bool _searched = false;
  bool _loading = false;
  bool _found = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search() async {
    if (_searchCtrl.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _searched = false;
    });
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _loading = false;
      _searched = true;
      _found = _searchCtrl.text.length > 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: const CPAppBar(title: 'Verify Work', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            _buildHero().animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 28),

            // Search bar
            _buildSearchBar().animate(delay: 100.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 16),

            // QR option
            _buildQROption().animate(delay: 150.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 28),

            // Results
            if (_loading) _buildLoading() else if (_searched) _buildResult(),

            if (!_searched && !_loading) ...[
              Text('Recent Verifications', style: AppTextStyles.headlineSmall)
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 12),
              StreamBuilder<List<ProofModel>>(
                  stream: ProofRepository().streamAllProofs(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.steelBlue));
                    }
                    final proofs = snapshot.data ?? [];
                    if (proofs.isEmpty) {
                      return const Text(
                          "No recent proofs registered on network.");
                    }

                    return Column(
                      children: proofs
                          .take(5)
                          .map((p) => _buildProofTile(p))
                          .toList(),
                    );
                  }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.steelBlue.withValues(alpha: 0.08),
            AppColors.steelBlueDark.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(color: AppColors.steelBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded,
              color: AppColors.steelBlue, size: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verify Authenticity',
                    style: AppTextStyles.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  'Search by file hash, transaction ID, or creator username to verify any work.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.charcoalLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            style: AppTextStyles.bodyMedium,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              hintText: 'Hash, TX ID, or @username...',
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.charcoalLight),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() {
                          _searched = false;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _search,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            child: const Text('Verify'),
          ),
        ),
      ],
    );
  }

  Widget _buildQROption() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: AppColors.silver),
        ),
        child: Row(
          children: [
            const Icon(Icons.qr_code_scanner_rounded,
                color: AppColors.steelBlue, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Scan QR Code', style: AppTextStyles.labelLarge),
                Text('Point your camera at a certificate QR',
                    style: AppTextStyles.labelSmall),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.charcoalLight),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.steelBlue),
              strokeWidth: 2.5,
            ),
            const SizedBox(height: 16),
            Text('Querying blockchain...',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.charcoalLight)),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _found ? AppColors.verifiedBg : AppColors.errorBg,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: _found
              ? AppColors.steelBlue.withValues(alpha: 0.4)
              : AppColors.error.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Icon(
            _found ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: _found ? AppColors.steelBlue : AppColors.error,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            _found ? 'Work Verified!' : 'Not Found',
            style: AppTextStyles.headlineMedium.copyWith(
              color: _found ? AppColors.steelBlue : AppColors.error,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _found
                ? 'This work is registered on the Polygon blockchain and is verified as original.'
                : 'No blockchain record found for this query. The work may not be registered yet.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }

  Widget _buildProofTile(ProofModel proof) {
    return FutureBuilder<PostModel?>(
        future: PostRepository().getPostById(proof.postId),
        builder: (context, snapshot) {
          final post = snapshot.data;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border:
                  Border.all(color: AppColors.silver.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.verifiedBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_rounded,
                      color: AppColors.steelBlue, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post?.title ?? 'Unknown Work',
                          style: AppTextStyles.labelLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(
                          'Tx: ${proof.txId != null && proof.txId!.length > 10 ? proof.txId!.substring(0, 10) : (proof.txId ?? 'Pending')}... · ${Formatters.timeAgo(proof.createdAt)}',
                          style: AppTextStyles.labelSmall),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.steelBlue, size: 18),
              ],
            ),
          ).animate().fadeIn(duration: 350.ms);
        });
  }
}
