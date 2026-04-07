import 'package:flutter/material.dart';
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

class CertificateScreen extends StatelessWidget {
  final String postId;
  const CertificateScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoalDark,
      appBar: const CPAppBar(
        title: 'Certificate',
        showBack: true,
      ),
      body: FutureBuilder(
          future: Future.wait([
            PostRepository().getPostById(postId),
            ProofRepository().getProofForPost(postId),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                  child: Text('Failed to load certificate data',
                      style: TextStyle(color: Colors.white)));
            }

            final results = snapshot.data as List<dynamic>;
            final post = results[0] as PostModel?;
            final proof = results[1] as ProofModel?;

            if (post == null || proof == null) {
              return const Center(
                  child: Text('Proof not found',
                      style: TextStyle(color: Colors.white)));
            }

            return Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Hero(
                  tag: 'cert_hero_$postId',
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.steelBlue.withValues(alpha: 0.2),
                          blurRadius: 40,
                          spreadRadius: 10,
                        )
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Certificate Background Pattern
                        Positioned.fill(
                          child: CustomPaint(
                              painter: _CertificatePatternPainter()),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              const Icon(Icons.workspace_premium_rounded,
                                  size: 64, color: AppColors.steelBlue),
                              const SizedBox(height: 16),
                              Text('CERTIFICATE OF CREATION',
                                  style: AppTextStyles.headlineSmall.copyWith(
                                      letterSpacing: 2,
                                      color: AppColors.charcoalLight)),
                              const SizedBox(height: 32),

                              Text('This certifies that the digital asset',
                                  style: AppTextStyles.bodyMedium),
                              const SizedBox(height: 8),
                              Text(post.title,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.headlineMedium
                                      .copyWith(color: AppColors.charcoal)),
                              const SizedBox(height: 24),

                              Text(
                                  'was verifiably anchored on the blockchain by',
                                  style: AppTextStyles.bodyMedium),
                              const SizedBox(height: 8),
                              Text(post.creatorName,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.displayMedium.copyWith(
                                      color: AppColors.steelBlue,
                                      fontSize: 24)),

                              const SizedBox(height: 48),
                              const Divider(),
                              const SizedBox(height: 24),

                              _certRow(
                                  'Date', Formatters.timeAgo(proof.createdAt)),
                              _certRow('Network', proof.networkName),

                              const SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('SHA-256 Checksum',
                                      style: AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.charcoalLight)),
                                  const SizedBox(height: 4),
                                  Text(proof.fileHash,
                                      style: AppTextStyles.mono
                                          .copyWith(fontSize: 10)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Evm Tx Hash',
                                      style: AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.charcoalLight)),
                                  const SizedBox(height: 4),
                                  Text(proof.txId ?? 'Pending',
                                      style: AppTextStyles.mono
                                          .copyWith(fontSize: 10)),
                                ],
                              ),

                              const SizedBox(height: 40),

                              // Signature / verification seal
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      const Icon(Icons.qr_code_2_rounded,
                                          size: 48,
                                          color: AppColors.charcoalDark),
                                      const SizedBox(height: 8),
                                      Text('Scan to Verify',
                                          style: AppTextStyles.labelSmall),
                                    ],
                                  ),
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.steelBlue, width: 2),
                                      color: AppColors.steelBlue
                                          .withValues(alpha: 0.1),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'VERIFIED',
                                        style: TextStyle(
                                            color: AppColors.steelBlue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            letterSpacing: 1),
                                      ),
                                    ),
                                  )
                                      .animate(
                                          onPlay: (c) =>
                                              c.repeat(reverse: true))
                                      .scale(
                                          begin: const Offset(0.95, 0.95),
                                          end: const Offset(1, 1),
                                          duration: 2.seconds),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget _certRow(String label, String value) {
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
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _CertificatePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.steelBlue.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw intricate geometric background
    const double step = 20;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Draw corner ornaments
    final ornamentPaint = Paint()
      ..color = AppColors.steelBlue.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const double oSize = 30;
    canvas.drawRect(const Rect.fromLTWH(10, 10, oSize, oSize), ornamentPaint);
    canvas.drawRect(Rect.fromLTWH(size.width - 10 - oSize, 10, oSize, oSize),
        ornamentPaint);
    canvas.drawRect(Rect.fromLTWH(10, size.height - 10 - oSize, oSize, oSize),
        ornamentPaint);
    canvas.drawRect(
        Rect.fromLTWH(
            size.width - 10 - oSize, size.height - 10 - oSize, oSize, oSize),
        ornamentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
