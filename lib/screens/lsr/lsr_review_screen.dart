// screens/lsr/lsr_review_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lsrd_pro/core/theme/app_theme.dart';

class LSRReviewScreen extends StatefulWidget {
  final Map<String, dynamic> reportData;
  final Function(Map<String, dynamic>) onDataUpdated;

  const LSRReviewScreen({
    super.key,
    required this.reportData,
    required this.onDataUpdated,
  });

  @override
  State<LSRReviewScreen> createState() => _LSRReviewScreenState();
}

class _LSRReviewScreenState extends State<LSRReviewScreen> {
  late Map<String, dynamic> _editableData;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _editingFields = {};

  @override
  void initState() {
    super.initState();
    _editableData = Map.from(widget.reportData);
    _initializeControllers();
  }

  void _initializeControllers() {
    final editableFields = [
      'propertyAddress',
      'surveyNumber',
      'plotArea',
      'encumbrances',
      'legalStatus',
      'marketValue',
      'recommendations',
    ];

    for (var field in editableFields) {
      _controllers[field] = TextEditingController(
        text: _editableData[field]?.toString() ?? '',
      );
      _editingFields[field] = false;
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleEdit(String field) {
    setState(() {
      _editingFields[field] = !(_editingFields[field] ?? false);
      if (!_editingFields[field]!) {
        _editableData[field] = _controllers[field]?.text;
        widget.onDataUpdated(_editableData);
      }
    });
  }

  void _saveAllChanges() {
    for (var entry in _controllers.entries) {
      _editableData[entry.key] = entry.value.text;
    }
    widget.onDataUpdated(_editableData);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All changes saved successfully'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildInfoAlert(),
          const SizedBox(height: 24),
          _buildBasicInfoSection(),
          const SizedBox(height: 20),
          _buildPropertyDetailsSection(),
          const SizedBox(height: 20),
          _buildOwnershipChainSection(),
          const SizedBox(height: 20),
          _buildLegalStatusSection(),
          const SizedBox(height: 20),
          _buildObservationsSection(),
          const SizedBox(height: 20),
          _buildRecommendationsSection(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review Report',
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Review and edit the AI-generated report before finalizing',
                style: GoogleFonts.roboto(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _saveAllChanges,
          icon: const Icon(Icons.save),
          tooltip: 'Save all changes',
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
            foregroundColor: AppTheme.primaryPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoAlert() {
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
            child: Text(
              'Click on any field with an edit icon to modify the content. Changes are auto-saved.',
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: AppTheme.accentBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      'Basic Information',
      Icons.info,
      [
        _buildReadOnlyField('Bank', _editableData['bank'] ?? 'N/A'),
        _buildReadOnlyField('Branch', _editableData['branch'] ?? 'N/A'),
        _buildReadOnlyField('Loan ID', _editableData['loanId'] ?? 'N/A'),
        _buildReadOnlyField('Applicant Name', _editableData['applicantName'] ?? 'N/A'),
        if (_editableData['coApplicantName']?.isNotEmpty ?? false)
          _buildReadOnlyField('Co-Applicant', _editableData['coApplicantName']),
        _buildReadOnlyField('Property Type', _editableData['propertyType'] ?? 'N/A'),
      ],
    );
  }

  Widget _buildPropertyDetailsSection() {
    return _buildSection(
      'Property Details',
      Icons.home,
      [
        _buildEditableField('Property Address', 'propertyAddress', maxLines: 2),
        _buildEditableField('Survey Number', 'surveyNumber'),
        _buildEditableField('Plot Area', 'plotArea'),
        _buildEditableField('Market Value', 'marketValue'),
      ],
    );
  }

  Widget _buildOwnershipChainSection() {
    List<dynamic> chain = _editableData['ownershipChain'] ?? [];
    
    return _buildSection(
      'Ownership Chain',
      Icons.timeline,
      [
        if (chain.isEmpty)
          Text(
            'No ownership chain data available',
            style: GoogleFonts.roboto(color: AppTheme.textMuted),
          )
        else
          ...chain.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> owner = entry.value;
            return _buildChainItem(
              owner['owner'] ?? 'Unknown',
              owner['year'] ?? 'N/A',
              owner['document'] ?? 'N/A',
              index == chain.length - 1,
            );
          }).toList(),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _showAddOwnerDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Add Owner'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryPurple,
            side: BorderSide(color: AppTheme.primaryPurple.withOpacity(0.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildChainItem(String owner, String year, String document, bool isLast) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: AppTheme.primaryPurple.withOpacity(0.3),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    owner,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        year,
                        style: GoogleFonts.roboto(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.description, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          document,
                          style: GoogleFonts.roboto(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalStatusSection() {
    return _buildSection(
      'Legal Status',
      Icons.gavel,
      [
        _buildEditableField('Encumbrances', 'encumbrances', maxLines: 3),
        const SizedBox(height: 12),
        _buildEditableField('Legal Status', 'legalStatus'),
      ],
    );
  }

  Widget _buildObservationsSection() {
    List<dynamic> observations = _editableData['observations'] ?? [];
    
    return _buildSection(
      'Observations',
      Icons.visibility,
      [
        if (observations.isEmpty)
          Text(
            'No observations available',
            style: GoogleFonts.roboto(color: AppTheme.textMuted),
          )
        else
          ...observations.asMap().entries.map((entry) {
            return _buildObservationItem(entry.value.toString(), entry.key);
          }).toList(),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _showAddObservationDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Add Observation'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryPurple,
            side: BorderSide(color: AppTheme.primaryPurple.withOpacity(0.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildObservationItem(String observation, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.success.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: AppTheme.success, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              observation,
              style: GoogleFonts.roboto(fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppTheme.error,
            onPressed: () {
              setState(() {
                List<dynamic> obs = List.from(_editableData['observations']);
                obs.removeAt(index);
                _editableData['observations'] = obs;
                widget.onDataUpdated(_editableData);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return _buildSection(
      'Recommendations',
      Icons.recommend,
      [
        _buildEditableField('Recommendations', 'recommendations', maxLines: 4),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryPurple, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: GoogleFonts.roboto(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, String fieldKey, {int maxLines = 1}) {
    bool isEditing = _editingFields[fieldKey] ?? false;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: GoogleFonts.roboto(
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  isEditing ? Icons.check : Icons.edit,
                  size: 18,
                ),
                color: isEditing ? AppTheme.success : AppTheme.primaryPurple,
                onPressed: () => _toggleEdit(fieldKey),
                tooltip: isEditing ? 'Save' : 'Edit',
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (isEditing)
            TextField(
              controller: _controllers[fieldKey],
              maxLines: maxLines,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              autofocus: true,
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                _controllers[fieldKey]?.text ?? 'N/A',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Reset to original data
              setState(() {
                _editableData = Map.from(widget.reportData);
                _initializeControllers();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Changes'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: AppTheme.error,
              side: BorderSide(color: AppTheme.error.withOpacity(0.5)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveAllChanges,
            icon: const Icon(Icons.check),
            label: const Text('Confirm & Continue'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddObservationDialog() {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Observation', style: GoogleFonts.roboto()),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter observation...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  List<dynamic> obs = List.from(_editableData['observations'] ?? []);
                  obs.add(controller.text);
                  _editableData['observations'] = obs;
                  widget.onDataUpdated(_editableData);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddOwnerDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController yearController = TextEditingController();
    final TextEditingController documentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Owner', style: GoogleFonts.roboto()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Owner Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: yearController,
              decoration: InputDecoration(
                labelText: 'Year',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: documentController,
              decoration: InputDecoration(
                labelText: 'Document Reference',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  List<dynamic> chain = List.from(_editableData['ownershipChain'] ?? []);
                  chain.add({
                    'owner': nameController.text,
                    'year': yearController.text,
                    'document': documentController.text,
                  });
                  _editableData['ownershipChain'] = chain;
                  widget.onDataUpdated(_editableData);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
