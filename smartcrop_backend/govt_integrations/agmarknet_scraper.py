"""
Agmarknet (Agricultural Marketing Information Network) Integration
Provides commodity-wise price trends and market analysis — with live data fetch
"""

import sqlite3
import os
import logging
import random
import re
from datetime import datetime, timedelta

try:
    import requests
except ImportError:
    requests = None

try:
    from bs4 import BeautifulSoup
except ImportError:
    BeautifulSoup = None

logger = logging.getLogger(__name__)

DB_PATH = os.path.join(os.path.dirname(__file__), 'govt_cache.db')

# Real government URLs
AGMARKNET_URL = 'https://agmarknet.gov.in/SearchCmmMkt.aspx'
ENAM_PRICES_URL = 'https://enam.gov.in/web/guest/commodity-wise-daily'

# Historical commodity price trend data (simulated from real patterns)
COMMODITY_TRENDS = {
    'Wheat': {'season': 'Rabi', 'peak_months': [3, 4], 'low_months': [6, 7]},
    'Rice (Paddy)': {'season': 'Kharif', 'peak_months': [11, 12], 'low_months': [3, 4]},
    'Maize': {'season': 'Kharif', 'peak_months': [10, 11], 'low_months': [2, 3]},
    'Cotton': {'season': 'Kharif', 'peak_months': [12, 1], 'low_months': [5, 6]},
    'Soybean': {'season': 'Kharif', 'peak_months': [10, 11], 'low_months': [3, 4]},
    'Sugarcane': {'season': 'Annual', 'peak_months': [1, 2], 'low_months': [7, 8]},
    'Mustard': {'season': 'Rabi', 'peak_months': [4, 5], 'low_months': [8, 9]},
    'Groundnut': {'season': 'Kharif', 'peak_months': [11, 12], 'low_months': [4, 5]},
    'Chana (Chickpea)': {'season': 'Rabi', 'peak_months': [3, 4], 'low_months': [6, 7]},
    'Tur (Pigeon Pea)': {'season': 'Kharif', 'peak_months': [12, 1], 'low_months': [6, 7]},
    'Onion': {'season': 'Rabi/Late Kharif', 'peak_months': [9, 10, 11], 'low_months': [2, 3]},
    'Potato': {'season': 'Rabi', 'peak_months': [6, 7, 8], 'low_months': [1, 2, 3]},
    'Tomato': {'season': 'All Season', 'peak_months': [6, 7, 8], 'low_months': [11, 12, 1]},
}


def _init_db():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS commodity_trends (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        commodity TEXT, month TEXT, year INTEGER,
        avg_price REAL, volume REAL,
        yoy_change REAL,
        source TEXT DEFAULT 'generated',
        created_at TEXT
    )''')
    c.execute('''CREATE TABLE IF NOT EXISTS market_alerts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        commodity TEXT, alert_type TEXT,
        message TEXT, severity TEXT,
        url TEXT DEFAULT '',
        created_at TEXT
    )''')
    # Add columns if missing (migration)
    for col, table in [('source', 'commodity_trends'), ('url', 'market_alerts')]:
        try:
            c.execute(f'ALTER TABLE {table} ADD COLUMN {col} TEXT DEFAULT ""')
        except Exception:
            pass
    conn.commit()
    conn.close()


def _try_fetch_agmarknet_alerts():
    """
    Attempt to scrape Agmarknet for real market data or news.
    Returns list of market alert dicts on success, empty list on failure.
    """
    alerts = []
    if not requests:
        return alerts
    headers = {'User-Agent': 'AgroGuard-AI/1.0 (Agricultural Decision Support)'}

    try:
        resp = requests.get(AGMARKNET_URL, headers=headers, timeout=10)
        if resp.status_code == 200 and BeautifulSoup:
            soup = BeautifulSoup(resp.text, 'lxml')
            # Look for any table with price-like data or any news/alert elements
            tables = soup.find_all('table')
            for table in tables[:3]:
                rows_el = table.find_all('tr')
                for row in rows_el[1:10]:  # First few data rows
                    cells = row.find_all(['td', 'th'])
                    if len(cells) >= 3:
                        texts = [c.get_text(strip=True) for c in cells]
                        # If it looks like commodity data
                        if any(c for c in texts if c and len(c) > 2):
                            commodity = texts[0] if texts[0] else 'General'
                            msg = ' — '.join(t for t in texts if t)
                            if len(msg) > 10:
                                alerts.append({
                                    'commodity': commodity,
                                    'alert_type': 'live_data',
                                    'message': msg[:200],
                                    'severity': 'info',
                                    'url': AGMARKNET_URL,
                                })
            if alerts:
                logger.info(f"Fetched {len(alerts)} data points from Agmarknet")

    except Exception as e:
        logger.debug(f"Agmarknet fetch error: {e}")

    return alerts


def _seed_trends():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute('SELECT COUNT(*) FROM commodity_trends')
    if c.fetchone()[0] > 0:
        conn.close()
        return

    from .enam_scraper import COMMODITIES
    now = datetime.now()
    rows = []

    for commodity, info in COMMODITIES.items():
        trend = COMMODITY_TRENDS.get(commodity, {'peak_months': [1], 'low_months': [7]})
        base = (info['min'] + info['max']) / 2

        for month_offset in range(12):
            dt = now - timedelta(days=30 * month_offset)
            month = dt.month
            year = dt.year
            month_name = dt.strftime('%b %Y')

            if month in trend.get('peak_months', []):
                factor = random.uniform(1.08, 1.20)
            elif month in trend.get('low_months', []):
                factor = random.uniform(0.80, 0.92)
            else:
                factor = random.uniform(0.95, 1.05)

            price = round(base * factor, 0)
            volume = round(random.uniform(1000, 15000), 0)
            yoy = round(random.uniform(-12, 18), 1)

            rows.append((commodity, month_name, year, price, volume, yoy, 'generated', now.isoformat()))

    c.executemany('''INSERT INTO commodity_trends
        (commodity, month, year, avg_price, volume, yoy_change, source, created_at)
        VALUES (?,?,?,?,?,?,?,?)''', rows)

    # Seed built-in market alerts
    alerts = [
        ('Wheat', 'price_surge', 'Wheat prices up 8% in Punjab mandis due to export demand', 'high', ''),
        ('Onion', 'shortage', 'Onion supply shortage expected in coming weeks — unseasonal rains', 'critical', ''),
        ('Rice (Paddy)', 'msp_update', 'Government announces MSP for Kharif paddy at ₹2,183/quintal', 'info', ''),
        ('Cotton', 'export', 'Cotton exports rise 15% — global demand boosting prices', 'medium', ''),
        ('Tomato', 'price_drop', 'Tomato prices normalize after summer peak', 'low', ''),
        ('Soybean', 'procurement', 'NAFED begins soybean procurement in MP at MSP rates', 'info', ''),
        ('Mustard', 'price_surge', 'Mustard oil prices at 3-year high — limited supply', 'high', ''),
        ('Potato', 'cold_storage', 'Cold storage stocks adequate — prices expected to remain stable', 'info', ''),
    ]
    for a in alerts:
        c.execute('''INSERT INTO market_alerts (commodity, alert_type, message, severity, url, created_at)
                     VALUES (?,?,?,?,?,?)''', (*a, now.isoformat()))

    # Try live Agmarknet data
    live_alerts = _try_fetch_agmarknet_alerts()
    for la in live_alerts[:10]:
        c.execute('''INSERT INTO market_alerts (commodity, alert_type, message, severity, url, created_at)
                     VALUES (?,?,?,?,?,?)''',
                  (la['commodity'], la['alert_type'], la['message'],
                   la['severity'], la.get('url', ''), now.isoformat()))

    conn.commit()
    conn.close()
    logger.info(f"Seeded commodity trends for {len(COMMODITIES)} commodities + {len(live_alerts)} live alerts")


def init():
    _init_db()
    _seed_trends()


def get_commodity_trend(commodity, months=6):
    """Get price trend for a commodity over N months."""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    c = conn.cursor()
    c.execute('''SELECT * FROM commodity_trends
                 WHERE LOWER(commodity) LIKE LOWER(?)
                 ORDER BY id DESC LIMIT ?''',
              (f'%{commodity}%', months))
    rows = [dict(r) for r in c.fetchall()]
    conn.close()

    trend_info = COMMODITY_TRENDS.get(commodity, {})
    return {
        'commodity': commodity,
        'season': trend_info.get('season', 'Unknown'),
        'trend_data': rows,
        'analysis': {
            'peak_months': [_month_name(m) for m in trend_info.get('peak_months', [])],
            'low_months': [_month_name(m) for m in trend_info.get('low_months', [])],
            'recommendation': _get_trade_recommendation(commodity, rows),
        }
    }


def get_market_alerts(commodity=None):
    """Get market alerts, optionally filtered by commodity."""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    c = conn.cursor()
    if commodity:
        c.execute('SELECT * FROM market_alerts WHERE LOWER(commodity) LIKE LOWER(?) ORDER BY id DESC',
                  (f'%{commodity}%',))
    else:
        c.execute('SELECT * FROM market_alerts ORDER BY id DESC')
    rows = [dict(r) for r in c.fetchall()]
    conn.close()
    return rows


def get_seasonal_calendar():
    """Get crop seasonal calendar with best buy/sell months."""
    calendar = []
    for commodity, info in COMMODITY_TRENDS.items():
        calendar.append({
            'commodity': commodity,
            'season': info['season'],
            'best_sell_months': [_month_name(m) for m in info['peak_months']],
            'best_buy_months': [_month_name(m) for m in info['low_months']],
        })
    return calendar


def _month_name(m):
    import calendar
    return calendar.month_abbr[m] if 1 <= m <= 12 else str(m)


def _get_trade_recommendation(commodity, rows):
    if not rows:
        return 'Insufficient data'
    prices = [r['avg_price'] for r in rows if r['avg_price']]
    if len(prices) < 2:
        return 'Hold — need more data'
    recent = prices[0]
    avg = sum(prices) / len(prices)
    if recent > avg * 1.10:
        return f'SELL — Current price ₹{recent:,.0f} is {((recent/avg)-1)*100:.0f}% above average'
    elif recent < avg * 0.90:
        return f'BUY/HOLD — Current price ₹{recent:,.0f} is {((avg/recent)-1)*100:.0f}% below average'
    else:
        return f'HOLD — Price ₹{recent:,.0f} is near the average ₹{avg:,.0f}'
