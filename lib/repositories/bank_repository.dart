// repositories/bank_repository.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/lsr_models.dart';

/// Repository for managing banks and branches
/// Currently uses local JSON, designed to be easily replaceable with API/Firebase
class BankRepository {
  static BankRepository? _instance;
  factory BankRepository() => _instance ??= BankRepository._();
  BankRepository._();
  
  List<Bank>? _cachedBanks;
  List<Branch>? _cachedBranches;
  
  /// Load banks from JSON
  Future<List<Bank>> getBanks() async {
    if (_cachedBanks != null) return _cachedBanks!;
    
    try {
      final jsonString = await rootBundle.loadString('assets/data/banks.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      _cachedBanks = jsonData.map((json) => Bank.fromJson(json)).toList();
      return _cachedBanks!;
    } catch (e) {
      // If JSON doesn't exist, return hardcoded data
      _cachedBanks = _getHardcodedBanks();
      return _cachedBanks!;
    }
  }
  
  /// Load branches from JSON
  Future<List<Branch>> getAllBranches() async {
    if (_cachedBranches != null) return _cachedBranches!;
    
    try {
      final jsonString = await rootBundle.loadString('assets/data/branches.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      _cachedBranches = jsonData.map((json) => Branch.fromJson(json)).toList();
      return _cachedBranches!;
    } catch (e) {
      // If JSON doesn't exist, return hardcoded data
      _cachedBranches = _getHardcodedBranches();
      return _cachedBranches!;
    }
  }
  
  /// Get branches for a specific bank
  Future<List<Branch>> getBranchesForBank(String bankId) async {
    final allBranches = await getAllBranches();
    return allBranches.where((branch) => branch.bankId == bankId).toList();
  }
  
  /// Get bank by ID
  Future<Bank?> getBankById(String bankId) async {
    final banks = await getBanks();
    try {
      return banks.firstWhere((bank) => bank.id == bankId);
    } catch (e) {
      return null;
    }
  }
  
  /// Get branch by ID
  Future<Branch?> getBranchById(String branchId) async {
    final branches = await getAllBranches();
    try {
      return branches.firstWhere((branch) => branch.id == branchId);
    } catch (e) {
      return null;
    }
  }
  
  /// Search banks by name
  Future<List<Bank>> searchBanks(String query) async {
    final banks = await getBanks();
    if (query.isEmpty) return banks;
    
    return banks.where((bank) =>
      bank.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
  
  /// Search branches by name or district
  Future<List<Branch>> searchBranches(String query, {String? bankId}) async {
    final branches = bankId != null 
      ? await getBranchesForBank(bankId)
      : await getAllBranches();
    
    if (query.isEmpty) return branches;
    
    return branches.where((branch) =>
      branch.name.toLowerCase().contains(query.toLowerCase()) ||
      branch.district.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
  
  /// Clear cache (useful when data is updated)
  void clearCache() {
    _cachedBanks = null;
    _cachedBranches = null;
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // HARDCODED DATA (Fallback)
  // ═══════════════════════════════════════════════════════════════════════════
  
  List<Bank> _getHardcodedBanks() {
    return [
      Bank(
        id: 'bank_sbi',
        name: 'State Bank of India',
        supportedFormats: ['standard', 'bankDetailed', 'minimal'],
      ),
      Bank(
        id: 'bank_hdfc',
        name: 'HDFC Bank',
        supportedFormats: ['standard', 'bankDetailed', 'minimal'],
      ),
      Bank(
        id: 'bank_icici',
        name: 'ICICI Bank',
        supportedFormats: ['standard', 'bankDetailed', 'minimal'],
      ),
      Bank(
        id: 'bank_pnb',
        name: 'Punjab National Bank',
        supportedFormats: ['standard', 'bankDetailed', 'minimal'],
      ),
      Bank(
        id: 'bank_bob',
        name: 'Bank of Baroda',
        supportedFormats: ['standard', 'bankDetailed', 'minimal'],
      ),
      Bank(
        id: 'bank_axis',
        name: 'Axis Bank',
        supportedFormats: ['standard', 'bankDetailed', 'minimal'],
      ),
    ];
  }
  
  List<Branch> _getHardcodedBranches() {
    return [
      // SBI Branches
      Branch(id: 'branch_sbi_001', name: 'MAIN BRANCH', bankId: 'bank_sbi', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_002', name: 'MI ROAD', bankId: 'bank_sbi', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_003', name: 'MALVIYA NAGAR', bankId: 'bank_sbi', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_004', name: 'VAISHALI NAGAR', bankId: 'bank_sbi', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_005', name: 'MANSAROVAR', bankId: 'bank_sbi', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_006', name: 'C-SCHEME', bankId: 'bank_sbi', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_007', name: 'TONK ROAD', bankId: 'bank_sbi', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_008', name: 'RAJA PARK', bankId: 'bank_sbi', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_009', name: 'SINDHI CAMP', bankId: 'bank_sbi', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_010', name: 'BAPU NAGAR', bankId: 'bank_sbi', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_011', name: 'SODALA', bankId: 'bank_sbi', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_012', name: 'VIDYADHAR NAGAR', bankId: 'bank_sbi', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_013', name: 'SITAPURA INDUSTRIAL AREA', bankId: 'bank_sbi', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_014', name: 'SANGANER', bankId: 'bank_sbi', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_015', name: 'JAGATPURA', bankId: 'bank_sbi', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_016', name: 'PRATAP NAGAR', bankId: 'bank_sbi', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_017', name: 'GOPALPURA BYPASS', bankId: 'bank_sbi', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_018', name: 'JOHRI BAZAR', bankId: 'bank_sbi', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_019', name: 'MAIN BRANCH', bankId: 'bank_sbi', district: 'JODHPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_020', name: 'SARDARPURA', bankId: 'bank_sbi', district: 'JODHPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_021', name: 'PAOTA', bankId: 'bank_sbi', district: 'JODHPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_022', name: 'SHASTRI NAGAR', bankId: 'bank_sbi', district: 'JODHPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_023', name: 'RATANADA', bankId: 'bank_sbi', district: 'JODHPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_024', name: 'CHOPASANI ROAD', bankId: 'bank_sbi', district: 'JODHPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_025', name: 'MAIN BRANCH', bankId: 'bank_sbi', district: 'UDAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_026', name: 'CHETAK CIRCLE', bankId: 'bank_sbi', district: 'UDAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_027', name: 'HIRAN MAGRI', bankId: 'bank_sbi', district: 'UDAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_028', name: 'SUKHADIA CIRCLE', bankId: 'bank_sbi', district: 'UDAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_029', name: 'MAIN BRANCH', bankId: 'bank_sbi', district: 'KOTA', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_030', name: 'DADABARI', bankId: 'bank_sbi', district: 'KOTA', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_031', name: 'TALWANDI', bankId: 'bank_sbi', district: 'KOTA', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_032', name: 'VIGYAN NAGAR', bankId: 'bank_sbi', district: 'KOTA', state: 'Rajasthan'),
      Branch(id: 'branch_sbi_033', name: 'GUMANPURA', bankId: 'bank_sbi', district: 'KOTA', state: 'Rajasthan'),
      
      // HDFC Branches
      Branch(id: 'branch_hdfc_001', name: 'ASHOK MARG', bankId: 'bank_hdfc', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_hdfc_002', name: 'MI ROAD', bankId: 'bank_hdfc', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_hdfc_003', name: 'MALVIYA NAGAR', bankId: 'bank_hdfc', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_hdfc_004', name: 'VAISHALI NAGAR', bankId: 'bank_hdfc', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_hdfc_005', name: 'MANSAROVAR', bankId: 'bank_hdfc', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_hdfc_006', name: 'C-SCHEME', bankId: 'bank_hdfc', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_hdfc_007', name: 'TONK ROAD', bankId: 'bank_hdfc', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_hdfc_008', name: 'RAJA PARK', bankId: 'bank_hdfc', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_hdfc_009', name: 'SITAPURA', bankId: 'bank_hdfc', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_hdfc_010', name: 'JAGATPURA', bankId: 'bank_hdfc', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_hdfc_011', name: 'VIDHYADHAR NAGAR', bankId: 'bank_hdfc', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_hdfc_012', name: 'AJMER ROAD', bankId: 'bank_hdfc', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_hdfc_013', name: 'SARDARPURA', bankId: 'bank_hdfc', district: 'JODHPUR', state: 'Rajasthan'),
      Branch(id: 'branch_hdfc_014', name: 'PAOTA', bankId: 'bank_hdfc', district: 'JODHPUR', state: 'Rajasthan'),
      Branch(id: 'branch_hdfc_015', name: 'HIGH COURT ROAD', bankId: 'bank_hdfc', district: 'JODHPUR', state: 'Rajasthan'),
      Branch(id: 'branch_hdfc_016', name: 'CHETAK CIRCLE', bankId: 'bank_hdfc', district: 'UDAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_hdfc_017', name: 'HIRAN MAGRI', bankId: 'bank_hdfc', district: 'UDAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_hdfc_018', name: 'DADABARI', bankId: 'bank_hdfc', district: 'KOTA', state: 'Rajasthan'),
      Branch(id: 'branch_hdfc_019', name: 'TALWANDI', bankId: 'bank_hdfc', district: 'KOTA', state: 'Rajasthan'),
      
      // ICICI Branches
      Branch(id: 'branch_icici_001', name: 'MI ROAD', bankId: 'bank_icici', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_icici_002', name: 'MALVIYA NAGAR', bankId: 'bank_icici', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_icici_003', name: 'VAISHALI NAGAR', bankId: 'bank_icici', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_icici_004', name: 'MANSAROVAR', bankId: 'bank_icici', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_icici_005', name: 'C-SCHEME', bankId: 'bank_icici', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_icici_006', name: 'TONK ROAD', bankId: 'bank_icici', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_icici_007', name: 'RAJA PARK', bankId: 'bank_icici', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_icici_008', name: 'JAGATPURA', bankId: 'bank_icici', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_icici_009', name: 'SITAPURA', bankId: 'bank_icici', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_icici_010', name: 'VIDHYADHAR NAGAR', bankId: 'bank_icici', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_icici_011', name: 'SARDARPURA', bankId: 'bank_icici', district: 'JODHPUR', state: 'Rajasthan'),
      Branch(id: 'branch_icici_012', name: 'PAOTA', bankId: 'bank_icici', district: 'JODHPUR', state: 'Rajasthan'),
      Branch(id: 'branch_icici_013', name: 'CHETAK CIRCLE', bankId: 'bank_icici', district: 'UDAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_icici_014', name: 'HIRAN MAGRI', bankId: 'bank_icici', district: 'UDAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_icici_015', name: 'DADABARI', bankId: 'bank_icici', district: 'KOTA', state: 'Rajasthan'),
      Branch(id: 'branch_icici_016', name: 'TALWANDI', bankId: 'bank_icici', district: 'KOTA', state: 'Rajasthan'),
      
      // PNB Branches
      Branch(id: 'branch_pnb_001', name: 'MAIN BRANCH', bankId: 'bank_pnb', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_pnb_002', name: 'MI ROAD', bankId: 'bank_pnb', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_pnb_003', name: 'MALVIYA NAGAR', bankId: 'bank_pnb', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_pnb_004', name: 'VAISHALI NAGAR', bankId: 'bank_pnb', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_pnb_005', name: 'MANSAROVAR', bankId: 'bank_pnb', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_pnb_006', name: 'TONK ROAD', bankId: 'bank_pnb', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_pnb_007', name: 'RAJA PARK', bankId: 'bank_pnb', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_pnb_008', name: 'SINDHI CAMP', bankId: 'bank_pnb', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_pnb_009', name: 'SARDARPURA', bankId: 'bank_pnb', district: 'JODHPUR', state: 'Rajasthan'),
      Branch(id: 'branch_pnb_010', name: 'PAOTA', bankId: 'bank_pnb', district: 'JODHPUR', state: 'Rajasthan'),
      Branch(id: 'branch_pnb_011', name: 'CHETAK CIRCLE', bankId: 'bank_pnb', district: 'UDAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_pnb_012', name: 'DADABARI', bankId: 'bank_pnb', district: 'KOTA', state: 'Rajasthan'),
      
      // Bank of Baroda Branches
      Branch(id: 'branch_bob_001', name: 'MAIN BRANCH', bankId: 'bank_bob', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_bob_002', name: 'MI ROAD', bankId: 'bank_bob', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_bob_003', name: 'MALVIYA NAGAR', bankId: 'bank_bob', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_bob_004', name: 'VAISHALI NAGAR', bankId: 'bank_bob', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_bob_005', name: 'MANSAROVAR', bankId: 'bank_bob', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_bob_006', name: 'TONK ROAD', bankId: 'bank_bob', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_bob_007', name: 'SITAPURA', bankId: 'bank_bob', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_bob_008', name: 'SARDARPURA', bankId: 'bank_bob', district: 'JODHPUR', state: 'Rajasthan'),
      Branch(id: 'branch_bob_009', name: 'PAOTA', bankId: 'bank_bob', district: 'JODHPUR', state: 'Rajasthan'),
      Branch(id: 'branch_bob_010', name: 'CHETAK CIRCLE', bankId: 'bank_bob', district: 'UDAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_bob_011', name: 'HIRAN MAGRI', bankId: 'bank_bob', district: 'UDAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_bob_012', name: 'DADABARI', bankId: 'bank_bob', district: 'KOTA', state: 'Rajasthan'),
      Branch(id: 'branch_bob_013', name: 'TALWANDI', bankId: 'bank_bob', district: 'KOTA', state: 'Rajasthan'),
      
      // Axis Bank Branches
      Branch(id: 'branch_axis_001', name: 'ASHOK MARG', bankId: 'bank_axis', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_axis_002', name: 'MI ROAD', bankId: 'bank_axis', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_axis_003', name: 'MALVIYA NAGAR', bankId: 'bank_axis', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_axis_004', name: 'VAISHALI NAGAR', bankId: 'bank_axis', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_axis_005', name: 'MANSAROVAR', bankId: 'bank_axis', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_axis_006', name: 'TONK ROAD', bankId: 'bank_axis', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_axis_007', name: 'RAJA PARK', bankId: 'bank_axis', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_axis_008', name: 'JAGATPURA', bankId: 'bank_axis', district: 'JAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_axis_009', name: 'SARDARPURA', bankId: 'bank_axis', district: 'JODHPUR', state: 'Rajasthan'),
      Branch(id: 'branch_axis_010', name: 'PAOTA', bankId: 'bank_axis', district: 'JODHPUR', state: 'Rajasthan'),
      Branch(id: 'branch_axis_011', name: 'CHETAK CIRCLE', bankId: 'bank_axis', district: 'UDAIPUR', state: 'Rajasthan'),
      Branch(id: 'branch_axis_012', name: 'DADABARI', bankId: 'bank_axis', district: 'KOTA', state: 'Rajasthan'),
    ];
  }
}