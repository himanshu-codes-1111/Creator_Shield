import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── New Palette Mapping ─────────────────────────────────────────────
  // white: #ffffffff
  // ink-black: #00171fff
  // deep-space-blue: #003459ff
  // cerulean: #007ea7ff
  // fresh-sky: #00a8e8ff

  // Retaining original variable names to prevent breaking changes but using the new hex values.
  static const Color charcoal = Color(0xFF00171F); // ink-black
  static const Color silver =
      Color(0xFFD4DEE2); // light cool gray derived for borders
  static const Color cream = Color(0xFFFFFFFF); // white
  static const Color steelBlue = Color(0xFF007EA7); // cerulean

  // ── Derived ──────────────────────────────────────────────────────
  static const Color charcoalDark = Color(0xFF000B0F); // darker ink-black
  static const Color charcoalLight =
      Color(0xFF66747A); // lighter ink-black for secondary text
  static const Color steelBlueDark = Color(0xFF003459); // deep-space-blue
  static const Color steelBlueLight = Color(0xFF00A8E8); // fresh-sky
  static const Color silverDark = Color(0xFF9BABDB); // darker silver
  static const Color creamDark = Color(0xFFF0F4F7); // off-white
  static const Color white = Color(0xFFFFFFFF); // white

  // ── Semantic ──────────────────────────────────────────────────────
  static const Color background = cream;
  static const Color surface = white;
  static const Color primary = steelBlue;
  static const Color primaryDark = steelBlueDark;
  static const Color primaryLight = steelBlueLight;
  static const Color text = charcoal;
  static const Color textSecondary = charcoalLight;
  static const Color border = silver;
  static const Color divider = Color(0xFFE8ECEF);

  // ── Status ────────────────────────────────────────────────────────
  static const Color success = Color(0xFF1E8F53);
  static const Color successBg = Color(0xFFE8F6ED);
  static const Color warning = Color(0xFFB57A1A);
  static const Color error = Color(0xFFD93838);
  static const Color errorBg = Color(0xFFFBEAEA);

  // ── Proof / Blockchain ────────────────────────────────────────────
  static const Color verified = steelBlue;
  static const Color verifiedBg = Color(0xFFE6F2F6);
  static const Color hashText = steelBlueDark;

  // ── Content type accents ─────────────────────────────────────────
  static const Color imageType = steelBlueLight;
  static const Color videoType = Color(0xFF7A6AA8);
  static const Color audioType = Color(0xFF28948D);
  static const Color documentType = Color(0xFFDD8E4B);
}
