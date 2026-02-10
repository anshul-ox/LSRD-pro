// screens/vetting/vetting_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lsrd_pro/core/theme/app_theme.dart';

class VettingScreen extends StatefulWidget {
  const VettingScreen({super.key});

  @override
  State<VettingScreen> createState() => _VettingScreenState();
}

class _VettingScreenState extends State<VettingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Vetting'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All Tasks (4)'),
            Tab(text: 'Pending (2)'),
            Tab(text: 'Today (2)'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(),
          _buildTaskList(filter: 'pending'),
          _buildTaskList(filter: 'today'),
          _buildTaskList(filter: 'completed'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList({String? filter}) {
    final tasks = [
      VettingTask(
        name: 'Rajesh Kumar',
        loanId: 'LN2401234',
        bank: 'HDFC Bank - Andheri West',
        address: 'Plot 45, Sector 12, Andheri West, Mumbai - 400053',
        time: 'Today, 2:00 PM',
        status: VettingStatus.pending,
      ),
      VettingTask(
        name: 'Priya Sharma',
        loanId: 'LN2401235',
        bank: 'SBI - Bandra',
        address: 'Flat 302, Silver Heights, Bandra, Mumbai - 400050',
        time: 'Today, 4:30 PM',
        status: VettingStatus.inProgress,
      ),
      VettingTask(
        name: 'Amit Patel',
        loanId: 'LN2401236',
        bank: 'ICICI Bank - Juhu',
        address: 'Bungalow 78, Juhu Scheme, Mumbai - 400049',
        time: 'Yesterday',
        status: VettingStatus.completed,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) => _buildTaskCard(tasks[index]),
    );
  }

  Widget _buildTaskCard(VettingTask task) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (task.status) {
      case VettingStatus.pending:
        statusColor = AppTheme.warning;
        statusText = 'Pending';
        statusIcon = Icons.schedule;
        break;
      case VettingStatus.inProgress:
        statusColor = AppTheme.accentBlue;
        statusText = 'In Progress';
        statusIcon = Icons.play_circle;
        break;
      case VettingStatus.completed:
        statusColor = AppTheme.success;
        statusText = 'Completed';
        statusIcon = Icons.check_circle;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.name,
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Loan ID: ${task.loanId}',
                        style: GoogleFonts.roboto(
                          color: AppTheme.textMuted,
                          fontSize: 13,
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: GoogleFonts.roboto(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.account_balance, task.bank),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, task.address),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.access_time, task.time),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  task.status == VettingStatus.pending
                      ? 'Start Vetting'
                      : task.status == VettingStatus.inProgress
                          ? 'Continue'
                          : 'View Report',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.roboto(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

enum VettingStatus { pending, inProgress, completed }

class VettingTask {
  final String name;
  final String loanId;
  final String bank;
  final String address;
  final String time;
  final VettingStatus status;

  VettingTask({
    required this.name,
    required this.loanId,
    required this.bank,
    required this.address,
    required this.time,
    required this.status,
  });
}