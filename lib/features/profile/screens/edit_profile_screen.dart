import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _bioCtrl;
  final List<String> _skills = [];
  bool _saving = false;

  final List<String> _allSkills = [
    'Digital Art',
    'Photography',
    'Music',
    'Filmmaking',
    'Writing',
    'Design',
    'Illustration',
    'Animation',
    '3D Art',
    'Podcast',
    'UI/UX',
    'Motion Graphics',
  ];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
    _usernameCtrl =
        TextEditingController(text: user?.email?.split('@').first ?? '');
    _bioCtrl = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: CPAppBar(
        title: 'Edit Profile',
        showBack: true,
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.steelBlue))
                : Text('Save',
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.steelBlue)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar section
            _buildAvatarSection().animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 28),

            Text('Basic Info', style: AppTextStyles.headlineSmall)
                .animate(delay: 100.ms)
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 12),

            TextFormField(
              controller: _nameCtrl,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                prefixIcon: Icon(Icons.person_outline_rounded,
                    color: AppColors.charcoalLight),
              ),
            ).animate(delay: 120.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 14),

            TextFormField(
              controller: _usernameCtrl,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.alternate_email_rounded,
                    color: AppColors.charcoalLight),
              ),
            ).animate(delay: 140.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 14),

            TextFormField(
              controller: _bioCtrl,
              style: AppTextStyles.bodyMedium,
              maxLines: 3,
              maxLength: AppConstants.maxBioLength,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell the world what you create...',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child:
                      Icon(Icons.notes_rounded, color: AppColors.charcoalLight),
                ),
              ),
            ).animate(delay: 160.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            Text('Skills & Specialties', style: AppTextStyles.headlineSmall)
                .animate(delay: 200.ms)
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 6),
            Text('Select what you create (shown on your profile)',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.charcoalLight))
                .animate(delay: 220.ms)
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 14),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _allSkills.map((skill) {
                final sel = _skills.contains(skill);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (sel) {
                        _skills.remove(skill);
                      } else {
                        _skills.add(skill);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.steelBlue : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? AppColors.steelBlue : AppColors.silver,
                        width: sel ? 1.5 : 1,
                      ),
                    ),
                    child: Text(skill,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: sel ? Colors.white : AppColors.charcoal,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                );
              }).toList(),
            ).animate(delay: 250.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: 28),

            Text('Social Links', style: AppTextStyles.headlineSmall)
                .animate(delay: 300.ms)
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 12),

            ...[
              ('Instagram', Icons.camera_alt_outlined),
              ('Twitter / X', Icons.alternate_email_rounded),
              ('Website', Icons.language_rounded),
            ].asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: TextFormField(
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      labelText: e.value.$1,
                      prefixIcon: Icon(e.value.$2,
                          color: AppColors.charcoalLight, size: 20),
                    ),
                  )
                      .animate(delay: Duration(milliseconds: 320 + 40 * e.key))
                      .fadeIn(duration: 400.ms),
                )),

            const SizedBox(height: 12),

            // Danger zone
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border:
                    Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.error, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Danger Zone',
                            style: AppTextStyles.labelLarge
                                .copyWith(color: AppColors.error)),
                        Text(
                            'Deleting your account is permanent and cannot be undone.',
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('Delete',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.error)),
                  ),
                ],
              ),
            ).animate(delay: 450.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    final user = FirebaseAuth.instance.currentUser;
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.steelBlue, AppColors.steelBlueDark],
                  ),
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.silver,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.steelBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Change profile photo',
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.steelBlue)),
        ],
      ),
    );
  }

  void _save() async {
    setState(() => _saving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updateDisplayName(_nameCtrl.text);
    }
    setState(() => _saving = false);
    if (mounted) context.pop();
  }
}
