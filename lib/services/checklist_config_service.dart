// services/checklist_config_service.dart

import '../models/lsr_models.dart';

/// Service that generates dynamic checklists based on:
/// - Bank
/// - LSR Format
/// - Case Type
/// - Property Type
class ChecklistConfigService {
  
  /// Generate checklist based on configuration
  static List<ChecklistItem> generateChecklist({
    required LSRFormat format,
    required CaseType caseType,
    required PropertyType propertyType,
    String? bankId,
  }) {
    List<ChecklistItem> checklist = [];
    
    // Base documents (always required)
    checklist.addAll(_getBaseDocuments(propertyType));
    
    // Case-type specific documents
    checklist.addAll(_getCaseTypeDocuments(caseType));
    
    // Format-specific documents
    checklist.addAll(_getFormatSpecificDocuments(format));
    
    // Property-type specific documents
    checklist.addAll(_getPropertyTypeDocuments(propertyType));
    
    // Bank-specific documents (if applicable)
    if (bankId != null) {
      checklist.addAll(_getBankSpecificDocuments(bankId, format));
    }
    
    // Sort by order and assign proper IDs
    checklist.sort((a, b) => a.order.compareTo(b.order));
    
    return checklist;
  }
  
  /// Base documents required for all LSRs
  static List<ChecklistItem> _getBaseDocuments(PropertyType propertyType) {
    final baseDocuments = <ChecklistItem>[
      ChecklistItem(
        id: 'base_001',
        documentName: 'Jamabandi (Latest Revenue Record)',
        isMandatory: true,
        order: 1,
        categoryTag: 'Revenue Records',
      ),
      ChecklistItem(
        id: 'base_002',
        documentName: 'Patta/Mother Title Deed',
        isMandatory: true,
        order: 2,
        categoryTag: 'Title Documents',
      ),
      ChecklistItem(
        id: 'base_003',
        documentName: 'Mutation Record (Intiqal)',
        isMandatory: true,
        order: 3,
        categoryTag: 'Revenue Records',
      ),
      ChecklistItem(
        id: 'base_004',
        documentName: 'Encumbrance Certificate (13/15 years)',
        isMandatory: true,
        order: 4,
        categoryTag: 'Legal Documents',
      ),
      ChecklistItem(
        id: 'base_005',
        documentName: 'Chain of Title Documents',
        isMandatory: true,
        order: 5,
        categoryTag: 'Title Documents',
      ),
    ];
    
    // Add agricultural-specific base document
    if (propertyType == PropertyType.agricultural) {
      baseDocuments.add(
        ChecklistItem(
          id: 'base_006',
          documentName: 'Fard Jamabandi (Latest)',
          isMandatory: true,
          order: 6,
          categoryTag: 'Revenue Records',
        ),
      );
    }
    
    return baseDocuments;
  }
  
  /// Documents specific to case type
  static List<ChecklistItem> _getCaseTypeDocuments(CaseType caseType) {
    switch (caseType) {
      case CaseType.purchase:
        return [
          ChecklistItem(
            id: 'case_001',
            documentName: 'Agreement to Sale (ATS)',
            isMandatory: true,
            order: 10,
            categoryTag: 'Transaction Documents',
          ),
          ChecklistItem(
            id: 'case_002',
            documentName: 'Possession Letter/Receipt',
            isMandatory: false,
            order: 11,
            categoryTag: 'Transaction Documents',
          ),
          ChecklistItem(
            id: 'case_003',
            documentName: 'Registered Sale Deed (Previous Owner)',
            isMandatory: true,
            order: 12,
            categoryTag: 'Title Documents',
          ),
        ];
        
      case CaseType.loanAgainstProperty:
        return [
          ChecklistItem(
            id: 'case_004',
            documentName: 'Original Registered Sale Deed',
            isMandatory: true,
            order: 10,
            categoryTag: 'Title Documents',
          ),
          ChecklistItem(
            id: 'case_005',
            documentName: 'Property Tax Receipts (Latest)',
            isMandatory: true,
            order: 11,
            categoryTag: 'Tax Documents',
          ),
          ChecklistItem(
            id: 'case_006',
            documentName: 'Possession Proof',
            isMandatory: true,
            order: 12,
            categoryTag: 'Possession Documents',
          ),
        ];
    }
  }
  
  /// Format-specific documents
  static List<ChecklistItem> _getFormatSpecificDocuments(LSRFormat format) {
    switch (format) {
      case LSRFormat.standard:
        return [
          ChecklistItem(
            id: 'format_001',
            documentName: 'Site Plan/Layout Plan',
            isMandatory: false,
            order: 20,
            categoryTag: 'Site Documents',
          ),
          ChecklistItem(
            id: 'format_002',
            documentName: 'Previous Search Report (if any)',
            isMandatory: false,
            order: 21,
            categoryTag: 'Legal Documents',
          ),
        ];
        
      case LSRFormat.bankDetailed:
        return [
          ChecklistItem(
            id: 'format_003',
            documentName: 'Site Plan/Layout Plan',
            isMandatory: true,
            order: 20,
            categoryTag: 'Site Documents',
          ),
          ChecklistItem(
            id: 'format_004',
            documentName: 'Previous Search Report (if any)',
            isMandatory: false,
            order: 21,
            categoryTag: 'Legal Documents',
          ),
          ChecklistItem(
            id: 'format_005',
            documentName: 'Registered Power of Attorney (if applicable)',
            isMandatory: false,
            order: 22,
            categoryTag: 'Authorization Documents',
          ),
          ChecklistItem(
            id: 'format_006',
            documentName: 'Will/Testament (if applicable)',
            isMandatory: false,
            order: 23,
            categoryTag: 'Legal Documents',
          ),
          ChecklistItem(
            id: 'format_007',
            documentName: 'Court Orders/Decrees (if any)',
            isMandatory: false,
            order: 24,
            categoryTag: 'Legal Documents',
          ),
          ChecklistItem(
            id: 'format_008',
            documentName: 'Succession Certificate (if applicable)',
            isMandatory: false,
            order: 25,
            categoryTag: 'Legal Documents',
          ),
          ChecklistItem(
            id: 'format_009',
            documentName: 'Legal Heir Certificate (if applicable)',
            isMandatory: false,
            order: 26,
            categoryTag: 'Legal Documents',
          ),
          ChecklistItem(
            id: 'format_010',
            documentName: 'Development Agreement (if any)',
            isMandatory: false,
            order: 27,
            categoryTag: 'Transaction Documents',
          ),
          ChecklistItem(
            id: 'format_011',
            documentName: 'Electricity Bill/Connection Proof',
            isMandatory: false,
            order: 28,
            categoryTag: 'Utility Documents',
          ),
          ChecklistItem(
            id: 'format_012',
            documentName: 'Building Plan Approval',
            isMandatory: false,
            order: 29,
            categoryTag: 'Approval Documents',
          ),
        ];
        
      case LSRFormat.minimal:
        return [
          ChecklistItem(
            id: 'format_013',
            documentName: 'Identity Proof of Owner',
            isMandatory: true,
            order: 20,
            categoryTag: 'Identification',
          ),
        ];
    }
  }
  
  /// Property-type specific documents
  static List<ChecklistItem> _getPropertyTypeDocuments(PropertyType propertyType) {
    switch (propertyType) {
      case PropertyType.agricultural:
        return [
          ChecklistItem(
            id: 'prop_001',
            documentName: 'Conversion Certificate (if converted)',
            isMandatory: false,
            order: 30,
            categoryTag: 'Land Documents',
          ),
          ChecklistItem(
            id: 'prop_002',
            documentName: 'Non-Agricultural (NA) Order',
            isMandatory: false,
            order: 31,
            categoryTag: 'Land Documents',
          ),
          ChecklistItem(
            id: 'prop_003',
            documentName: '8-A Certificate (Rajasthan)',
            isMandatory: false,
            order: 32,
            categoryTag: 'Revenue Documents',
          ),
        ];
        
      case PropertyType.residential:
      case PropertyType.commercial:
        return [
          ChecklistItem(
            id: 'prop_004',
            documentName: 'Occupancy Certificate',
            isMandatory: false,
            order: 30,
            categoryTag: 'Building Documents',
          ),
          ChecklistItem(
            id: 'prop_005',
            documentName: 'Completion Certificate',
            isMandatory: false,
            order: 31,
            categoryTag: 'Building Documents',
          ),
          ChecklistItem(
            id: 'prop_006',
            documentName: 'Society NOC (if applicable)',
            isMandatory: false,
            order: 32,
            categoryTag: 'Approval Documents',
          ),
        ];
        
      case PropertyType.plotLand:
        return [
          ChecklistItem(
            id: 'prop_007',
            documentName: 'Layout Plan Approval',
            isMandatory: true,
            order: 30,
            categoryTag: 'Planning Documents',
          ),
          ChecklistItem(
            id: 'prop_008',
            documentName: 'Zoning Certificate',
            isMandatory: false,
            order: 31,
            categoryTag: 'Planning Documents',
          ),
        ];
        
      case PropertyType.industrial:
        return [
          ChecklistItem(
            id: 'prop_009',
            documentName: 'Industrial License',
            isMandatory: false,
            order: 30,
            categoryTag: 'License Documents',
          ),
          ChecklistItem(
            id: 'prop_010',
            documentName: 'Pollution Clearance',
            isMandatory: false,
            order: 31,
            categoryTag: 'Environmental Documents',
          ),
        ];
    }
  }
  
  /// Bank-specific documents
  static List<ChecklistItem> _getBankSpecificDocuments(String bankId, LSRFormat format) {
    // This can be extended based on specific bank requirements
    // For now, returning HDFC/SBI specific requirements
    
    if (bankId.contains('hdfc') || bankId.contains('HDFC')) {
      return [
        ChecklistItem(
          id: 'bank_hdfc_001',
          documentName: 'HDFC Technical Valuation Report',
          isMandatory: format == LSRFormat.bankDetailed,
          order: 40,
          categoryTag: 'Bank Documents',
        ),
        ChecklistItem(
          id: 'bank_hdfc_002',
          documentName: 'Bank Sanctioned Letter Copy',
          isMandatory: false,
          order: 41,
          categoryTag: 'Bank Documents',
        ),
      ];
    }
    
    if (bankId.contains('sbi') || bankId.contains('SBI')) {
      return [
        ChecklistItem(
          id: 'bank_sbi_001',
          documentName: 'SBI Valuation Report',
          isMandatory: format == LSRFormat.bankDetailed,
          order: 40,
          categoryTag: 'Bank Documents',
        ),
        ChecklistItem(
          id: 'bank_sbi_002',
          documentName: 'SBI Loan Application Copy',
          isMandatory: false,
          order: 41,
          categoryTag: 'Bank Documents',
        ),
      ];
    }
    
    return [];
  }
  
  /// Get checklist summary statistics
  static Map<String, int> getChecklistStats(List<ChecklistItem> checklist) {
    int total = checklist.length;
    int mandatory = checklist.where((item) => item.isMandatory).length;
    int optional = total - mandatory;
    int available = checklist.where((item) => item.status == DocumentStatus.available).length;
    int notAvailable = checklist.where((item) => item.status == DocumentStatus.notAvailable).length;
    int na = checklist.where((item) => item.status == DocumentStatus.na).length;
    
    return {
      'total': total,
      'mandatory': mandatory,
      'optional': optional,
      'available': available,
      'notAvailable': notAvailable,
      'na': na,
    };
  }
  
  /// Group checklist by category
  static Map<String, List<ChecklistItem>> groupByCategory(List<ChecklistItem> checklist) {
    Map<String, List<ChecklistItem>> grouped = {};
    
    for (var item in checklist) {
      String category = item.categoryTag ?? 'Other Documents';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(item);
    }
    
    return grouped;
  }
}