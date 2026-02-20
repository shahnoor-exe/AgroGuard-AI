import 'package:intl/intl.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Disease Detection Service – Web-Compatible (no sqflite / dart:io)
/// Uses an in-memory store + a rich built-in local disease knowledge base.
/// ─────────────────────────────────────────────────────────────────────────────
class DiseaseDatabaseService {
  // ── In-memory history store ─────────────────────────────────────────────────
  static final List<Map<String, dynamic>> _history = [];
  static int _nextId = 1;

  // ── Built-in local disease knowledge base ──────────────────────────────────
  static const Map<String, Map<String, dynamic>> localDiseaseKB = {
    // ── Leaf spot / blight group ──────────────────────────────────────────────
    'early blight': {
      'scientificName': 'Alternaria solani',
      'affectedCrops': ['Tomato', 'Potato'],
      'severity': 'Moderate',
      'symptoms': [
        'Dark brown circular spots with concentric rings (target-board pattern)',
        'Yellow halo surrounding spots',
        'Lower/older leaves affected first',
        'Stem lesions possible near soil line',
      ],
      'causes': 'Fungal pathogen Alternaria solani; favoured by warm, wet conditions.',
      'treatment': [
        'Apply copper-based fungicide (e.g. Copper Oxychloride 50% WP @ 3 g/L)',
        'Spray Mancozeb 75% WP @ 2.5 g/L every 7-10 days',
        'Remove and destroy infected leaves immediately',
        'Apply Chlorothalonil as a protectant spray',
      ],
      'prevention': [
        'Use certified disease-free seeds / resistant varieties',
        'Practice crop rotation (3-year cycle, avoid Solanaceae)',
        'Maintain proper plant spacing for airflow',
        'Avoid overhead irrigation; use drip irrigation',
        'Apply mulch to prevent soil splash',
      ],
      'organicOptions': [
        'Neem oil spray (5 ml/L)',
        'Trichoderma viride bio-fungicide',
        'Baking soda solution (1 tsp/L water)',
      ],
    },

    'late blight': {
      'scientificName': 'Phytophthora infestans',
      'affectedCrops': ['Tomato', 'Potato'],
      'severity': 'High',
      'symptoms': [
        'Water-soaked pale green to brown lesions on leaves',
        'White cottony mould on underside of leaves in humid conditions',
        'Dark brown lesions with greasy appearance on stems',
        'Rapid wilting and collapse of entire plant',
      ],
      'causes': 'Oomycete Phytophthora infestans; spreads rapidly in cool, wet weather (10–25 °C).',
      'treatment': [
        'Apply Metalaxyl + Mancozeb @ 2.5 g/L immediately',
        'Spray Cymoxanil + Famoxadone every 5-7 days',
        'Remove and burn infected plant material',
        'Apply Fosetyl-Aluminium as systemic treatment',
      ],
      'prevention': [
        'Plant resistant varieties (e.g. Sarvodaya, Kufri Jyoti for potato)',
        'Avoid planting in low-lying, poorly drained areas',
        'Destroy volunteer potato plants and cull piles',
        'Ensure adequate phosphorus and potassium nutrition',
        'Monitor forecasts and apply preventive sprays before rain',
      ],
      'organicOptions': [
        'Copper hydroxide spray',
        'Bacillus subtilis bio-fungicide',
        'Remove infected tissue within 24 hours',
      ],
    },

    'powdery mildew': {
      'scientificName': 'Erysiphe spp. / Podosphaera spp.',
      'affectedCrops': ['Wheat', 'Cucumber', 'Grape', 'Apple', 'Tomato'],
      'severity': 'Moderate',
      'symptoms': [
        'White powdery coating on upper leaf surface',
        'Yellowing of leaves beneath white patches',
        'Stunted growth and distorted young leaves',
        'Premature leaf drop in severe cases',
      ],
      'causes': 'Obligate fungal pathogen; favoured by dry weather with high humidity and warm temperatures (15–28 °C).',
      'treatment': [
        'Spray Hexaconazole 5% SC @ 1 ml/L',
        'Apply Propiconazole 25% EC @ 1 ml/L every 10 days',
        'Use Sulphur 80% WP @ 3 g/L as contact fungicide',
        'Spray Myclobutanil for resistant strains',
      ],
      'prevention': [
        'Plant resistant varieties',
        'Maintain good plant spacing to improve air circulation',
        'Avoid excessive nitrogen fertilisation',
        'Remove infected plant debris after harvest',
      ],
      'organicOptions': [
        'Potassium bicarbonate spray (5 g/L)',
        'Neem oil + mild soap solution',
        'Whey or diluted milk spray (1:10)',
      ],
    },

    'leaf rust': {
      'scientificName': 'Puccinia triticina / P. striiformis',
      'affectedCrops': ['Wheat', 'Barley'],
      'severity': 'High',
      'symptoms': [
        'Orange-brown pustules (uredinia) on upper leaf surface',
        'Pustules rupture releasing powdery rust-coloured spores',
        'Lesions surrounded by pale yellow haze',
        'Severe lodging and grain shrivelling at high incidence',
      ],
      'causes': 'Obligate fungal pathogen Puccinia spp.; wind-dispersed spores; cool moist conditions (10–20 °C).',
      'treatment': [
        'Spray Propiconazole 25% EC @ 1 ml/L at first sign',
        'Apply Tebuconazole 25% WG @ 1 g/L',
        'Use Mancozeb 75% WP as protectant @ 2.5 g/L',
        'Combine systemic + contact fungicide for best control',
      ],
      'prevention': [
        'Sow rust-resistant varieties (HD 2967, GW 322)',
        'Adjust sowing date to avoid peak rust season',
        'Apply balanced NPK; avoid excess nitrogen',
        'Monitor fields weekly during susceptible growth stages',
      ],
      'organicOptions': [
        'Remove and burn infected plants',
        'Explore biocontrol agents (Pseudomonas fluorescens)',
      ],
    },

    'bacterial blight': {
      'scientificName': 'Xanthomonas oryzae / X. campestris',
      'affectedCrops': ['Rice', 'Cotton', 'Pepper'],
      'severity': 'High',
      'symptoms': [
        'Water-soaked streaks on leaf margins turning yellow then brown',
        'Leaf wilting and rolling',
        'Bacterial exudate forming creamy droplets when humid',
        'Kresek (wilt) phase in seedlings: rapid death',
      ],
      'causes': 'Bacterial pathogen spread by water splash, insects, and contaminated tools.',
      'treatment': [
        'Spray Copper Oxychloride 50% WP @ 3 g/L + Streptomycin 200 ppm',
        'Apply Bactericidal copper formulations every 7 days',
        'Remove and destroy heavily infected plants',
        'Use Plantomycin (Streptomycin Sulphate) as directed',
      ],
      'prevention': [
        'Use certified healthy seed; seed treatment with hot water (52 °C for 30 min)',
        'Avoid flood irrigation linking fields',
        'Reduce nitrogen application during outbreak',
        'Maintain field hygiene; sanitise equipment',
      ],
      'organicOptions': [
        'Panchagavya spray (3%)',
        'Pseudomonas fluorescens bio-agent',
      ],
    },

    'fusarium wilt': {
      'scientificName': 'Fusarium oxysporum',
      'affectedCrops': ['Tomato', 'Banana', 'Cotton', 'Watermelon'],
      'severity': 'High',
      'symptoms': [
        'Yellowing of older lower leaves, progressing upward',
        'Wilting of leaves on one side of plant (unilateral wilt)',
        'Brown discolouration of vascular tissue when stem is cut',
        'Plant death in severe cases',
      ],
      'causes': 'Soil-borne fungus infects through roots; persists in soil for years.',
      'treatment': [
        'Drench soil with Carbendazim 50% WP @ 1 g/L',
        'Apply Trichoderma harzianum @ 4 g/kg soil',
        'Use Thiophanate-methyl as systemic treatment',
        'Bio-fumigation with Brassica crop residues',
      ],
      'prevention': [
        'Use resistant/tolerant varieties',
        'Solarise soil before planting (6-8 weeks)',
        'Practice 4-year crop rotation away from host crops',
        'Maintain soil pH 6.5–7.0; improve drainage',
        'Avoid wounding roots during transplant',
      ],
      'organicOptions': [
        'Neem cake soil incorporation (250 kg/acre)',
        'Trichoderma viride + Pseudomonas fluorescens mix',
        'Vermicompost to boost beneficial microflora',
      ],
    },

    'anthracnose': {
      'scientificName': 'Colletotrichum spp.',
      'affectedCrops': ['Mango', 'Tomato', 'Pepper', 'Bean', 'Grape'],
      'severity': 'Moderate–High',
      'symptoms': [
        'Dark, sunken, circular lesions on fruits and leaves',
        'Salmon-pink spore masses in moist conditions',
        'Premature fruit drop',
        'Dark cankers on stems and twigs',
      ],
      'causes': 'Fungal pathogen; spread by rain splash; warm, wet conditions (25–30 °C).',
      'treatment': [
        'Spray Mancozeb 75% WP @ 2.5 g/L every 7-10 days',
        'Apply Carbendazim 50% WP @ 1 g/L systemic spray',
        'Use Azoxystrobin for post-harvest control',
        'Hot water treatment for fruits (48 °C for 15 min)',
      ],
      'prevention': [
        'Harvest in dry weather; avoid bruising',
        'Prune to improve canopy ventilation',
        'Apply pre-harvest calcium sprays to strengthen tissue',
        'Remove mummified fruits and cankers',
      ],
      'organicOptions': [
        'Kasugamycin bio-fungicide',
        'Neem oil spray at fruit set',
        'Bordeaux mixture (1%)',
      ],
    },

    'downy mildew': {
      'scientificName': 'Plasmopara viticola / Peronospora spp.',
      'affectedCrops': ['Grape', 'Cucumber', 'Onion', 'Soybean'],
      'severity': 'Moderate–High',
      'symptoms': [
        'Pale green to yellow oily patches on upper leaf surface',
        'Greyish-white to purple fluffy growth on leaf underside',
        'Browning and necrosis of affected tissue',
        'Distorted and stunted young shoots',
      ],
      'causes': 'Oomycete pathogen; thrives in cool, wet nights and warm days.',
      'treatment': [
        'Apply Fosetyl-Aluminium @ 2.5 g/L systemically',
        'Spray Metalaxyl-M + Chlorothalonil @ 2 g/L',
        'Use Cymoxanil 8% + Mancozeb 64% WP @ 2.5 g/L',
        'Alternate chemical groups to prevent resistance',
      ],
      'prevention': [
        'Choose resistant grape/cucumber varieties',
        'Ensure good air circulation through pruning',
        'Apply preventive copper sprays before wet periods',
        'Avoid evening overhead irrigation',
      ],
      'organicOptions': [
        'Bordeaux mixture 1% spray',
        'Copper sulphate + lime',
        'Compost tea foliar spray',
      ],
    },

    'mosaic virus': {
      'scientificName': 'TMV / CMV / BYMV (various)',
      'affectedCrops': ['Tomato', 'Pepper', 'Cucumber', 'Bean'],
      'severity': 'Moderate',
      'symptoms': [
        'Yellow-green mottling / mosaic pattern on leaves',
        'Leaf curling, puckering, and distortion',
        'Stunted plant growth',
        'Fruit deformation with blotchy ripening',
      ],
      'causes': 'Viral infection transmitted by aphids, whiteflies, or mechanical contact.',
      'treatment': [
        'No chemical cure for virus; remove infected plants',
        'Control vector insects with Imidacloprid 17.8% SL @ 0.5 ml/L',
        'Apply reflective mulches to deter aphids',
        'Spray mineral oil to reduce virus transmission',
      ],
      'prevention': [
        'Use certified virus-free seed and resistant varieties',
        'Control aphids and whiteflies with systemic insecticides',
        'Roguing: remove and destroy infected plants early',
        'Disinfect tools and hands with 10% bleach solution',
        'Avoid tobacco near susceptible crops (TMV source)',
      ],
      'organicOptions': [
        'Yellow sticky traps for whitefly/aphid monitoring',
        'Neem oil spray to suppress vectors',
        'Reflective silver mulch',
      ],
    },

    'healthy': {
      'scientificName': 'N/A',
      'affectedCrops': ['All'],
      'severity': 'None',
      'symptoms': ['No disease symptoms detected'],
      'causes': 'Plant appears healthy.',
      'treatment': ['No treatment required'],
      'prevention': [
        'Continue regular monitoring',
        'Maintain balanced fertilisation and irrigation',
        'Remove weeds that harbour pests',
      ],
      'organicOptions': ['Routine neem oil spray as preventive measure'],
    },

    // ── Tomato-specific diseases ───────────────────────────────────────────
    'leaf mold': {
      'scientificName': 'Passalora fulva (syn. Fulvia fulva)',
      'affectedCrops': ['Tomato'],
      'severity': 'Moderate',
      'symptoms': [
        'Pale yellow patches on upper leaf surface',
        'Olive-green to brown velvety mould on leaf underside',
        'Leaves curl, wither and drop prematurely',
        'Usually starts on lower leaves and moves upward',
      ],
      'causes':
          'Fungal pathogen favoured by high humidity (>85%) and warm temperatures (20–25 °C); poor ventilation accelerates spread.',
      'treatment': [
        'Apply sulphur-based fungicide (e.g. Sulphur 80% WP @ 3 g/L)',
        'Spray Chlorothalonil 75% WP @ 2 g/L every 7-10 days',
        'Remove and destroy infected leaves immediately',
        'Reduce greenhouse humidity below 85%',
      ],
      'prevention': [
        'Ensure proper ventilation and plant spacing',
        'Avoid overhead watering; use drip irrigation',
        'Use resistant tomato varieties (e.g. those with Cf genes)',
        'Remove plant debris at end of season',
        'Maintain humidity below 80% in protected cultivation',
      ],
      'organicOptions': [
        'Neem oil spray (5 ml/L)',
        'Potassium bicarbonate solution (5 g/L)',
        'Bacillus subtilis bio-fungicide',
      ],
    },

    'bacterial spot': {
      'scientificName': 'Xanthomonas vesicatoria',
      'affectedCrops': ['Tomato', 'Pepper'],
      'severity': 'Moderate–High',
      'symptoms': [
        'Small, dark, water-soaked spots on leaves, stems and fruit',
        'Spots may have yellow halo and become raised/scabby',
        'Severe defoliation in wet conditions',
        'Fruit spots reduce marketability',
      ],
      'causes':
          'Bacterial pathogen spread by rain splash, contaminated seed and tools; favoured by warm, wet weather.',
      'treatment': [
        'Apply copper-based bactericide (Copper Hydroxide @ 2 g/L)',
        'Spray Streptomycin 200 ppm as foliar treatment',
        'Remove heavily infected plants',
        'Avoid working with wet plants to reduce spread',
      ],
      'prevention': [
        'Use certified disease-free seed',
        'Hot-water seed treatment (50 °C for 25 min)',
        'Practice crop rotation (2-3 years)',
        'Improve air circulation; avoid overhead irrigation',
        'Sanitise tools between plants with 10% bleach',
      ],
      'organicOptions': [
        'Copper sulphate spray (Bordeaux mixture 1%)',
        'Bacillus amyloliquefaciens bio-bactericide',
      ],
    },

    'septoria leaf spot': {
      'scientificName': 'Septoria lycopersici',
      'affectedCrops': ['Tomato'],
      'severity': 'Moderate',
      'symptoms': [
        'Numerous small circular spots (1-3 mm) with dark brown borders',
        'Grey or tan centres with tiny dark pycnidia (fruiting bodies)',
        'Lower leaves affected first; progresses upward',
        'Severe defoliation exposes fruit to sun scald',
      ],
      'causes':
          'Fungal pathogen spread by rain splash; survives on plant debris; favoured by warm, wet weather.',
      'treatment': [
        'Spray Mancozeb 75% WP @ 2.5 g/L every 7-10 days',
        'Apply Chlorothalonil or Azoxystrobin as protectant',
        'Remove and destroy infected lower leaves',
        'Ensure good air flow around plants',
      ],
      'prevention': [
        'Use mulch to prevent soil splash onto lower leaves',
        'Practice 3-year crop rotation away from Solanaceae',
        'Stake and prune plants for better air circulation',
        'Remove all plant debris at end of season',
      ],
      'organicOptions': [
        'Copper-based fungicide sprays',
        'Neem oil (5 ml/L) preventive application',
        'Compost tea foliar spray',
      ],
    },

    'spider mites': {
      'scientificName': 'Tetranychus urticae (Two-spotted spider mite)',
      'affectedCrops': ['Tomato', 'Pepper', 'Cucumber', 'Strawberry'],
      'severity': 'Moderate',
      'symptoms': [
        'Fine stippling and yellowing of leaves (tiny white/yellow dots)',
        'Fine silky webbing on leaf undersides',
        'Leaves become bronzed and dry out',
        'Severe infestations cause leaf drop and plant stress',
      ],
      'causes':
          'Arachnid pest; thrives in hot, dry conditions (>30 °C); populations explode when natural enemies are absent.',
      'treatment': [
        'Spray Abamectin 1.8% EC @ 0.5 ml/L',
        'Apply Spiromesifen or Etoxazole as miticide',
        'Increase humidity with misting to slow reproduction',
        'Wash off mites with strong water spray on undersides',
      ],
      'prevention': [
        'Monitor plants weekly with a hand lens',
        'Maintain adequate moisture; avoid drought stress',
        'Avoid excessive nitrogen that promotes lush growth',
        'Introduce predatory mites (Phytoseiulus persimilis)',
      ],
      'organicOptions': [
        'Neem oil spray (5 ml/L) every 5 days',
        'Insecticidal soap spray',
        'Release predatory mites as biocontrol',
      ],
    },

    'target spot': {
      'scientificName': 'Corynespora cassiicola',
      'affectedCrops': ['Tomato', 'Cucumber', 'Soybean'],
      'severity': 'Moderate–High',
      'symptoms': [
        'Brown circular lesions with concentric rings (target-like)',
        'Spots on leaves, stems and fruit',
        'Severe infection causes premature defoliation',
        'Fruit spots reduce quality and shelf life',
      ],
      'causes':
          'Fungal pathogen; spread by rain and wind; thrives in warm, humid conditions.',
      'treatment': [
        'Apply Chlorothalonil 75% WP @ 2 g/L every 7-10 days',
        'Spray Mancozeb 75% WP @ 2.5 g/L as protectant',
        'Use Azoxystrobin + Difenoconazole combination',
        'Remove and destroy affected leaves and fruit',
      ],
      'prevention': [
        'Improve air circulation through proper spacing',
        'Avoid overhead watering',
        'Practice crop rotation (2-3 years)',
        'Remove all crop debris after harvest',
      ],
      'organicOptions': [
        'Copper hydroxide spray',
        'Bacillus subtilis bio-fungicide',
        'Neem oil preventive spray',
      ],
    },

    'yellow leaf curl virus': {
      'scientificName': 'Tomato Yellow Leaf Curl Virus (TYLCV)',
      'affectedCrops': ['Tomato'],
      'severity': 'High',
      'symptoms': [
        'Severe upward curling and cupping of leaves',
        'Intense yellowing of leaf margins and interveinal areas',
        'Stunted plant growth with shortened internodes',
        'Drastically reduced fruit set and yield',
      ],
      'causes':
          'Begomovirus transmitted by silverleaf whitefly (Bemisia tabaci); cannot be spread mechanically.',
      'treatment': [
        'No chemical cure exists; remove infected plants immediately',
        'Control whitefly vectors with Imidacloprid 17.8% SL @ 0.5 ml/L',
        'Apply Thiamethoxam 25% WG @ 0.3 g/L systemically',
        'Use yellow sticky traps to monitor and reduce whitefly',
      ],
      'prevention': [
        'Plant TYLCV-resistant tomato varieties (e.g. Ty-1, Ty-3 genes)',
        'Use fine-mesh insect-proof netting in nurseries',
        'Maintain a whitefly-free period between crops',
        'Remove weed hosts around the field',
        'Rogue and destroy infected plants within 24 hours',
      ],
      'organicOptions': [
        'Yellow sticky traps for whitefly monitoring',
        'Neem oil spray to repel whiteflies',
        'Reflective silver mulch to deter vectors',
      ],
    },
  };

  // ── Lookup disease in local KB (fuzzy match) ────────────────────────────────
  static Map<String, dynamic>? lookupDisease(String diseaseName) {
    // Normalise: lowercase, replace underscores and hyphens with spaces, trim
    final key = diseaseName.toLowerCase().trim().replaceAll(RegExp(r'[_\-]+'), ' ');

    // 1. Exact match
    if (localDiseaseKB.containsKey(key)) return localDiseaseKB[key];

    // 2. KB key contained in query OR query contained in KB key
    for (final entry in localDiseaseKB.entries) {
      if (key.contains(entry.key) || entry.key.contains(key)) {
        return entry.value;
      }
    }

    // 3. Word-overlap: any KB key word appears in the query words
    final queryWords = key.split(RegExp(r'\s+')).where((w) => w.length > 3).toList();
    for (final entry in localDiseaseKB.entries) {
      final entryWords = entry.key.split(RegExp(r'\s+'));
      if (queryWords.any(entryWords.contains)) {
        return entry.value;
      }
    }

    // 4. Substring scan: each KB key word appears somewhere inside the query string
    for (final entry in localDiseaseKB.entries) {
      final entryWords = entry.key.split(RegExp(r'\s+')).where((w) => w.length > 3);
      if (entryWords.every(key.contains)) {
        return entry.value;
      }
    }

    return null;
  }

  // ── Save analysis to in-memory history ─────────────────────────────────────
  static Future<int> saveDiseaseAnalysis({
    required String imagePath,
    required String disease,
    required double confidence,
    required String symptoms,
    required String treatment,
    required String prevention,
    String? imageAnalysis,
    String? recommendation,
    String? actionItems,
    String? cropType,
    String? fieldName,
    String? notes,
  }) async {
    try {
      final id = _nextId++;
      _history.insert(0, {
        'id': id,
        'timestamp': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        'imagePath': imagePath,
        'disease': disease,
        'confidence': confidence,
        'symptoms': symptoms,
        'treatment': treatment,
        'prevention': prevention,
        'imageAnalysis': imageAnalysis ?? '',
        'recommendation': recommendation ?? '',
        'actionItems': actionItems ?? '',
        'cropType': cropType ?? 'Unknown',
        'fieldName': fieldName ?? 'Default Field',
        'notes': notes ?? '',
        'isFavorite': 0,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return id;
    } catch (e) {
      return -1;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllAnalyses() async =>
      List<Map<String, dynamic>>.from(_history);

  static Future<Map<String, dynamic>?> getAnalysisById(int id) async {
    try {
      return _history.firstWhere((a) => a['id'] == id);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> deleteAnalysis(int id) async {
    _history.removeWhere((a) => a['id'] == id);
    return true;
  }

  static Future<bool> toggleFavorite(int id, bool isFavorite) async {
    final idx = _history.indexWhere((a) => a['id'] == id);
    if (idx != -1) _history[idx]['isFavorite'] = isFavorite ? 1 : 0;
    return true;
  }

  static Future<Map<String, dynamic>> getStatistics() async {
    if (_history.isEmpty) {
      return {
        'totalAnalyses': 0,
        'averageConfidence': 0.0,
        'diseaseCounts': <Map<String, dynamic>>[],
      };
    }
    final total = _history.length;
    final avgConf = _history
            .map((a) => (a['confidence'] as num).toDouble())
            .reduce((a, b) => a + b) /
        total;
    final counts = <String, int>{};
    for (final a in _history) {
      final d = a['disease'] as String;
      counts[d] = (counts[d] ?? 0) + 1;
    }
    final diseaseCounts = counts.entries
        .map((e) => {'disease': e.key, 'count': e.value})
        .toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    return {
      'totalAnalyses': total,
      'averageConfidence': avgConf,
      'diseaseCounts': diseaseCounts,
    };
  }
}
