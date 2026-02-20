import 'package:flutter/material.dart';
import 'dart:js' as js;
import '../core/lang_provider.dart';
import '../services/govt_api_service.dart';
import 'mandi_price_screen.dart';
import 'scheme_checker_screen.dart';
import 'insurance_screen.dart';
import 'advisory_feed_screen.dart';

/// Government Portal Hub Screen
/// Master navigation screen for all 5 government integrations
class GovtPortalScreen extends StatefulWidget {
  const GovtPortalScreen({super.key});
  @override
  State<GovtPortalScreen> createState() => _GovtPortalScreenState();
}

class _GovtPortalScreenState extends State<GovtPortalScreen> with TickerProviderStateMixin {
  Map<String, dynamic>? _dashboard;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadDashboard();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    try {
      final res = await GovtApiService.getDashboard(state: 'Punjab');
      if (mounted) {
        setState(() {
          _dashboard = res['dashboard'] as Map<String, dynamic>?;
        });
        _fadeCtrl.forward();
      }
    } catch (_) {
      if (mounted) setState(() {});
      _fadeCtrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: AppLang.current,
    builder: (context, _, __) => Scaffold(
      backgroundColor: const Color(0xFFFAFAF5),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: _buildContent(context)),
        ],
      ),
    ),
  );

  Widget _buildAppBar(BuildContext context) => SliverAppBar(
    expandedHeight: 180,
    pinned: true,
    backgroundColor: const Color(0xFF1B4332),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
      onPressed: () => Navigator.pop(context),
    ),
    flexibleSpace: FlexibleSpaceBar(
      background: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF40916C)],
          ),
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(right: -20, bottom: -20,
              child: Icon(Icons.account_balance, size: 160, color: Colors.white.withValues(alpha: 0.06))),
            Positioned(left: 20, bottom: 40, right: 80, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('🏛️', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(AppStrings.t('govtPortalBadge'),
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.w600)),
                  ]),
                ),
                const SizedBox(height: 10),
                Text(AppStrings.t('govtPortalTitle'),
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, height: 1.1)),
                const SizedBox(height: 4),
                Text(AppStrings.t('govtPortalSubtitle'),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
              ],
            )),
          ],
        ),
      ),
    ),
  );

  Widget _buildContent(BuildContext context) => FadeTransition(
    opacity: _fadeAnim,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick summary strip
          if (_dashboard != null) _buildSummaryStrip(),
          if (_dashboard != null) const SizedBox(height: 20),

          // Critical alerts
          if (_dashboard != null && (_dashboard!['critical_alerts'] as List?)?.isNotEmpty == true)
            _buildAlertBanner(),

          // Service cards
          _sectionHeader('🏛️', AppStrings.t('govtServices')),
          const SizedBox(height: 12),

          _serviceCard(
            emoji: '📊', title: AppStrings.t('mandiPrices'),
            subtitle: AppStrings.t('mandiPricesSub'),
            gradient: [const Color(0xFF2D6A4F), const Color(0xFF40916C)],
            detail: _dashboard != null
                ? '${_dashboard!['mandi_prices_available']} ${AppStrings.t('pricesAvailable')}'
                : null,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MandiPriceScreen())),
          ),
          const SizedBox(height: 12),

          _serviceCard(
            emoji: '📋', title: AppStrings.t('govtSchemes'),
            subtitle: AppStrings.t('govtSchemesSub'),
            gradient: [const Color(0xFF264653), const Color(0xFF2A9D8F)],
            detail: _dashboard != null
                ? '${_dashboard!['total_schemes']} ${AppStrings.t('schemesAvailable')}'
                : null,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SchemeCheckerScreen())),
          ),
          const SizedBox(height: 12),

          _serviceCard(
            emoji: '🛡️', title: AppStrings.t('cropInsurance'),
            subtitle: AppStrings.t('cropInsuranceSub'),
            gradient: [const Color(0xFFE76F51), const Color(0xFFE9A23B)],
            detail: null,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InsuranceScreen())),
          ),
          const SizedBox(height: 12),

          _serviceCard(
            emoji: '📢', title: AppStrings.t('govtAdvisories'),
            subtitle: AppStrings.t('govtAdvisoriesSub'),
            gradient: [const Color(0xFF6B4226), const Color(0xFFD4A373)],
            detail: _dashboard != null
                ? '${_dashboard!['active_advisories']} ${AppStrings.t('activeAlerts')}'
                : null,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdvisoryFeedScreen())),
          ),

          const SizedBox(height: 28),

          // Direct government portal links
          _sectionHeader('🔗', AppStrings.t('govtPortalLinks')),
          const SizedBox(height: 12),
          _buildPortalLinksGrid(),

          const SizedBox(height: 28),

          // Info card
          _buildInfoCard(),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );

  Widget _buildSummaryStrip() => Row(
    children: [
      _summaryChip('📊', '${_dashboard!['mandi_prices_available']}', AppStrings.t('prices')),
      const SizedBox(width: 8),
      _summaryChip('📋', '${_dashboard!['total_schemes']}', AppStrings.t('schemes')),
      const SizedBox(width: 8),
      _summaryChip('📢', '${_dashboard!['active_advisories']}', AppStrings.t('alerts')),
      const SizedBox(width: 8),
      _summaryChip('⚠️', '${(_dashboard!['critical_alerts'] as List?)?.length ?? 0}', AppStrings.t('critical')),
    ],
  );

  Widget _summaryChip(String emoji, String count, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: const Color(0xFF2D6A4F).withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1B2A1B))),
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF6B7B6B), fontWeight: FontWeight.w500)),
      ]),
    ),
  );

  Widget _buildAlertBanner() {
    final alerts = _dashboard!['critical_alerts'] as List;
    final alert = alerts.first;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE76F51).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE76F51).withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Text('⚠️', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(alert['commodity']?.toString() ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFE76F51))),
          Text(alert['message']?.toString() ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF4A5D4A), height: 1.3)),
        ])),
      ]),
    );
  }

  Widget _sectionHeader(String emoji, String title) => Row(children: [
    Container(width: 4, height: 22, decoration: BoxDecoration(color: const Color(0xFF2D6A4F), borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 10),
    Text(emoji, style: const TextStyle(fontSize: 18)),
    const SizedBox(width: 6),
    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1B2A1B))),
  ]);

  Widget _serviceCard({
    required String emoji, required String title, required String subtitle,
    required List<Color> gradient, String? detail, required VoidCallback onTap,
  }) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient),
          boxShadow: [BoxShadow(color: gradient.last.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(14)),
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
            if (detail != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Text(detail, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ])),
          Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.6), size: 18),
        ]),
      ),
    ),
  );

  Widget _buildPortalLinksGrid() {
    final links = [
      {'emoji': '📊', 'name': 'eNAM', 'url': 'https://enam.gov.in/web/guest/commodity-wise-daily'},
      {'emoji': '📈', 'name': 'Agmarknet', 'url': 'https://agmarknet.gov.in/SearchCmmMkt.aspx'},
      {'emoji': '📱', 'name': 'mKisan', 'url': 'https://mkisan.gov.in/advisoryDetails.aspx'},
      {'emoji': '📋', 'name': 'myScheme', 'url': 'https://www.myscheme.gov.in/search/category/Agriculture,Rural%20&%20Environment'},
      {'emoji': '🛡️', 'name': 'PMFBY', 'url': 'https://pmfby.gov.in'},
      {'emoji': '📰', 'name': 'PIB Agri', 'url': 'https://pib.gov.in/RssPage.aspx?strAction=Agriculture'},
      {'emoji': '🏛️', 'name': 'Agricoop', 'url': 'https://agricoop.gov.in/en/schemes'},
      {'emoji': '🧮', 'name': 'Premium Calc', 'url': 'https://pmfby.gov.in/premiumCalculator'},
    ];

    return Wrap(
      spacing: 10, runSpacing: 10,
      children: links.map((link) => InkWell(
        onTap: () => js.context.callMethod('open', [link['url'], '_blank']),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: (MediaQuery.of(context).size.width - 62) / 4,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2D6A4F).withValues(alpha: 0.1)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(link['emoji']!, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(link['name']!, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF1B2A1B))),
            const SizedBox(height: 4),
            const Icon(Icons.open_in_new, size: 10, color: Color(0xFF2D6A4F)),
          ]),
        ),
      )).toList(),
    );
  }

  Widget _buildInfoCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF2D6A4F).withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF2D6A4F).withValues(alpha: 0.12)),
    ),
    child: Row(children: [
      const Text('ℹ️', style: TextStyle(fontSize: 22)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(AppStrings.t('govtDataNote'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2D6A4F))),
        const SizedBox(height: 2),
        Text(AppStrings.t('govtDataNoteDetail'), style: const TextStyle(fontSize: 11, color: Color(0xFF6B7B6B), height: 1.3)),
      ])),
    ]),
  );
}
