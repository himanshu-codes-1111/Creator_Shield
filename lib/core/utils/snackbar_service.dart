import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class SnackBarService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSuccess(String message) {
    _showSnackBar(message, AppColors.success, Icons.check_circle_rounded);
  }

  static void showError(String message) {
    _showSnackBar(message, AppColors.error, Icons.error_rounded);
  }

  static void showWarning(String message) {
    _showSnackBar(message, AppColors.warning, Icons.warning_rounded);
  }

  static void _showSnackBar(String message, Color color, IconData icon) {
    if (scaffoldMessengerKey.currentState == null) return;
    
    scaffoldMessengerKey.currentState!
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.charcoalDark.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
                border: Border.all(color: color.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            duration: const Duration(seconds: 4),
            margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
          ),
        );
  }
}
