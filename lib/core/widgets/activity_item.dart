import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum ActivityStatus {
  processing,
  completed,
  discrepancy,
  draft,
}

class ActivityItemData {
  final String title;
  final String subtitle;
  final ActivityStatus status;
  final IconData icon;

  ActivityItemData({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.icon,
  });
}

class ActivityItem extends StatelessWidget {
  final ActivityItemData data;

  const ActivityItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    
    switch (data.status) {
      case ActivityStatus.processing:
        statusColor = AppTheme.accentBlue;
        statusText = 'Processing';
        break;
      case ActivityStatus.completed:
        statusColor = AppTheme.success;
        statusText = 'Completed';
        break;
      case ActivityStatus.discrepancy:
        statusColor = AppTheme.warning;
        statusText = 'Discrepancy';
        break;
      case ActivityStatus.draft:
        statusColor = AppTheme.textMuted;
        statusText = 'Draft';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  data.subtitle,
                  style: GoogleFonts.roboto(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: GoogleFonts.roboto(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}