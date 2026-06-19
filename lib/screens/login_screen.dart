import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../widgets/primary_button.dart';
import 'main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (authProvider.isAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Login failed. Try again.'),
            backgroundColor: Colors.red,
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
              'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800',
              fit: BoxFit.cover,
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
                  SizedBox(height: screenH * 0.30),

                  Text('Login', style: AppTextStyles.displayLarge),
                  AppSpacing.gapXS,
                  Text(
                    'Welcome back, food lover 🍜',
                    style: AppTextStyles.bodySmall,
                  ),

                  AppSpacing.gapXL,

                  // ── Form ──────────────────────
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
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
                            if (v.length < 6) {
                              return 'Min 6 characters';
                            }
                            return null;
                          },
                        ),

                        AppSpacing.gapSM,

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Forgot Password?',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),

                        AppSpacing.gapMD,

                        PrimaryButton(
                          label: 'Get Started',
                          onTap: _handleLogin,
                          isLoading: _isLoading,
                        ),

                        AppSpacing.gapMD,

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: AppTextStyles.bodySmall,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign Up',
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
