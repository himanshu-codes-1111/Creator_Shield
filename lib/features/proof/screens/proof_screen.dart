import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/proof_repository.dart';
import '../../../shared/models/post_model.dart';
import '../../../shared/models/proof_model.dart';

class ProofScreen extends StatelessWidget {
  final String postId;
  const ProofScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: const CPAppBar(title: 'Proof of Creation', showBack: true),
      body: FutureBuilder(
          future: Future.wait([
            PostRepository().getPostById(postId),
            ProofRepository().getProofForPost(postId),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.steelBlue));
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text('Failed to load proof data'));
            }

            final results = snapshot.data as List<dynamic>;
            final post = results[0] as PostModel?;
            final proof = results[1] as ProofModel?;

            if (post == null || proof == null) {
              return const Center(
                  child: Text('Proof not found or anchoring pending.'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Hero(
                    tag: 'cert_hero_$postId',
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusL),
                        border: Border.all(
                            color: AppColors.silver.withValues(alpha: 0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.steelBlue.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified_rounded,
                                  color: AppColors.steelBlue, size: 28),
                              const SizedBox(width: 10),
                              Text('Authentic Creation',
                                  style: AppTextStyles.headlineMedium
                                      .copyWith(color: AppColors.steelBlue)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Divider(height: 1),
                          const SizedBox(height: 20),
                          _InfoRow('Creator', post.creatorName),
                          _InfoRow('Title', post.title),
                          _InfoRow('Content Type',
                              post.contentType.name.toUpperCase()),
                          _InfoRow(
                              'Created', Formatters.timeAgo(post.createdAt)),
                          _InfoRow('License', post.licenseType.name),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.verifiedBg,
                              borderRadius:
                                  BorderRadius.circular(AppConstants.radiusS),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('SHA-256 Hash',
                                    style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.charcoalLight)),
                                const SizedBox(height: 4),
                                Text(proof.fileHash,
                                    style: AppTextStyles.mono
                                        .copyWith(fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                  const SizedBox(height: 24),
                  Text('Blockchain Record', style: AppTextStyles.headlineSmall)
                      .animate(delay: 200.ms)
                      .fadeIn(),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      border: Border.all(color: AppColors.silver),
                    ),
                    child: Column(
                      children: [
                        _BlockchainRow('Network', proof.networkName),
                        _BlockchainRow('Transaction ID', proof.txId ?? 'Pending'),
                        if (proof.blockNumber != null)
                          _BlockchainRow('Block', proof.blockNumber!),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon:
                                const Icon(Icons.open_in_new_rounded, size: 16),
                            label: const Text('View on Polygonscan'),
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.push('/proof/$postId/certificate'),
                      icon: const Icon(Icons.workspace_premium_rounded),
                      label: const Text('View Full Certificate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.charcoalDark,
                        foregroundColor: AppColors.white,
                      ),
                    ),
                  ).animate(delay: 400.ms).fadeIn(),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.charcoalLight)),
          ),
          Expanded(
            child: Text(value,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _BlockchainRow extends StatelessWidget {
  final String label, value;
  const _BlockchainRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final bool isMono = label == 'Transaction ID';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.charcoalLight)),
          const SizedBox(height: 4),
          Text(
            value,
            style: isMono
                ? AppTextStyles.mono.copyWith(fontSize: 12)
                : AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
