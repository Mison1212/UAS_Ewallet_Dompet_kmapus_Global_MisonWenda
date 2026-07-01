import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/deep_link_wrapper.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../blocs/account/account_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/feature_icon.dart';
import '../../widgets/transaction_row.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hideBalance = false;

  @override
  void initState() {
    super.initState();
    context.read<AccountBloc>().add(AccountLoadRequested());
    context.read<AuthBloc>().add(AuthCheckRequested());

    // Cek apakah ada pembayaran tertunda dari e-commerce
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (PendingDeepLink.payload != null) {
        final payload = PendingDeepLink.payload!;
        PendingDeepLink.payload = null; // Hapus setelah dieksekusi
        context.push('/merchant', extra: payload);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        final firstName = user?.firstName ?? 'Kamu';
        final fullName = user?.name ?? 'User';

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: BlocBuilder<AccountBloc, AccountState>(
            builder: (context, accountState) {
              final balance = accountState is AccountLoaded ? accountState.account.balance : 0.0;
              final txns =
                  accountState is AccountLoaded ? accountState.transactions : <TransactionEntity>[];
              final loading = accountState is AccountLoading;

              return RefreshIndicator(
                onRefresh: () async => context.read<AccountBloc>().add(AccountRefreshRequested()),
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: AppColors.premiumGradient,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          20,
                          MediaQuery.of(context).padding.top + 14,
                          20,
                          108,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                AppAvatar(
                                  name: fullName,
                                  size: 48,
                                  bg: Colors.white.withValues(alpha: 0.18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Selamat siang,',
                                        style: TextStyle(
                                          fontFamily: 'PlusJakartaSans',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.mint,
                                        ),
                                      ),
                                      Text(
                                        firstName,
                                        style: const TextStyle(
                                          fontFamily: 'PlusJakartaSans',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          height: 1.15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const AppLogo(size: 42),
                                const SizedBox(width: 10),
                                Stack(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.14),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.12),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.notifications_outlined,
                                        size: 22,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 11,
                                      child: Container(
                                        width: 9,
                                        height: 9,
                                        decoration: BoxDecoration(
                                          color: AppColors.gold,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                _HeaderPill(
                                  icon: Icons.verified_user_outlined,
                                  label: 'Akun aktif',
                                ),
                                const SizedBox(width: 10),
                                _HeaderPill(
                                  icon: Icons.lock_outline_rounded,
                                  label: 'Transaksi aman',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -64),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildBalanceCard(balance, loading),
                        ),
                      ),
                      const SizedBox(height: 0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildPointsRow(),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildFeatureGrid(),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildDeeplinkBanner(),
                      ),
                      const SizedBox(height: 22),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildTransactions(txns),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard(double balance, bool loading) {
    final actions = [
      {'icon': Icons.add_rounded, 'label': 'Top Up', 'tone': 'blue', 'route': '/topup'},
      {'icon': Icons.near_me_rounded, 'label': 'Transfer', 'tone': 'green', 'route': '/transfer'},
      {'icon': Icons.qr_code_scanner_rounded, 'label': 'Bayar', 'tone': 'teal', 'route': '/payment'},
      {'icon': Icons.south_west_rounded, 'label': 'Tarik', 'tone': 'gold', 'route': '/topup'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.shadowCard,
        border: Border.all(color: AppColors.line2),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryBorder.withValues(alpha: 0.55)),
                ),
                child: const Center(child: AppLogo(size: 28)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dompet Kampus Global',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Saldo tersedia',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/topup'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: AppColors.primaryBorder.withValues(alpha: 0.45)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                      SizedBox(width: 5),
                      Text('Isi',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  loading
                      ? 'Memuat...'
                      : _hideBalance
                          ? CurrencyFormatter.maskBalance()
                          : CurrencyFormatter.format(balance),
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: 0,
                    height: 1,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(_hideBalance ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 21, color: AppColors.slate400),
                onPressed: () => setState(() => _hideBalance = !_hideBalance),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.line2)),
            ),
            padding: const EdgeInsets.only(top: 14),
            child: Row(
              children: actions.map((a) {
                return Expanded(
                  child: _QuickAction(
                    icon: a['icon'] as IconData,
                    label: a['label'] as String,
                    tone: a['tone'] as String,
                    onTap: () => context.go(a['route'] as String),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsRow() {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.stars_rounded,
            tone: 'gold',
            title: 'Poin Kampus',
            value: '1.250',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            icon: Icons.badge_outlined,
            tone: 'teal',
            title: 'KTM Digital',
            value: 'Aktif',
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      {'icon': Icons.smartphone_outlined, 'label': 'Pulsa', 'tone': 'blue'},
      {'icon': Icons.bolt_outlined, 'label': 'PLN', 'tone': 'gold'},
      {'icon': Icons.restaurant_outlined, 'label': 'Kantin', 'tone': 'red'},
      {'icon': Icons.receipt_long_outlined, 'label': 'UKT', 'tone': 'violet'},
      {'icon': Icons.wifi_rounded, 'label': 'Paket Data', 'tone': 'green'},
      {'icon': Icons.card_giftcard_rounded, 'label': 'Voucher', 'tone': 'red'},
      {'icon': Icons.favorite_outline_rounded, 'label': 'Donasi', 'tone': 'gold'},
      {'icon': Icons.more_horiz_rounded, 'label': 'Lainnya', 'tone': 'slate'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.shadowSoft,
        border: Border.all(color: AppColors.line2),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        children: [
          const _SectionTitle(
            title: 'Layanan Kampus',
            action: 'Lihat semua',
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 18,
            crossAxisSpacing: 8,
            childAspectRatio: 0.82,
            children: features.map((f) {
              return _FeatureTile(
                icon: f['icon'] as IconData,
                label: f['label'] as String,
                tone: f['tone'] as String,
                onTap: () {},
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeeplinkBanner() {
    return GestureDetector(
      onTap: () => context.go('/merchant'),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF10201E), Color(0xFF006B60)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppColors.shadowSoft,
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: const Icon(Icons.shopping_bag_outlined, size: 24, color: AppColors.mint),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bayar merchant kampus',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      )),
                  SizedBox(height: 4),
                  Text('Checkout kantin, koperasi, atau toko online via DKG',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12.5,
                        color: Colors.white70,
                      )),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.white60),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactions(List<TransactionEntity> txns) {
    return Column(
      children: [
        _SectionTitle(
          title: 'Transaksi terakhir',
          action: 'Lihat semua',
          onTap: () => context.go('/history'),
        ),
        const SizedBox(height: 13),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppColors.shadowSoft,
            border: Border.all(color: AppColors.line2),
          ),
          child: txns.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Row(
                    children: [
                      const FeatureIcon(
                        icon: Icons.receipt_long_outlined,
                        tone: 'slate',
                        size: 44,
                        iconSize: 21,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Belum ada transaksi',
                          style: TextStyle(
                            color: AppColors.slate500,
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: txns
                      .take(4)
                      .toList()
                      .asMap()
                      .entries
                      .map((e) => TransactionRow(txn: e.value, divider: e.key > 0))
                      .toList(),
                ),
        ),
      ],
    );
  }
}

class _HeaderPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.mint),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tone;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.tone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FeatureIcon(icon: icon, tone: tone, size: 48, iconSize: 23),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.slate600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String tone;
  final String title;
  final String value;

  const _MetricCard({
    required this.icon,
    required this.tone,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.shadowSoft,
        border: Border.all(color: AppColors.line2),
      ),
      child: Row(
        children: [
          FeatureIcon(icon: icon, tone: tone, size: 42, iconSize: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11.5,
                    color: AppColors.slate500,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback? onTap;

  const _SectionTitle({
    required this.title,
    required this.action,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tone;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.icon,
    required this.label,
    required this.tone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FeatureIcon(icon: icon, tone: tone, size: 52, iconSize: 24),
          const SizedBox(height: 9),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11.8,
              fontWeight: FontWeight.w700,
              color: AppColors.slate600,
            ),
          ),
        ],
      ),
    );
  }
}
