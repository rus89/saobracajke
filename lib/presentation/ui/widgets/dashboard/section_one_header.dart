import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SectionOneHeader extends StatelessWidget {
  final int totalAccidents;
  final int delta;
  final int fatalities;
  final int fatalitiesDelta;
  final int injuries;
  final int injuriesDelta;
  final int materialDamageAccidents;
  final int materialDamageAccidentsDelta;

  const SectionOneHeader({
    super.key,
    required this.totalAccidents,
    required this.delta,
    required this.fatalities,
    required this.fatalitiesDelta,
    required this.injuries,
    required this.injuriesDelta,
    required this.materialDamageAccidents,
    required this.materialDamageAccidentsDelta,
  });

  @override
  Widget build(BuildContext context) {
    // Determine Trend Color (Green is good/less accidents, Red is bad)
    final bool isImprovement = delta <= 0;
    final Color trendColor = isImprovement
        ? Colors.green.shade700
        : Colors.red.shade700;
    final Color trendBg = isImprovement
        ? Colors.green.shade50
        : Colors.red.shade50;
    final String sign = delta > 0 ? "+" : "";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
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
                  color: Colors.black.withValues(alpha: 0.06),
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
                  NumberFormat('#,###').format(totalAccidents),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 20),

                // The Trend Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: trendBg,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isImprovement
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        size: 18,
                        color: trendColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "$sign$delta",
                        style: TextStyle(
                          color: trendColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "vs prošlu godinu",
                        style: TextStyle(
                          color: trendColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

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
                  color: Colors.red,
                  icon: Icons.heart_broken,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStat(
                  label: "SA MATERIJALNOM ŠTETOM",
                  count: materialDamageAccidents,
                  delta: materialDamageAccidentsDelta,
                  color: Colors.blue,
                  icon: Icons.build,
                ),
              ),
            ],
          ),
        ],
      ),
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
    final Color deltaColor = isUp ? Colors.red.shade600 : Colors.green.shade600;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
              // Mini delta indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: deltaColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${isUp ? '+' : ''}$delta",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: deltaColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            NumberFormat('#,###').format(count),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
