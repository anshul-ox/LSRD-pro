// repositories/lsr_repository.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lsr_models.dart';

/// Repository for managing LSR Reports
/// Uses SharedPreferences for local storage
/// Designed to be easily replaced with Firebase/API
class LSRRepository {
  static LSRRepository? _instance;
  factory LSRRepository() => _instance ??= LSRRepository._();
  LSRRepository._();
  
  static const String _keyReports = 'lsr_reports';
  static const String _keyCounter = 'lsr_counter';
  
  List<LSRReport>? _cachedReports;
  
  /// Get all LSR reports
  Future<List<LSRReport>> getAllReports() async {
    if (_cachedReports != null) return _cachedReports!;
    
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_keyReports);
    
    if (jsonString == null) {
      _cachedReports = [];
      return _cachedReports!;
    }
    
    try {
      final List<dynamic> jsonData = json.decode(jsonString);
      _cachedReports = jsonData
          .map((json) => LSRReport.fromJson(json as Map<String, dynamic>))
          .toList();
      return _cachedReports!;
    } catch (e) {
      _cachedReports = [];
      return _cachedReports!;
    }
  }
  
  /// Save a new LSR report
  Future<LSRReport> createReport(LSRReport report) async {
    final reports = await getAllReports();
    
    // Generate ID if not provided
    final newReport = report.id.isEmpty 
        ? report.copyWith(
            id: await _generateId(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          )
        : report.copyWith(
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
    
    reports.add(newReport);
    await _saveReports(reports);
    
    return newReport;
  }
  
  /// Update an existing LSR report
  Future<LSRReport> updateReport(LSRReport report) async {
    final reports = await getAllReports();
    final index = reports.indexWhere((r) => r.id == report.id);
    
    if (index == -1) {
      throw Exception('Report not found');
    }
    
    final updatedReport = report.copyWith(updatedAt: DateTime.now());
    reports[index] = updatedReport;
    await _saveReports(reports);
    
    return updatedReport;
  }
  
  /// Delete a report
  Future<void> deleteReport(String reportId) async {
    final reports = await getAllReports();
    reports.removeWhere((r) => r.id == reportId);
    await _saveReports(reports);
  }
  
  /// Get report by ID
  Future<LSRReport?> getReportById(String reportId) async {
    final reports = await getAllReports();
    try {
      return reports.firstWhere((r) => r.id == reportId);
    } catch (e) {
      return null;
    }
  }
  
  /// Get reports by status
  Future<List<LSRReport>> getReportsByStatus(LSRStatus status) async {
    final reports = await getAllReports();
    return reports.where((r) => r.status == status).toList();
  }
  
  /// Get reports by bank
  Future<List<LSRReport>> getReportsByBank(String bankId) async {
    final reports = await getAllReports();
    return reports.where((r) => r.bankId == bankId).toList();
  }
  
  /// Get reports by date range
  Future<List<LSRReport>> getReportsByDateRange(DateTime start, DateTime end) async {
    final reports = await getAllReports();
    return reports.where((r) => 
      r.createdAt.isAfter(start) && r.createdAt.isBefore(end)
    ).toList();
  }
  
  /// Get reports created this month
  Future<List<LSRReport>> getThisMonthReports() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    return getReportsByDateRange(startOfMonth, endOfMonth);
  }
  
  /// Get dashboard statistics
  Future<DashboardStats> getDashboardStats() async {
    final allReports = await getAllReports();
    final thisMonthReports = await getThisMonthReports();
    
    // Count by status
    final draftCount = allReports.where((r) => r.status == LSRStatus.draft).length;
    final completedCount = allReports.where((r) => r.status == LSRStatus.completed).length;
    final submittedCount = allReports.where((r) => r.status == LSRStatus.submitted).length;
    final discrepancyCount = allReports.where((r) => r.status == LSRStatus.discrepancyFound).length;
    
    // Bank-wise count
    final Map<String, int> bankWiseCount = {};
    for (var report in allReports) {
      bankWiseCount[report.bankId] = (bankWiseCount[report.bankId] ?? 0) + 1;
    }
    
    // Case type distribution
    final Map<String, int> caseTypeDistribution = {};
    for (var report in allReports) {
      final caseTypeName = report.caseType.displayName;
      caseTypeDistribution[caseTypeName] = (caseTypeDistribution[caseTypeName] ?? 0) + 1;
    }
    
    // Calculate revenue (₹1500 per LSR - sample logic)
    final double monthRevenue = thisMonthReports.length * 1500.0;
    
    return DashboardStats(
      totalLSRs: allReports.length,
      draftLSRs: draftCount,
      completedLSRs: completedCount,
      submittedLSRs: submittedCount,
      discrepancyLSRs: discrepancyCount,
      thisMonthLSRs: thisMonthReports.length,
      thisMonthRevenue: monthRevenue,
      bankWiseCount: bankWiseCount,
      caseTypeDistribution: caseTypeDistribution,
    );
  }
  
  /// Search reports
  Future<List<LSRReport>> searchReports(String query) async {
    final reports = await getAllReports();
    if (query.isEmpty) return reports;
    
    final lowerQuery = query.toLowerCase();
    return reports.where((report) =>
      report.applicantName.toLowerCase().contains(lowerQuery) ||
      report.loanId.toLowerCase().contains(lowerQuery) ||
      report.presentOwner.toLowerCase().contains(lowerQuery)
    ).toList();
  }
  
  /// Clear all reports (for testing)
  Future<void> clearAllReports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyReports);
    await prefs.remove(_keyCounter);
    _cachedReports = null;
  }
  
  /// Clear cache
  void clearCache() {
    _cachedReports = null;
  }
  
  // Private helper methods
  
  Future<void> _saveReports(List<LSRReport> reports) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(reports.map((r) => r.toJson()).toList());
    await prefs.setString(_keyReports, jsonString);
    _cachedReports = reports;
  }
  
  Future<String> _generateId() async {
    final prefs = await SharedPreferences.getInstance();
    int counter = prefs.getInt(_keyCounter) ?? 1000;
    counter++;
    await prefs.setInt(_keyCounter, counter);
    
    final now = DateTime.now();
    return 'LSR${now.year}${now.month.toString().padLeft(2, '0')}${counter.toString().padLeft(4, '0')}';
  }
}