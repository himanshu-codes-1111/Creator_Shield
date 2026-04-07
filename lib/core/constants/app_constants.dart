class AppConstants {
  AppConstants._();

  static const String appName = 'CreatorProof';
  static const String appTagline = 'Own Your Creation. Prove It On-Chain.';
  static const String appVersion = '1.0.0';

  // Blockchain
  static const String networkName = 'Polygon Mainnet';
  static const String contractAddress = '0x71C7...3aC1';

  // Limits
  static const int maxFileSizeMB = 100;
  static const int maxTagsPerWork = 10;
  static const int maxBioLength = 300;
  static const int maxTitleLength = 100;

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 400);
  static const Duration animSlow = Duration(milliseconds: 600);

  // Spacing
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircle = 999.0;
}
