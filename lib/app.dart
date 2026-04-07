import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/routes/app_routes.dart';
import 'data/providers/auth_provider.dart';
import 'core/utils/snackbar_service.dart';

class CreatorProofApp extends StatelessWidget {
  const CreatorProofApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'CreatorProof',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRoutes.router,
            scaffoldMessengerKey: SnackBarService.scaffoldMessengerKey,
          );
        },
      ),
    );
  }
}
