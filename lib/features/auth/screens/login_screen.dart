import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await context
          .read<AuthProvider>()
          .login(_emailCtrl.text.trim(), _passCtrl.text);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _googleSignIn() async {
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().loginWithGoogle();
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header
              _buildHeader(),

              const SizedBox(height: 48),

              // Form
              _buildForm(),

              const SizedBox(height: 28),

              // Divider
              _buildDivider(),

              const SizedBox(height: 20),

              // Google sign-in
              _buildGoogleButton(),

              const SizedBox(height: 32),

              // Register link
              _buildRegisterRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo mark
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: const DecorationImage(
              image: AssetImage('assets/images/logo.png'),
              fit: BoxFit.cover,
            ),
          ),
        ).animate().scale(
              begin: const Offset(0.7, 0.7),
              duration: 500.ms,
              curve: Curves.elasticOut,
            ),

        const SizedBox(height: 24),

        Text('Welcome back,',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.charcoalLight))
            .animate(delay: 100.ms)
            .fadeIn(duration: 400.ms),

        Text('Creator.', style: AppTextStyles.displayLarge)
            .animate(delay: 150.ms)
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.1, end: 0),

        const SizedBox(height: 8),

        Text(
          'Sign in to access your proof dashboard.',
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoalLight),
        ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: AppTextStyles.bodyMedium,
            decoration: const InputDecoration(
              labelText: 'Email address',
              prefixIcon: Icon(Icons.mail_outline_rounded,
                  color: AppColors.charcoalLight),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your email';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ).animate(delay: 250.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),

          const SizedBox(height: 16),

          // Password
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscure,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded,
                  color: AppColors.charcoalLight),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: AppColors.charcoalLight,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your password';
              if (v.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),

          const SizedBox(height: 12),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Forgot password?',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.steelBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ).animate(delay: 350.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 16),

          // Sign In button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text('Sign In'),
            ),
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: AppTextStyles.labelMedium,
          ),
        ),
        const Expanded(child: Divider()),
      ],
    ).animate(delay: 450.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _loading ? null : _googleSignIn,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.charcoal,
          side: const BorderSide(color: AppColors.silver),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.steelBlue.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.g_mobiledata_rounded,
                  size: 16, color: AppColors.steelBlue),
            ),
            const SizedBox(width: 12),
            Text(
              'Sign in with Google',
              style: AppTextStyles.button.copyWith(color: AppColors.charcoal),
            ),
          ],
        ),
      ),
    ).animate(delay: 500.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildRegisterRow() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Don't have an account? ",
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.charcoalLight),
          ),
          GestureDetector(
            onTap: () => context.push('/register'),
            child: Text(
              'Join as Creator',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.steelBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 550.ms).fadeIn(duration: 400.ms);
  }
}
