// providers/lsr_provider.dart

import 'package:flutter/foundation.dart';
import '../models/lsr_models.dart';
import '../repositories/lsr_repository.dart';
import '../repositories/bank_repository.dart';
import '../services/checklist_config_service.dart';

/// Main provider for LSR operations
/// Handles all business logic and state management
class LSRProvider with ChangeNotifier {
  final LSRRepository _lsrRepository = LSRRepository();
  final BankRepository _bankRepository = BankRepository();
  
  // ═══════════════════════════════════════════════════════════════════════════
  // STATE
  // ═══════════════════════════════════════════════════════════════════════════
  
  List<Bank> _banks = [];
  List<Branch> _branches = [];
  List<LSRReport> _reports = [];
  DashboardStats _dashboardStats = DashboardStats.empty();
  
  bool _isLoading = false;
  String? _error;
  
  // Current LSR being created/edited
  LSRReport? _currentReport;
  Bank? _selectedBank;
  Branch? _selectedBranch;
  LSRFormat? _selectedFormat;
  CaseType? _selectedCaseType;
  PropertyType? _selectedPropertyType;
  List<ChecklistItem> _currentChecklist = [];
  
  // ═══════════════════════════════════════════════════════════════════════════
  // GETTERS
  // ═══════════════════════════════════════════════════════════════════════════
  
  List<Bank> get banks => _banks;
  List<Branch> get branches => _branches;
  List<LSRReport> get reports => _reports;
  DashboardStats get dashboardStats => _dashboardStats;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  LSRReport? get currentReport => _currentReport;
  Bank? get selectedBank => _selectedBank;
  Branch? get selectedBranch => _selectedBranch;
  LSRFormat? get selectedFormat => _selectedFormat;
  CaseType? get selectedCaseType => _selectedCaseType;
  PropertyType? get selectedPropertyType => _selectedPropertyType;
  List<ChecklistItem> get currentChecklist => _currentChecklist;
  
  // Computed properties
  bool get hasSelectedBank => _selectedBank != null;
  bool get hasSelectedBranch => _selectedBranch != null;
  bool get hasSelectedFormat => _selectedFormat != null;
  bool get hasSelectedCaseType => _selectedCaseType != null;
  bool get hasSelectedPropertyType => _selectedPropertyType != null;
  
  bool get canGenerateChecklist => 
      hasSelectedFormat && hasSelectedCaseType && hasSelectedPropertyType;
  
  String get atsRequirementText => _selectedCaseType?.requiresATS ?? false
      ? 'ATS Required'
      : 'ATS Not Required';
  
  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Initialize provider - load banks and reports
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await Future.wait([
        _loadBanks(),
        _loadReports(),
        _loadDashboardStats(),
      ]);
      _error = null;
    } catch (e) {
      _error = 'Failed to initialize: $e';
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> _loadBanks() async {
    _banks = await _bankRepository.getBanks();
  }
  
  Future<void> _loadReports() async {
    _reports = await _lsrRepository.getAllReports();
  }
  
  Future<void> _loadDashboardStats() async {
    _dashboardStats = await _lsrRepository.getDashboardStats();
  }
  
  /// Refresh dashboard stats
  Future<void> refreshDashboard() async {
    _setLoading(true);
    try {
      await Future.wait([
        _loadReports(),
        _loadDashboardStats(),
      ]);
      _error = null;
    } catch (e) {
      _error = 'Failed to refresh: $e';
    } finally {
      _setLoading(false);
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // LSR CREATION FLOW
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Start creating a new LSR
  void startNewLSR() {
    _currentReport = null;
    _selectedBank = null;
    _selectedBranch = null;
    _selectedFormat = null;
    _selectedCaseType = null;
    _selectedPropertyType = null;
    _currentChecklist = [];
    notifyListeners();
  }
  
  /// Select bank and load its branches
  Future<void> selectBank(Bank bank) async {
    _selectedBank = bank;
    _selectedBranch = null; // Reset branch when bank changes
    _branches = await _bankRepository.getBranchesForBank(bank.id);
    notifyListeners();
  }
  
  /// Select branch
  void selectBranch(Branch branch) {
    _selectedBranch = branch;
    notifyListeners();
  }
  
  /// Select LSR format
  void selectFormat(LSRFormat format) {
    _selectedFormat = format;
    _regenerateChecklist();
    notifyListeners();
  }
  
  /// Select case type
  void selectCaseType(CaseType caseType) {
    _selectedCaseType = caseType;
    _regenerateChecklist();
    notifyListeners();
  }
  
  /// Select property type
  void selectPropertyType(PropertyType propertyType) {
    _selectedPropertyType = propertyType;
    _regenerateChecklist();
    notifyListeners();
  }
  
  /// Regenerate checklist based on current selections
  void _regenerateChecklist() {
    if (!canGenerateChecklist) {
      _currentChecklist = [];
      return;
    }
    
    _currentChecklist = ChecklistConfigService.generateChecklist(
      format: _selectedFormat!,
      caseType: _selectedCaseType!,
      propertyType: _selectedPropertyType!,
      bankId: _selectedBank?.id,
    );
  }
  
  /// Update checklist item status
  void updateChecklistItem(String itemId, DocumentStatus status, {String? remarks}) {
    final index = _currentChecklist.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _currentChecklist[index] = _currentChecklist[index].copyWith(
        status: status,
        remarks: remarks,
      );
      notifyListeners();
    }
  }
  
  /// Create and save LSR report
  Future<LSRReport> createLSRReport({
    required String applicantName,
    required String presentOwner,
    required String loanId,
    String? coApplicantName,
    String? propertyAddress,
    String? surveyNumber,
    String? plotArea,
    String? marketValue,
    Map<String, dynamic>? uploadedDocuments,
  }) async {
    if (_selectedBank == null || 
        _selectedBranch == null || 
        _selectedFormat == null ||
        _selectedCaseType == null ||
        _selectedPropertyType == null) {
      throw Exception('Please complete all required selections');
    }
    
    _setLoading(true);
    try {
      final report = LSRReport(
        id: '', // Will be generated by repository
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        bankId: _selectedBank!.id,
        branchId: _selectedBranch!.id,
        format: _selectedFormat!,
        caseType: _selectedCaseType!,
        propertyType: _selectedPropertyType!,
        applicantName: applicantName,
        coApplicantName: coApplicantName,
        presentOwner: presentOwner,
        loanId: loanId,
        propertyAddress: propertyAddress,
        surveyNumber: surveyNumber,
        plotArea: plotArea,
        marketValue: marketValue,
        checklist: _currentChecklist,
        uploadedDocuments: uploadedDocuments,
        status: LSRStatus.draft,
      );
      
      final savedReport = await _lsrRepository.createReport(report);
      _currentReport = savedReport;
      
      await refreshDashboard();
      _error = null;
      
      return savedReport;
    } catch (e) {
      _error = 'Failed to create report: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Update existing LSR report
  Future<LSRReport> updateLSRReport(LSRReport report) async {
    _setLoading(true);
    try {
      final updatedReport = await _lsrRepository.updateReport(report);
      
      // Update in local list
      final index = _reports.indexWhere((r) => r.id == report.id);
      if (index != -1) {
        _reports[index] = updatedReport;
      }
      
      await refreshDashboard();
      _error = null;
      
      return updatedReport;
    } catch (e) {
      _error = 'Failed to update report: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Update report status
  Future<void> updateReportStatus(String reportId, LSRStatus newStatus) async {
    final report = await _lsrRepository.getReportById(reportId);
    if (report != null) {
      await updateLSRReport(report.copyWith(status: newStatus));
    }
  }
  
  /// Delete report
  Future<void> deleteReport(String reportId) async {
    _setLoading(true);
    try {
      await _lsrRepository.deleteReport(reportId);
      _reports.removeWhere((r) => r.id == reportId);
      await refreshDashboard();
      _error = null;
    } catch (e) {
      _error = 'Failed to delete report: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // FILTERING & SEARCH
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Get reports by status
  List<LSRReport> getReportsByStatus(LSRStatus status) {
    return _reports.where((r) => r.status == status).toList();
  }
  
  /// Get reports by bank
  List<LSRReport> getReportsByBank(String bankId) {
    return _reports.where((r) => r.bankId == bankId).toList();
  }
  
  /// Search reports
  Future<List<LSRReport>> searchReports(String query) async {
    return _lsrRepository.searchReports(query);
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Get bank name by ID
  String getBankName(String bankId) {
    try {
      return _banks.firstWhere((b) => b.id == bankId).name;
    } catch (e) {
      return 'Unknown Bank';
    }
  }
  
  /// Get branch name by ID
  String getBranchName(String branchId) {
    try {
      return _branches.firstWhere((b) => b.id == branchId).displayName;
    } catch (e) {
      return 'Unknown Branch';
    }
  }
  
  /// Get checklist statistics
  Map<String, int> getChecklistStats() {
    return ChecklistConfigService.getChecklistStats(_currentChecklist);
  }
  
  /// Get grouped checklist
  Map<String, List<ChecklistItem>> getGroupedChecklist() {
    return ChecklistConfigService.groupByCategory(_currentChecklist);
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  /// Reset provider (for testing)
  void reset() {
    _banks = [];
    _branches = [];
    _reports = [];
    _dashboardStats = DashboardStats.empty();
    _isLoading = false;
    _error = null;
    _currentReport = null;
    _selectedBank = null;
    _selectedBranch = null;
    _selectedFormat = null;
    _selectedCaseType = null;
    _selectedPropertyType = null;
    _currentChecklist = [];
    notifyListeners();
  }
}