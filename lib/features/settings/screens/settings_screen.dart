import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          _buildSectionHeader('Preferences'),
          _buildSwitchListTile(
            title: 'Dark Mode',
            subtitle: 'Switch between light and dark themes',
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            value: isDark,
            onChanged: (val) => themeProvider.toggleTheme(val),
          ),
          _buildSwitchListTile(
            title: 'Push Notifications',
            subtitle: 'Receive updates on your content',
            icon: Icons.notifications_active_rounded,
            value: true,
            onChanged: (val) {}, // Stub
          ),
          const Divider(height: 32),
          _buildSectionHeader('Support & Legal'),
          _buildListTile(
            title: 'Privacy Policy',
            icon: Icons.lock_outline_rounded,
            onTap: () {}, // Stub
          ),
          _buildListTile(
            title: 'Terms of Service',
            icon: Icons.description_outlined,
            onTap: () {}, // Stub
          ),
          _buildListTile(
            title: 'Help Center',
            icon: Icons.help_outline_rounded,
            onTap: () {}, // Stub
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'App Version 1.0.0',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.charcoalLight),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.steelBlue,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.steelBlue.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.steelBlue, size: 20),
      ),
      title: Text(title, style: AppTextStyles.headlineSmall),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.steelBlue,
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.silver.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.charcoalLight, size: 20),
      ),
      title: Text(title, style: AppTextStyles.headlineSmall),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.silverDark),
      onTap: onTap,
    );
  }
}
