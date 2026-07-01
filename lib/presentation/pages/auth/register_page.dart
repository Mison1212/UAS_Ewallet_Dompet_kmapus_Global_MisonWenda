import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/failures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/usecases/auth/register_with_otp_usecase.dart';
import '../../../injection/injection_container.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/feature_icon.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _name = '';
  String _email = '';
  String _pw = '';
  bool _showPw = false;
  bool _agree = true;
  bool _loading = false;

  bool get _valid => _name.length > 1 && _email.contains('@') && _pw.length >= 6 && _agree;

  Future<void> _register() async {
    setState(() => _loading = true);
    try {
      await sl<RegisterUsecase>()(_name, _email, _pw);

      if (mounted) context.go('/verify-email', extra: {'email': _email});
    } on ServerFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.red),
        );
      }
    } on NetworkFailure catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada koneksi internet.'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Container(
            height: 264,
            decoration: const BoxDecoration(
              gradient: AppColors.premiumGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AuthBackButton(onPressed: () => context.go('/')),
                  const SizedBox(height: 26),
                  const AppLogo(size: 58),
                  const SizedBox(height: 22),
                  const Text(
                    'Buat akun',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Daftar gratis dalam 1 menit',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mint,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.line2),
                      boxShadow: AppColors.shadowCard,
                    ),
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
                    child: Column(
                      children: [
                        AppField(
                          label: 'Nama lengkap',
                          value: _name,
                          onChanged: (v) => setState(() => _name = v),
                          placeholder: 'Nama Lengkap',
                          prefixIcon: const Icon(DkgIcons.user, size: 20),
                        ),
                        const SizedBox(height: 14),
                        AppField(
                          label: 'Email',
                          value: _email,
                          onChanged: (v) => setState(() => _email = v),
                          placeholder: 'nama@email.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(DkgIcons.mail, size: 20),
                        ),
                        const SizedBox(height: 14),
                        AppField(
                          label: 'Kata sandi',
                          value: _pw,
                          onChanged: (v) => setState(() => _pw = v),
                          obscureText: !_showPw,
                          placeholder: 'Min. 6 karakter',
                          prefixIcon: const Icon(DkgIcons.lock, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPw ? DkgIcons.eyeOff : DkgIcons.eye,
                              size: 20,
                              color: AppColors.slate400,
                            ),
                            onPressed: () => setState(() => _showPw = !_showPw),
                          ),
                        ),
                        const SizedBox(height: 18),
                        GestureDetector(
                          onTap: () => setState(() => _agree = !_agree),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _agree ? AppColors.primary : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _agree ? AppColors.primary : AppColors.line,
                                    width: 1.4,
                                  ),
                                  boxShadow: _agree ? AppColors.shadowPrimary : [],
                                ),
                                child: _agree
                                    ? const Icon(DkgIcons.check, size: 15, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 13,
                                      color: AppColors.slate500,
                                      height: 1.5,
                                    ),
                                    children: [
                                      TextSpan(text: 'Saya setuju dengan '),
                                      TextSpan(
                                        text: 'Syarat & Ketentuan',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      TextSpan(text: ' dan '),
                                      TextSpan(
                                        text: 'Kebijakan Privasi',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      TextSpan(text: '.'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          label: 'Daftar',
                          onPressed: _valid ? _register : null,
                          isLoading: _loading,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Sudah punya akun? ',
                              style: TextStyle(fontSize: 14, color: AppColors.slate500),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/login'),
                              child: const Text(
                                'Masuk',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
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
}

class _AuthBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AuthBackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: const Icon(DkgIcons.arrowLeft, color: Colors.white, size: 20),
      ),
    );
  }
}
