import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SectionOneHeader extends StatelessWidget {
  final int totalAccidents;
  final int delta; // e.g. -150 or +400
  final int fatalities;
  final int fatalitiesDelta;
  final int injuries;
  final int injuriesDelta;

  const SectionOneHeader({
    super.key,
    required this.totalAccidents,
    required this.delta,
    required this.fatalities,
    required this.fatalitiesDelta,
    required this.injuries,
    required this.injuriesDelta,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Determine Trend Color (Green is good/less accidents, Red is bad)
    final bool isImprovement = delta < 0;
    final Color trendColor = isImprovement
        ? Colors.green.shade700
        : Colors.red.shade700;
    final Color trendBg = isImprovement
        ? Colors.green.shade50
        : Colors.red.shade50;
    final String sign = delta > 0 ? "+" : ""; // Negative number already has "-"

    return Column(
      children: [
        // --- MAIN CARD (Total Accidents) ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "UKUPNO NESREĆA",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                NumberFormat('#,###').format(totalAccidents), // 24.500
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 16),

              // The Trend Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: trendBg,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isImprovement ? Icons.arrow_downward : Icons.arrow_upward,
                      size: 16,
                      color: trendColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$sign$delta u odnosu na prošlu godinu",
                      style: TextStyle(
                        color: trendColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // --- SUB-METRICS ROW (The Breakdown) ---
        Row(
          children: [
            // Left: Injuries
            Expanded(
              child: _buildMiniStat(
                label: "POVREĐENI",
                count: injuries,
                delta: injuriesDelta,
                color: Colors.orange,
                icon: Icons.personal_injury,
              ),
            ),
            const SizedBox(width: 12),
            // Right: Deaths (The most critical metric)
            Expanded(
              child: _buildMiniStat(
                label: "POGINULI",
                count: fatalities,
                delta: fatalitiesDelta,
                color: Colors.red, // Alert color for deaths
                icon: Icons.heart_broken, // Emotional impact icon
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStat({
    required String label,
    required int count,
    required int delta,
    required Color color,
    required IconData icon,
  }) {
    final bool isUp = delta > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const Spacer(),
              // Mini delta indicator
              Text(
                "${isUp ? '+' : ''}$delta",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isUp ? Colors.red : Colors.green, // More deaths = Red
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
