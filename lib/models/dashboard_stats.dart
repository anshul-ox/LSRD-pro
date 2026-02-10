class DashboardStats {
  final int totalLSR;
  final int lsrThisMonth;
  final int pendingVetting;
  final int totalVetting;
  final int draftDeeds;
  final int deedsInProgress;
  final double monthlyRevenue;
  final double revenueGrowth;

  DashboardStats({
    required this.totalLSR,
    required this.lsrThisMonth,
    required this.pendingVetting,
    required this.totalVetting,
    required this.draftDeeds,
    required this.deedsInProgress,
    required this.monthlyRevenue,
    required this.revenueGrowth,
  });

  factory DashboardStats.sample() {
    return DashboardStats(
      totalLSR: 248,
      lsrThisMonth: 12,
      pendingVetting: 8,
      totalVetting: 18,
      draftDeeds: 32,
      deedsInProgress: 12,
      monthlyRevenue: 240000,
      revenueGrowth: 0.18,
    );
  }
}