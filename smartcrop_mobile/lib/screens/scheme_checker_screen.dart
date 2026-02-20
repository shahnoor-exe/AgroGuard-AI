import 'package:flutter/material.dart';
import 'dart:js' as js;
import '../core/lang_provider.dart';
import '../services/govt_api_service.dart';

/// Scheme Eligibility Checker — myScheme integration
/// Farmer fills profile → checks eligibility → sees matched schemes
class SchemeCheckerScreen extends StatefulWidget {
  const SchemeCheckerScreen({super.key});
  @override
  State<SchemeCheckerScreen> createState() => _SchemeCheckerScreenState();
}

class _SchemeCheckerScreenState extends State<SchemeCheckerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageCtrl = TextEditingController();
  final _landCtrl = TextEditingController();
  final _keywordCtrl = TextEditingController();
  String _gender = 'male';
  String? _state;
  String _farmerType = 'all';
  List<String> _states = [];
  Map<String, dynamic>? _result;
  bool _loading = false;
  bool _showForm = true;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  @override
  void dispose() {
    _ageCtrl.dispose();
    _landCtrl.dispose();
    _keywordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStates() async {
    final states = await GovtApiService.getStates();
    if (mounted) setState(() => _states = states);
  }

  Future<void> _checkEligibility() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _showForm = false; });

    final res = await GovtApiService.checkEligibility(
      age: int.tryParse(_ageCtrl.text),
      gender: _gender,
      landHectares: double.tryParse(_landCtrl.text),
      state: _state,
      farmerType: _farmerType == 'all' ? null : _farmerType,
      keywords: _keywordCtrl.text.isEmpty ? null : _keywordCtrl.text,
    );

    if (mounted) setState(() { _result = res; _loading = false; });
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: AppLang.current,
    builder: (context, _, __) => Scaffold(
      backgroundColor: const Color(0xFFFAFAF5),
      appBar: AppBar(
        title: Text(AppStrings.t('govtSchemes'), style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFF264653),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_showForm)
            TextButton.icon(
              onPressed: () => setState(() { _showForm = true; _result = null; }),
              icon: const Icon(Icons.edit, color: Colors.white70, size: 16),
              label: Text(AppStrings.t('editProfile'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(color: Color(0xFF264653)),
              SizedBox(height: 16),
              Text('Checking eligibility...', style: TextStyle(color: Color(0xFF6B7B6B))),
            ]))
          : _showForm ? _buildForm() : _buildResults(),
    ),
  );

  // ── Profile Form ───────────────────────────────────────────────────────

  Widget _buildForm() => SingleChildScrollView(
    padding: const EdgeInsets.all(18),
    child: Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF264653), Color(0xFF2A9D8F)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('📋', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(AppStrings.t('schemeCheckerTitle'),
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(AppStrings.t('schemeCheckerSub'),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
          ]),
        ),
        const SizedBox(height: 24),

        // Age
        _fieldLabel(AppStrings.t('yourAge')),
        TextFormField(
          controller: _ageCtrl,
          keyboardType: TextInputType.number,
          decoration: _inputDecor(AppStrings.t('enterAge'), Icons.person),
          validator: (v) => v == null || v.isEmpty ? AppStrings.t('required') : null,
        ),
        const SizedBox(height: 16),

        // Gender
        _fieldLabel(AppStrings.t('genderLabel')),
        Row(children: [
          _genderChip('male', '👨', AppStrings.t('male')),
          const SizedBox(width: 10),
          _genderChip('female', '👩', AppStrings.t('female')),
        ]),
        const SizedBox(height: 16),

        // State
        _fieldLabel(AppStrings.t('stateLabel')),
        _buildStateDropdown(),
        const SizedBox(height: 16),

        // Land holding
        _fieldLabel(AppStrings.t('landHolding')),
        TextFormField(
          controller: _landCtrl,
          keyboardType: TextInputType.number,
          decoration: _inputDecor(AppStrings.t('enterLand'), Icons.landscape),
          validator: (v) => v == null || v.isEmpty ? AppStrings.t('required') : null,
        ),
        const SizedBox(height: 16),

        // Farmer type
        _fieldLabel(AppStrings.t('farmerTypeLabel')),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _typeChip('all', AppStrings.t('allTypes')),
          _typeChip('small_marginal', AppStrings.t('smallMarginal')),
          _typeChip('medium', AppStrings.t('mediumFarmer')),
          _typeChip('large', AppStrings.t('largeFarmer')),
        ]),
        const SizedBox(height: 16),

        // Keywords
        _fieldLabel(AppStrings.t('interestKeywords')),
        TextFormField(
          controller: _keywordCtrl,
          decoration: _inputDecor(AppStrings.t('enterKeywords'), Icons.search),
        ),
        const SizedBox(height: 28),

        // Submit button
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _checkEligibility,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF264653),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.search, color: Colors.white),
              const SizedBox(width: 8),
              Text(AppStrings.t('checkEligibility'),
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
        const SizedBox(height: 20),
      ]),
    ),
  );

  // ── Results ────────────────────────────────────────────────────────────

  Widget _buildResults() {
    if (_result == null || _result!['success'] != true) {
      return Center(child: Text(AppStrings.t('errorOccurred'), style: const TextStyle(color: Colors.red)));
    }

    final eligible = List<dynamic>.from((_result!['eligible_schemes'] as List?) ?? []);
    final ineligible = List<dynamic>.from((_result!['ineligible_schemes'] as List?) ?? []);
    final total = _result!['total_schemes'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Summary card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF2D6A4F), Color(0xFF40916C)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('🎉', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text('${AppStrings.t('youAreEligible')} ${eligible.length} ${AppStrings.t('outOf')} $total ${AppStrings.t('schemesWord')}',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(AppStrings.t('eligibilityNote'),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 20),

        // Eligible schemes
        if (eligible.isNotEmpty) ...[
          _sectionLabel('✅', '${AppStrings.t('eligibleSchemes')} (${eligible.length})'),
          const SizedBox(height: 10),
          ...eligible.map((s) => _buildSchemeCard(s, true)),
        ],

        // Ineligible
        if (ineligible.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionLabel('❌', AppStrings.t('notEligible')),
          const SizedBox(height: 10),
          ...ineligible.map((s) => _buildSchemeCard(s, false)),
        ],
      ]),
    );
  }

  Widget _buildSchemeCard(dynamic scheme, bool eligible) {
    final s = scheme as Map<String, dynamic>;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: eligible
            ? const Color(0xFF2D6A4F).withValues(alpha: 0.15)
            : const Color(0xFFE76F51).withValues(alpha: 0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: eligible
                  ? const Color(0xFF2D6A4F).withValues(alpha: 0.08)
                  : const Color(0xFFE76F51).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(eligible ? Icons.check_circle : Icons.cancel,
              color: eligible ? const Color(0xFF2D6A4F) : const Color(0xFFE76F51), size: 20),
          ),
          title: Text(s['name']?.toString() ?? '',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1B2A1B))),
          subtitle: Text(s['ministry']?.toString() ?? '',
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7B6B))),
          children: [
            _detailRow('📝', AppStrings.t('description'), s['description']?.toString() ?? ''),
            _detailRow('💰', AppStrings.t('benefits'), s['benefits']?.toString() ?? ''),
            _detailRow('✅', AppStrings.t('eligibilityReq'), s['eligibility']?.toString() ?? ''),
            _detailRow('📄', AppStrings.t('documents'), s['documents']?.toString() ?? ''),
            _detailRow('🔗', AppStrings.t('howToApply'), s['how_to_apply']?.toString() ?? ''),

            // Visit Website button — links to real government portal
            if (s['website'] != null && (s['website']?.toString() ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final url = s['website'].toString();
                    js.context.callMethod('open', [url, '_blank']);
                  },
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text(AppStrings.t('visitGovtPortal'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A4F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],

            if (!eligible && (s['match_reasons'] as List?)?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE76F51).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('⚠️ ', style: TextStyle(fontSize: 14)),
                  Expanded(child: Text((s['match_reasons'] as List).join('\n'),
                    style: const TextStyle(fontSize: 12, color: Color(0xFFE76F51), height: 1.3))),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String emoji, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(emoji, style: const TextStyle(fontSize: 14)),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2D6A4F))),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF4A5D4A), height: 1.4)),
      ])),
    ]),
  );

  // ── Form helpers ───────────────────────────────────────────────────────

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1B2A1B))),
  );

  Widget _sectionLabel(String emoji, String text) => Row(children: [
    Text(emoji, style: const TextStyle(fontSize: 18)),
    const SizedBox(width: 8),
    Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1B2A1B))),
  ]);

  InputDecoration _inputDecor(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: const Color(0xFF2D6A4F), size: 20),
    filled: true, fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFF2D6A4F).withValues(alpha: 0.2))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFF2D6A4F).withValues(alpha: 0.2))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D6A4F))),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  Widget _genderChip(String value, String emoji, String label) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _gender == value ? const Color(0xFF264653) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF264653).withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: _gender == value ? Colors.white : const Color(0xFF1B2A1B),
          )),
        ]),
      ),
    ),
  );

  Widget _typeChip(String value, String label) => GestureDetector(
    onTap: () => setState(() => _farmerType = value),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _farmerType == value ? const Color(0xFF264653) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF264653).withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600,
        color: _farmerType == value ? Colors.white : const Color(0xFF1B2A1B),
      )),
    ),
  );

  Widget _buildStateDropdown() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFF2D6A4F).withValues(alpha: 0.2)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _state,
        hint: Text(AppStrings.t('selectState'), style: const TextStyle(fontSize: 13, color: Color(0xFF6B7B6B))),
        isExpanded: true,
        items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
        onChanged: (v) => setState(() => _state = v),
      ),
    ),
  );
}
