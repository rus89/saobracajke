import 'package:flutter/material.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';

/// Shimmer animation wrapper. Paints a translucent gradient that slides
/// horizontally across its [child], giving a "loading" shimmer effect.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _controller.addListener(_onTick);
  }

  void _onTick() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.surfaceContainerHighest;
    final highlight = theme.colorScheme.surface;

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [base, highlight, base],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
          end: Alignment(1.0 + 2.0 * _controller.value, 0),
        ).createShader(bounds);
      },
      child: widget.child,
    );
  }
}

/// A single rounded skeleton placeholder rectangle.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Dashboard skeleton: mimics the layout of SectionOneHeader + chart cards.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter bar placeholder
            const SkeletonBox(width: double.infinity, height: 48),
            const SizedBox(height: AppSpacing.md),
            const SkeletonBox(width: double.infinity, height: 48),
            const SizedBox(height: AppSpacing.xxl),

            // Section header
            const SkeletonBox(width: 200, height: 14),
            const SizedBox(height: AppSpacing.lg),

            // Big summary card
            const SkeletonBox(
              width: double.infinity,
              height: 160,
              borderRadius: 20,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Three mini stat cards
            Row(
              children: [
                Expanded(
                  child: SkeletonBox(
                    width: double.infinity,
                    height: 110,
                    borderRadius: 16,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: SkeletonBox(
                    width: double.infinity,
                    height: 110,
                    borderRadius: 16,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: SkeletonBox(
                    width: double.infinity,
                    height: 110,
                    borderRadius: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // Section header
            const SkeletonBox(width: 180, height: 14),
            const SizedBox(height: AppSpacing.lg),

            // Chart placeholder 1
            const SkeletonBox(
              width: double.infinity,
              height: 260,
              borderRadius: 12,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Chart placeholder 2
            const SkeletonBox(
              width: double.infinity,
              height: 260,
              borderRadius: 12,
            ),
          ],
        ),
      ),
    );
  }
}

/// Map skeleton: mimics the map screen layout with filter card + map area.
class MapSkeleton extends StatelessWidget {
  const MapSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Stack(
        children: [
          // Map area
          const SkeletonBox(
            width: double.infinity,
            height: double.infinity,
            borderRadius: 0,
          ),
          // Filter card overlay
          Positioned(
            top: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Column(
              children: [
                SkeletonBox(
                  width: double.infinity,
                  height: 48,
                  borderRadius: 12,
                ),
                const SizedBox(height: AppSpacing.sm),
                SkeletonBox(
                  width: double.infinity,
                  height: 48,
                  borderRadius: 12,
                ),
              ],
            ),
          ),
          // Legend placeholder
          const Positioned(
            bottom: 20,
            left: 20,
            child: SkeletonBox(width: 130, height: 90, borderRadius: 8),
          ),
        ],
      ),
    );
  }
}
