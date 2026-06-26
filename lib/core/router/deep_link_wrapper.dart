import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'app_router.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../injection/injection_container.dart';

class PendingDeepLink {
  static Map<String, dynamic>? payload;
}

class DeepLinkWrapper extends StatefulWidget {
  final Widget child;
  const DeepLinkWrapper({super.key, required this.child});

  @override
  State<DeepLinkWrapper> createState() => _DeepLinkWrapperState();
}

class _DeepLinkWrapperState extends State<DeepLinkWrapper> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      debugPrint('Error listening to deep links: $err');
    });
  }

  void _handleDeepLink(Uri uri) async {
    if (uri.scheme == 'myewallet' && uri.host == 'pay') {
      final orderId = uri.queryParameters['order_id'];
      final amount = uri.queryParameters['amount'];
      final callbackUrl = uri.queryParameters['callback_url'];

      if (orderId != null && amount != null) {
        final payload = {
          'order_id': orderId,
          'amount': amount,
          'callback_url': callbackUrl,
        };

        // Cek apakah user sudah login
        final authRepo = sl<AuthRepository>();
        final token = await authRepo.getSavedToken();
        final isVerified = await authRepo.isAuthVerified();

        if (token != null && token.isNotEmpty && isVerified) {
          // Sudah login, langsung proses checkout
          Future.delayed(const Duration(milliseconds: 500), () {
            AppRouter.router.push('/merchant', extra: payload);
          });
        } else {
          // Belum login, simpan payload agar dieksekusi setelah login (di HomePage)
          PendingDeepLink.payload = payload;
          // GoRouter otomatis akan menahan user di /login
        }
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
