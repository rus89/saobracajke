// ABOUTME: Bottom sheet showing detailed metadata for a single accident marker.
// ABOUTME: Displays date, time, station, participants, and optional official description.
import 'package:flutter/material.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';
import 'package:saobracajke/core/theme/app_theme.dart';
import 'package:saobracajke/domain/accident_types.dart';
import 'package:saobracajke/domain/models/accident_model.dart';

class AccidentDetailSheet extends StatelessWidget {
  const AccidentDetailSheet({super.key, required this.accident});

  final AccidentModel accident;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AccidentTypes.markerColor(accident.type);
    return Semantics(
      label: 'Accident details: ${accident.type}, ${accident.department}',
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          border: const Border(
            top: BorderSide(color: AppTheme.outline),
          ),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusMd),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 3,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppTheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(Icons.directions_car, size: 20, color: color),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(accident.type, style: theme.textTheme.titleMedium),
                      Text(
                        accident.department,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 3.5,
              children: [
                _MetaField(
                  label: 'DATUM',
                  value:
                      '${accident.date.day}.${accident.date.month}.${accident.date.year}',
                ),
                _MetaField(
                  label: 'VREME',
                  value:
                      '${accident.date.hour}:${accident.date.minute.toString().padLeft(2, '0')}',
                ),
                _MetaField(label: 'STANICA', value: accident.station),
                _MetaField(label: 'UČESNICI', value: accident.participants),
              ],
            ),
            if (accident.officialDesc != null) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Text('OPIS', style: theme.textTheme.labelSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                accident.officialDesc!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetaField extends StatelessWidget {
  const _MetaField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
