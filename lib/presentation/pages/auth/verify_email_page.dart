import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/feature_icon.dart';

class VerifyEmailPage extends StatelessWidget {
  final String? email;
  const VerifyEmailPage({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    final displayEmail = email ?? 'email kamu';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(DkgIcons.arrowLeft, color: AppColors.ink),
                onPressed: () => context.go('/login'),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 14, 28, 28),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Center(
                            child: Icon(DkgIcons.mail, size: 36, color: AppColors.primary),
                          ),
                        ),
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(DkgIcons.check, size: 13, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Cek email Anda',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        text: 'Link verifikasi telah kami kirim ke\n',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14.5,
                          color: AppColors.slate500,
                          height: 1.55,
                        ),
                        children: [
                          TextSpan(
                            text: displayEmail,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const TextSpan(
                            text: '\nSilakan klik link di email tersebut untuk mengaktifkan akun Anda sebelum masuk.',
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    AppButton(
                      label: 'Saya sudah verifikasi',
                      onPressed: () => context.go('/login'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
