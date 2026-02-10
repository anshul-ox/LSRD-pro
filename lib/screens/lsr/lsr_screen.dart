import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lsrd_pro/core/theme/app_theme.dart';
import 'lsr_create_screen.dart';

class LSRScreen extends StatelessWidget {
  const LSRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              'Legal Scrutiny Reports',
              style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {},
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatusCards(),
                const SizedBox(height: 24),
                _buildRecentLSR(),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LSRCreateScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New LSR'),
      ),
    );
  }

  Widget _buildStatusCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            'Pending',
            '12',
            AppTheme.warning,
            Icons.pending_actions,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatusCard(
            'In Review',
            '5',
            AppTheme.accentBlue,
            Icons.rate_review,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatusCard(
            'Completed',
            '231',
            AppTheme.success,
            Icons.check_circle,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(String title, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            count,
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLSR() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Reports',
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildLSRItem(
          'Ramesh Kumar',
          'LN2401234',
          'HDFC Bank - Andheri',
          'Processing',
          AppTheme.accentBlue,
        ),
        _buildLSRItem(
          'Priya Sharma',
          'LN2401235',
          'SBI - Bandra',
          'Discrepancy Found',
          AppTheme.error,
        ),
        _buildLSRItem(
          'Amit Patel',
          'LN2401236',
          'ICICI Bank - Juhu',
          'Completed',
          AppTheme.success,
        ),
      ],
    );
  }

  Widget _buildLSRItem(String name, String loanId, String bank, String status, Color statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.description, color: AppTheme.primaryPurple),
        ),
        title: Text(
          name,
          style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(loanId, style: GoogleFonts.roboto(color: AppTheme.textMuted)),
            Text(bank, style: GoogleFonts.roboto(color: AppTheme.textMuted, fontSize: 12)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: GoogleFonts.roboto(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}