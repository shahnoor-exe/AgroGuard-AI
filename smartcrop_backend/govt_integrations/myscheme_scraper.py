"""
myScheme Portal Integration
Government scheme eligibility checker with real govt URL linking.
Sources:
  - https://www.myscheme.gov.in/search/category/Agriculture,Rural%20&%20Environment
  - https://agricoop.gov.in/en/schemes
"""

import sqlite3
import os
import logging
import re
import traceback
from datetime import datetime

try:
    import requests
    from bs4 import BeautifulSoup
except ImportError:
    requests = None
    BeautifulSoup = None

logger = logging.getLogger(__name__)

DB_PATH = os.path.join(os.path.dirname(__file__), 'govt_cache.db')

MYSCHEME_URL = 'https://www.myscheme.gov.in/search/category/Agriculture,Rural%20&%20Environment'
AGRICOOP_URL = 'https://agricoop.gov.in/en/schemes'

# Comprehensive Indian Government schemes for farmers
SCHEMES_DB = [
    {
        'name': 'PM-KISAN Samman Nidhi',
        'ministry': 'Ministry of Agriculture & Farmers Welfare',
        'description': 'Direct income support of ₹6,000/year in 3 installments to all land-holding farmer families.',
        'benefits': '₹6,000 per year (₹2,000 every 4 months) directly to bank account',
        'eligibility': 'All farmer families with cultivable land. Exclusions: income tax payers, govt employees, institutional land holders, professionals (doctors, engineers, lawyers, CAs).',
        'documents': 'Aadhaar Card, Bank Account (Aadhaar linked), Land Records/Khasra-Khatauni',
        'how_to_apply': 'Apply at pmkisan.gov.in or through Common Service Centre (CSC) or local Patwari/Revenue officer',
        'website': 'https://pmkisan.gov.in',
        'category': 'income_support',
        'tags': 'income,cash,direct benefit,pm kisan,small farmer,marginal farmer,land holder',
        'state': 'All India',
        'min_land': 0, 'max_land': 9999,
        'min_age': 18, 'max_age': 99,
        'gender': 'all',
        'farmer_type': 'all',
    },
    {
        'name': 'PM Fasal Bima Yojana (PMFBY)',
        'ministry': 'Ministry of Agriculture & Farmers Welfare',
        'description': 'Comprehensive crop insurance against natural calamities, pests, and diseases at affordable premium.',
        'benefits': 'Insurance cover for full sum insured. Premium: Kharif 2%, Rabi 1.5%, Horticulture 5%. Remaining premium paid by Govt.',
        'eligibility': 'All farmers growing notified crops in notified areas. Both loanee and non-loanee farmers eligible.',
        'documents': 'Aadhaar Card, Bank Account, Land Records, Sowing Certificate, Previous season crop details',
        'how_to_apply': 'Through bank (loanee farmers), CSC, or pmfby.gov.in. Deadline: Before sowing season cutoff date.',
        'website': 'https://pmfby.gov.in',
        'category': 'insurance',
        'tags': 'insurance,crop insurance,fasal bima,natural calamity,flood,drought,pest,disease',
        'state': 'All India',
        'min_land': 0, 'max_land': 9999,
        'min_age': 18, 'max_age': 99,
        'gender': 'all',
        'farmer_type': 'all',
    },
    {
        'name': 'Kisan Credit Card (KCC)',
        'ministry': 'Ministry of Agriculture & Farmers Welfare / RBI',
        'description': 'Provides affordable credit to farmers for crop production, post-harvest expenses, and allied activities at 4% interest.',
        'benefits': 'Credit limit up to ₹3 lakh at 4% interest (with interest subvention). Can also get ₹1.6 lakh for animal husbandry/fisheries.',
        'eligibility': 'All farmers — owner cultivators, tenant farmers, sharecroppers, SHGs, JLGs. PM-KISAN beneficiaries auto-eligible.',
        'documents': 'Aadhaar, PAN Card, Land Records, Passport Photo, Bank Account details',
        'how_to_apply': 'Apply at any bank branch or through PM-KISAN portal. Simplified 1-page application form.',
        'website': 'https://pmkisan.gov.in/KCCForm.aspx',
        'category': 'credit',
        'tags': 'loan,credit,kcc,kisan credit card,bank loan,interest,subvention,working capital',
        'state': 'All India',
        'min_land': 0, 'max_land': 9999,
        'min_age': 18, 'max_age': 75,
        'gender': 'all',
        'farmer_type': 'all',
    },
    {
        'name': 'Soil Health Card Scheme',
        'ministry': 'Ministry of Agriculture & Farmers Welfare',
        'description': 'Free soil testing and health card with crop-wise fertilizer recommendations to improve productivity and reduce input costs.',
        'benefits': 'Free soil testing, nutrient status report, crop-wise fertilizer recommendations. Saves 10-15% on fertilizer costs.',
        'eligibility': 'All farmers with agricultural land.',
        'documents': 'Aadhaar Card, Land details, Mobile number',
        'how_to_apply': 'Contact nearest Soil Testing Lab, KVK, or Agriculture Department office. Also available at soilhealth.dac.gov.in',
        'website': 'https://soilhealth.dac.gov.in',
        'category': 'input_support',
        'tags': 'soil,testing,health,fertilizer,nutrient,organic,recommendation',
        'state': 'All India',
        'min_land': 0, 'max_land': 9999,
        'min_age': 18, 'max_age': 99,
        'gender': 'all',
        'farmer_type': 'all',
    },
    {
        'name': 'PM Kisan Maandhan Yojana',
        'ministry': 'Ministry of Agriculture & Farmers Welfare',
        'description': 'Pension scheme for small & marginal farmers. ₹3,000/month pension after age 60.',
        'benefits': '₹3,000/month pension after 60 years. Monthly contribution: ₹55-200 based on entry age. Govt matches equal amount.',
        'eligibility': 'Small & marginal farmers (land up to 2 hectares). Age 18-40 years. Not income tax payer.',
        'documents': 'Aadhaar Card, Bank Account, Land Records, Age proof',
        'how_to_apply': 'Visit nearest CSC or register at maandhan.in. Self-enrollment also available.',
        'website': 'https://maandhan.in',
        'category': 'pension',
        'tags': 'pension,old age,retirement,social security,small farmer,marginal farmer',
        'state': 'All India',
        'min_land': 0, 'max_land': 2,
        'min_age': 18, 'max_age': 40,
        'gender': 'all',
        'farmer_type': 'small_marginal',
    },
    {
        'name': 'National Mission on Sustainable Agriculture (NMSA)',
        'ministry': 'Ministry of Agriculture & Farmers Welfare',
        'description': 'Promotes sustainable agricultural practices — micro irrigation, organic farming, soil health, climate adaptation.',
        'benefits': 'Subsidy up to 55% on micro irrigation (drip/sprinkler). Support for organic farming, soil conservation, water management.',
        'eligibility': 'All farmers. Priority to small, marginal, SC/ST, women farmers.',
        'documents': 'Aadhaar, Land Records, Bank Account, Caste Certificate (if applicable)',
        'how_to_apply': 'Apply through State Agriculture Department or DBT Agriculture portal of respective state.',
        'website': 'https://nmsa.dac.gov.in',
        'category': 'subsidy',
        'tags': 'organic,drip,sprinkler,irrigation,sustainable,micro irrigation,water,subsidy',
        'state': 'All India',
        'min_land': 0, 'max_land': 9999,
        'min_age': 18, 'max_age': 99,
        'gender': 'all',
        'farmer_type': 'all',
    },
    {
        'name': 'Agriculture Infrastructure Fund (AIF)',
        'ministry': 'Ministry of Agriculture & Farmers Welfare',
        'description': 'Financing facility of ₹1 lakh crore for post-harvest management and agricultural infrastructure.',
        'benefits': 'Loans up to ₹2 crore with 3% interest subvention for 7 years. Credit guarantee via CGTMSE.',
        'eligibility': 'Farmers, FPOs, PACS, SHGs, Entrepreneurs, Agri-startups, State agencies.',
        'documents': 'Project Report, Aadhaar, PAN, Bank Account, Land/Lease documents, GST (if applicable)',
        'how_to_apply': 'Apply online at agriinfra.dac.gov.in. Loans sanctioned through scheduled banks, NBFCs.',
        'website': 'https://agriinfra.dac.gov.in',
        'category': 'infrastructure',
        'tags': 'warehouse,cold storage,infrastructure,processing,aif,loan,subsidy,fpo,cooperative',
        'state': 'All India',
        'min_land': 0, 'max_land': 9999,
        'min_age': 18, 'max_age': 99,
        'gender': 'all',
        'farmer_type': 'all',
    },
    {
        'name': 'Rashtriya Krishi Vikas Yojana (RKVY)',
        'ministry': 'Ministry of Agriculture & Farmers Welfare',
        'description': 'State-driven scheme for holistic agriculture development — innovation, agri-entrepreneurship (RAFTAAR).',
        'benefits': 'Project grants up to ₹25 lakh for agri-startups. Fund for innovation, value chain development, skill building.',
        'eligibility': 'Agri-startups, entrepreneurs, FPOs, innovators in agriculture sector.',
        'documents': 'Business Plan, Aadhaar, PAN, Bank Account, Education certificates',
        'how_to_apply': 'Through RKVY-RAFTAAR portal or State Agriculture Department. Incubation through selected R-ABIs.',
        'website': 'https://rkvy.nic.in',
        'category': 'startup',
        'tags': 'startup,entrepreneur,innovation,raftaar,agri business,incubation,grant',
        'state': 'All India',
        'min_land': 0, 'max_land': 9999,
        'min_age': 18, 'max_age': 45,
        'gender': 'all',
        'farmer_type': 'all',
    },
    {
        'name': 'PM Kusum Yojana',
        'ministry': 'Ministry of New and Renewable Energy',
        'description': 'Solar pumps & solarization of grid-connected pumps for farmers. Reduce irrigation costs to near zero.',
        'benefits': 'Subsidy up to 60% on solar pumps (up to 7.5 HP). Additional income by selling surplus solar power to DISCOM.',
        'eligibility': 'All farmers with agricultural grid connection or requiring irrigation pump.',
        'documents': 'Aadhaar, Land Records, Electricity connection details, Bank Account',
        'how_to_apply': 'Apply via State Renewable Energy Department or MNRE portal. Check kusum.online',
        'website': 'https://mnre.gov.in/kusum',
        'category': 'energy',
        'tags': 'solar,pump,electricity,energy,irrigation,kusum,subsidy,renewable',
        'state': 'All India',
        'min_land': 0, 'max_land': 9999,
        'min_age': 18, 'max_age': 99,
        'gender': 'all',
        'farmer_type': 'all',
    },
    {
        'name': 'Mahila Kisan Sashaktikaran Pariyojana (MKSP)',
        'ministry': 'Ministry of Rural Development',
        'description': 'Empowerment of women farmers in agriculture — skill training, sustainable farming practices, market linkage.',
        'benefits': 'Training on sustainable agriculture, livestock, NTFP. SHG formation. Market access. Certification for organic.',
        'eligibility': 'Women farmers, especially from vulnerable communities. Priority to SC/ST/minority women.',
        'documents': 'Aadhaar, Bank Account, SHG membership details, BPL card (if applicable)',
        'how_to_apply': 'Through SHGs and State Rural Livelihood Missions (SRLM). Contact local block office.',
        'website': 'https://nrlm.gov.in',
        'category': 'women',
        'tags': 'women,mahila,empowerment,training,skill,shg,self help group',
        'state': 'All India',
        'min_land': 0, 'max_land': 9999,
        'min_age': 18, 'max_age': 65,
        'gender': 'female',
        'farmer_type': 'all',
    },
    {
        'name': 'Sub-Mission on Agricultural Mechanization (SMAM)',
        'ministry': 'Ministry of Agriculture & Farmers Welfare',
        'description': 'Subsidized farm machinery — tractors, harvesters, rotavators, threshers. Custom hiring centres.',
        'benefits': 'Subsidy 40-50% on farm equipment. 80% subsidy for Custom Hiring Centres. Higher subsidy for SC/ST/women/NE states.',
        'eligibility': 'All farmers. Priority to small/marginal, SC/ST, women. Individuals, FPOs, cooperatives.',
        'documents': 'Aadhaar, Land Records, Bank Account, Quotation from dealer, Caste certificate (if applicable)',
        'how_to_apply': 'Apply on agrimachinery.nic.in or through District Agriculture office.',
        'website': 'https://agrimachinery.nic.in',
        'category': 'mechanization',
        'tags': 'tractor,machinery,equipment,harvester,subsidy,mechanization,custom hiring',
        'state': 'All India',
        'min_land': 0, 'max_land': 9999,
        'min_age': 18, 'max_age': 99,
        'gender': 'all',
        'farmer_type': 'all',
    },
    {
        'name': 'National Horticulture Mission (NHM)',
        'ministry': 'Ministry of Agriculture & Farmers Welfare',
        'description': 'Promotes horticulture — fruits, vegetables, flowers, spices. Covers production, PHM, and marketing.',
        'benefits': 'Subsidy for planting material, drip irrigation, green houses, pack houses, cold storage. Up to 50% cost.',
        'eligibility': 'Horticulture farmers. Land required for area expansion. FPOs, cooperatives eligible for PHM.',
        'documents': 'Aadhaar, Land Records, Bank Account, Project proposal (for infrastructure)',
        'how_to_apply': 'Apply through State Horticulture Mission / Department. Online in some states.',
        'website': 'https://nhm.gov.in',
        'category': 'horticulture',
        'tags': 'fruit,vegetable,flower,spice,horticulture,greenhouse,polyhouse,nursery',
        'state': 'All India',
        'min_land': 0, 'max_land': 9999,
        'min_age': 18, 'max_age': 99,
        'gender': 'all',
        'farmer_type': 'all',
    },
]


def _init_db():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS govt_schemes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT, ministry TEXT, description TEXT,
        benefits TEXT, eligibility TEXT, documents TEXT,
        how_to_apply TEXT, website TEXT,
        category TEXT, tags TEXT, state TEXT,
        min_land REAL, max_land REAL,
        min_age INTEGER, max_age INTEGER,
        gender TEXT, farmer_type TEXT,
        source TEXT DEFAULT 'built-in',
        created_at TEXT
    )''')
    c.execute('''CREATE TABLE IF NOT EXISTS farmer_saved_schemes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        scheme_id INTEGER, farmer_name TEXT,
        saved_at TEXT,
        FOREIGN KEY(scheme_id) REFERENCES govt_schemes(id)
    )''')
    conn.commit()
    conn.close()


def _try_fetch_live_schemes():
    """
    Attempt to scrape schemes from myScheme.gov.in and agricoop.gov.in.
    Returns list of extra scheme dicts, or empty list.
    """
    extra = []
    if not requests:
        return extra
    headers = {'User-Agent': 'AgroGuard-AI/1.0 (Agricultural Decision Support)'}

    # 1) Try myScheme.gov.in
    try:
        resp = requests.get(MYSCHEME_URL, headers=headers, timeout=10)
        if resp.status_code == 200 and BeautifulSoup:
            soup = BeautifulSoup(resp.text, 'lxml')
            cards = soup.select('.card, .scheme-card, article, .search-result-item, [class*=scheme]')
            if not cards:
                cards = soup.find_all('div', class_=re.compile(r'card|scheme|result', re.I))
            for card in cards[:20]:
                title_el = card.find(['h2', 'h3', 'h4', 'a'])
                desc_el = card.find('p')
                link_el = card.find('a', href=True)
                if title_el:
                    name = title_el.get_text(strip=True)
                    if len(name) > 5:
                        extra.append({
                            'name': name,
                            'description': desc_el.get_text(strip=True) if desc_el else name,
                            'website': 'https://www.myscheme.gov.in' + link_el['href'] if link_el and link_el['href'].startswith('/') else MYSCHEME_URL,
                            'source': 'myscheme.gov.in',
                        })
            if extra:
                logger.info(f"Fetched {len(extra)} schemes from myScheme.gov.in")
    except Exception as e:
        logger.debug(f"myScheme fetch error: {e}")

    # 2) Try agricoop.gov.in
    try:
        resp = requests.get(AGRICOOP_URL, headers=headers, timeout=10)
        if resp.status_code == 200 and BeautifulSoup:
            soup = BeautifulSoup(resp.text, 'lxml')
            links = soup.find_all('a', href=True)
            for a in links:
                text = a.get_text(strip=True)
                href = a['href']
                if len(text) > 10 and ('scheme' in text.lower() or 'yojana' in text.lower() or 'mission' in text.lower()):
                    full_url = href if href.startswith('http') else f'https://agricoop.gov.in{href}'
                    extra.append({
                        'name': text,
                        'description': text,
                        'website': full_url,
                        'source': 'agricoop.gov.in',
                    })
            if extra:
                logger.info(f"Fetched {len(extra)} scheme links from agricoop.gov.in")
    except Exception as e:
        logger.debug(f"Agricoop fetch error: {e}")

    return extra


def _seed_schemes():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute('SELECT COUNT(*) FROM govt_schemes')
    if c.fetchone()[0] > 0:
        conn.close()
        return

    now = datetime.now().isoformat()

    # Seed built-in schemes
    for s in SCHEMES_DB:
        c.execute('''INSERT INTO govt_schemes
            (name, ministry, description, benefits, eligibility, documents,
             how_to_apply, website, category, tags, state,
             min_land, max_land, min_age, max_age, gender, farmer_type, source, created_at)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)''',
                  (s['name'], s['ministry'], s['description'], s['benefits'],
                   s['eligibility'], s['documents'], s['how_to_apply'], s['website'],
                   s['category'], s['tags'], s['state'],
                   s['min_land'], s['max_land'], s['min_age'], s['max_age'],
                   s['gender'], s['farmer_type'], 'built-in', now))

    # Attempt live fetch for additional schemes
    live = _try_fetch_live_schemes()
    for ls in live:
        # Only add if not duplicate
        c.execute('SELECT COUNT(*) FROM govt_schemes WHERE LOWER(name) = LOWER(?)', (ls['name'],))
        if c.fetchone()[0] == 0:
            c.execute('''INSERT INTO govt_schemes
                (name, ministry, description, benefits, eligibility, documents,
                 how_to_apply, website, category, tags, state,
                 min_land, max_land, min_age, max_age, gender, farmer_type, source, created_at)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)''',
                      (ls['name'], ls.get('ministry', 'Government of India'),
                       ls.get('description', ''), ls.get('benefits', 'Visit website for details'),
                       ls.get('eligibility', 'Check website'), ls.get('documents', 'Aadhaar, Bank Account'),
                       f"Visit {ls.get('website', MYSCHEME_URL)}", ls.get('website', MYSCHEME_URL),
                       'general', 'government,scheme,agriculture', 'All India',
                       0, 9999, 18, 99, 'all', 'all', ls.get('source', 'live'), now))

    conn.commit()
    conn.close()
    logger.info(f"Seeded {len(SCHEMES_DB)} built-in + {len(live)} live schemes")


def init():
    _init_db()
    _seed_schemes()


def get_all_schemes():
    """Get all available government schemes."""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    c = conn.cursor()
    c.execute('SELECT * FROM govt_schemes ORDER BY name')
    rows = [dict(r) for r in c.fetchall()]
    conn.close()
    return rows


def check_eligibility(age=None, gender=None, land_hectares=None, state=None,
                      farmer_type=None, keywords=None):
    """
    Check scheme eligibility based on farmer profile.
    Returns matched schemes sorted by relevance.
    """
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    c = conn.cursor()
    c.execute('SELECT * FROM govt_schemes')
    all_schemes = [dict(r) for r in c.fetchall()]
    conn.close()

    results = []

    for scheme in all_schemes:
        score = 0
        reasons = []
        disqualified = False

        # Age check
        if age is not None:
            if scheme['min_age'] <= age <= scheme['max_age']:
                score += 10
            else:
                disqualified = True
                reasons.append(f"Age requirement: {scheme['min_age']}-{scheme['max_age']} years")

        # Gender check
        if gender and scheme['gender'] != 'all':
            if gender.lower() != scheme['gender'].lower():
                disqualified = True
                reasons.append(f"Available for {scheme['gender']} only")

        # Land holding check
        if land_hectares is not None:
            if scheme['min_land'] <= land_hectares <= scheme['max_land']:
                score += 10
                if scheme['max_land'] <= 5:
                    score += 5  # Bonus for targeted schemes
            else:
                disqualified = True
                reasons.append(f"Land requirement: {scheme['min_land']}-{scheme['max_land']} hectares")

        # Farmer type check
        if farmer_type and scheme['farmer_type'] != 'all':
            if farmer_type.lower() == scheme['farmer_type'].replace('_', ' ').lower():
                score += 15
            else:
                score -= 5

        # Keyword/tag matching (simple TF-IDF-like scoring)
        if keywords:
            kw_lower = keywords.lower().split()
            tags = scheme['tags'].lower()
            desc = scheme['description'].lower()
            name = scheme['name'].lower()
            for kw in kw_lower:
                if kw in tags:
                    score += 8
                if kw in desc:
                    score += 5
                if kw in name:
                    score += 12

        if not disqualified:
            score += 10  # Base score for eligible
            results.append({
                **scheme,
                'match_score': score,
                'eligible': True,
                'match_reasons': [],
            })
        else:
            results.append({
                **scheme,
                'match_score': max(0, score),
                'eligible': False,
                'match_reasons': reasons,
            })

    # Sort: eligible first, then by score
    results.sort(key=lambda x: (-int(x['eligible']), -x['match_score']))

    eligible = [r for r in results if r['eligible']]
    ineligible = [r for r in results if not r['eligible']]

    return {
        'total_schemes': len(all_schemes),
        'eligible_count': len(eligible),
        'eligible_schemes': eligible,
        'ineligible_schemes': ineligible[:5],  # Top 5 ineligible with reasons
        'profile': {
            'age': age, 'gender': gender,
            'land_hectares': land_hectares,
            'state': state, 'farmer_type': farmer_type,
            'keywords': keywords,
        }
    }


def get_scheme_by_id(scheme_id):
    """Get full scheme details by ID."""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    c = conn.cursor()
    c.execute('SELECT * FROM govt_schemes WHERE id = ?', (scheme_id,))
    row = c.fetchone()
    conn.close()
    return dict(row) if row else None


def get_scheme_categories():
    """Get scheme categories with counts."""
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute('SELECT category, COUNT(*) as cnt FROM govt_schemes GROUP BY category ORDER BY cnt DESC')
    cats = [{'category': r[0], 'count': r[1]} for r in c.fetchall()]
    conn.close()
    return cats
