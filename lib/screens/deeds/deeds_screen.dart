import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lsrd_pro/core/theme/app_theme.dart';

class DeedsScreen extends StatefulWidget {
  const DeedsScreen({super.key});

  @override
  State<DeedsScreen> createState() => _DeedsScreenState();
}

class _DeedsScreenState extends State<DeedsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPartiesExpanded = true;
  bool _isWitnessesExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deed Drafting'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConfigurationCard(),
              const SizedBox(height: 20),
              _buildPartiesCard(),
              const SizedBox(height: 20),
              _buildWitnessesCard(),
              const SizedBox(height: 20),
              _buildPropertyCard(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                  child: const Text('Generate Deed'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigurationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Configuration',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildDropdown(
              'Deed Type',
              'Select deed type',
              [
                'Sale Deed (बैनामा)',
                'Gift Deed (हिबानामा)',
                'Mortgage Deed',
                'Release Deed (त्यागपत्र)',
                'Partition Deed (बंटवारानामा)',
              ],
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              'Language',
              'Select language',
              ['Hindi', 'English'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartiesCard() {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: _isPartiesExpanded,
        onExpansionChanged: (expanded) => setState(() => _isPartiesExpanded = expanded),
        title: Text(
          'Parties to the Deed',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Executant (Seller)',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryPurple,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField('Full name of seller'),
                const SizedBox(height: 16),
                Text(
                  'Claimant (Buyer)',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryPurple,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField('Full name of buyer'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWitnessesCard() {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: _isWitnessesExpanded,
        onExpansionChanged: (expanded) => setState(() => _isWitnessesExpanded = expanded),
        title: Text(
          'Witnesses',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildWitnessField(1),
                const SizedBox(height: 12),
                _buildWitnessField(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWitnessField(int number) {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Witness $number',
        hintText: 'Full name, Father\'s name, Address',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildPropertyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Property Details',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField('Khasra Number'),
            const SizedBox(height: 16),
            _buildTextField('Khata Number'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField('Area'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown('Unit', 'sqyd', ['sqyd', 'sqft', 'bigha']),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Boundaries (चौहद्दी)',
              style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField('North')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('South')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField('East')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('West')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String hint, List<String> items) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      hint: Text(hint),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (value) {},
    );
  }

  Widget _buildTextField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}