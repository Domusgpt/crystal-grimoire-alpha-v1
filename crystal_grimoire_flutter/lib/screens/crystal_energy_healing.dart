import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import '../config/enhanced_theme.dart';
import '../widgets/common/enhanced_mystical_widgets.dart';
import '../widgets/animations/enhanced_animations.dart';
import '../data/crystal_database.dart';

class CrystalEnergyHealingScreen extends StatefulWidget {
  const CrystalEnergyHealingScreen({Key? key}) : super(key: key);

  @override
  State<CrystalEnergyHealingScreen> createState() => _CrystalEnergyHealingScreenState();
}

class _CrystalEnergyHealingScreenState extends State<CrystalEnergyHealingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _energyFlowController;
  late AnimationController _chakraController;
  late AnimationController _healingWaveController;
  
  // Healing session state
  bool _sessionActive = false;
  int _sessionDuration = 900; // 15 minutes default
  int _remainingTime = 900;
  Timer? _sessionTimer;
  
  // Selected healing configuration
  String _selectedHealingType = 'Chakra Alignment';
  String _selectedCrystalSet = 'Rainbow Chakra Set';
  List<Map<String, dynamic>> _placedCrystals = [];
  Map<String, bool> _chakraActivation = {};
  
  // Energy tracking
  double _overallEnergyLevel = 0.7;
  Map<String, double> _chakraEnergyLevels = {};
  List<Map<String, dynamic>> _energyReadings = [];
  
  // Healing guidance
  String _currentGuidance = '';
  int _currentStep = 0;
  List<Map<String, dynamic>> _healingSteps = [];
  
  // Crystal sets and healing types
  final Map<String, List<Map<String, dynamic>>> _crystalSets = {
    'Rainbow Chakra Set': [
      {'name': 'Red Jasper', 'chakra': 'Root', 'color': Colors.red, 'position': 'Base of spine'},
      {'name': 'Carnelian', 'chakra': 'Sacral', 'color': Colors.orange, 'position': 'Lower abdomen'},
      {'name': 'Citrine', 'chakra': 'Solar Plexus', 'color': Colors.yellow, 'position': 'Upper abdomen'},
      {'name': 'Rose Quartz', 'chakra': 'Heart', 'color': Colors.pink, 'position': 'Center of chest'},
      {'name': 'Sodalite', 'chakra': 'Throat', 'color': Colors.blue, 'position': 'Throat area'},
      {'name': 'Amethyst', 'chakra': 'Third Eye', 'color': Colors.purple, 'position': 'Between eyebrows'},
      {'name': 'Clear Quartz', 'chakra': 'Crown', 'color': Colors.white, 'position': 'Top of head'},
    ],
    'Emotional Healing Set': [
      {'name': 'Rose Quartz', 'chakra': 'Heart', 'color': Colors.pink, 'position': 'Heart center'},
      {'name': 'Lepidolite', 'chakra': 'Heart', 'color': Colors.purple, 'position': 'Left hand'},
      {'name': 'Green Aventurine', 'chakra': 'Heart', 'color': Colors.green, 'position': 'Right hand'},
      {'name': 'Moonstone', 'chakra': 'Crown', 'color': Colors.grey, 'position': 'Crown area'},
    ],
    'Protection & Grounding Set': [
      {'name': 'Black Tourmaline', 'chakra': 'Root', 'color': Colors.black, 'position': 'Between feet'},
      {'name': 'Hematite', 'chakra': 'Root', 'color': Colors.grey, 'position': 'Left foot'},
      {'name': 'Smoky Quartz', 'chakra': 'Root', 'color': Colors.brown, 'position': 'Right foot'},
      {'name': 'Black Obsidian', 'chakra': 'Root', 'color': Colors.black87, 'position': 'Base of spine'},
    ],
    'Mental Clarity Set': [
      {'name': 'Clear Quartz', 'chakra': 'Crown', 'color': Colors.white, 'position': 'Crown'},
      {'name': 'Fluorite', 'chakra': 'Third Eye', 'color': Colors.purple, 'position': 'Third eye'},
      {'name': 'Sodalite', 'chakra': 'Throat', 'color': Colors.blue, 'position': 'Throat'},
      {'name': 'Amazonite', 'chakra': 'Throat', 'color': Colors.teal, 'position': 'Left temple'},
    ],
  };
  
  final List<String> _healingTypes = [
    'Chakra Alignment',
    'Emotional Healing',
    'Physical Healing',
    'Aura Cleansing',
    'Energy Boost',
    'Stress Relief',
    'Spiritual Connection',
    'Pain Relief',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    _energyFlowController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _chakraController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
    
    _healingWaveController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
    
    _initializeChakraLevels();
    _generateHealingSteps();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _energyFlowController.dispose();
    _chakraController.dispose();
    _healingWaveController.dispose();
    _sessionTimer?.cancel();
    super.dispose();
  }

  void _initializeChakraLevels() {
    final chakras = ['Root', 'Sacral', 'Solar Plexus', 'Heart', 'Throat', 'Third Eye', 'Crown'];
    for (String chakra in chakras) {
      _chakraEnergyLevels[chakra] = 0.5 + (math.Random().nextDouble() * 0.3);
      _chakraActivation[chakra] = false;
    }
  }

  void _generateHealingSteps() {
    switch (_selectedHealingType) {
      case 'Chakra Alignment':
        _healingSteps = [
          {
            'title': 'Preparation',
            'instruction': 'Find a quiet, comfortable space. Lie down and take three deep breaths.',
            'duration': 120,
            'crystals': [],
          },
          {
            'title': 'Root Chakra Activation',
            'instruction': 'Place Red Jasper at the base of your spine. Visualize red energy grounding you.',
            'duration': 180,
            'crystals': ['Red Jasper'],
          },
          {
            'title': 'Sacral Chakra Healing',
            'instruction': 'Add Carnelian below your navel. Feel orange energy flowing through your creativity center.',
            'duration': 180,
            'crystals': ['Red Jasper', 'Carnelian'],
          },
          {
            'title': 'Solar Plexus Empowerment',
            'instruction': 'Place Citrine on your upper abdomen. Yellow light strengthens your personal power.',
            'duration': 180,
            'crystals': ['Red Jasper', 'Carnelian', 'Citrine'],
          },
          {
            'title': 'Heart Chakra Opening',
            'instruction': 'Rose Quartz on your heart center. Green-pink light opens you to love and compassion.',
            'duration': 180,
            'crystals': ['Red Jasper', 'Carnelian', 'Citrine', 'Rose Quartz'],
          },
          {
            'title': 'Integration & Completion',
            'instruction': 'All chakras are now aligned. Feel the rainbow energy flowing through your entire being.',
            'duration': 60,
            'crystals': ['Red Jasper', 'Carnelian', 'Citrine', 'Rose Quartz', 'Sodalite', 'Amethyst', 'Clear Quartz'],
          },
        ];
        break;
      // Add more healing types...
      default:
        _healingSteps = _generateDefaultSteps();
    }
  }

  List<Map<String, dynamic>> _generateDefaultSteps() {
    return [
      {
        'title': 'Begin Healing Session',
        'instruction': 'Prepare your space and selected crystals. Create a peaceful environment.',
        'duration': 180,
        'crystals': [],
      },
      {
        'title': 'Crystal Placement',
        'instruction': 'Place your chosen crystals according to the healing guidance.',
        'duration': 240,
        'crystals': _crystalSets[_selectedCrystalSet] ?? [],
      },
      {
        'title': 'Energy Activation',
        'instruction': 'Focus on your intention. Feel the crystal energy beginning to flow.',
        'duration': 300,
        'crystals': _crystalSets[_selectedCrystalSet] ?? [],
      },
      {
        'title': 'Deep Healing',
        'instruction': 'Allow the crystals to work. Breathe deeply and surrender to the healing process.',
        'duration': 300,
        'crystals': _crystalSets[_selectedCrystalSet] ?? [],
      },
      {
        'title': 'Integration',
        'instruction': 'Slowly return to awareness. Give thanks to the crystals and your healing guides.',
        'duration': 120,
        'crystals': [],
      },
    ];
  }

  void _startHealingSession() {
    setState(() {
      _sessionActive = true;
      _currentStep = 0;
      _remainingTime = _sessionDuration;
    });
    
    _startSessionTimer();
    _activateEnergyFlow();
    HapticFeedback.mediumImpact();
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
          _updateEnergyLevels();
          _checkStepProgress();
        } else {
          _endHealingSession();
        }
      });
    });
  }

  void _checkStepProgress() {
    if (_healingSteps.isNotEmpty) {
      int elapsedTime = _sessionDuration - _remainingTime;
      int stepStartTime = 0;
      
      for (int i = 0; i < _healingSteps.length; i++) {
        int stepDuration = _healingSteps[i]['duration'] as int;
        if (elapsedTime >= stepStartTime && elapsedTime < stepStartTime + stepDuration) {
          if (_currentStep != i) {
            setState(() {
              _currentStep = i;
              _currentGuidance = _healingSteps[i]['instruction'];
            });
            _updateCrystalPlacements();
            HapticFeedback.lightImpact();
          }
          break;
        }
        stepStartTime += stepDuration;
      }
    }
  }

  void _updateCrystalPlacements() {
    if (_currentStep < _healingSteps.length) {
      final stepCrystals = _healingSteps[_currentStep]['crystals'] as List;
      setState(() {
        _placedCrystals = stepCrystals.map((crystal) {
          if (crystal is String) {
            // Find crystal details
            final crystalSet = _crystalSets[_selectedCrystalSet] ?? [];
            final crystalData = crystalSet.firstWhere(
              (c) => c['name'] == crystal,
              orElse: () => {'name': crystal, 'chakra': 'Heart', 'color': Colors.purple},
            );
            return crystalData;
          }
          return crystal as Map<String, dynamic>;
        }).toList();
      });
    }
  }

  void _updateEnergyLevels() {
    final random = math.Random();
    
    // Simulate energy building during session
    setState(() {
      _overallEnergyLevel = math.min(1.0, _overallEnergyLevel + (random.nextDouble() * 0.002));
      
      _chakraEnergyLevels.forEach((chakra, level) {
        final isActive = _placedCrystals.any((crystal) => crystal['chakra'] == chakra);
        if (isActive) {
          _chakraEnergyLevels[chakra] = math.min(1.0, level + (random.nextDouble() * 0.003));
          _chakraActivation[chakra] = true;
        }
      });
    });
    
    // Record energy reading every 30 seconds
    if ((_sessionDuration - _remainingTime) % 30 == 0) {
      _energyReadings.add({
        'time': _sessionDuration - _remainingTime,
        'overall': _overallEnergyLevel,
        'chakras': Map.from(_chakraEnergyLevels),
      });
    }
  }

  void _activateEnergyFlow() {
    _energyFlowController.repeat();
    _chakraController.repeat();
    _healingWaveController.repeat(reverse: true);
  }

  void _endHealingSession() {
    setState(() {
      _sessionActive = false;
      _currentStep = 0;
      _currentGuidance = 'Healing session complete. Take time to integrate the energy.';
    });
    
    _sessionTimer?.cancel();
    HapticFeedback.heavyImpact();
    
    _showSessionSummary();
  }

  void _showSessionSummary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CrystalGrimoireTheme.royalPurple,
        title: const Text(
          '✨ Healing Session Complete',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Session Duration: ${_formatTime(_sessionDuration)}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              'Final Energy Level: ${(_overallEnergyLevel * 100).toInt()}%',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              'Activated Chakras: ${_chakraActivation.values.where((v) => v).length}/7',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveHealingSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CrystalGrimoireTheme.amethyst,
            ),
            child: const Text('Save Session'),
          ),
        ],
      ),
    );
  }

  void _saveHealingSession() {
    // In a real app, this would save to local storage or backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('💎 Healing session saved to your energy journal'),
        backgroundColor: CrystalGrimoireTheme.successGreen,
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: CrystalGrimoireTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Energy flow background
            if (_sessionActive) _buildEnergyFlowBackground(),
            
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSetupTab(),
                        _buildSessionTab(),
                        _buildEnergyReadingsTab(),
                        _buildHealingLibraryTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyFlowBackground() {
    return AnimatedBuilder(
      animation: _energyFlowController,
      builder: (context, child) {
        return CustomPaint(
          painter: EnergyFlowPainter(_energyFlowController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              if (_sessionActive) {
                _showExitConfirmation();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🔮 Energy Healing',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  _sessionActive ? 'Session Active' : 'Crystal-guided healing sessions',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (_sessionActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CrystalGrimoireTheme.successGreen.withOpacity(0.3),
                    CrystalGrimoireTheme.etherealBlue.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatTime(_remainingTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [CrystalGrimoireTheme.amethyst, CrystalGrimoireTheme.cosmicViolet],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        tabs: const [
          Tab(text: 'Setup'),
          Tab(text: 'Session'),
          Tab(text: 'Energy'),
          Tab(text: 'Library'),
        ],
      ),
    );
  }

  Widget _buildSetupTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Healing type selection
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.healing,
                    color: CrystalGrimoireTheme.successGreen,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Healing Type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _healingTypes.map((type) {
                  final isSelected = type == _selectedHealingType;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedHealingType = type;
                        _generateHealingSteps();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected ? const LinearGradient(
                          colors: [CrystalGrimoireTheme.amethyst, CrystalGrimoireTheme.cosmicViolet],
                        ) : null,
                        color: isSelected ? null : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected 
                            ? CrystalGrimoireTheme.celestialGold
                            : Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Crystal set selection
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.diamond,
                    color: CrystalGrimoireTheme.amethyst,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Crystal Set',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              ..._crystalSets.entries.map((entry) {
                final isSelected = entry.key == _selectedCrystalSet;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    tileColor: isSelected 
                      ? CrystalGrimoireTheme.amethyst.withOpacity(0.3)
                      : Colors.white.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected 
                          ? CrystalGrimoireTheme.celestialGold
                          : Colors.white.withOpacity(0.2),
                      ),
                    ),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: entry.value.take(2).map((c) => c['color'] as Color).toList(),
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.value.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${entry.value.length} crystals',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    trailing: isSelected 
                      ? Icon(
                          Icons.check_circle,
                          color: CrystalGrimoireTheme.celestialGold,
                        )
                      : const Icon(
                          Icons.radio_button_unchecked,
                          color: Colors.white54,
                        ),
                    onTap: () {
                      setState(() {
                        _selectedCrystalSet = entry.key;
                      });
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Session duration
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: CrystalGrimoireTheme.etherealBlue,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Session Duration',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Slider(
                value: _sessionDuration.toDouble(),
                min: 300, // 5 minutes
                max: 3600, // 1 hour
                divisions: 11,
                activeColor: CrystalGrimoireTheme.etherealBlue,
                inactiveColor: Colors.white.withOpacity(0.3),
                label: _formatTime(_sessionDuration),
                onChanged: (value) {
                  setState(() {
                    _sessionDuration = value.toInt();
                    _remainingTime = _sessionDuration;
                  });
                },
              ),
              
              Center(
                child: Text(
                  _formatTime(_sessionDuration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Start session button
        EnhancedMysticalButton(
          text: _sessionActive ? 'Session Running...' : 'Begin Healing Session',
          icon: Icons.play_arrow,
          isPrimary: true,
          isPremium: true,
          width: double.infinity,
          onPressed: _sessionActive ? null : _startHealingSession,
        ),
      ],
    );
  }

  Widget _buildSessionTab() {
    if (!_sessionActive) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.self_improvement,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No active healing session',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Go to Setup to begin a new session',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Session progress
        EnhancedMysticalCard(
          gradient: LinearGradient(
            colors: [
              CrystalGrimoireTheme.successGreen.withOpacity(0.3),
              CrystalGrimoireTheme.etherealBlue.withOpacity(0.3),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Session Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: CrystalGrimoireTheme.successGreen.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'Step ${_currentStep + 1}/${_healingSteps.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              LinearProgressIndicator(
                value: (_sessionDuration - _remainingTime) / _sessionDuration,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(CrystalGrimoireTheme.successGreen),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                _formatTime(_remainingTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Current step guidance
        if (_healingSteps.isNotEmpty && _currentStep < _healingSteps.length)
          EnhancedMysticalCard(
            isGlowing: true,
            glowColor: CrystalGrimoireTheme.celestialGold,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _healingSteps[_currentStep]['title'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _healingSteps[_currentStep]['instruction'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Crystal placement guide
        if (_placedCrystals.isNotEmpty)
          EnhancedMysticalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Crystals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                
                ..._placedCrystals.map((crystal) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (crystal['color'] as Color).withOpacity(0.3),
                          CrystalGrimoireTheme.royalPurple.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: crystal['color'] as Color,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: crystal['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.diamond,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                crystal['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Position: ${crystal['position']}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _chakraController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (math.sin(_chakraController.value * 2 * math.pi) * 0.1),
                              child: Icon(
                                Icons.auto_awesome,
                                color: CrystalGrimoireTheme.celestialGold,
                                size: 24,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        
        const SizedBox(height: 24),
        
        // End session button
        EnhancedMysticalButton(
          text: 'End Session',
          icon: Icons.stop,
          onPressed: _endHealingSession,
          width: double.infinity,
        ),
      ],
    );
  }

  Widget _buildEnergyReadingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Overall energy level
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Overall Energy Level',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _overallEnergyLevel,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getEnergyColor(_overallEnergyLevel),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(_overallEnergyLevel * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Chakra energy levels
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chakra Energy Levels',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              ..._chakraEnergyLevels.entries.map((entry) {
                final chakra = entry.key;
                final level = entry.value;
                final isActive = _chakraActivation[chakra] ?? false;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getChakraColor(chakra),
                          shape: BoxShape.circle,
                          boxShadow: isActive ? [
                            BoxShadow(
                              color: _getChakraColor(chakra).withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ] : null,
                        ),
                        child: isActive
                          ? AnimatedBuilder(
                              animation: _chakraController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _chakraController.value * 2 * math.pi,
                                  child: const Icon(
                                    Icons.auto_awesome,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                );
                              },
                            )
                          : Icon(
                              Icons.circle,
                              color: Colors.white.withOpacity(0.7),
                              size: 20,
                            ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chakra,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: level,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getChakraColor(chakra),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(level * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        
        if (_energyReadings.isNotEmpty) ...[
          const SizedBox(height: 16),
          
          // Energy reading history
          EnhancedMysticalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Energy Reading History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        CrystalGrimoireTheme.etherealBlue.withOpacity(0.2),
                        CrystalGrimoireTheme.amethyst.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Energy Flow Chart\n(Real-time visualization)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHealingLibraryTab() {
    final healingMethods = [
      {
        'title': 'Crystal Grid Healing',
        'description': 'Sacred geometry patterns for amplified healing energy',
        'duration': '20-30 minutes',
        'difficulty': 'Intermediate',
        'crystals': ['Clear Quartz', 'Amethyst', 'Rose Quartz'],
      },
      {
        'title': 'Chakra Balancing Sequence',
        'description': 'Complete alignment of all seven main energy centers',
        'duration': '15-25 minutes',
        'difficulty': 'Beginner',
        'crystals': ['Rainbow Chakra Set'],
      },
      {
        'title': 'Emotional Release Protocol',
        'description': 'Deep healing for emotional trauma and blockages',
        'duration': '30-45 minutes',
        'difficulty': 'Advanced',
        'crystals': ['Rose Quartz', 'Lepidolite', 'Moonstone'],
      },
      {
        'title': 'Physical Pain Relief',
        'description': 'Targeted crystal therapy for physical discomfort',
        'duration': '15-20 minutes',
        'difficulty': 'Beginner',
        'crystals': ['Hematite', 'Clear Quartz', 'Fluorite'],
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Healing Methods Library',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Explore different crystal healing techniques',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        
        ...healingMethods.map((method) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: EnhancedMysticalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          method['title']! as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(method['difficulty']! as String),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          method['difficulty']! as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    method['description']! as String,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: CrystalGrimoireTheme.etherealBlue,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        method['duration']! as String,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.diamond,
                        color: CrystalGrimoireTheme.amethyst,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          (method['crystals'] as List<String>).join(', '),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  EnhancedMysticalButton(
                    text: 'Start Healing',
                    icon: Icons.play_arrow,
                    onPressed: () {
                      // Set up this healing method
                      setState(() {
                        _selectedHealingType = method['title']! as String;
                        _tabController.animateTo(0);
                      });
                    },
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Color _getEnergyColor(double level) {
    if (level < 0.3) return CrystalGrimoireTheme.errorRed;
    if (level < 0.6) return CrystalGrimoireTheme.warningAmber;
    if (level < 0.8) return CrystalGrimoireTheme.etherealBlue;
    return CrystalGrimoireTheme.successGreen;
  }

  Color _getChakraColor(String chakra) {
    switch (chakra) {
      case 'Root': return Colors.red;
      case 'Sacral': return Colors.orange;
      case 'Solar Plexus': return Colors.yellow;
      case 'Heart': return Colors.green;
      case 'Throat': return Colors.blue;
      case 'Third Eye': return Colors.indigo;
      case 'Crown': return Colors.purple;
      default: return Colors.white;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner': return CrystalGrimoireTheme.successGreen;
      case 'Intermediate': return CrystalGrimoireTheme.warningAmber;
      case 'Advanced': return CrystalGrimoireTheme.errorRed;
      default: return CrystalGrimoireTheme.amethyst;
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CrystalGrimoireTheme.royalPurple,
        title: const Text(
          'End Healing Session?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to end your current healing session?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Session'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _endHealingSession();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CrystalGrimoireTheme.errorRed,
            ),
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }
}

class EnergyFlowPainter extends CustomPainter {
  final double animationValue;
  
  EnergyFlowPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw flowing energy streams
    for (int i = 0; i < 20; i++) {
      final x = (size.width * (i / 20) + animationValue * 100) % size.width;
      final y = size.height * 0.5 + (math.sin(animationValue * 2 * math.pi + i) * 200);
      final radius = 3 + (math.sin(animationValue * 2 * math.pi + i * 0.5) * 2);
      
      paint.color = [
        CrystalGrimoireTheme.successGreen,
        CrystalGrimoireTheme.etherealBlue,
        CrystalGrimoireTheme.amethyst,
        CrystalGrimoireTheme.celestialGold,
      ][i % 4].withOpacity(0.3);
      
      canvas.drawCircle(Offset(x, y), radius.abs(), paint);
    }

    // Draw chakra energy points
    final chakraPositions = [
      Offset(size.width * 0.5, size.height * 0.85), // Root
      Offset(size.width * 0.5, size.height * 0.75), // Sacral
      Offset(size.width * 0.5, size.height * 0.65), // Solar Plexus
      Offset(size.width * 0.5, size.height * 0.55), // Heart
      Offset(size.width * 0.5, size.height * 0.45), // Throat
      Offset(size.width * 0.5, size.height * 0.35), // Third Eye
      Offset(size.width * 0.5, size.height * 0.25), // Crown
    ];
    
    final chakraColors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];
    
    for (int i = 0; i < chakraPositions.length; i++) {
      final position = chakraPositions[i];
      final color = chakraColors[i];
      final radius = 15 + (math.sin(animationValue * 2 * math.pi + i * 0.3) * 5);
      
      paint.color = color.withOpacity(0.4);
      canvas.drawCircle(position, radius, paint);
      
      paint.color = color.withOpacity(0.8);
      canvas.drawCircle(position, radius * 0.6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}