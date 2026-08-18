import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/user_profile.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../cart/providers/cart_provider.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../providers/user_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: userAsync.when(
          loading: () => const LoadingView(),
          error: (err, _) => ErrorView(
            message: '$err',
            onRetry: () => ref.invalidate(userProvider),
          ),
          data: (user) => _ProfileBody(user: user),
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profil', style: text.headlineLarge),
          const SizedBox(height: 20),
          _ProfileCard(user: user),
          const SizedBox(height: 20),
          const _StatsRow(),
          const SizedBox(height: 28),
          _MenuSection(
            title: 'COMPTE',
            items: [
              _MenuRow(
                icon: Icons.shopping_bag_outlined,
                label: 'Mes commandes',
                onTap: () => _showSoon(context),
              ),
              _MenuRow(
                icon: Icons.location_on_outlined,
                label: 'Adresses',
                onTap: () => _showSoon(context),
              ),
              _MenuRow(
                icon: Icons.credit_card_outlined,
                label: 'Paiement',
                onTap: () => _showSoon(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _MenuSection(
            title: 'PRÉFÉRENCES',
            items: [
              _MenuRow(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () => _showSoon(context),
              ),
              _MenuRow(
                icon: Icons.language_outlined,
                label: 'Langue',
                trailing: 'Français',
                onTap: () => _showSoon(context),
              ),
              _MenuRow(
                icon: Icons.dark_mode_outlined,
                label: 'Thème',
                trailing: 'Sombre',
                onTap: () => _showSoon(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _MenuSection(
            title: 'AIDE',
            items: [
              _MenuRow(
                icon: Icons.help_outline,
                label: 'Support',
                onTap: () => _showSoon(context),
              ),
              _MenuRow(
                icon: Icons.description_outlined,
                label: 'Conditions d\'utilisation',
                onTap: () => _showSoon(context),
              ),
              _MenuRow(
                icon: Icons.logout_rounded,
                label: 'Se déconnecter',
                destructive: true,
                onTap: () => _showSoon(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _showSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Fonctionnalité à venir'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderHairline),
      ),
      child: Column(
        children: [
          _AvatarRing(imageUrl: user.avatarUrl),
          const SizedBox(height: 14),
          Text(user.name, style: text.titleMedium),
          const SizedBox(height: 4),
          Text(user.email, style: text.bodySmall),
          const SizedBox(height: 14),
          _MembershipChip(memberSince: user.memberSince),
        ],
      ),
    );
  }
}

class _AvatarRing extends StatelessWidget {
  const _AvatarRing({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.seed,
            AppTheme.seed.withValues(alpha: 0.35),
          ],
        ),
      ),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const ColoredBox(
            color: AppTheme.surfaceSubtle,
            child: Icon(Icons.person_outline,
                color: AppTheme.textSecondary, size: 32),
          ),
        ),
      ),
    );
  }
}

class _MembershipChip extends StatelessWidget {
  const _MembershipChip({required this.memberSince});

  final DateTime memberSince;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.seed.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Membre depuis ${Formatters.monthYear(memberSince)}',
        style: const TextStyle(
          color: AppTheme.seed,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Row of three stat cards.
///
/// Split into 3 distinct [ConsumerWidget]s so each card only rebuilds when
/// its own provider changes (cart change ≠ favorites card rebuild).
class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _OrdersStatCard()),
        SizedBox(width: 12),
        Expanded(child: _FavoritesStatCard()),
        SizedBox(width: 12),
        Expanded(child: _CartStatCard()),
      ],
    );
  }
}

class _OrdersStatCard extends StatelessWidget {
  const _OrdersStatCard();
  // Mocked — no orders provider in scope. Left as a static number to keep the
  // profile visually rich without inventing a fake orders feature.
  @override
  Widget build(BuildContext context) => const _StatCard(value: '12', label: 'Commandes');
}

class _FavoritesStatCard extends ConsumerWidget {
  const _FavoritesStatCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(favoritesProvider).value?.length ?? 0;
    return _StatCard(value: '$count', label: 'Favoris');
  }
}

class _CartStatCard extends ConsumerWidget {
  const _CartStatCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartItemCountProvider);
    return _StatCard(value: '$count', label: 'Panier');
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderHairline),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: text.headlineMedium?.copyWith(
              color: AppTheme.seed,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: text.bodySmall),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.title, required this.items});

  final String title;
  final List<_MenuRow> items;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title, style: text.labelSmall),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderHairline),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  items[i],
                  if (i < items.length - 1)
                    const Divider(
                      height: 1,
                      indent: 52,
                      color: AppTheme.borderHairline,
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final color = destructive ? const Color(0xFFEF4444) : null;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? AppTheme.textSecondary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: text.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) ...[
              Text(trailing!, style: text.bodySmall),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }
}
