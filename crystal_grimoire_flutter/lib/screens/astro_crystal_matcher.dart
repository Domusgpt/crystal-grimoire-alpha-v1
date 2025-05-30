import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AstroCrystalMatcher extends StatefulWidget {
  const AstroCrystalMatcher({Key? key}) : super(key: key);

  @override
  _AstroCrystalMatcherState createState() => _AstroCrystalMatcherState();
}

class _AstroCrystalMatcherState extends State<AstroCrystalMatcher>
    with TickerProviderStateMixin {
  // Controllers
  late AnimationController _cosmicAnimationController;
  late AnimationController _pulseController;
  late TabController _tabController;
  
  // Birth chart data
  DateTime _birthDate = DateTime.now();
  TimeOfDay _birthTime = TimeOfDay.now();
  String _birthLocation = '';
  Map<String, dynamic> _birthChart = {};
  
  // Current cosmic data
  Map<String, dynamic> _currentPlanets = {};
  double _moonPhase = 0.0;
  String _moonSign = '';
  List<Map<String, dynamic>> _activeTransits = [];
  
  // Crystal recommendations
  List<Map<String, dynamic>> _recommendedCrystals = [];
  List<Map<String, dynamic>> _dailyCrystals = [];
  Map<String, List<String>> _moonPhaseCrystals = {};
  
  // Selected zodiac sign for collections
  String _selectedZodiac = 'Aries';
  
  // Loading states
  bool _isCalculating = false;
  bool _chartCalculated = false;

  @override
  void initState() {
    super.initState();
    _cosmicAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _tabController = TabController(length: 5, vsync: this);
    
    _initializeCosmicData();
    _loadCrystalDatabase();
  }

  @override
  void dispose() {
    _cosmicAnimationController.dispose();
    _pulseController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _initializeCosmicData() {
    // Initialize current planetary positions
    _calculateCurrentPlanets();
    _calculateMoonPhase();
  }

  void _calculateCurrentPlanets() {
    // Simplified planetary positions (in production, use astronomical API)
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    
    _currentPlanets = {
      'sun': _calculatePlanetPosition('sun', dayOfYear),
      'moon': _calculatePlanetPosition('moon', dayOfYear),
      'mercury': _calculatePlanetPosition('mercury', dayOfYear),
      'venus': _calculatePlanetPosition('venus', dayOfYear),
      'mars': _calculatePlanetPosition('mars', dayOfYear),
      'jupiter': _calculatePlanetPosition('jupiter', dayOfYear),
      'saturn': _calculatePlanetPosition('saturn', dayOfYear),
      'uranus': _calculatePlanetPosition('uranus', dayOfYear),
      'neptune': _calculatePlanetPosition('neptune', dayOfYear),
      'pluto': _calculatePlanetPosition('pluto', dayOfYear),
    };
    
    _moonSign = _getZodiacSign(_currentPlanets['moon']['longitude']);
  }

  Map<String, dynamic> _calculatePlanetPosition(String planet, int dayOfYear) {
    // Simplified orbital calculations
    final orbitalPeriods = {
      'sun': 365.25,
      'moon': 27.32,
      'mercury': 87.97,
      'venus': 224.70,
      'mars': 686.98,
      'jupiter': 4332.59,
      'saturn': 10759.22,
      'uranus': 30688.5,
      'neptune': 60182.0,
      'pluto': 90560.0,
    };
    
    final period = orbitalPeriods[planet] ?? 365.25;
    final longitude = (dayOfYear / period * 360) % 360;
    
    return {
      'longitude': longitude,
      'sign': _getZodiacSign(longitude),
      'degree': longitude % 30,
    };
  }

  String _getZodiacSign(double longitude) {
    final signs = [
      'Aries', 'Taurus', 'Gemini', 'Cancer',
      'Leo', 'Virgo', 'Libra', 'Scorpio',
      'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];
    final index = (longitude / 30).floor();
    return signs[index % 12];
  }

  void _calculateMoonPhase() {
    final now = DateTime.now();
    final newMoon = DateTime(2000, 1, 6, 18, 14); // Known new moon
    final lunarCycle = 29.53058867; // Days in lunar cycle
    
    final daysSinceNewMoon = now.difference(newMoon).inMinutes / 1440.0;
    final currentCycle = daysSinceNewMoon / lunarCycle;
    _moonPhase = (currentCycle - currentCycle.floor());
  }

  String _getMoonPhaseName() {
    if (_moonPhase < 0.03 || _moonPhase > 0.97) return 'New Moon';
    if (_moonPhase < 0.22) return 'Waxing Crescent';
    if (_moonPhase < 0.28) return 'First Quarter';
    if (_moonPhase < 0.47) return 'Waxing Gibbous';
    if (_moonPhase < 0.53) return 'Full Moon';
    if (_moonPhase < 0.72) return 'Waning Gibbous';
    if (_moonPhase < 0.78) return 'Last Quarter';
    return 'Waning Crescent';
  }

  void _loadCrystalDatabase() {
    // Crystal associations by astrological properties
    _moonPhaseCrystals = {
      'New Moon': ['Black Moonstone', 'Labradorite', 'Clear Quartz', 'Black Tourmaline'],
      'Waxing Crescent': ['Selenite', 'Green Aventurine', 'Citrine', 'Carnelian'],
      'First Quarter': ['Rose Quartz', 'Sodalite', 'Fluorite', 'Pyrite'],
      'Waxing Gibbous': ['Amethyst', 'Moonstone', 'Celestite', 'Amazonite'],
      'Full Moon': ['Rainbow Moonstone', 'Clear Quartz', 'Selenite', 'Howlite'],
      'Waning Gibbous': ['Smoky Quartz', 'Black Obsidian', 'Hematite', 'Jet'],
      'Last Quarter': ['Lepidolite', 'Blue Lace Agate', 'Angelite', 'Chrysocolla'],
      'Waning Crescent': ['Black Tourmaline', 'Shungite', 'Apache Tear', 'Onyx'],
    };
  }

  Future<void> _calculateBirthChart() async {
    setState(() {
      _isCalculating = true;
    });
    
    // Simulate API call for birth chart calculation
    await Future.delayed(const Duration(seconds: 2));
    
    // Calculate birth chart (simplified)
    final birthDateTime = DateTime(
      _birthDate.year,
      _birthDate.month,
      _birthDate.day,
      _birthTime.hour,
      _birthTime.minute,
    );
    
    final dayOfYear = birthDateTime.difference(DateTime(birthDateTime.year, 1, 1)).inDays;
    
    _birthChart = {
      'sun': _calculatePlanetPosition('sun', dayOfYear),
      'moon': _calculatePlanetPosition('moon', dayOfYear),
      'ascendant': _calculateAscendant(birthDateTime),
      'mercury': _calculatePlanetPosition('mercury', dayOfYear),
      'venus': _calculatePlanetPosition('venus', dayOfYear),
      'mars': _calculatePlanetPosition('mars', dayOfYear),
      'jupiter': _calculatePlanetPosition('jupiter', dayOfYear),
      'saturn': _calculatePlanetPosition('saturn', dayOfYear),
    };
    
    _generateCrystalRecommendations();
    _calculateActiveTransits();
    
    setState(() {
      _isCalculating = false;
      _chartCalculated = true;
    });
  }

  Map<String, dynamic> _calculateAscendant(DateTime birthDateTime) {
    // Simplified ascendant calculation
    final hour = birthDateTime.hour + birthDateTime.minute / 60.0;
    final ascendantDegree = (hour * 15.0) % 360;
    
    return {
      'longitude': ascendantDegree,
      'sign': _getZodiacSign(ascendantDegree),
      'degree': ascendantDegree % 30,
    };
  }

  void _generateCrystalRecommendations() {
    _recommendedCrystals = [];
    
    // Sun sign crystals
    final sunCrystals = _getCrystalsForSign(_birthChart['sun']['sign']);
    _recommendedCrystals.add({
      'category': 'Sun Sign',
      'description': 'Core personality and vitality',
      'crystals': sunCrystals,
    });
    
    // Moon sign crystals
    final moonCrystals = _getCrystalsForSign(_birthChart['moon']['sign']);
    _recommendedCrystals.add({
      'category': 'Moon Sign',
      'description': 'Emotional nature and intuition',
      'crystals': moonCrystals,
    });
    
    // Ascendant crystals
    final ascCrystals = _getCrystalsForSign(_birthChart['ascendant']['sign']);
    _recommendedCrystals.add({
      'category': 'Rising Sign',
      'description': 'Outer personality and appearance',
      'crystals': ascCrystals,
    });
    
    // Element balance crystals
    final elementCrystals = _getElementBalanceCrystals();
    _recommendedCrystals.add({
      'category': 'Element Balance',
      'description': 'Harmonize your elemental energies',
      'crystals': elementCrystals,
    });
  }

  List<Map<String, dynamic>> _getCrystalsForSign(String sign) {
    final crystalMap = {
      'Aries': [
        {'name': 'Carnelian', 'property': 'Leadership & courage'},
        {'name': 'Red Jasper', 'property': 'Grounding energy'},
        {'name': 'Bloodstone', 'property': 'Vitality & strength'},
      ],
      'Taurus': [
        {'name': 'Rose Quartz', 'property': 'Self-love & comfort'},
        {'name': 'Emerald', 'property': 'Abundance & growth'},
        {'name': 'Rhodonite', 'property': 'Emotional balance'},
      ],
      'Gemini': [
        {'name': 'Blue Lace Agate', 'property': 'Communication'},
        {'name': 'Citrine', 'property': 'Mental clarity'},
        {'name': 'Tiger Eye', 'property': 'Focus & decision'},
      ],
      'Cancer': [
        {'name': 'Moonstone', 'property': 'Intuition & emotions'},
        {'name': 'Pearl', 'property': 'Nurturing energy'},
        {'name': 'Chrysocolla', 'property': 'Emotional healing'},
      ],
      'Leo': [
        {'name': 'Sunstone', 'property': 'Leadership & joy'},
        {'name': 'Pyrite', 'property': 'Confidence & success'},
        {'name': 'Golden Topaz', 'property': 'Personal power'},
      ],
      'Virgo': [
        {'name': 'Amazonite', 'property': 'Truth & clarity'},
        {'name': 'Moss Agate', 'property': 'Grounding & growth'},
        {'name': 'Fluorite', 'property': 'Organization & focus'},
      ],
      'Libra': [
        {'name': 'Lepidolite', 'property': 'Balance & peace'},
        {'name': 'Jade', 'property': 'Harmony & luck'},
        {'name': 'Prehnite', 'property': 'Inner peace'},
      ],
      'Scorpio': [
        {'name': 'Obsidian', 'property': 'Protection & truth'},
        {'name': 'Malachite', 'property': 'Transformation'},
        {'name': 'Labradorite', 'property': 'Psychic abilities'},
      ],
      'Sagittarius': [
        {'name': 'Turquoise', 'property': 'Wisdom & travel'},
        {'name': 'Sodalite', 'property': 'Truth & learning'},
        {'name': 'Lapis Lazuli', 'property': 'Higher knowledge'},
      ],
      'Capricorn': [
        {'name': 'Garnet', 'property': 'Success & grounding'},
        {'name': 'Black Tourmaline', 'property': 'Protection'},
        {'name': 'Smoky Quartz', 'property': 'Practicality'},
      ],
      'Aquarius': [
        {'name': 'Amethyst', 'property': 'Intuition & clarity'},
        {'name': 'Aquamarine', 'property': 'Communication'},
        {'name': 'Clear Quartz', 'property': 'Amplification'},
      ],
      'Pisces': [
        {'name': 'Aquamarine', 'property': 'Emotional clarity'},
        {'name': 'Amethyst', 'property': 'Spiritual connection'},
        {'name': 'Fluorite', 'property': 'Psychic protection'},
      ],
    };
    
    return crystalMap[sign] ?? [];
  }

  List<Map<String, dynamic>> _getElementBalanceCrystals() {
    // Count elements in birth chart
    final elements = {'Fire': 0, 'Earth': 0, 'Air': 0, 'Water': 0};
    final elementSigns = {
      'Fire': ['Aries', 'Leo', 'Sagittarius'],
      'Earth': ['Taurus', 'Virgo', 'Capricorn'],
      'Air': ['Gemini', 'Libra', 'Aquarius'],
      'Water': ['Cancer', 'Scorpio', 'Pisces'],
    };
    
    _birthChart.forEach((planet, data) {
      elementSigns.forEach((element, signs) {
        if (signs.contains(data['sign'])) {
          elements[element] = elements[element]! + 1;
        }
      });
    });
    
    // Find lacking elements and recommend crystals
    final crystals = <Map<String, dynamic>>[];
    elements.forEach((element, count) {
      if (count < 2) {
        switch (element) {
          case 'Fire':
            crystals.add({'name': 'Carnelian', 'property': 'Boost Fire energy'});
            break;
          case 'Earth':
            crystals.add({'name': 'Hematite', 'property': 'Boost Earth energy'});
            break;
          case 'Air':
            crystals.add({'name': 'Selenite', 'property': 'Boost Air energy'});
            break;
          case 'Water':
            crystals.add({'name': 'Aquamarine', 'property': 'Boost Water energy'});
            break;
        }
      }
    });
    
    return crystals;
  }

  void _calculateActiveTransits() {
    _activeTransits = [];
    
    // Check major transits (simplified)
    _birthChart.forEach((planet, birthData) {
      _currentPlanets.forEach((transitPlanet, transitData) {
        final aspect = _calculateAspect(
          birthData['longitude'],
          transitData['longitude'],
        );
        
        if (aspect != null) {
          _activeTransits.add({
            'transit': '$transitPlanet ${aspect['name']} natal $planet',
            'crystals': _getTransitCrystals(transitPlanet, aspect['type']),
            'influence': _getTransitInfluence(transitPlanet, planet, aspect['type']),
          });
        }
      });
    });
  }

  Map<String, dynamic>? _calculateAspect(double angle1, double angle2) {
    final diff = (angle1 - angle2).abs() % 360;
    final orb = 8.0; // Degree of orb
    
    final aspects = [
      {'angle': 0, 'name': 'conjunct', 'type': 'major'},
      {'angle': 60, 'name': 'sextile', 'type': 'harmonious'},
      {'angle': 90, 'name': 'square', 'type': 'challenging'},
      {'angle': 120, 'name': 'trine', 'type': 'harmonious'},
      {'angle': 180, 'name': 'opposite', 'type': 'challenging'},
    ];
    
    for (final aspect in aspects) {
      if ((diff - (aspect['angle'] as num)).abs() < orb) {
        return aspect as Map<String, dynamic>;
      }
    }
    
    return null;
  }

  List<String> _getTransitCrystals(String planet, String aspectType) {
    final crystalMap = {
      'sun': {
        'harmonious': ['Sunstone', 'Citrine', 'Clear Quartz'],
        'challenging': ['Black Tourmaline', 'Smoky Quartz', 'Hematite'],
        'major': ['Gold Rutilated Quartz', 'Pyrite', 'Tiger Eye'],
      },
      'moon': {
        'harmonious': ['Moonstone', 'Selenite', 'Pearl'],
        'challenging': ['Black Moonstone', 'Smoky Quartz', 'Lepidolite'],
        'major': ['Rainbow Moonstone', 'Labradorite', 'White Opal'],
      },
      'mercury': {
        'harmonious': ['Blue Lace Agate', 'Sodalite', 'Amazonite'],
        'challenging': ['Fluorite', 'Black Tourmaline', 'Shungite'],
        'major': ['Aquamarine', 'Chrysocolla', 'Blue Kyanite'],
      },
      'venus': {
        'harmonious': ['Rose Quartz', 'Rhodonite', 'Green Aventurine'],
        'challenging': ['Rhodochrosite', 'Malachite', 'Black Obsidian'],
        'major': ['Emerald', 'Pink Tourmaline', 'Kunzite'],
      },
      'mars': {
        'harmonious': ['Carnelian', 'Red Jasper', 'Garnet'],
        'challenging': ['Hematite', 'Black Tourmaline', 'Obsidian'],
        'major': ['Bloodstone', 'Ruby', 'Fire Opal'],
      },
    };
    
    return crystalMap[planet]?[aspectType] ?? ['Clear Quartz'];
  }

  String _getTransitInfluence(String transitPlanet, String natalPlanet, String aspectType) {
    final influences = {
      'sun': 'vitality and self-expression',
      'moon': 'emotions and intuition',
      'mercury': 'communication and thinking',
      'venus': 'love and relationships',
      'mars': 'energy and action',
      'jupiter': 'expansion and opportunity',
      'saturn': 'structure and responsibility',
    };
    
    final aspectDescriptions = {
      'harmonious': 'brings ease to',
      'challenging': 'creates tension in',
      'major': 'powerfully activates',
    };
    
    return '${transitPlanet.toUpperCase()} ${aspectDescriptions[aspectType]} your ${influences[natalPlanet] ?? 'life area'}';
  }

  void _generateDailyCrystals() {
    final today = DateTime.now();
    final dayEnergy = today.weekday;
    
    final dailyRecommendations = {
      1: [ // Monday - Moon
        {'name': 'Moonstone', 'purpose': 'Emotional balance'},
        {'name': 'Pearl', 'purpose': 'Inner wisdom'},
        {'name': 'Selenite', 'purpose': 'Mental clarity'},
      ],
      2: [ // Tuesday - Mars
        {'name': 'Carnelian', 'purpose': 'Motivation'},
        {'name': 'Red Jasper', 'purpose': 'Physical energy'},
        {'name': 'Garnet', 'purpose': 'Passion'},
      ],
      3: [ // Wednesday - Mercury
        {'name': 'Sodalite', 'purpose': 'Communication'},
        {'name': 'Blue Lace Agate', 'purpose': 'Expression'},
        {'name': 'Amazonite', 'purpose': 'Truth speaking'},
      ],
      4: [ // Thursday - Jupiter
        {'name': 'Amethyst', 'purpose': 'Spiritual growth'},
        {'name': 'Lapis Lazuli', 'purpose': 'Wisdom'},
        {'name': 'Turquoise', 'purpose': 'Good fortune'},
      ],
      5: [ // Friday - Venus
        {'name': 'Rose Quartz', 'purpose': 'Love attraction'},
        {'name': 'Emerald', 'purpose': 'Heart healing'},
        {'name': 'Green Aventurine', 'purpose': 'Abundance'},
      ],
      6: [ // Saturday - Saturn
        {'name': 'Black Tourmaline', 'purpose': 'Protection'},
        {'name': 'Hematite', 'purpose': 'Grounding'},
        {'name': 'Obsidian', 'purpose': 'Shadow work'},
      ],
      7: [ // Sunday - Sun
        {'name': 'Sunstone', 'purpose': 'Vitality'},
        {'name': 'Citrine', 'purpose': 'Joy'},
        {'name': 'Pyrite', 'purpose': 'Success'},
      ],
    };
    
    _dailyCrystals = [
      {
        'category': 'Planetary Day Ruler',
        'crystals': dailyRecommendations[dayEnergy] ?? [],
      },
      {
        'category': 'Moon Phase Support',
        'crystals': _moonPhaseCrystals[_getMoonPhaseName()]?.map((crystal) => {
          'name': crystal,
          'purpose': 'Lunar alignment',
        }).toList() ?? [],
      },
      {
        'category': 'Current Moon Sign',
        'crystals': _getCrystalsForSign(_moonSign).map((c) => {
          'name': c['name'],
          'purpose': c['property'],
        }).toList(),
      },
    ];
  }

  Widget _buildBirthChartTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Birth Chart Calculator',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[300],
                  ),
                ),
                const SizedBox(height: 20),
                _buildDatePicker(),
                const SizedBox(height: 15),
                _buildTimePicker(),
                const SizedBox(height: 15),
                _buildLocationInput(),
                const SizedBox(height: 25),
                _buildCalculateButton(),
              ],
            ),
          ),
          if (_chartCalculated) ...[
            const SizedBox(height: 20),
            _buildChartVisualization(),
            const SizedBox(height: 20),
            _buildCrystalRecommendations(),
          ],
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _birthDate,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: ColorScheme.dark(
                  primary: Colors.purple[300]!,
                  surface: Colors.grey[900]!,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            _birthDate = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.purple[300]!.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.purple[300]),
            const SizedBox(width: 10),
            Text(
              'Birth Date: ${DateFormat('MMM dd, yyyy').format(_birthDate)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _birthTime,
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: ColorScheme.dark(
                  primary: Colors.purple[300]!,
                  surface: Colors.grey[900]!,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            _birthTime = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.purple[300]!.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: Colors.purple[300]),
            const SizedBox(width: 10),
            Text(
              'Birth Time: ${_birthTime.format(context)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInput() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Birth Location',
        hintText: 'City, Country',
        prefixIcon: Icon(Icons.location_on, color: Colors.purple[300]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.purple[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.purple[300]!.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.purple[300]!),
        ),
      ),
      onChanged: (value) {
        _birthLocation = value;
      },
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isCalculating ? null : _calculateBirthChart,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isCalculating
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Calculate Birth Chart',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildChartVisualization() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Birth Chart',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.purple[300],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: CustomPaint(
              size: const Size(double.infinity, 300),
              painter: AstroChartPainter(
                birthChart: _birthChart,
                animation: _cosmicAnimationController,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildPlanetaryPositions(),
        ],
      ),
    );
  }

  Widget _buildPlanetaryPositions() {
    return Column(
      children: _birthChart.entries.map((entry) {
        final planet = entry.key;
        final data = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _getPlanetColors(planet),
                  ),
                ),
                child: Center(
                  child: Text(
                    _getPlanetSymbol(planet),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${planet.toUpperCase()} in ${data['sign']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${data['degree'].toStringAsFixed(1)}° ${data['sign']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Color> _getPlanetColors(String planet) {
    final colors = {
      'sun': [Colors.yellow[600]!, Colors.orange[600]!],
      'moon': [Colors.grey[300]!, Colors.blue[200]!],
      'mercury': [Colors.orange[400]!, Colors.yellow[400]!],
      'venus': [Colors.pink[300]!, Colors.pink[500]!],
      'mars': [Colors.red[400]!, Colors.red[700]!],
      'jupiter': [Colors.purple[300]!, Colors.indigo[400]!],
      'saturn': [Colors.brown[400]!, Colors.grey[600]!],
      'ascendant': [Colors.teal[300]!, Colors.cyan[400]!],
    };
    return colors[planet] ?? [Colors.grey[400]!, Colors.grey[600]!];
  }

  String _getPlanetSymbol(String planet) {
    final symbols = {
      'sun': '☉',
      'moon': '☽',
      'mercury': '☿',
      'venus': '♀',
      'mars': '♂',
      'jupiter': '♃',
      'saturn': '♄',
      'uranus': '♅',
      'neptune': '♆',
      'pluto': '♇',
      'ascendant': 'AC',
    };
    return symbols[planet] ?? '?';
  }

  Widget _buildCrystalRecommendations() {
    return Column(
      children: _recommendedCrystals.map((category) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['category'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[300],
                  ),
                ),
                Text(
                  category['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: (category['crystals'] as List).map((crystal) {
                    return _buildCrystalChip(
                      crystal['name'],
                      crystal['property'],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCrystalChip(String name, String property) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple[400]!.withOpacity(0.3),
                  Colors.blue[400]!.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.purple[300]!.withOpacity(0.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  property,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyCosmicTab() {
    _generateDailyCrystals();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today\'s Cosmic Weather',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[300],
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildCurrentPlanetaryPositions(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildDailyCrystalRecommendations(),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanetaryPositions() {
    return Column(
      children: [
        _buildCosmicIndicator('Moon Phase', _getMoonPhaseName()),
        const SizedBox(height: 10),
        _buildCosmicIndicator('Moon in', _moonSign),
        const SizedBox(height: 10),
        _buildCosmicIndicator(
          'Sun in',
          _currentPlanets['sun']['sign'],
        ),
        const SizedBox(height: 20),
        Text(
          'Planetary Positions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.purple[300],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _currentPlanets.entries.map((entry) {
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.purple[300]!.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    _getPlanetSymbol(entry.key),
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    entry.value['sign'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCosmicIndicator(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple[400]!.withOpacity(0.3),
                Colors.blue[400]!.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyCrystalRecommendations() {
    return Column(
      children: _dailyCrystals.map((category) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['category'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[300],
                  ),
                ),
                const SizedBox(height: 15),
                ...((category['crystals'] as List).map((crystal) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple[400]!,
                                Colors.blue[400]!,
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.diamond,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                crystal['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                crystal['purpose'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList()),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMoonPhaseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildGlassCard(
            child: Column(
              children: [
                Text(
                  'Lunar Crystal Calendar',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[300],
                  ),
                ),
                const SizedBox(height: 20),
                _buildMoonPhaseWheel(),
                const SizedBox(height: 20),
                Text(
                  'Current Phase: ${_getMoonPhaseName()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(_moonPhase * 100).toStringAsFixed(1)}% illuminated',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildMoonPhaseCrystals(),
        ],
      ),
    );
  }

  Widget _buildMoonPhaseWheel() {
    return SizedBox(
      height: 250,
      child: AnimatedBuilder(
        animation: _cosmicAnimationController,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(250, 250),
            painter: MoonPhasePainter(
              currentPhase: _moonPhase,
              animation: _cosmicAnimationController,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoonPhaseCrystals() {
    return Column(
      children: _moonPhaseCrystals.entries.map((entry) {
        final isCurrentPhase = entry.key == _getMoonPhaseName();
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: isCurrentPhase
                  ? LinearGradient(
                      colors: [
                        Colors.purple[400]!.withOpacity(0.3),
                        Colors.blue[400]!.withOpacity(0.3),
                      ],
                    )
                  : null,
              border: Border.all(
                color: isCurrentPhase
                    ? Colors.purple[300]!
                    : Colors.grey[700]!,
                width: isCurrentPhase ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getMoonPhaseIcon(entry.key),
                        color: isCurrentPhase
                            ? Colors.purple[300]
                            : Colors.grey[400],
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isCurrentPhase
                              ? Colors.purple[300]
                              : Colors.grey[300],
                        ),
                      ),
                      if (isCurrentPhase)
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'CURRENT',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.value.map((crystal) {
                      return Chip(
                        label: Text(crystal),
                        backgroundColor: isCurrentPhase
                            ? Colors.purple[400]!.withOpacity(0.3)
                            : Colors.grey[800],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getMoonPhaseIcon(String phase) {
    final icons = {
      'New Moon': Icons.circle_outlined,
      'Waxing Crescent': Icons.nightlight_round,
      'First Quarter': Icons.contrast,
      'Waxing Gibbous': Icons.lens,
      'Full Moon': Icons.circle,
      'Waning Gibbous': Icons.lens,
      'Last Quarter': Icons.contrast,
      'Waning Crescent': Icons.nightlight_round,
    };
    return icons[phase] ?? Icons.circle;
  }

  Widget _buildTransitsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Planetary Transits',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[300],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Current cosmic influences affecting your birth chart',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (!_chartCalculated)
            _buildGlassCard(
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.purple[300],
                    size: 50,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Calculate your birth chart first to see active transits',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          else if (_activeTransits.isEmpty)
            _buildGlassCard(
              child: const Text(
                'No major transits active at this time',
                style: TextStyle(fontSize: 16),
              ),
            )
          else
            ..._activeTransits.map((transit) => _buildTransitCard(transit)),
        ],
      ),
    );
  }

  Widget _buildTransitCard(Map<String, dynamic> transit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: _buildGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.transit_enterexit,
                  color: Colors.purple[300],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    transit['transit'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              transit['influence'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Supporting Crystals:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple[300],
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (transit['crystals'] as List<String>).map((crystal) {
                return Chip(
                  label: Text(crystal),
                  backgroundColor: Colors.purple[400]!.withOpacity(0.3),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZodiacTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zodiac Crystal Collections',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[300],
                  ),
                ),
                const SizedBox(height: 20),
                _buildZodiacSelector(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildZodiacDetails(),
        ],
      ),
    );
  }

  Widget _buildZodiacSelector() {
    final signs = [
      'Aries', 'Taurus', 'Gemini', 'Cancer',
      'Leo', 'Virgo', 'Libra', 'Scorpio',
      'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: signs.length,
      itemBuilder: (context, index) {
        final sign = signs[index];
        final isSelected = sign == _selectedZodiac;
        
        return InkWell(
          onTap: () {
            setState(() {
              _selectedZodiac = sign;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        Colors.purple[400]!,
                        Colors.blue[400]!,
                      ],
                    )
                  : null,
              border: Border.all(
                color: isSelected
                    ? Colors.purple[300]!
                    : Colors.grey[700]!,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getZodiacSymbol(sign),
                    style: TextStyle(
                      fontSize: 24,
                      color: isSelected ? Colors.white : Colors.grey[300],
                    ),
                  ),
                  Text(
                    sign,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getZodiacSymbol(String sign) {
    final symbols = {
      'Aries': '♈',
      'Taurus': '♉',
      'Gemini': '♊',
      'Cancer': '♋',
      'Leo': '♌',
      'Virgo': '♍',
      'Libra': '♎',
      'Scorpio': '♏',
      'Sagittarius': '♐',
      'Capricorn': '♑',
      'Aquarius': '♒',
      'Pisces': '♓',
    };
    return symbols[sign] ?? '?';
  }

  Widget _buildZodiacDetails() {
    final zodiacInfo = _getZodiacInfo(_selectedZodiac);
    
    return Column(
      children: [
        _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _getZodiacSymbol(_selectedZodiac),
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.purple[300],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedZodiac,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          zodiacInfo['dates'] as String? ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Element: ${zodiacInfo['element']}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Quality: ${zodiacInfo['quality']}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Ruling Planet: ${zodiacInfo['ruler']}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crystal Collection',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[300],
                ),
              ),
              const SizedBox(height: 15),
              ..._getCrystalsForSign(_selectedZodiac).map((crystal) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple[400]!,
                              Colors.blue[400]!,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.diamond,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              crystal['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              crystal['property'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, String> _getZodiacInfo(String sign) {
    final info = {
      'Aries': {
        'dates': 'March 21 - April 19',
        'element': 'Fire',
        'quality': 'Cardinal',
        'ruler': 'Mars',
      },
      'Taurus': {
        'dates': 'April 20 - May 20',
        'element': 'Earth',
        'quality': 'Fixed',
        'ruler': 'Venus',
      },
      'Gemini': {
        'dates': 'May 21 - June 20',
        'element': 'Air',
        'quality': 'Mutable',
        'ruler': 'Mercury',
      },
      'Cancer': {
        'dates': 'June 21 - July 22',
        'element': 'Water',
        'quality': 'Cardinal',
        'ruler': 'Moon',
      },
      'Leo': {
        'dates': 'July 23 - August 22',
        'element': 'Fire',
        'quality': 'Fixed',
        'ruler': 'Sun',
      },
      'Virgo': {
        'dates': 'August 23 - September 22',
        'element': 'Earth',
        'quality': 'Mutable',
        'ruler': 'Mercury',
      },
      'Libra': {
        'dates': 'September 23 - October 22',
        'element': 'Air',
        'quality': 'Cardinal',
        'ruler': 'Venus',
      },
      'Scorpio': {
        'dates': 'October 23 - November 21',
        'element': 'Water',
        'quality': 'Fixed',
        'ruler': 'Mars/Pluto',
      },
      'Sagittarius': {
        'dates': 'November 22 - December 21',
        'element': 'Fire',
        'quality': 'Mutable',
        'ruler': 'Jupiter',
      },
      'Capricorn': {
        'dates': 'December 22 - January 19',
        'element': 'Earth',
        'quality': 'Cardinal',
        'ruler': 'Saturn',
      },
      'Aquarius': {
        'dates': 'January 20 - February 18',
        'element': 'Air',
        'quality': 'Fixed',
        'ruler': 'Saturn/Uranus',
      },
      'Pisces': {
        'dates': 'February 19 - March 20',
        'element': 'Water',
        'quality': 'Mutable',
        'ruler': 'Jupiter/Neptune',
      },
    };
    
    return info[sign] ?? {};
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.purple[300]!.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple[300]!.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Cosmic background
          AnimatedBuilder(
            animation: _cosmicAnimationController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: CosmicBackgroundPainter(
                  animation: _cosmicAnimationController,
                ),
              );
            },
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBirthChartTab(),
                      _buildDailyCosmicTab(),
                      _buildMoonPhaseTab(),
                      _buildTransitsTab(),
                      _buildZodiacTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 10),
              Text(
                'Astro Crystal Matcher',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[300],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.purple[300],
            tabs: const [
              Tab(text: 'Birth Chart'),
              Tab(text: 'Daily Cosmic'),
              Tab(text: 'Moon Phases'),
              Tab(text: 'Transits'),
              Tab(text: 'Zodiac'),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom painters
class CosmicBackgroundPainter extends CustomPainter {
  final Animation<double> animation;

  CosmicBackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Dark gradient background
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black,
        Colors.purple[900]!.withOpacity(0.3),
        Colors.black,
      ],
    );
    
    paint.shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
    
    // Stars
    final random = math.Random(42);
    paint.shader = null;
    
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2;
      final opacity = random.nextDouble() * 0.8;
      
      paint.color = Colors.white.withOpacity(
        opacity * (0.5 + 0.5 * math.sin(animation.value * 2 * math.pi + i)),
      );
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
    
    // Nebula effects
    final nebulaPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
    
    for (int i = 0; i < 3; i++) {
      final center = Offset(
        size.width * (0.2 + i * 0.3),
        size.height * (0.3 + math.sin(animation.value * 2 * math.pi + i) * 0.1),
      );
      
      nebulaPaint.color = [
        Colors.purple[300]!.withOpacity(0.1),
        Colors.blue[300]!.withOpacity(0.1),
        Colors.pink[300]!.withOpacity(0.1),
      ][i];
      
      canvas.drawCircle(center, 100, nebulaPaint);
    }
  }

  @override
  bool shouldRepaint(oldDelegate) => true;
}

class AstroChartPainter extends CustomPainter {
  final Map<String, dynamic> birthChart;
  final Animation<double> animation;

  AstroChartPainter({
    required this.birthChart,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 30;
    
    // Draw zodiac wheel
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Outer circle
    paint.color = Colors.purple[300]!;
    canvas.drawCircle(center, radius, paint);
    
    // Inner circles
    paint.color = Colors.purple[300]!.withOpacity(0.3);
    canvas.drawCircle(center, radius * 0.7, paint);
    canvas.drawCircle(center, radius * 0.4, paint);
    
    // Draw zodiac divisions
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * math.pi / 180;
      final start = Offset(
        center.dx + radius * 0.4 * math.cos(angle),
        center.dy + radius * 0.4 * math.sin(angle),
      );
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      
      canvas.drawLine(start, end, paint);
    }
    
    // Draw planets
    birthChart.forEach((planet, data) {
      final longitude = data['longitude'] as double;
      final angle = (longitude - 90) * math.pi / 180;
      final planetRadius = radius * 0.55;
      
      final position = Offset(
        center.dx + planetRadius * math.cos(angle),
        center.dy + planetRadius * math.sin(angle),
      );
      
      // Planet glow
      final glowPaint = Paint()
        ..color = _getPlanetColor(planet).withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      
      canvas.drawCircle(position, 20, glowPaint);
      
      // Planet circle
      final planetPaint = Paint()
        ..color = _getPlanetColor(planet)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(position, 15, planetPaint);
      
      // Planet symbol
      final textPainter = TextPainter(
        text: TextSpan(
          text: _getPlanetSymbol(planet),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        position - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    });
  }

  Color _getPlanetColor(String planet) {
    final colors = {
      'sun': Colors.yellow[600]!,
      'moon': Colors.grey[300]!,
      'mercury': Colors.orange[400]!,
      'venus': Colors.pink[300]!,
      'mars': Colors.red[400]!,
      'jupiter': Colors.purple[300]!,
      'saturn': Colors.brown[400]!,
      'ascendant': Colors.teal[300]!,
    };
    return colors[planet] ?? Colors.grey[400]!;
  }

  String _getPlanetSymbol(String planet) {
    final symbols = {
      'sun': '☉',
      'moon': '☽',
      'mercury': '☿',
      'venus': '♀',
      'mars': '♂',
      'jupiter': '♃',
      'saturn': '♄',
      'ascendant': 'AC',
    };
    return symbols[planet] ?? '?';
  }

  @override
  bool shouldRepaint(oldDelegate) => true;
}

class MoonPhasePainter extends CustomPainter {
  final double currentPhase;
  final Animation<double> animation;

  MoonPhasePainter({
    required this.currentPhase,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    
    // Draw moon phases in a circle
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45 - 90) * math.pi / 180;
      final phaseCenter = Offset(
        center.dx + radius * 0.7 * math.cos(angle),
        center.dy + radius * 0.7 * math.sin(angle),
      );
      
      _drawMoonPhase(canvas, phaseCenter, 25, i / 8.0, i == (currentPhase * 8).round() % 8);
    }
    
    // Draw center moon with current phase
    _drawMoonPhase(canvas, center, 50, currentPhase, true);
    
    // Draw connecting lines
    final paint = Paint()
      ..color = Colors.purple[300]!.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45 - 90) * math.pi / 180;
      final start = Offset(
        center.dx + 50 * math.cos(angle),
        center.dy + 50 * math.sin(angle),
      );
      final end = Offset(
        center.dx + radius * 0.7 * math.cos(angle),
        center.dy + radius * 0.7 * math.sin(angle),
      );
      
      canvas.drawLine(start, end, paint);
    }
  }

  void _drawMoonPhase(Canvas canvas, Offset center, double radius, double phase, bool isActive) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Moon background
    paint.color = isActive ? Colors.grey[300]! : Colors.grey[700]!;
    canvas.drawCircle(center, radius, paint);
    
    // Shadow for phase
    if (phase > 0.0 && phase < 1.0) {
      final path = Path();
      
      if (phase < 0.5) {
        // Waxing - shadow on left
        final shadowWidth = radius * 2 * (0.5 - phase);
        path.addArc(
          Rect.fromCircle(center: center, radius: radius),
          math.pi / 2,
          math.pi,
        );
        path.quadraticBezierTo(
          center.dx - shadowWidth,
          center.dy,
          center.dx,
          center.dy - radius,
        );
      } else {
        // Waning - shadow on right
        final shadowWidth = radius * 2 * (phase - 0.5);
        path.addArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2,
          math.pi,
        );
        path.quadraticBezierTo(
          center.dx + shadowWidth,
          center.dy,
          center.dx,
          center.dy + radius,
        );
      }
      
      paint.color = Colors.black.withOpacity(0.7);
      canvas.drawPath(path, paint);
    }
    
    // Glow for active phase
    if (isActive) {
      final glowPaint = Paint()
        ..color = Colors.purple[300]!.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      
      canvas.drawCircle(center, radius + 10, glowPaint);
    }
  }

  @override
  bool shouldRepaint(oldDelegate) => true;
}