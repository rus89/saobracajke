import 'package:flutter/material.dart';
import '../../../../../domain/models/accident_model.dart';

//-------------------------------------------------------------------------------
class AccidentCard extends StatelessWidget {
  final AccidentModel accident;

  const AccidentCard({super.key, required this.accident});

  @override
  Widget build(BuildContext context) {
    // Formatting the date to Serbian standard: "22.01.2023 u 14:30"
    final formattedDate =
        "${accident.date.day.toString().padLeft(2, '0')}.${accident.date.month.toString().padLeft(2, '0')}.${accident.date.year} • ${accident.date.hour.toString().padLeft(2, '0')}:${accident.date.minute.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: Navigate to full detail screen if needed
            debugPrint("Tapped accident: ${accident.id}");
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER: Date & ID ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50, // Gentle Green Theme
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      "#${accident.id}",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // --- TITLE: Accident Type ---
                Text(
                  accident.type,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                // --- SUBTITLE: Location (Station) ---
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        accident.station, // "Policijska stanica..."
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // --- FOOTER: Participants ---
                // Shows who was involved (e.g., "Passenger Car, Pedestrian")
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        accident.participants.isNotEmpty
                            ? accident.participants
                            : "Nema podataka o učesnicima",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
