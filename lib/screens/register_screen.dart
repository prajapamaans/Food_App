import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (authProvider.isAuthenticated) {
        // Successfully registered! Show a snackbar and let the user log in.
        Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => const MainScreen()),
  (route) => false,
);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.error ?? 'Registration failed. Try again.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Background food image (top 45%) ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenH * 0.45,
            child: Image.network(
              'https://images.pexels.com/photos/1199957/pexels-photo-1199957.jpeg?w=800',
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: AppColors.surfaceHigh,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) =>
                  Container(color: AppColors.surfaceHigh),
            ),
          ),

          // ── Gradient overlay ──────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenH * 0.45,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withOpacity(0.2),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),

          // ── Scrollable Content ─────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: AppSpacing.screen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Space for image area
                  SizedBox(height: screenH * 0.26),

                  Text('Create Account', style: AppTextStyles.displayLarge),
                  AppSpacing.gapXS,
                  Text(
                    'Start your food journey here 🚀',
                    style: AppTextStyles.bodySmall,
                  ),

                  AppSpacing.gapXL,

                  // ── Form ──────────────────────
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildField(
                          controller: _nameCtrl,
                          hint: 'Full Name',
                          icon: Icons.person_outline,
                          keyboardType: TextInputType.name,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),

                        AppSpacing.gapMD,

                        _buildField(
                          controller: _emailCtrl,
                          hint: 'Email address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Email is required';
                            }
                            if (!v.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),

                        AppSpacing.gapMD,

                        _buildField(
                          controller: _passwordCtrl,
                          hint: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textHint,
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password is required';
                            }
                            if (v.length < 8) {
                              return 'Min 8 characters';
                            }
                            if (!RegExp(r'(?=.*[0-9])').hasMatch(v)) {
                              return 'Requires a number';
                            }
                            if (!RegExp(r'(?=.*[A-Z])').hasMatch(v)) {
                              return 'Requires an uppercase letter';
                            }
                            if (!RegExp(r'(?=.*[a-z])').hasMatch(v)) {
                              return 'Requires a lowercase letter';
                            }
                            if (!RegExp(r'(?=.*[\W_])').hasMatch(v)) {
                              return 'Requires a special character';
                            }
                            return null;
                          },
                        ),

                        AppSpacing.gapXL,

                        PrimaryButton(
                          label: 'Sign Up',
                          onTap: _handleRegister,
                          isLoading: _isLoading,
                        ),

                        AppSpacing.gapMD,

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: AppTextStyles.bodySmall,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Login',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        AppSpacing.gapXL,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.bodyLarge,
      autocorrect: false,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textHint),
        prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surface,
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(color: AppColors.primary, width: 1.5),
        errorBorder: _border(color: AppColors.error),
        focusedErrorBorder: _border(color: AppColors.error, width: 1.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  OutlineInputBorder _border({
    Color color = AppColors.divider,
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
