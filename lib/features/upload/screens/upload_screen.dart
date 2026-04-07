import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import '../../../data/services/cloudinary_service.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../shared/models/proof_model.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/proof_repository.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../data/services/blockchain_wallet_service.dart';
import '../../../data/services/blockchain_tx_service.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/post_model.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  ContentType? _selectedType;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  String _selectedCategory = 'Digital Art';
  LicenseType _licenseType = LicenseType.allRightsReserved;
  PlatformFile? _pickedFile;
  bool _uploading = false;

  final List<String> _categories = [
    'Digital Art',
    'Photography',
    'Music',
    'Film',
    'Writing',
    'Design',
    '3D Art',
    'Other',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: const CPAppBar(title: 'Upload Work'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepLabel('1', 'Choose content type'),
            const SizedBox(height: 12),
            _buildTypeSelector(),
            const SizedBox(height: 28),
            _buildStepLabel('2', 'Upload your file'),
            const SizedBox(height: 12),
            _buildDropZone(),
            const SizedBox(height: 28),
            _buildStepLabel('3', 'Add details'),
            const SizedBox(height: 12),
            _buildMetadataForm(),
            const SizedBox(height: 28),
            _buildStepLabel('4', 'Select license'),
            const SizedBox(height: 12),
            _buildLicenseSelector(),
            const SizedBox(height: 36),
            _buildSubmitButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStepLabel(String num, String label) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: AppColors.steelBlue,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(num,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 10),
        Text(label, style: AppTextStyles.headlineSmall),
      ],
    );
  }

  Widget _buildTypeSelector() {
    final types = [
      (ContentType.image, Icons.image_rounded, 'Image', AppColors.imageType),
      (ContentType.video, Icons.videocam_rounded, 'Video', AppColors.videoType),
      (
        ContentType.audio,
        Icons.music_note_rounded,
        'Audio',
        AppColors.audioType
      ),
      (
        ContentType.document,
        Icons.description_rounded,
        'Document',
        AppColors.documentType
      ),
    ];

    return Row(
      children: types
          .map((t) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _TypeCard(
                    icon: t.$2,
                    label: t.$3,
                    color: t.$4,
                    selected: _selectedType == t.$1,
                    onTap: () => setState(() => _selectedType = t.$1),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDropZone() {
    final hasFile = _pickedFile != null;
    return GestureDetector(
      onTap: () async {
        final result = await FilePicker.pickFiles(
          type: FileType.any,
        );
        if (result != null && result.files.isNotEmpty) {
          setState(() {
            _pickedFile = result.files.first;
          });
        }
      },
      child: DottedBorder(
        color: hasFile ? AppColors.steelBlue : AppColors.silver,
        strokeWidth: 1.8,
        dashPattern: const [8, 5],
        borderType: BorderType.RRect,
        radius: const Radius.circular(AppConstants.radiusL),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: hasFile ? AppColors.verifiedBg : AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          child: hasFile
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.steelBlue, size: 40),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(_pickedFile!.name,
                          style: AppTextStyles.labelLarge
                              .copyWith(color: AppColors.steelBlue),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(height: 4),
                    Text('${(_pickedFile!.size / (1024 * 1024)).toStringAsFixed(2)} MB • Tap to change', 
                        style: AppTextStyles.labelSmall),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_upload_outlined,
                        color: AppColors.silver, size: 40),
                    const SizedBox(height: 10),
                    Text('Drag & drop or tap to browse',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.charcoalLight)),
                  ],
                ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildMetadataForm() {
    return Column(
      children: [
        TextFormField(
          controller: _titleCtrl,
          style: AppTextStyles.bodyMedium,
          decoration: const InputDecoration(
            labelText: 'Title *',
            hintText: 'Name your work',
            prefixIcon:
                Icon(Icons.title_rounded, color: AppColors.charcoalLight),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _descCtrl,
          style: AppTextStyles.bodyMedium,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Describe your creation...',
            alignLabelWithHint: true,
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(Icons.notes_rounded, color: AppColors.charcoalLight),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _tagsCtrl,
          style: AppTextStyles.bodyMedium,
          decoration: const InputDecoration(
            labelText: 'Tags',
            hintText: 'art, digitalwork, original ...',
            prefixIcon: Icon(Icons.tag_rounded, color: AppColors.charcoalLight),
          ),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          style: AppTextStyles.bodyMedium,
          decoration: const InputDecoration(
            labelText: 'Category',
            prefixIcon:
                Icon(Icons.category_outlined, color: AppColors.charcoalLight),
          ),
          items: _categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => _selectedCategory = v!),
        ),
      ],
    );
  }

  Widget _buildLicenseSelector() {
    final licenses = [
      (
        LicenseType.allRightsReserved,
        'All Rights Reserved',
        Icons.do_not_disturb_on_rounded
      ),
      (
        LicenseType.creativeCommons,
        'Creative Commons',
        Icons.copyright_rounded
      ),
      (
        LicenseType.commercial,
        'Commercial Use',
        Icons.monetization_on_outlined
      ),
      (LicenseType.custom, 'Custom License', Icons.tune_rounded),
    ];

    return Column(
      children: licenses.map((l) {
        final selected = _licenseType == l.$1;
        return GestureDetector(
          onTap: () => setState(() => _licenseType = l.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: selected ? AppColors.verifiedBg : AppColors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(
                color: selected ? AppColors.steelBlue : AppColors.silver,
                width: selected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(l.$3,
                    color: selected
                        ? AppColors.steelBlue
                        : AppColors.charcoalLight,
                    size: 20),
                const SizedBox(width: 12),
                Text(l.$2, style: AppTextStyles.bodyMedium),
                const Spacer(),
                if (selected)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.steelBlue, size: 18),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton() {
    return Column(
      children: [
        // Info card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.verifiedBg,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.steelBlue, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your file will be SHA-256 hashed and stored as proof on the Polygon blockchain.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.steelBlue),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _uploading
                ? null
                : () async {
                    if (_titleCtrl.text.isEmpty || _selectedType == null || _pickedFile == null || _pickedFile?.path == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'Please fill title, type, and attach a valid file.')));
                      return;
                    }

                    setState(() => _uploading = true);
                    try {
                      final auth =
                          Provider.of<AuthProvider>(context, listen: false);
                      final user = auth.currentUser;
                      if (user == null) throw Exception("User not signed in.");

                      // 1. Generate real File Hash
                      final file = File(_pickedFile!.path!);
                      final bytes = await file.readAsBytes();
                      final digest = sha256.convert(bytes);
                      final String hashString = digest.toString();

                      // 2. Upload to Cloudinary
                      final cloudinary = CloudinaryService();
                      final downloadUrl = await cloudinary.uploadFile(file);

                      // 3. Anchor on Polygon Amoy EVM
                      final txService =
                          BlockchainTxService(BlockchainWalletService());
                      final txId =
                          await txService.anchorProofTransaction(hashString);

                      // 4. Save to Firestore (Post)
                      final postId = const Uuid().v4();
                      final post = PostModel(
                        id: postId,
                        creatorId: user.id,
                        creatorName: user.displayName,
                        creatorUsername:
                            user.username.isNotEmpty ? user.username : 'creator',
                        title: _titleCtrl.text,
                        description: _descCtrl.text,
                        contentType: _selectedType!,
                        category: _selectedCategory,
                        previewUrl: downloadUrl,
                        fileHash: hashString,
                        txId: txId,
                        isOnChain: true,
                        licenseType: _licenseType,
                        createdAt: DateTime.now(),
                      );
                      await PostRepository().createPost(post);

                      // 4. Save to Firestore (Proof Registry)
                      final proof = ProofModel(
                        id: const Uuid().v4(),
                        postId: postId,
                        creatorId: user.id,
                        fileHash: hashString,
                        txId: txId,
                        createdAt: DateTime.now(),
                        networkName: 'Polygon Amoy Testnet',
                      );
                      await ProofRepository().createProof(proof);

                      // 5. Send Global Notification
                      await NotificationRepository().sendGlobalNotification(
                        title: 'New Drop: ${_titleCtrl.text}',
                        subtitle: '${user.displayName} just uploaded a new piece.',
                        type: 'proof',
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Proof anchored successfully on-chain!')));
                        context.pop();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Transaction Failed: $e')));
                      }
                    } finally {
                      if (mounted) setState(() => _uploading = false);
                    }
                  },
            icon: _uploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : const Icon(Icons.upload_rounded),
            label: Text(_uploading
                ? 'Hashing & Uploading...'
                : 'Upload & Register Proof'),
          ),
        ),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 76,
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(
            color: selected ? color : AppColors.silver,
            width: selected ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected ? color : AppColors.silverDark, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: selected ? color : AppColors.silverDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
