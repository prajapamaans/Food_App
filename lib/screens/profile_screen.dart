import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'splash_screen.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploadingPhoto = false;

  Future<void> _pickPhoto() async {
    setState(() => _isUploadingPhoto = true);

    final success = await context.read<AuthProvider>().uploadProfilePhoto();

    if (mounted) {
      setState(() => _isUploadingPhoto = false);
    }

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload photo. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // ── Avatar ─────────────────────────────
              GestureDetector(
                onTap: _isUploadingPhoto ? null : _pickPhoto,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary,
                      backgroundImage: auth.profileImageBase64 != null
                          ? MemoryImage(base64Decode(auth.profileImageBase64!))
                          : null,
                      child: auth.profileImageBase64 == null
                          ? Text(
                              (auth.userEmail ?? 'U')[0].toUpperCase(),
                              style: AppTextStyles.h1.copyWith(
                                color: Colors.white,
                                fontSize: 40,
                              ),
                            )
                          : null,
                    ),
                    if (_isUploadingPhoto)
                      const Positioned.fill(
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.background, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Name ───────────────────────────────
              Text(
                auth.userName ?? 'User',
                style: AppTextStyles.h1,
              ),

              const SizedBox(height: 8),

              // ── Email ──────────────────────────────
              Text(
                auth.userEmail ?? 'No email',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 48),

              // ── Logout Button ──────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SplashScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}