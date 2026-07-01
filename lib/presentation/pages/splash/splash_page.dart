import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthUnauthenticated) {
          // Stay on splash to show welcome
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.premiumGradient),
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 42,
                  right: -24,
                  child: Container(
                    width: 158,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Positioned(
                  top: 64,
                  right: 24,
                  child: Container(
                    width: 94,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.mint.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const Spacer(),
                      const AppLogo(size: 92, light: true),
                      const SizedBox(height: 26),
                      const Text(
                        'Dompet Kampus',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'GLOBAL',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mint,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Bayar, transfer, dan kelola uang\ndalam satu aplikasi yang aman.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          AppButton(
                            label: 'Buat Akun Baru',
                            variant: AppButtonVariant.white,
                            onPressed: () => context.push('/register'),
                          ),
                          const SizedBox(height: 11),
                          AppButton(
                            label: 'Masuk ke Akun',
                            variant: AppButtonVariant.outlineWhite,
                            onPressed: () => context.push('/login'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
