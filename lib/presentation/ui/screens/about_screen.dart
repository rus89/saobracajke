// ABOUTME: Static informational screen showing app details, data source, disclaimer, and contact.
// ABOUTME: All text in Serbian; uses AppTheme and AppSpacing tokens for consistent styling.
import 'package:flutter/material.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('O aplikaciji')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Icon(
                Icons.directions_car,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Saobraćajne Nezgode',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Verzija $_appVersion',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              _Section(
                icon: Icons.storage_outlined,
                title: 'Izvor podataka',
                body: 'Podaci u ovoj aplikaciji potiču sa portala '
                    'otvorenih podataka Republike Srbije:\n'
                    'https://data.gov.rs/sr/datasets/podatsi-o-saobrakajnim-nezgodama-po-politsijskim-upravama-i-opshtinama/',
              ),
              const SizedBox(height: AppSpacing.xxl),
              _Section(
                icon: Icons.warning_amber_outlined,
                title: 'Napomena',
                body: 'Ova aplikacija je razvijena u edukativne svrhe. '
                    'Autor nije povezan ni sa jednim državnim organom '
                    'niti institucijom. '
                    'Podaci se prikazuju u viđenom stanju, '
                    'nisu za zvaničnu upotrebu i '
                    'mogu biti nepotpuni ili zastareli.',
              ),
              const SizedBox(height: AppSpacing.xxl),
              _Section(
                icon: Icons.email_outlined,
                title: 'Kontakt',
                body: 'serbiaopendata@gmail.com',
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(body, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
