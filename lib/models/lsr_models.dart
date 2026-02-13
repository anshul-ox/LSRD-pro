// models/lsr_models.dart

import 'package:flutter/foundation.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ENUMS
// ═══════════════════════════════════════════════════════════════════════════

/// LSR Format Types
enum LSRFormat {
  standard('Standard LSR', 'Comprehensive standard format'),
  bankDetailed(
    'Detailed Bank-Specific',
    'Extended checklist with bank requirements',
  ),
  minimal('Minimal Scrutiny', 'Quick verification format');

  final String displayName;
  final String description;
  const LSRFormat(this.displayName, this.description);
}

/// Case Types with business logic implications
enum CaseType {
  purchase('Purchase Case', 'Buying property from seller', true),
  loanAgainstProperty('Loan Against Property', 'LAP - Own property', false);

  final String displayName;
  final String description;
  final bool requiresATS; // Agreement to Sale requirement
  const CaseType(this.displayName, this.description, this.requiresATS);
}

/// Property Types
enum PropertyType {
  residential('Residential'),
  commercial('Commercial'),
  agricultural('Agricultural Land'),
  industrial('Industrial'),
  plotLand('Plot/Land');

  final String displayName;
  const PropertyType(this.displayName);
}

/// Document Status
enum DocumentStatus {
  available('Available'),
  notAvailable('Not Available'),
  na('N/A');

  final String displayName;
  const DocumentStatus(this.displayName);
}

/// LSR Report Status
enum LSRStatus {
  draft('Draft'),
  documentsUploaded('Documents Uploaded'),
  aiProcessing('AI Processing'),
  inReview('In Review'),
  completed('Completed'),
  submitted('Submitted'),
  discrepancyFound('Discrepancy Found');

  final String displayName;
  const LSRStatus(this.displayName);
}

// ═══════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════════════

/// Bank Model
class Bank {
  final String id;
  final String name;
  final String? logoUrl;
  final List<String> supportedFormats; // Which LSR formats this bank supports
  final bool isActive;

  Bank({
    required this.id,
    required this.name,
    this.logoUrl,
    List<String>? supportedFormats,
    this.isActive = true,
  }) : supportedFormats =
           supportedFormats ?? ['standard', 'bankDetailed', 'minimal'];

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String?,
      supportedFormats: (json['supportedFormats'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'supportedFormats': supportedFormats,
      'isActive': isActive,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bank && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Branch Model
class Branch {
  final String id;
  final String name;
  final String bankId;
  final String district;
  final String? city;
  final String? state;
  final String? ifscCode;
  final bool isActive;

  Branch({
    required this.id,
    required this.name,
    required this.bankId,
    required this.district,
    this.city,
    this.state,
    this.ifscCode,
    this.isActive = true,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] as String,
      name: json['name'] as String,
      bankId: json['bankId'] as String,
      district: json['district'] as String,
      city: json['city'] as String?,
      state: json['state'] as String?,
      ifscCode: json['ifscCode'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bankId': bankId,
      'district': district,
      'city': city,
      'state': state,
      'ifscCode': ifscCode,
      'isActive': isActive,
    };
  }

  String get displayName => '$name, $district';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Branch && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Checklist Item Model
class ChecklistItem {
  final String id;
  final String documentName;
  final bool isMandatory;
  final DocumentStatus status;
  final String? remarks;
  final int order; // Display order
  final String? categoryTag; // For grouping

  ChecklistItem({
    required this.id,
    required this.documentName,
    this.isMandatory = true,
    this.status = DocumentStatus.available,
    this.remarks,
    required this.order,
    this.categoryTag,
  });

  ChecklistItem copyWith({
    String? id,
    String? documentName,
    bool? isMandatory,
    DocumentStatus? status,
    String? remarks,
    int? order,
    String? categoryTag,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      documentName: documentName ?? this.documentName,
      isMandatory: isMandatory ?? this.isMandatory,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      order: order ?? this.order,
      categoryTag: categoryTag ?? this.categoryTag,
    );
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as String,
      documentName: json['documentName'] as String,
      isMandatory: json['isMandatory'] as bool? ?? true,
      status: DocumentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DocumentStatus.available,
      ),
      remarks: json['remarks'] as String?,
      order: json['order'] as int,
      categoryTag: json['categoryTag'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentName': documentName,
      'isMandatory': isMandatory,
      'status': status.name,
      'remarks': remarks,
      'order': order,
      'categoryTag': categoryTag,
    };
  }
}

/// LSR Report Model
class LSRReport {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Bank & Branch
  final String bankId;
  final String branchId;

  // Format & Case Type
  final LSRFormat format;
  final CaseType caseType;
  final PropertyType propertyType;

  // Applicant Details
  final String applicantName;
  final String? coApplicantName;
  final String presentOwner;
  final String loanId;

  // Property Details
  final String? propertyAddress;
  final String? surveyNumber;
  final String? plotArea;
  final String? marketValue;

  // Documents & Checklist
  final List<ChecklistItem> checklist;
  final Map<String, dynamic>? uploadedDocuments;

  // AI Generated Data
  final List<OwnershipChainItem>? ownershipChain;
  final String? encumbrances;
  final String? legalStatus;
  final List<String>? observations;
  final String? recommendations;

  // Status
  final LSRStatus status;

  LSRReport({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.bankId,
    required this.branchId,
    required this.format,
    required this.caseType,
    required this.propertyType,
    required this.applicantName,
    this.coApplicantName,
    required this.presentOwner,
    required this.loanId,
    this.propertyAddress,
    this.surveyNumber,
    this.plotArea,
    this.marketValue,
    required this.checklist,
    this.uploadedDocuments,
    this.ownershipChain,
    this.encumbrances,
    this.legalStatus,
    this.observations,
    this.recommendations,
    this.status = LSRStatus.draft,
  });

  LSRReport copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? bankId,
    String? branchId,
    LSRFormat? format,
    CaseType? caseType,
    PropertyType? propertyType,
    String? applicantName,
    String? coApplicantName,
    String? presentOwner,
    String? loanId,
    String? propertyAddress,
    String? surveyNumber,
    String? plotArea,
    String? marketValue,
    List<ChecklistItem>? checklist,
    Map<String, dynamic>? uploadedDocuments,
    List<OwnershipChainItem>? ownershipChain,
    String? encumbrances,
    String? legalStatus,
    List<String>? observations,
    String? recommendations,
    LSRStatus? status,
  }) {
    return LSRReport(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bankId: bankId ?? this.bankId,
      branchId: branchId ?? this.branchId,
      format: format ?? this.format,
      caseType: caseType ?? this.caseType,
      propertyType: propertyType ?? this.propertyType,
      applicantName: applicantName ?? this.applicantName,
      coApplicantName: coApplicantName ?? this.coApplicantName,
      presentOwner: presentOwner ?? this.presentOwner,
      loanId: loanId ?? this.loanId,
      propertyAddress: propertyAddress ?? this.propertyAddress,
      surveyNumber: surveyNumber ?? this.surveyNumber,
      plotArea: plotArea ?? this.plotArea,
      marketValue: marketValue ?? this.marketValue,
      checklist: checklist ?? this.checklist,
      uploadedDocuments: uploadedDocuments ?? this.uploadedDocuments,
      ownershipChain: ownershipChain ?? this.ownershipChain,
      encumbrances: encumbrances ?? this.encumbrances,
      legalStatus: legalStatus ?? this.legalStatus,
      observations: observations ?? this.observations,
      recommendations: recommendations ?? this.recommendations,
      status: status ?? this.status,
    );
  }

  factory LSRReport.fromJson(Map<String, dynamic> json) {
    return LSRReport(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      bankId: json['bankId'] as String,
      branchId: json['branchId'] as String,
      format: LSRFormat.values.firstWhere((e) => e.name == json['format']),
      caseType: CaseType.values.firstWhere((e) => e.name == json['caseType']),
      propertyType: PropertyType.values.firstWhere(
        (e) => e.name == json['propertyType'],
      ),
      applicantName: json['applicantName'] as String,
      coApplicantName: json['coApplicantName'] as String?,
      presentOwner: json['presentOwner'] as String,
      loanId: json['loanId'] as String,
      propertyAddress: json['propertyAddress'] as String?,
      surveyNumber: json['surveyNumber'] as String?,
      plotArea: json['plotArea'] as String?,
      marketValue: json['marketValue'] as String?,
      checklist:
          (json['checklist'] as List<dynamic>?)
              ?.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      uploadedDocuments: json['uploadedDocuments'] as Map<String, dynamic>?,
      ownershipChain: (json['ownershipChain'] as List<dynamic>?)
          ?.map((e) => OwnershipChainItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      encumbrances: json['encumbrances'] as String?,
      legalStatus: json['legalStatus'] as String?,
      observations: (json['observations'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      recommendations: json['recommendations'] as String?,
      status: LSRStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LSRStatus.draft,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'bankId': bankId,
      'branchId': branchId,
      'format': format.name,
      'caseType': caseType.name,
      'propertyType': propertyType.name,
      'applicantName': applicantName,
      'coApplicantName': coApplicantName,
      'presentOwner': presentOwner,
      'loanId': loanId,
      'propertyAddress': propertyAddress,
      'surveyNumber': surveyNumber,
      'plotArea': plotArea,
      'marketValue': marketValue,
      'checklist': checklist.map((e) => e.toJson()).toList(),
      'uploadedDocuments': uploadedDocuments,
      'ownershipChain': ownershipChain?.map((e) => e.toJson()).toList(),
      'encumbrances': encumbrances,
      'legalStatus': legalStatus,
      'observations': observations,
      'recommendations': recommendations,
      'status': status.name,
    };
  }
}

/// Ownership Chain Item
class OwnershipChainItem {
  final String owner;
  final String year;
  final String document;

  OwnershipChainItem({
    required this.owner,
    required this.year,
    required this.document,
  });

  factory OwnershipChainItem.fromJson(Map<String, dynamic> json) {
    return OwnershipChainItem(
      owner: json['owner'] as String,
      year: json['year'] as String,
      document: json['document'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'owner': owner, 'year': year, 'document': document};
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DASHBOARD STATISTICS MODEL
// ═══════════════════════════════════════════════════════════════════════════

class DashboardStats {
  final int totalLSRs;
  final int draftLSRs;
  final int completedLSRs;
  final int submittedLSRs;
  final int discrepancyLSRs;
  final int thisMonthLSRs;
  final double thisMonthRevenue;
  final Map<String, int> bankWiseCount;
  final Map<String, int> caseTypeDistribution;

  DashboardStats({
    required this.totalLSRs,
    required this.draftLSRs,
    required this.completedLSRs,
    required this.submittedLSRs,
    required this.discrepancyLSRs,
    required this.thisMonthLSRs,
    required this.thisMonthRevenue,
    required this.bankWiseCount,
    required this.caseTypeDistribution,
  });

  factory DashboardStats.empty() {
    return DashboardStats(
      totalLSRs: 0,
      draftLSRs: 0,
      completedLSRs: 0,
      submittedLSRs: 0,
      discrepancyLSRs: 0,
      thisMonthLSRs: 0,
      thisMonthRevenue: 0.0,
      bankWiseCount: {},
      caseTypeDistribution: {},
    );
  }
}
