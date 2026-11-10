import 'package:flutter/material.dart';

import '../app/theme.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onLogout,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 8,
        8,
        20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'CampusSafe',
                style: text.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (onLogout != null)
                IconButton(
                  tooltip: 'Log out',
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: onLogout,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: text.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: text.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
