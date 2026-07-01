import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'feature_icon.dart';

class AppTabBar extends StatelessWidget {
  final String active;
  final ValueChanged<String> onTab;
  final VoidCallback? onScan;

  const AppTabBar({
    super.key,
    required this.active,
    required this.onTab,
    this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        border: const Border(top: BorderSide(color: AppColors.line2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _TabItem(icon: DkgIcons.home, label: 'Home', tabKey: 'home', active: active, onTap: onTab),
            _TabItem(icon: DkgIcons.history, label: 'Riwayat', tabKey: 'history', active: active, onTap: onTab),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: onScan,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: AppColors.shadowPrimary,
                    ),
                    child: const Icon(DkgIcons.scan, color: Colors.white, size: 26),
                  ),
                ),
              ),
            ),
            _TabItem(icon: DkgIcons.gift, label: 'Promo', tabKey: 'promo', active: active, onTap: onTab),
            _TabItem(icon: DkgIcons.user, label: 'Akun', tabKey: 'akun', active: active, onTap: onTab),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tabKey;
  final String active;
  final ValueChanged<String> onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.tabKey,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = active == tabKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(tabKey),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 23,
              color: isActive ? AppColors.primary : AppColors.slate400,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? AppColors.primary : AppColors.slate400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
