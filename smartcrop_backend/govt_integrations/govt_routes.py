"""
Government Integration Flask Blueprint
RESTful API endpoints for all 5 government portal integrations
"""

import logging
from flask import Blueprint, request, jsonify
from datetime import datetime

logger = logging.getLogger(__name__)

govt_bp = Blueprint('govt', __name__, url_prefix='/api/govt')

# Import integration modules
from . import enam_scraper
from . import agmarknet_scraper
from . import mkisan_fetcher
from . import myscheme_scraper
from . import pmfby_checker


def init_all():
    """Initialize all government integration modules and seed data."""
    logger.info("Initializing Government Portal integrations...")
    enam_scraper.init()
    agmarknet_scraper.init()
    mkisan_fetcher.init()
    myscheme_scraper.init()
    pmfby_checker.init()
    logger.info("✅ Government Portal integrations initialized")


# ============================================================================
# eNAM — Mandi Prices
# ============================================================================

@govt_bp.route('/mandi/prices', methods=['GET'])
def mandi_prices():
    """Get mandi prices with optional filters."""
    try:
        state = request.args.get('state')
        commodity = request.args.get('commodity')
        mandi = request.args.get('mandi')
        limit = int(request.args.get('limit', 50))

        prices = enam_scraper.get_mandi_prices(state=state, commodity=commodity, mandi=mandi, limit=limit)
        return jsonify({
            'success': True,
            'source': 'eNAM',
            'count': len(prices),
            'data': prices,
            'last_updated': datetime.now().isoformat(),
        })
    except Exception as e:
        logger.error(f"Mandi prices error: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@govt_bp.route('/mandi/compare/<commodity>', methods=['GET'])
def mandi_compare(commodity):
    """Compare prices for a commodity across mandis."""
    try:
        result = enam_scraper.get_price_comparison(commodity)
        return jsonify({'success': True, 'source': 'eNAM', **result})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@govt_bp.route('/mandi/states', methods=['GET'])
def mandi_states():
    """Get available states."""
    return jsonify({'success': True, 'states': enam_scraper.get_states()})


@govt_bp.route('/mandi/commodities', methods=['GET'])
def mandi_commodities():
    """Get available commodities with MSP info."""
    return jsonify({'success': True, 'commodities': enam_scraper.get_commodities()})


@govt_bp.route('/mandi/mandis/<state>', methods=['GET'])
def mandi_list(state):
    """Get mandis for a state."""
    return jsonify({'success': True, 'state': state, 'mandis': enam_scraper.get_mandis_for_state(state)})


# ============================================================================
# Agmarknet — Commodity Trends & Market Analysis
# ============================================================================

@govt_bp.route('/market/trend/<commodity>', methods=['GET'])
def market_trend(commodity):
    """Get commodity price trend."""
    try:
        months = int(request.args.get('months', 6))
        result = agmarknet_scraper.get_commodity_trend(commodity, months=months)
        return jsonify({'success': True, 'source': 'Agmarknet', **result})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@govt_bp.route('/market/alerts', methods=['GET'])
def market_alerts():
    """Get market alerts."""
    try:
        commodity = request.args.get('commodity')
        alerts = agmarknet_scraper.get_market_alerts(commodity=commodity)
        return jsonify({'success': True, 'count': len(alerts), 'alerts': alerts})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@govt_bp.route('/market/calendar', methods=['GET'])
def seasonal_calendar():
    """Get crop seasonal buy/sell calendar."""
    return jsonify({'success': True, 'calendar': agmarknet_scraper.get_seasonal_calendar()})


# ============================================================================
# mKisan — Government Advisories
# ============================================================================

@govt_bp.route('/advisories', methods=['GET'])
def advisories():
    """Get government advisories with optional filters."""
    try:
        category = request.args.get('category')
        state = request.args.get('state')
        crop = request.args.get('crop')
        limit = int(request.args.get('limit', 30))

        advs = mkisan_fetcher.get_advisories(category=category, state=state, crop=crop, limit=limit)
        return jsonify({
            'success': True,
            'source': 'mKisan',
            'count': len(advs),
            'data': advs,
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@govt_bp.route('/advisories/categories', methods=['GET'])
def advisory_categories():
    """Get advisory category list."""
    return jsonify({'success': True, 'categories': mkisan_fetcher.get_categories()})


@govt_bp.route('/advisories/refresh', methods=['POST'])
def refresh_pib():
    """Force refresh PIB RSS feed for latest agriculture notifications."""
    try:
        live = mkisan_fetcher._try_fetch_pib_rss()
        if live:
            import sqlite3, os
            db = os.path.join(os.path.dirname(__file__), 'govt_cache.db')
            conn = sqlite3.connect(db)
            c = conn.cursor()
            added = 0
            for adv in live:
                c.execute('SELECT COUNT(*) FROM govt_advisories WHERE LOWER(title) = LOWER(?)', (adv['title'],))
                if c.fetchone()[0] == 0:
                    c.execute('''INSERT INTO govt_advisories
                        (category, title, body, source, crop, state, severity, published_at, url, fetched_at)
                        VALUES (?,?,?,?,?,?,?,?,?,?)''',
                        (adv['category'], adv['title'], adv['body'], adv['source'],
                         adv['crop'], adv['state'], adv['severity'], adv['published_at'],
                         adv.get('url', ''), datetime.now().isoformat()))
                    added += 1
            conn.commit()
            conn.close()
            return jsonify({'success': True, 'fetched': len(live), 'new_added': added})
        return jsonify({'success': True, 'fetched': 0, 'message': 'No new notifications from PIB'})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@govt_bp.route('/portal-links', methods=['GET'])
def portal_links():
    """Get all real government portal URLs for direct linking."""
    return jsonify({
        'success': True,
        'links': {
            'enam': {
                'name': 'eNAM — National Agriculture Market',
                'url': 'https://enam.gov.in/web/guest/commodity-wise-daily',
                'description': 'Live mandi commodity prices',
            },
            'agmarknet': {
                'name': 'Agmarknet — Agricultural Marketing',
                'url': 'https://agmarknet.gov.in/SearchCmmMkt.aspx',
                'description': 'Commodity market data and trends',
            },
            'mkisan': {
                'name': 'mKisan Portal',
                'url': 'https://mkisan.gov.in/advisoryDetails.aspx',
                'description': 'Government SMS advisories for farmers',
            },
            'myscheme': {
                'name': 'myScheme — Agriculture Schemes',
                'url': 'https://www.myscheme.gov.in/search/category/Agriculture,Rural%20&%20Environment',
                'description': 'Search government schemes for agriculture',
            },
            'pmfby': {
                'name': 'PMFBY — Crop Insurance',
                'url': 'https://pmfby.gov.in',
                'description': 'Pradhan Mantri Fasal Bima Yojana',
            },
            'pmfby_calculator': {
                'name': 'PMFBY Premium Calculator',
                'url': 'https://pmfby.gov.in/premiumCalculator',
                'description': 'Calculate crop insurance premium',
            },
            'pib': {
                'name': 'PIB — Agriculture Notifications',
                'url': 'https://pib.gov.in/RssPage.aspx?strAction=Agriculture',
                'description': 'Press Information Bureau agriculture feed',
            },
            'agricoop': {
                'name': 'Agriculture Ministry Schemes',
                'url': 'https://agricoop.gov.in/en/schemes',
                'description': 'Ministry of Agriculture official schemes',
            },
        }
    })


# ============================================================================
# myScheme — Scheme Eligibility Checker
# ============================================================================

@govt_bp.route('/schemes', methods=['GET'])
def all_schemes():
    """Get all government schemes."""
    try:
        schemes = myscheme_scraper.get_all_schemes()
        return jsonify({'success': True, 'count': len(schemes), 'schemes': schemes})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@govt_bp.route('/schemes/check', methods=['POST'])
def check_eligibility():
    """Check scheme eligibility based on farmer profile."""
    try:
        data = request.get_json() or {}
        result = myscheme_scraper.check_eligibility(
            age=data.get('age'),
            gender=data.get('gender'),
            land_hectares=data.get('land_hectares'),
            state=data.get('state'),
            farmer_type=data.get('farmer_type'),
            keywords=data.get('keywords'),
        )
        return jsonify({'success': True, **result})
    except Exception as e:
        logger.error(f"Eligibility check error: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@govt_bp.route('/schemes/<int:scheme_id>', methods=['GET'])
def scheme_detail(scheme_id):
    """Get scheme details by ID."""
    scheme = myscheme_scraper.get_scheme_by_id(scheme_id)
    if scheme:
        return jsonify({'success': True, 'scheme': scheme})
    return jsonify({'success': False, 'error': 'Scheme not found'}), 404


@govt_bp.route('/schemes/categories', methods=['GET'])
def scheme_categories():
    """Get scheme category list."""
    return jsonify({'success': True, 'categories': myscheme_scraper.get_scheme_categories()})


# ============================================================================
# PMFBY — Crop Insurance
# ============================================================================

@govt_bp.route('/insurance/calculate', methods=['POST'])
def insurance_calculate():
    """Calculate crop insurance premium."""
    try:
        data = request.get_json() or {}
        season = data.get('season', 'Kharif')
        crop = data.get('crop')
        area = float(data.get('area_hectares', 1))

        if not crop:
            return jsonify({'success': False, 'error': 'crop is required'}), 400

        result = pmfby_checker.calculate_premium(season, crop, area)
        if 'error' in result:
            return jsonify({'success': False, **result}), 404

        return jsonify({'success': True, 'source': 'PMFBY', **result})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@govt_bp.route('/insurance/status/<application_id>', methods=['GET'])
def insurance_status(application_id):
    """Check insurance claim status."""
    try:
        result = pmfby_checker.check_claim_status(application_id)
        return jsonify({'success': True, 'source': 'PMFBY', **result})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@govt_bp.route('/insurance/crops', methods=['GET'])
def insurance_crops():
    """Get available crops for insurance."""
    return jsonify({'success': True, 'crops': pmfby_checker.get_available_crops()})


@govt_bp.route('/insurance/deadlines', methods=['GET'])
def insurance_deadlines():
    """Get enrollment deadlines."""
    return jsonify({'success': True, 'deadlines': pmfby_checker.get_enrollment_deadlines()})


# ============================================================================
# Combined / Dashboard
# ============================================================================

@govt_bp.route('/dashboard', methods=['GET'])
def govt_dashboard():
    """Combined government services dashboard summary."""
    try:
        state = request.args.get('state', 'Punjab')

        # Collect summary data from all modules
        mandi_count = len(enam_scraper.get_mandi_prices(state=state, limit=100))
        advisories = mkisan_fetcher.get_advisories(state=state, limit=5)
        alerts = agmarknet_scraper.get_market_alerts()
        schemes = myscheme_scraper.get_all_schemes()
        deadlines = pmfby_checker.get_enrollment_deadlines()

        critical_alerts = [a for a in alerts if a.get('severity') in ('critical', 'high')]

        return jsonify({
            'success': True,
            'dashboard': {
                'mandi_prices_available': mandi_count,
                'active_advisories': len(advisories),
                'recent_advisories': advisories[:3],
                'market_alerts': len(alerts),
                'critical_alerts': critical_alerts[:3],
                'total_schemes': len(schemes),
                'insurance_deadlines': deadlines,
                'state': state,
                'last_updated': datetime.now().isoformat(),
            }
        })
    except Exception as e:
        logger.error(f"Dashboard error: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500
