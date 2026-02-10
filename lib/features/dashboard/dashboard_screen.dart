import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lsrd_pro/core/theme/app_theme.dart';

import 'package:lsrd_pro/screens/vetting/vetting_screen.dart';
import '../../screens/deeds/deeds_screen.dart';
import 'package:lsrd_pro/screens/billing/billing_screen.dart';

import 'package:lsrd_pro/core/widgets/stat_card.dart';
import 'package:lsrd_pro/core/widgets/activity_item.dart';
import 'package:lsrd_pro/screens/lsr/lsr_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardHome(),
    const LSRScreen(),
    const VettingScreen(),
    const DeedsScreen(),
    const BillingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_outlined, 'Dashboard', 0),
                _buildNavItem(Icons.description_outlined, 'LSR', 1),
                _buildNavItem(Icons.location_on_outlined, 'Vetting', 2),
                _buildNavItem(Icons.edit_document, 'Deeds', 3),
                _buildNavItem(Icons.attach_money, 'Billing', 4),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 0 ? _buildFAB() : null,
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryPurple : AppTheme.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppTheme.primaryPurple : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {
        // Quick action menu
        _showQuickActions();
      },
      backgroundColor: AppTheme.primaryPurple,
      child: const Icon(Icons.add),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildQuickAction(
                  icon: Icons.description,
                  color: AppTheme.primaryPurple,
                  title: 'New LSR Report',
                  subtitle: 'Start legal scrutiny process',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 1);
                  },
                ),
                const SizedBox(height: 16),
                _buildQuickAction(
                  icon: Icons.location_on,
                  color: AppTheme.primaryTeal,
                  title: 'New Vetting Task',
                  subtitle: 'Assign field verification',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 2);
                  },
                ),
                const SizedBox(height: 16),
                _buildQuickAction(
                  icon: Icons.edit_document,
                  color: AppTheme.primaryGreen,
                  title: 'Draft New Deed',
                  subtitle: 'Create legal document',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 3);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.roboto(color: AppTheme.textMuted, fontSize: 13),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}

// Dashboard Home Content
class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 180,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primaryPurple, AppTheme.primaryPurpleDark],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good Morning',
                                style: GoogleFonts.roboto(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Adv. Rajesh Mehta',
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'RM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildStatsGrid(),
                  const SizedBox(height: 24),
                  _buildRecentActivity(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        StatCard(
          title: 'Total LSR',
          value: '248',
          subtitle: '+12 this month',
          icon: Icons.description_outlined,
          color: AppTheme.primaryPurple,
          trend: Trend.up,
        ),
        StatCard(
          title: 'Vetting',
          value: '18',
          subtitle: '8 pending',
          icon: Icons.location_on_outlined,
          color: AppTheme.accentOrange,
          trend: Trend.neutral,
        ),
        StatCard(
          title: 'Draft Deeds',
          value: '32',
          subtitle: '12 in progress',
          icon: Icons.edit_document,
          color: AppTheme.primaryTeal,
          trend: Trend.up,
        ),
        StatCard(
          title: 'This Month',
          value: '₹2.4L',
          subtitle: '+18% vs last',
          icon: Icons.account_balance_wallet_outlined,
          color: AppTheme.success,
          trend: Trend.up,
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      ActivityItemData(
        title: 'Rajesh Kumar - Loan #LN2401234',
        subtitle: '2 hours ago',
        status: ActivityStatus.processing,
        icon: Icons.access_time,
      ),
      ActivityItemData(
        title: 'Site Visit - Andheri West',
        subtitle: '5 hours ago',
        status: ActivityStatus.completed,
        icon: Icons.check_circle,
      ),
      ActivityItemData(
        title: 'Priya Sharma - Loan #LN2401235',
        subtitle: '1 day ago',
        status: ActivityStatus.discrepancy,
        icon: Icons.warning,
      ),
      ActivityItemData(
        title: 'Sale Deed Draft - Mumbai',
        subtitle: '2 days ago',
        status: ActivityStatus.draft,
        icon: Icons.edit,
      ),
      ActivityItemData(
        title: 'Amit Patel - Loan #LN2401236',
        subtitle: '3 days ago',
        status: ActivityStatus.completed,
        icon: Icons.check_circle,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: GoogleFonts.roboto(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => ActivityItem(data: activities[index]),
        ),
      ],
    );
  }
}