// ABOUTME: Static informational screen: app title, data source, disclaimer, contact.
// ABOUTME: Hero card with accent stripe and three info cards, all dark-theme styled.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';
import 'package:saobracajke/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

const String _feedbackEmail = 'serbiaopendataapps@gmail.com';

@visibleForTesting
const String playStoreUrl =
    'https://play.google.com/store/apps/details?id=com.serbiaOpenData.saobracajke';

@visibleForTesting
bool shouldShowRateTile({bool isWeb = kIsWeb}) => !isWeb;

@visibleForTesting
Uri buildFeedbackUri(PackageInfo info) {
  return Uri(
    scheme: 'mailto',
    path: _feedbackEmail,
    queryParameters: {
      'subject': 'Saobraćajne Nezgode — povratna informacija',
      'body': 'Verzija aplikacije: v${info.version}+${info.buildNumber}\n\n',
    },
  );
}

@visibleForTesting
SnackBar buildCopyableSnackBar(String target) {
  return SnackBar(
    content: Text(target),
    duration: const Duration(seconds: 8),
    action: SnackBarAction(
      label: 'Kopiraj',
      onPressed: () => Clipboard.setData(ClipboardData(text: target)),
    ),
  );
}

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const String _datasetUrl =
      'https://data.gov.rs/sr/datasets/podatsi-o-saobratshajnim-nezgodama-po-politsijskim-upravama-i-opshtinama/';

  PackageInfo? _packageInfo;
  String? _versionLabel;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _packageInfo = info;
      _versionLabel = 'v${info.version}+${info.buildNumber}';
    });
  }

  Future<void> _openExternalUrl(BuildContext context, String url) async {
    try {
      final ok = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(buildCopyableSnackBar(url));
      }
    } on Exception catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(buildCopyableSnackBar(url));
    }
  }

  Future<void> _openFeedback(BuildContext context) async {
    final info = _packageInfo;
    if (info == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(buildCopyableSnackBar(_feedbackEmail));
      return;
    }
    try {
      final ok = await launchUrl(buildFeedbackUri(info));
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(buildCopyableSnackBar(_feedbackEmail));
      }
    } on Exception catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(buildCopyableSnackBar(_feedbackEmail));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('O aplikaciji')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Hero(theme: theme, version: _versionLabel),
              const SizedBox(height: AppSpacing.lg),
              _InfoCard(
                theme: theme,
                icon: Icons.storage_outlined,
                iconColor: AppTheme.semanticMaterialDamage,
                title: 'Izvor podataka',
                body:
                    'Podaci u ovoj aplikaciji potiču sa portala otvorenih podataka Republike Srbije.',
                actionLabel: 'Otvori izvor',
                onAction: () => _openExternalUrl(context, _datasetUrl),
              ),
              const SizedBox(height: AppSpacing.md),
              _InfoCard(
                theme: theme,
                icon: Icons.warning_amber_outlined,
                iconColor: AppTheme.semanticInjuries,
                title: 'Napomena',
                body:
                    'Ova aplikacija je razvijena u edukativne svrhe. Autor nije povezan ni sa jednim državnim organom niti institucijom. Podaci se prikazuju u viđenom stanju, nisu za zvaničnu upotrebu i mogu biti nepotpuni ili zastareli.',
              ),
              const SizedBox(height: AppSpacing.md),
              _InfoCard(
                theme: theme,
                icon: Icons.email_outlined,
                iconColor: AppTheme.primary,
                title: 'Kontakt',
                body: 'serbiaopendataapps@gmail.com',
              ),
              if (shouldShowRateTile()) ...[
                const SizedBox(height: AppSpacing.md),
                _ActionCard(
                  theme: theme,
                  icon: Icons.star_rate,
                  iconColor: AppTheme.primary,
                  title: 'Oceni aplikaciju',
                  subtitle: 'Otvori Google Play prodavnicu',
                  semanticsLabel: 'Oceni aplikaciju u Google Play prodavnici',
                  onTap: () => _openExternalUrl(context, playStoreUrl),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              _ActionCard(
                theme: theme,
                icon: Icons.mail_outline,
                iconColor: AppTheme.primary,
                title: 'Prijavite grešku ili predlog',
                subtitle: 'Pošaljite poruku autoru',
                semanticsLabel: 'Prijavite grešku ili predlog autoru',
                onTap: () => _openFeedback(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.theme,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.semanticsLabel,
    required this.onTap,
  });

  final ThemeData theme;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      container: true,
      excludeSemantics: true,
      label: semanticsLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.outline),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSpacing.minTouchTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: Icon(icon, size: 16, color: iconColor),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: theme.textTheme.titleSmall),
                          const SizedBox(height: 2),
                          Text(subtitle, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.theme, required this.version});

  final ThemeData theme;
  final String? version;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saobraćajne Nezgode',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Otvoreni podaci Srbije',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (version != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      border: Border.all(color: AppTheme.primary),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusPill,
                      ),
                    ),
                    child: Text(
                      version!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.primary,
                      ),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.theme,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final ThemeData theme;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 34, top: AppSpacing.sm),
            child: Text(body, style: theme.textTheme.bodySmall),
          ),
          if (actionLabel != null && onAction != null)
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ),
        ],
      ),
    );
  }
}
