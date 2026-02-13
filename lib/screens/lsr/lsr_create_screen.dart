import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lsrd_pro/core/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lsrd_pro/core/services/api_service.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'lsr_review_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

class LSRCreateScreen extends StatefulWidget {
  const LSRCreateScreen({super.key});

  @override
  State<LSRCreateScreen> createState() => _LSRCreateScreenState();
}

class _LSRCreateScreenState extends State<LSRCreateScreen> {
  int _currentStep = 0;
  final List<String> _steps = [
    'Bank & Branch',
    'Upload Documents',
    'Case Details',
    'AI Processing',
    'Review & Edit',
    'Report',
  ];

  // Form data controllers
  final TextEditingController _applicantNameController =
      TextEditingController();
  final TextEditingController _coApplicantNameController =
      TextEditingController();
  final TextEditingController _presentOwnerController = TextEditingController();
  final TextEditingController _loanIdController = TextEditingController();

  String? _selectedBank;
  String? _selectedBranch;
  String? _selectedReportFormat;
  String? _selectedPropertyType;

  // Rajasthan Bank Branches Data
  final Map<String, List<Map<String, String>>> _rajasthanBranches = {
    'State Bank of India': [
      {'name': 'MAIN BRANCH, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'MI ROAD, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'MALVIYA NAGAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'VAISHALI NAGAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'MANSAROVAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'C-SCHEME, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'TONK ROAD, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'RAJA PARK, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'SINDHI CAMP, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'BAPU NAGAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'SODALA, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'VIDYADHAR NAGAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'SITAPURA INDUSTRIAL AREA, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'SANGANER, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'JAGATPURA, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'PRATAP NAGAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'GOPALPURA BYPASS, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'JOHRI BAZAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'MAIN BRANCH, JODHPUR', 'district': 'JODHPUR'},
      {'name': 'SARDARPURA, JODHPUR', 'district': 'JODHPUR'},
      {'name': 'PAOTA, JODHPUR', 'district': 'JODHPUR'},
      {'name': 'SHASTRI NAGAR, JODHPUR', 'district': 'JODHPUR'},
      {'name': 'RATANADA, JODHPUR', 'district': 'JODHPUR'},
      {'name': 'CHOPASANI ROAD, JODHPUR', 'district': 'JODHPUR'},
      {'name': 'MAIN BRANCH, UDAIPUR', 'district': 'UDAIPUR'},
      {'name': 'CHETAK CIRCLE, UDAIPUR', 'district': 'UDAIPUR'},
      {'name': 'HIRAN MAGRI, UDAIPUR', 'district': 'UDAIPUR'},
      {'name': 'SUKHADIA CIRCLE, UDAIPUR', 'district': 'UDAIPUR'},
      {'name': 'MAIN BRANCH, KOTA', 'district': 'KOTA'},
      {'name': 'DADABARI, KOTA', 'district': 'KOTA'},
      {'name': 'TALWANDI, KOTA', 'district': 'KOTA'},
      {'name': 'VIGYAN NAGAR, KOTA', 'district': 'KOTA'},
      {'name': 'GUMANPURA, KOTA', 'district': 'KOTA'},
      {'name': 'MAIN BRANCH, AJMER', 'district': 'AJMER'},
      {'name': 'VAISHALI NAGAR, AJMER', 'district': 'AJMER'},
      {'name': 'NASIRABAD, AJMER', 'district': 'AJMER'},
      {'name': 'MAIN BRANCH, BIKANER', 'district': 'BIKANER'},
      {'name': 'RANI BAZAR, BIKANER', 'district': 'BIKANER'},
      {'name': 'SADUL GANJ, BIKANER', 'district': 'BIKANER'},
      {'name': 'MAIN BRANCH, ALWAR', 'district': 'ALWAR'},
      {'name': 'BHIWADI, ALWAR', 'district': 'ALWAR'},
      {'name': 'NEEMRANA, ALWAR', 'district': 'ALWAR'},
    ],
    'HDFC Bank': [
      {'name': 'ASHOK MARG, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'MI ROAD, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'MALVIYA NAGAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'VAISHALI NAGAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'MANSAROVAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'C-SCHEME, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'TONK ROAD, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'RAJA PARK, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'SITAPURA, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'JAGATPURA, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'VIDHYADHAR NAGAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'AJMER ROAD, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'SARDARPURA, JODHPUR', 'district': 'JODHPUR'},
      {'name': 'PAOTA, JODHPUR', 'district': 'JODHPUR'},
      {'name': 'HIGH COURT ROAD, JODHPUR', 'district': 'JODHPUR'},
      {'name': 'CHETAK CIRCLE, UDAIPUR', 'district': 'UDAIPUR'},
      {'name': 'HIRAN MAGRI, UDAIPUR', 'district': 'UDAIPUR'},
      {'name': 'DADABARI, KOTA', 'district': 'KOTA'},
      {'name': 'TALWANDI, KOTA', 'district': 'KOTA'},
    ],
    'ICICI Bank': [
      {'name': 'MI ROAD, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'MALVIYA NAGAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'VAISHALI NAGAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'MANSAROVAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'C-SCHEME, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'TONK ROAD, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'RAJA PARK, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'JAGATPURA, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'SITAPURA, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'VIDHYADHAR NAGAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'SARDARPURA, JODHPUR', 'district': 'JODHPUR'},
      {'name': 'PAOTA, JODHPUR', 'district': 'JODHPUR'},
      {'name': 'CHETAK CIRCLE, UDAIPUR', 'district': 'UDAIPUR'},
      {'name': 'HIRAN MAGRI, UDAIPUR', 'district': 'UDAIPUR'},
      {'name': 'DADABARI, KOTA', 'district': 'KOTA'},
      {'name': 'TALWANDI, KOTA', 'district': 'KOTA'},
    ],
    'Punjab National Bank': [
      {'name': 'MAIN BRANCH, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'MI ROAD, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'MALVIYA NAGAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'VAISHALI NAGAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'MANSAROVAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'TONK ROAD, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'RAJA PARK, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'SINDHI CAMP, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'SARDARPURA, JODHPUR', 'district': 'JODHPUR'},
      {'name': 'PAOTA, JODHPUR', 'district': 'JODHPUR'},
      {'name': 'CHETAK CIRCLE, UDAIPUR', 'district': 'UDAIPUR'},
      {'name': 'DADABARI, KOTA', 'district': 'KOTA'},
    ],
    'Bank of Baroda': [
      {'name': 'MAIN BRANCH, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'MI ROAD, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'MALVIYA NAGAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'VAISHALI NAGAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'MANSAROVAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'TONK ROAD, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'SITAPURA, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'SARDARPURA, JODHPUR', 'district': 'JODHPUR'},
      {'name': 'PAOTA, JODHPUR', 'district': 'JODHPUR'},
      {'name': 'CHETAK CIRCLE, UDAIPUR', 'district': 'UDAIPUR'},
      {'name': 'HIRAN MAGRI, UDAIPUR', 'district': 'UDAIPUR'},
      {'name': 'DADABARI, KOTA', 'district': 'KOTA'},
      {'name': 'TALWANDI, KOTA', 'district': 'KOTA'},
    ],
    'Axis Bank': [
      {'name': 'ASHOK MARG, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'MI ROAD, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'MALVIYA NAGAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'VAISHALI NAGAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'MANSAROVAR, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'TONK ROAD, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'RAJA PARK, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'JAGATPURA, JAIPUR', 'district': 'JAIPUR'},
      {'name': 'SARDARPURA, JODHPUR', 'district': 'JODHPUR'},
      {'name': 'PAOTA, JODHPUR', 'district': 'JODHPUR'},
      {'name': 'CHETAK CIRCLE, UDAIPUR', 'district': 'UDAIPUR'},
      {'name': 'DADABARI, KOTA', 'district': 'KOTA'},
    ],
  };

  // Get available branches for selected bank
  List<String> get _availableBranches {
    if (_selectedBank == null ||
        !_rajasthanBranches.containsKey(_selectedBank)) {
      return [];
    }
    return _rajasthanBranches[_selectedBank]!
        .map((branch) => branch['name']!)
        .toList();
  }

  // Get bank names
  List<String> get _bankNames => _rajasthanBranches.keys.toList()..sort();

  // Document upload status with file details
  Map<String, DocumentUpload> _uploadedDocuments = {
    'Jamabandi': DocumentUpload(),
    'Sale Deed': DocumentUpload(),
    'Patta/Mother Title': DocumentUpload(),
    'Mutation Record': DocumentUpload(),
  };

  // AI generated data (mock data for demonstration)
  Map<String, dynamic> _aiGeneratedData = {};

  // Analysis State
  bool _isAnalyzing = false;
  String _analysisStatus = 'Starting analysis...';
  int _progressStep = 0;
  bool _hasError = false;

  @override
  void dispose() {
    _applicantNameController.dispose();
    _coApplicantNameController.dispose();
    _presentOwnerController.dispose();
    _loanIdController.dispose();
    super.dispose();
  }

  Future<void> _startAnalysis() async {
    if (_isAnalyzing) return;

    print("DEBUG: _startAnalysis called. Starting...");

    setState(() {
      _isAnalyzing = true;
      _hasError = false;
      _progressStep = 1;
      _analysisStatus = 'Uploading and extracting data...';
    });

    try {
      // 1. Collect files
      Map<String, String> startFiles = {};

      print("DEBUG: Collecting files...");

      if (_uploadedDocuments['Jamabandi']?.isUploaded ?? false) {
        startFiles['jamabandi'] = _uploadedDocuments['Jamabandi']!.filePath;
      }
      if (_uploadedDocuments['Sale Deed']?.isUploaded ?? false) {
        startFiles['deed'] = _uploadedDocuments['Sale Deed']!.filePath;
      }

      if (startFiles.length < 2) {
        throw Exception('Please upload both Jamabandi and Sale Deed');
      }

      // 2. Call API
      print(
        "DEBUG: Calling ApiService.analyzeDocuments with files: ${startFiles.keys}",
      );
      final result = await ApiService.analyzeDocuments(startFiles, 'demo_user');
      print("DEBUG: API Response received: $result");

      if (result['success'] == false) {
        throw Exception(result['error'] ?? 'API responded with failure');
      }

      setState(() {
        _progressStep = 2;
        _analysisStatus = 'Establishing ownership chain...';
      });
      await Future.delayed(
        const Duration(milliseconds: 800),
      ); // UI delay for effect

      setState(() {
        _progressStep = 3;
        _analysisStatus = 'Cross-validating documents...';
      });
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _progressStep = 4;
        _analysisStatus = 'Generating final report...';
      });
      await Future.delayed(const Duration(milliseconds: 800));

      // 3. Map result to UI
      // Expected structure from new prompt:
      // {
      //   "extraction": { "jamabandi": {...}, "deed": {...} },
      //   "validation": { "owner_match": true, ... },
      //   "decision": { "recommendation": "approved", "reason": "...", "issues": [] }
      // }

      print("DEBUG: Processing API result...");
      var data = result['data'] ?? result; // fallback for both structures
      var extraction = data['extraction'] ?? {};
      var jamabandi = extraction['jamabandi'] ?? {};
      var deed = extraction['deed'] ?? {};
      var validation = data['validation'] ?? {};
      var decision = data['decision'] ?? {};

      print("DEBUG: Jamabandi Extraction: $jamabandi");
      print("DEBUG: Deed Extraction: $deed");
      print("DEBUG: Decision: $decision");

      // Prepare Ownership Chain
      List<Map<String, dynamic>> chain = [];
      // Entry 1: Jamabandi Owner
      if (jamabandi['owner_name'] != null) {
        chain.add({
          'owner': jamabandi['owner_name'],
          'year': 'Jamabandi Record',
          'document': 'Jamabandi (${jamabandi['dates']?.isNotEmpty == true ? jamabandi['dates'][0] : 'Date N/A'})',
        });
      }
      // Entry 2: Sale Deed Transaction
      if (deed['buyer_name'] != null) {
        chain.add({
          'owner': deed['buyer_name'],
          'year': 'Buyer (Deed: ${deed['registration_date'] ?? 'Date N/A'})',
          'document': 'Sale Deed ${deed['registration_number'] ?? ''}',
        });
      }
      if (chain.isEmpty) {
        chain.add({
          'owner': 'Review Required',
          'year': 'Data Missing',
          'document': 'N/A',
        });
      }

      // Prepare Observations/Recommendations
      String primaryReason = decision['reason'] ?? 'Analysis Completed';
      List<dynamic> issues = decision['issues'] ?? [];
      String detailedRec = primaryReason;
      if (issues.isNotEmpty) {
        detailedRec += '\n\nIssues:\n${issues.join('\n')}';
      }

      print("DEBUG: Updating UI state with mapped data...");
      setState(() {
        _aiGeneratedData = {
          'propertyAddress': jamabandi['village'] ?? 'Extracted from documents',
          'surveyNumber': jamabandi['plot_number'] ?? 'Extracted',
          'plotArea': jamabandi['area'] ?? 'As per deed',
          'legalStatus':
              decision['recommendation']?.toString().toUpperCase() ?? 'PENDING',
          'recommendations': detailedRec,
          'ownershipChain': chain,
          // Additional fields that might be used by Review Screen
          'encumbrances': validation['owner_match'] == true
              ? 'Ownership Verified'
              : 'Ownership Issue: ${validation['owner_explanation'] ?? 'Unknown'}',
          'observations': issues.cast<String>(),
          'marketValue': deed['sale_amount'] ?? 'Pending Valuation',
        };
        _isAnalyzing = false;
        _hasError = false;
        _currentStep++;
      });
      print("DEBUG: Analysis complete. UI updated.");
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("DEBUG: Analysis failed with error: $e");
        print("DEBUG: Stack trace: $stackTrace");
      }

      if (mounted) {
        // Extract meaningful error message
        String errorMessage = e.toString();
        String displayMessage = 'Analysis failed';

        if (errorMessage.contains('Cannot connect to backend')) {
          displayMessage = 'Cannot connect to backend server';
        } else if (errorMessage.contains('timeout')) {
          displayMessage = 'Request timed out - files may be too large';
        } else if (errorMessage.contains('Backend error')) {
          displayMessage = 'Backend processing error';
        } else if (errorMessage.contains('No valid files')) {
          displayMessage = 'Please upload both required documents';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayMessage,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  errorMessage.length > 200
                    ? '${errorMessage.substring(0, 200)}...'
                    : errorMessage,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: AppTheme.error,
            duration: const Duration(seconds: 8),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'DETAILS',
              textColor: Colors.white,
              onPressed: () {
                // Show detailed error dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Error Details'),
                    content: SingleChildScrollView(
                      child: Text(errorMessage),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CLOSE'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
        setState(() {
          _isAnalyzing = false;
          _hasError = true;
          _analysisStatus = displayMessage;
        });
      }
    }
  }

  // Handle bank selection change
  void _onBankChanged(String? newBank) {
    setState(() {
      _selectedBank = newBank;
      // Reset branch selection when bank changes
      _selectedBranch = null;
    });
  }

  Future<void> _pickDocument(String documentType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
        withData: kIsWeb,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _uploadedDocuments[documentType] = DocumentUpload(
            isUploaded: true,
            fileName: result.files.single.name,
            filePath: result.files.single.path!,
            fileSize: result.files.single.size,
          );
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.files.single.name} uploaded successfully'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading file: $e'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removeDocument(String documentType) {
    setState(() {
      _uploadedDocuments[documentType] = DocumentUpload();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Document removed'),
        backgroundColor: AppTheme.warning,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Scrutiny Report'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: List.generate(_steps.length * 2 - 1, (index) {
                    if (index.isEven) {
                      final stepIndex = index ~/ 2;
                      return _buildStepIndicator(stepIndex);
                    } else {
                      return Expanded(
                        child: Container(
                          height: 2,
                          color: (index ~/ 2) < _currentStep
                              ? AppTheme.primaryPurple
                              : Colors.grey.shade300,
                        ),
                      );
                    }
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  'Step ${_currentStep + 1} of ${_steps.length}: ${_steps[_currentStep]}',
                  style: GoogleFonts.roboto(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _buildStepContent(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildStepIndicator(int index) {
    final isCompleted = index < _currentStep;
    final isCurrent = index == _currentStep;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isCompleted || isCurrent
            ? AppTheme.primaryPurple
            : Colors.grey.shade300,
        shape: BoxShape.circle,
        border: isCurrent ? Border.all(color: Colors.white, width: 3) : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : Text(
                '${index + 1}',
                style: GoogleFonts.roboto(
                  color: isCurrent ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBankSelectionStep();
      case 1:
        return _buildDocumentUploadStep();
      case 2:
        return _buildCaseDetailsStep();
      case 3:
        return _buildAIProcessingStep();
      case 4:
        return _buildReviewEditStep();
      case 5:
        return _buildReportStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBankSelectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Bank & Branch',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildDropdownField(
            'Bank Name',
            'Select bank',
            Icons.account_balance,
            _bankNames,
            _selectedBank,
            _onBankChanged,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            'Branch',
            _selectedBank == null ? 'Select bank first' : 'Select branch',
            Icons.location_on,
            _availableBranches,
            _selectedBranch,
            (value) => setState(() => _selectedBranch = value),
            enabled: _selectedBank != null,
          ),
          if (_selectedBranch != null) ...[
            const SizedBox(height: 12),
            _buildBranchInfoCard(),
          ],
          const SizedBox(height: 16),
          _buildDropdownField(
            'Report Format',
            'Select format',
            Icons.description,
            ['Standard Format', 'Detailed Format', 'Summary Format'],
            _selectedReportFormat,
            (value) => setState(() => _selectedReportFormat = value),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchInfoCard() {
    if (_selectedBank == null || _selectedBranch == null)
      return const SizedBox.shrink();

    // Find district for selected branch
    String? district;
    final branches = _rajasthanBranches[_selectedBank];
    if (branches != null) {
      final branchData = branches.firstWhere(
        (b) => b['name'] == _selectedBranch,
        orElse: () => {'name': '', 'district': 'N/A'},
      );
      district = branchData['district'];
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.accentBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Branch Details',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'District: ${district ?? 'N/A'}',
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Property Documents',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload all relevant documents for AI analysis',
            style: GoogleFonts.roboto(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 24),
          _buildUploadCard(
            'Jamabandi',
            'PDF, JPG, JPEG, PNG up to 10MB',
            Icons.upload_file,
          ),
          _buildUploadCard(
            'Sale Deed',
            'PDF, JPG, JPEG, PNG up to 10MB',
            Icons.upload_file,
          ),
          _buildUploadCard(
            'Patta/Mother Title',
            'PDF, JPG, JPEG, PNG up to 10MB',
            Icons.upload_file,
          ),
          _buildUploadCard(
            'Mutation Record',
            'PDF, JPG, JPEG, PNG up to 10MB',
            Icons.upload_file,
          ),
          const SizedBox(height: 16),
          _buildUploadSummary(),
        ],
      ),
    );
  }

  Widget _buildUploadCard(String title, String subtitle, IconData icon) {
    DocumentUpload upload = _uploadedDocuments[title]!;
    bool isUploaded = upload.isUploaded;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isUploaded ? 2 : 1,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUploaded
                ? AppTheme.success.withOpacity(0.1)
                : AppTheme.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isUploaded ? Icons.check_circle : icon,
            color: isUploaded ? AppTheme.success : AppTheme.primaryPurple,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (isUploaded) ...[
              Text(
                upload.fileName,
                style: GoogleFonts.roboto(
                  color: AppTheme.success,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                _formatFileSize(upload.fileSize),
                style: GoogleFonts.roboto(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ] else
              Text(
                subtitle,
                style: GoogleFonts.roboto(color: AppTheme.textMuted),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isUploaded)
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                color: AppTheme.error,
                onPressed: () => _removeDocument(title),
                tooltip: 'Remove file',
              ),
            ElevatedButton(
              onPressed: () => _pickDocument(title),
              style: ElevatedButton.styleFrom(
                backgroundColor: isUploaded
                    ? AppTheme.accentBlue.withOpacity(0.1)
                    : AppTheme.primaryPurple.withOpacity(0.1),
                foregroundColor: isUploaded
                    ? AppTheme.accentBlue
                    : AppTheme.primaryPurple,
                elevation: 0,
              ),
              child: Text(isUploaded ? 'Replace' : 'Upload'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSummary() {
    int uploadedCount = _uploadedDocuments.values
        .where((doc) => doc.isUploaded)
        .length;
    int totalCount = _uploadedDocuments.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: uploadedCount == totalCount
            ? AppTheme.success.withOpacity(0.1)
            : AppTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: uploadedCount == totalCount
              ? AppTheme.success.withOpacity(0.3)
              : AppTheme.warning.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            uploadedCount == totalCount
                ? Icons.check_circle
                : Icons.info_outline,
            color: uploadedCount == totalCount
                ? AppTheme.success
                : AppTheme.warning,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              uploadedCount == totalCount
                  ? 'All documents uploaded successfully!'
                  : 'Uploaded $uploadedCount of $totalCount documents',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                color: uploadedCount == totalCount
                    ? AppTheme.success
                    : AppTheme.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Case Information',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            'Applicant Name',
            'Enter applicant name',
            _applicantNameController,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Co-Applicant Name',
            'Enter co-applicant name (optional)',
            _coApplicantNameController,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Present Owner',
            'Enter present owner name',
            _presentOwnerController,
          ),
          const SizedBox(height: 16),
          _buildTextField('Loan ID', 'Enter bank loan ID', _loanIdController),
          const SizedBox(height: 16),
          _buildDropdownField(
            'Property Type',
            'Select property type',
            Icons.home,
            ['Residential', 'Commercial', 'Agricultural', 'Industrial'],
            _selectedPropertyType,
            (value) => setState(() => _selectedPropertyType = value),
          ),
        ],
      ),
    );
  }

  Widget _buildAIProcessingStep() {
    // Trigger API call only once when this step is built
    // Using a reliable check to prevent multiple calls would be better in a real state management solution
    // For now, we rely on a flag or just checking if data is already populated?
    // But _aiGeneratedData might be populated from previous steps? No, it's init as empty.

    // We'll use a FutureBuilder or just call it here with a flag.
    // But since this is a build method, calling API directly is bad practice.
    // However, existing code was using Future.delayed inside build.
    // I will introduce a `_isAnalyzing` flag and call a method `_startAnalysis` from `build` if not analyzing.
    // BETTER: Use a FutureBuilder or verify `_isAnalyzing`.

    if (!_isAnalyzing && _aiGeneratedData.isEmpty && !_hasError) {
      _startAnalysis();
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.error),
            const SizedBox(height: 16),
            Text(
              'Analysis Failed',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _analysisStatus,
              style: GoogleFonts.roboto(color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _startAnalysis,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Analysis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              strokeWidth: 8,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primaryPurple.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'AI Analyzing Documents...',
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _analysisStatus,
            style: GoogleFonts.roboto(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 48),
          _buildProgressItem('Document OCR', _progressStep >= 1),
          _buildProgressItem('Chain Establishment', _progressStep >= 2),
          _buildProgressItem('Cross-Validation', _progressStep >= 3),
          _buildProgressItem('Report Generation', _progressStep >= 4),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, bool completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 40),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? AppTheme.success : AppTheme.textMuted,
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: completed ? AppTheme.textPrimary : AppTheme.textMuted,
              fontWeight: completed ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const Spacer(),
          if (completed)
            Text(
              'Done',
              style: GoogleFonts.roboto(
                color: AppTheme.success,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewEditStep() {
    return LSRReviewScreen(
      reportData: {
        'bank': _selectedBank ?? 'N/A',
        'branch': _selectedBranch ?? 'N/A',
        'reportFormat': _selectedReportFormat ?? 'N/A',
        'applicantName': _applicantNameController.text,
        'coApplicantName': _coApplicantNameController.text,
        'presentOwner': _presentOwnerController.text,
        'loanId': _loanIdController.text,
        'propertyType': _selectedPropertyType ?? 'N/A',
        ..._aiGeneratedData,
      },
      onDataUpdated: (updatedData) {
        setState(() {
          _aiGeneratedData = {..._aiGeneratedData, ...updatedData};
        });
      },
    );
  }

  Widget _buildReportStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.success, size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Report Generated Successfully',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.success,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'All validations passed. Chain is complete.',
                        style: GoogleFonts.roboto(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildActionCard(
            'Download Word',
            Icons.description,
            AppTheme.accentBlue,
          ),
          _buildActionCard(
            'Download PDF',
            Icons.picture_as_pdf,
            AppTheme.error,
          ),
          _buildActionCard('Share Report', Icons.share, AppTheme.primaryPurple),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
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
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (title == 'Download PDF') {
            _generateAndDownloadPdf();
          } else {
            // Handle download/share actions
            // You can access all the data here for PDF generation
            final finalData = {
              'bank': _selectedBank,
              'branch': _selectedBranch,
              'reportFormat': _selectedReportFormat,
              'applicantName': _applicantNameController.text,
              'coApplicantName': _coApplicantNameController.text,
              'presentOwner': _presentOwnerController.text,
              'loanId': _loanIdController.text,
              'propertyType': _selectedPropertyType,
              'uploadedDocuments': _uploadedDocuments,
              ..._aiGeneratedData,
            };

            // TODO: Implement other actions
            print('Final data for report: $finalData');
          }
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep--),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.primaryPurple),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _canProceed()
                    ? () {
                        if (_currentStep < _steps.length - 1) {
                          setState(() => _currentStep++);
                        } else {
                          Navigator.pop(context);
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _currentStep == _steps.length - 1 ? 'Finish' : 'Continue',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedBank != null &&
            _selectedBranch != null &&
            _selectedReportFormat != null;
      case 1:
        // Require at least 2 documents to be uploaded
        return _uploadedDocuments.values
                .where((doc) => doc.isUploaded)
                .length >=
            2;
      case 2:
        return _applicantNameController.text.isNotEmpty &&
            _presentOwnerController.text.isNotEmpty &&
            _loanIdController.text.isNotEmpty &&
            _selectedPropertyType != null;
      default:
        return true;
    }
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String hint,
    IconData icon,
    List<String> items,
    String? value,
    Function(String?) onChanged, {
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: enabled ? AppTheme.textMuted : Colors.grey.shade400,
        ), // 👈 CHANGED
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: !enabled,
        fillColor: !enabled ? Colors.grey.shade100 : null,
      ),
      hint: Text(hint),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: enabled ? onChanged : null,
    );
  }

  Future<void> _generateAndDownloadPdf() async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Legal Scrutiny Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(DateTime.now().toString().split(' ')[0]),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Bank Details
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Bank Details',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Divider(),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Text('Bank Name: ${_selectedBank ?? "N/A"}'),
                      ),
                      pw.Expanded(
                        child: pw.Text('Branch: ${_selectedBranch ?? "N/A"}'),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Text('Loan ID: ${_loanIdController.text}'),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          'Format: ${_selectedReportFormat ?? "N/A"}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Applicant Details
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Applicant Details',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Divider(),
                  pw.Text('Applicant Name: ${_applicantNameController.text}'),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Co-Applicant Name: ${_coApplicantNameController.text}',
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text('Present Owner: ${_presentOwnerController.text}'),
                  pw.SizedBox(height: 5),
                  pw.Text('Property Type: ${_selectedPropertyType ?? "N/A"}'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // AI Analysis
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Property Analysis',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Divider(),
                  pw.Text(
                    'Address: ${_aiGeneratedData["propertyAddress"] ?? "N/A"}',
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Survey No: ${_aiGeneratedData["surveyNumber"] ?? "N/A"}',
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Legal Status: ${_aiGeneratedData["legalStatus"] ?? "N/A"}',
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Plot Area: ${_aiGeneratedData["plotArea"] ?? "N/A"}',
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Recommendations
            pw.Text(
              'Recommendations:',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.Paragraph(text: _aiGeneratedData["recommendations"] ?? "None"),
          ];
        },
      ),
    );

    // Save or Share
    final output = await getTemporaryDirectory();
    final file = File(
      "${output.path}/LSR_Report_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], text: 'Legal Scrutiny Report');
  }
}

// Document Upload Model
class DocumentUpload {
  final bool isUploaded;
  final String fileName;
  final String filePath;
  final int fileSize;
  final dynamic fileBytes;

  DocumentUpload({
    this.isUploaded = false,
    this.fileName = '',
    this.filePath = '',
    this.fileSize = 0,
    this.fileBytes,
  });

  bool get isWebUpload => fileBytes != null;
  bool get isMobileUpload => filePath.isNotEmpty;
}
