// widgets/lsr_widgets.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/lsr_models.dart';
import '../providers/lsr_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════
// BANK SELECTOR WIDGET
// ═══════════════════════════════════════════════════════════════════════════

class BankSelectorWidget extends StatelessWidget {
  const BankSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LSRProvider>(
      builder: (context, provider, child) {
        final banks = provider.banks;
        final selectedBank = provider.selectedBank;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parent Bank / Finance Company',
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showBankBottomSheet(context, banks, provider),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance,
                      color: selectedBank != null
                          ? AppTheme.primaryPurple
                          : AppTheme.textMuted,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedBank?.name ?? 'Select Bank / Finance Company',
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: selectedBank != null
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: selectedBank != null
                              ? AppTheme.textPrimary
                              : AppTheme.textMuted,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: AppTheme.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBankBottomSheet(
      BuildContext context, List<Bank> banks, LSRProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Select Bank',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: banks.length,
                itemBuilder: (context, index) {
                  final bank = banks[index];
                  final isSelected = provider.selectedBank?.id == bank.id;
                  
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryPurple.withOpacity(0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.account_balance,
                        color: isSelected
                            ? AppTheme.primaryPurple
                            : AppTheme.textMuted,
                      ),
                    ),
                    title: Text(
                      bank.name,
                      style: GoogleFonts.roboto(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: AppTheme.primaryPurple)
                        : null,
                    onTap: () {
                      provider.selectBank(bank);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BRANCH SELECTOR WIDGET
// ═══════════════════════════════════════════════════════════════════════════

class BranchSelectorWidget extends StatelessWidget {
  const BranchSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LSRProvider>(
      builder: (context, provider, child) {
        final branches = provider.branches;
        final selectedBranch = provider.selectedBranch;
        final enabled = provider.hasSelectedBank;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Home Branch (Rajasthan)',
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: enabled ? AppTheme.textMuted : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: enabled
                  ? () => _showBranchBottomSheet(context, branches, provider)
                  : null,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: enabled ? Colors.grey.shade300 : Colors.grey.shade200,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: enabled ? null : Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: enabled
                          ? (selectedBranch != null
                              ? AppTheme.primaryPurple
                              : AppTheme.textMuted)
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedBranch?.displayName ?? 'Select Branch',
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: selectedBranch != null
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: enabled
                              ? (selectedBranch != null
                                  ? AppTheme.textPrimary
                                  : AppTheme.textMuted)
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: enabled ? AppTheme.textMuted : Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBranchBottomSheet(
      BuildContext context, List<Branch> branches, LSRProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Select Branch',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: branches.length,
                itemBuilder: (context, index) {
                  final branch = branches[index];
                  final isSelected = provider.selectedBranch?.id == branch.id;
                  
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryPurple.withOpacity(0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: isSelected
                            ? AppTheme.primaryPurple
                            : AppTheme.textMuted,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      branch.name,
                      style: GoogleFonts.roboto(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      branch.district,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: AppTheme.primaryPurple)
                        : null,
                    onTap: () {
                      provider.selectBranch(branch);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CASE TYPE TOGGLE WIDGET
// ═══════════════════════════════════════════════════════════════════════════

class CaseTypeToggleWidget extends StatelessWidget {
  const CaseTypeToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LSRProvider>(
      builder: (context, provider, child) {
        final selectedCaseType = provider.selectedCaseType;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.work_outline, size: 16, color: AppTheme.textMuted),
                const SizedBox(width: 8),
                Text(
                  'SELECT CASE TYPE',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCaseTypeCard(
                    context,
                    CaseType.purchase,
                    selectedCaseType == CaseType.purchase,
                    () => provider.selectCaseType(CaseType.purchase),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCaseTypeCard(
                    context,
                    CaseType.loanAgainstProperty,
                    selectedCaseType == CaseType.loanAgainstProperty,
                    () => provider.selectCaseType(CaseType.loanAgainstProperty),
                  ),
                ),
              ],
            ),
            if (selectedCaseType != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selectedCaseType.requiresATS
                      ? AppTheme.success.withOpacity(0.1)
                      : AppTheme.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selectedCaseType.requiresATS
                        ? AppTheme.success.withOpacity(0.3)
                        : AppTheme.accentBlue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedCaseType.requiresATS
                          ? Icons.check_circle_outline
                          : Icons.info_outline,
                      color: selectedCaseType.requiresATS
                          ? AppTheme.success
                          : AppTheme.accentBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedCaseType.requiresATS
                            ? '✅ ATS Required for Purchase Case'
                            : '📋 No ATS Needed for LAP',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selectedCaseType.requiresATS
                              ? AppTheme.success
                              : AppTheme.accentBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCaseTypeCard(
    BuildContext context,
    CaseType caseType,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final Color color = caseType == CaseType.purchase
        ? AppTheme.success
        : AppTheme.accentBlue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              caseType == CaseType.purchase
                  ? Icons.shopping_bag_outlined
                  : Icons.account_balance,
              color: isSelected ? color : AppTheme.textMuted,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              caseType.displayName,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? color : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              caseType == CaseType.purchase
                  ? 'Buying property from seller'
                  : 'Loan on your own property',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 10,
                color: AppTheme.textMuted,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  caseType.requiresATS ? 'ATS Required' : 'No ATS Needed',
                  style: GoogleFonts.roboto(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CHECKLIST BUILDER WIDGET
// ═══════════════════════════════════════════════════════════════════════════

class ChecklistBuilderWidget extends StatelessWidget {
  const ChecklistBuilderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LSRProvider>(
      builder: (context, provider, child) {
        final groupedChecklist = provider.getGroupedChecklist();
        
        if (groupedChecklist.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.checklist, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'Checklist will appear here',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete all selections above',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChecklistHeader(provider),
            const SizedBox(height: 16),
            ...groupedChecklist.entries.map((entry) {
              return _buildCategorySection(
                context,
                entry.key,
                entry.value,
                provider,
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildChecklistHeader(LSRProvider provider) {
    final stats = provider.getChecklistStats();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPurple.withOpacity(0.1),
            AppTheme.accentBlue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.checklist_rtl, color: AppTheme.primaryPurple),
              const SizedBox(width: 8),
              Text(
                'REQUIRED DOCUMENTS CHECKLIST',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatChip('Total', stats['total']!, AppTheme.textPrimary),
              _buildStatChip('Mandatory', stats['mandatory']!, AppTheme.error),
              _buildStatChip('Optional', stats['optional']!, AppTheme.accentBlue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 11,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String category,
    List<ChecklistItem> items,
    LSRProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 16,
                  color: AppTheme.accentBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  category.toUpperCase(),
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: AppTheme.accentBlue,
                  ),
                ),
              ],
            ),
          ),
          ...items.map((item) {
            return _buildChecklistItem(context, item, provider);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(
    BuildContext context,
    ChecklistItem item,
    LSRProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                item.isMandatory ? Icons.star : Icons.star_border,
                size: 16,
                color: item.isMandatory ? AppTheme.error : AppTheme.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.documentName,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (item.isMandatory)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'REQUIRED',
                    style: GoogleFonts.roboto(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.error,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'OPTIONAL',
                    style: GoogleFonts.roboto(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...DocumentStatus.values.map((status) {
                final isSelected = item.status == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        provider.updateChecklistItem(item.id, status);
                      }
                    },
                    selectedColor: AppTheme.success.withOpacity(0.2),
                    labelStyle: GoogleFonts.roboto(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppTheme.success : AppTheme.textMuted,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }
}