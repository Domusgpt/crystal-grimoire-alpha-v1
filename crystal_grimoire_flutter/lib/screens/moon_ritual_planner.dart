import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import '../config/enhanced_theme.dart';
import '../widgets/common/enhanced_mystical_widgets.dart';
import '../widgets/animations/enhanced_animations.dart';
import '../data/crystal_database.dart';

class MoonRitualPlannerScreen extends StatefulWidget {
  const MoonRitualPlannerScreen({Key? key}) : super(key: key);

  @override
  State<MoonRitualPlannerScreen> createState() => _MoonRitualPlannerScreenState();
}

class _MoonRitualPlannerScreenState extends State<MoonRitualPlannerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _moonPhaseController;
  late AnimationController _starsController;
  late AnimationController _ritualGlowController;
  
  DateTime _selectedDate = DateTime.now();
  String _currentMoonPhase = '';
  double _moonIllumination = 0.0;
  Map<String, dynamic> _currentRitualRecommendations = {};
  List<Map<String, dynamic>> _upcomingRituals = [];
  List<Map<String, dynamic>> _plannedRituals = [];
  List<Map<String, dynamic>> _ritualHistory = [];
  
  // Ritual configuration
  String _selectedRitualType = 'Manifestation';
  String _selectedElement = 'Earth';
  List<String> _selectedCrystals = [];
  String _ritualIntention = '';
  TimeOfDay _preferredTime = const TimeOfDay(hour: 21, minute: 0); // 9 PM default
  
  // Moon phase data and calculations
  final List<String> _moonPhases = [
    'New Moon',
    'Waxing Crescent',
    'First Quarter',
    'Waxing Gibbous',
    'Full Moon',
    'Waning Gibbous',
    'Third Quarter',
    'Waning Crescent',
  ];
  
  final Map<String, Map<String, dynamic>> _moonPhaseData = {
    'New Moon': {
      'description': 'Perfect for new beginnings, setting intentions, and planting seeds of manifestation',
      'energy': 'Fresh start, new possibilities, inner reflection',
      'crystals': ['Moonstone', 'Labradorite', 'Clear Quartz', 'Selenite'],
      'color': Color(0xFF1A1A2E),
      'rituals': ['Intention Setting', 'Manifestation', 'Fresh Start'],
      'best_time': 'Midnight',
    },
    'Waxing Crescent': {
      'description': 'Time for taking action on intentions, building momentum, and nurturing growth',
      'energy': 'Growth, building energy, taking first steps',
      'crystals': ['Green Aventurine', 'Citrine', 'Carnelian', 'Amazonite'],
      'color': Color(0xFF2E4C6D),
      'rituals': ['Growth Work', 'Momentum Building', 'Courage'],
      'best_time': 'Evening',
    },
    'First Quarter': {
      'description': 'Decision-making time, overcoming challenges, and pushing through obstacles',
      'energy': 'Determination, decision-making, overcoming obstacles',
      'crystals': ['Tiger\'s Eye', 'Fluorite', 'Sodalite', 'Hematite'],
      'color': Color(0xFF4A90A4),
      'rituals': ['Decision Making', 'Challenge Override', 'Strength'],
      'best_time': 'Dawn',
    },
    'Waxing Gibbous': {
      'description': 'Refining plans, adjusting course, and preparing for culmination',
      'energy': 'Refinement, adjustment, preparation for peak',
      'crystals': ['Lapis Lazuli', 'Amethyst', 'Rose Quartz', 'Aquamarine'],
      'color': Color(0xFF7FB3D3),
      'rituals': ['Refinement', 'Adjustment', 'Preparation'],
      'best_time': 'Late Evening',
    },
    'Full Moon': {
      'description': 'Peak energy for manifestation, gratitude, charging crystals, and releasing',
      'energy': 'Peak power, manifestation, gratitude, release',
      'crystals': ['Selenite', 'Clear Quartz', 'Moonstone', 'Lepidolite'],
      'color': Color(0xFFF5F5DC),
      'rituals': ['Manifestation', 'Gratitude', 'Crystal Charging', 'Release'],
      'best_time': 'Midnight',
    },
    'Waning Gibbous': {
      'description': 'Gratitude practices, sharing wisdom, and reflecting on achievements',
      'energy': 'Gratitude, sharing, reflection on success',
      'crystals': ['Citrine', 'Sunstone', 'Carnelian', 'Orange Calcite'],
      'color': Color(0xFFE6E6FA),
      'rituals': ['Gratitude', 'Wisdom Sharing', 'Reflection'],
      'best_time': 'Sunset',
    },
    'Third Quarter': {
      'description': 'Releasing what no longer serves, forgiveness, and letting go',
      'energy': 'Release, forgiveness, letting go of the old',
      'crystals': ['Black Obsidian', 'Smoky Quartz', 'Apache Tear', 'Black Tourmaline'],
      'color': Color(0xFF8A9BA8),
      'rituals': ['Release', 'Forgiveness', 'Letting Go'],
      'best_time': 'Late Night',
    },
    'Waning Crescent': {
      'description': 'Rest, restoration, inner work, and preparing for the next cycle',
      'energy': 'Rest, restoration, inner work, preparation',
      'crystals': ['Lepidolite', 'Moonstone', 'Prehnite', 'Blue Lace Agate'],
      'color': Color(0xFF4F5B62),
      'rituals': ['Rest & Restore', 'Inner Work', 'Cycle Preparation'],
      'best_time': 'Early Morning',
    },
  };
  
  final List<String> _ritualTypes = [
    'Manifestation',
    'Release & Letting Go',
    'Gratitude & Abundance',
    'Protection & Cleansing',
    'Love & Relationships',
    'Wisdom & Intuition',
    'Healing & Recovery',
    'Career & Success',
    'Spiritual Growth',
    'Dream Work',
  ];
  
  final List<String> _elements = ['Earth', 'Water', 'Fire', 'Air', 'Spirit'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    _moonPhaseController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    _starsController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();
    
    _ritualGlowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _calculateCurrentMoonPhase();
    _generateUpcomingRituals();
    _loadRitualHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _moonPhaseController.dispose();
    _starsController.dispose();
    _ritualGlowController.dispose();
    super.dispose();
  }

  void _calculateCurrentMoonPhase() {
    // Simplified moon phase calculation (in a real app, use astronomical calculations)
    final daysSinceNewMoon = DateTime.now().difference(DateTime(2024, 1, 11)).inDays % 29.53;
    final phaseIndex = ((daysSinceNewMoon / 29.53) * 8).floor() % 8;
    
    setState(() {
      _currentMoonPhase = _moonPhases[phaseIndex];
      _moonIllumination = _calculateIllumination(daysSinceNewMoon);
      _currentRitualRecommendations = _moonPhaseData[_currentMoonPhase] ?? {};
    });
  }
  
  double _calculateIllumination(double daysSinceNewMoon) {
    // Simplified illumination calculation
    final phase = (daysSinceNewMoon / 29.53) * 2 * math.pi;
    return (1 - math.cos(phase)) / 2;
  }
  
  void _generateUpcomingRituals() {
    final now = DateTime.now();
    _upcomingRituals.clear();
    
    for (int i = 0; i < 8; i++) {
      final date = now.add(Duration(days: i));
      final daysSinceNewMoon = date.difference(DateTime(2024, 1, 11)).inDays % 29.53;
      final phaseIndex = ((daysSinceNewMoon / 29.53) * 8).floor() % 8;
      final phase = _moonPhases[phaseIndex];
      final phaseData = _moonPhaseData[phase] ?? {};
      
      _upcomingRituals.add({
        'date': date,
        'phase': phase,
        'illumination': _calculateIllumination(daysSinceNewMoon.toDouble()),
        'recommended_rituals': phaseData['rituals'] ?? [],
        'best_time': phaseData['best_time'] ?? 'Evening',
        'energy': phaseData['energy'] ?? '',
        'crystals': phaseData['crystals'] ?? [],
      });
    }
  }
  
  void _loadRitualHistory() {
    // In a real app, this would load from storage
    _ritualHistory = [
      {
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'type': 'Manifestation',
        'phase': 'Full Moon',
        'crystals': ['Clear Quartz', 'Moonstone', 'Selenite'],
        'outcome': 'Powerful session with clear visions',
        'rating': 5,
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 10)),
        'type': 'Release & Letting Go',
        'phase': 'Third Quarter',
        'crystals': ['Black Obsidian', 'Smoky Quartz'],
        'outcome': 'Deep emotional release achieved',
        'rating': 4,
      },
    ];
  }
  
  void _schedulePlannedRitual() {
    if (_ritualIntention.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🌙 Please set your ritual intention first'),
          backgroundColor: CrystalGrimoireTheme.warningAmber,
        ),
      );
      return;
    }
    
    final newRitual = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'date': _selectedDate,
      'time': _preferredTime,
      'type': _selectedRitualType,
      'element': _selectedElement,
      'crystals': List.from(_selectedCrystals),
      'intention': _ritualIntention,
      'phase': _getMoonPhaseForDate(_selectedDate),
      'created': DateTime.now(),
    };
    
    setState(() {
      _plannedRituals.add(newRitual);
      _plannedRituals.sort((a, b) => a['date'].compareTo(b['date']));
    });
    
    HapticFeedback.heavyImpact();
    _showRitualScheduledDialog();
  }
  
  String _getMoonPhaseForDate(DateTime date) {
    final daysSinceNewMoon = date.difference(DateTime(2024, 1, 11)).inDays % 29.53;
    final phaseIndex = ((daysSinceNewMoon / 29.53) * 8).floor() % 8;
    return _moonPhases[phaseIndex];
  }
  
  void _showRitualScheduledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CrystalGrimoireTheme.royalPurple,
        title: const Text(
          '🌙✨ Ritual Scheduled',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your $_selectedRitualType ritual has been scheduled for ${_formatDate(_selectedDate)}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              'Moon Phase: ${_getMoonPhaseForDate(_selectedDate)}',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 10),
            Text(
              'Selected Crystals: ${_selectedCrystals.join(", ")}',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
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
              _setRitualReminder();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CrystalGrimoireTheme.celestialGold,
            ),
            child: const Text('Set Reminder'),
          ),
        ],
      ),
    );
  }
  
  void _setRitualReminder() {
    // In a real app, this would set a system notification
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔔 Ritual reminder set! You\'ll be notified 1 hour before.'),
        backgroundColor: CrystalGrimoireTheme.successGreen,
        duration: Duration(seconds: 3),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
  
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
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
            // Animated night sky background
            _buildNightSkyBackground(),
            
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildCurrentMoonTab(),
                        _buildPlanRitualTab(),
                        _buildUpcomingTab(),
                        _buildHistoryTab(),
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
  
  Widget _buildNightSkyBackground() {
    return Stack(
      children: [
        // Stars
        AnimatedBuilder(
          animation: _starsController,
          builder: (context, child) {
            return CustomPaint(
              painter: StarsPainter(_starsController.value),
              size: Size.infinite,
            );
          },
        ),
        // Moon
        Positioned(
          top: 100,
          right: 30,
          child: AnimatedBuilder(
            animation: _moonPhaseController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _moonPhaseController.value * 2 * math.pi * 0.1,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.6),
                        Colors.white.withOpacity(0.3),
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: MoonPhasePainter(_moonIllumination),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🌙 Moon Ritual Planner',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Current: $_currentMoonPhase (${(_moonIllumination * 100).toInt()}%)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (_currentRitualRecommendations['color'] as Color?)?.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            child: Text(
              'Today',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
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
            colors: [CrystalGrimoireTheme.moonlightSilver, CrystalGrimoireTheme.cosmicViolet],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        tabs: const [
          Tab(text: 'Current Moon'),
          Tab(text: 'Plan Ritual'),
          Tab(text: 'Upcoming'),
          Tab(text: 'History'),
        ],
      ),
    );
  }
  
  Widget _buildCurrentMoonTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Current moon phase card
        EnhancedMysticalCard(
          gradient: LinearGradient(
            colors: [
              (_currentRitualRecommendations['color'] as Color?)?.withOpacity(0.3) ?? CrystalGrimoireTheme.royalPurple.withOpacity(0.3),
              CrystalGrimoireTheme.cosmicViolet.withOpacity(0.2),
            ],
          ),
          isGlowing: true,
          glowColor: _currentRitualRecommendations['color'] as Color? ?? CrystalGrimoireTheme.moonlightSilver,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: CustomPaint(
                      painter: MoonPhasePainter(_moonIllumination),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentMoonPhase,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${(_moonIllumination * 100).toInt()}% Illuminated',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                _currentRitualRecommendations['description'] ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Energy: ${_currentRitualRecommendations['energy'] ?? ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Best Time: ${_currentRitualRecommendations['best_time'] ?? 'Evening'}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Recommended crystals
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recommended Crystals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: (_currentRitualRecommendations['crystals'] as List<String>? ?? []).map((crystal) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CrystalGrimoireTheme.amethyst.withOpacity(0.3),
                          CrystalGrimoireTheme.etherealBlue.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CrystalGrimoireTheme.celestialGold.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.diamond,
                          color: CrystalGrimoireTheme.celestialGold,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          crystal,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Recommended rituals
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recommended Rituals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              ...(_currentRitualRecommendations['rituals'] as List<String>? ?? []).map((ritual) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    tileColor: Colors.white.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    leading: AnimatedBuilder(
                      animation: _ritualGlowController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_ritualGlowController.value * 0.1),
                          child: Icon(
                            Icons.auto_awesome,
                            color: CrystalGrimoireTheme.celestialGold,
                            size: 24,
                          ),
                        );
                      },
                    ),
                    title: Text(
                      ritual,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withOpacity(0.5),
                      size: 16,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedRitualType = ritual;
                        _tabController.animateTo(1);
                      });
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Quick ritual button
        EnhancedMysticalButton(
          text: 'Start Quick Ritual Now',
          icon: Icons.play_circle_fill,
          isPrimary: true,
          isPremium: true,
          width: double.infinity,
          onPressed: () {
            _startQuickRitual();
          },
        ),
      ],
    );
  }
  
  void _startQuickRitual() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CrystalGrimoireTheme.royalPurple,
        title: Text(
          '🌙 Quick ${_currentMoonPhase} Ritual',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Begin a 10-minute ritual perfect for the current moon phase.',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'You\'ll need:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...(_currentRitualRecommendations['crystals'] as List<String>? ?? []).take(3).map((crystal) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $crystal',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _launchQuickRitualGuide();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CrystalGrimoireTheme.celestialGold,
            ),
            child: const Text('Begin Ritual'),
          ),
        ],
      ),
    );
  }
  
  void _launchQuickRitualGuide() {
    // In a real app, this would navigate to a guided ritual screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🌙 ${_currentMoonPhase} ritual guide starting...'),
        backgroundColor: CrystalGrimoireTheme.successGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  Widget _buildPlanRitualTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Date selection
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: CrystalGrimoireTheme.etherealBlue,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Ritual Date',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              ListTile(
                contentPadding: const EdgeInsets.all(12),
                tileColor: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: Icon(
                  Icons.event,
                  color: CrystalGrimoireTheme.celestialGold,
                ),
                title: Text(
                  _formatDate(_selectedDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Moon Phase: ${_getMoonPhaseForDate(_selectedDate)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white54,
                  size: 16,
                ),
                onTap: _selectDate,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Time selection
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: CrystalGrimoireTheme.moonlightSilver,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Preferred Time',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              ListTile(
                contentPadding: const EdgeInsets.all(12),
                tileColor: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: Icon(
                  Icons.schedule,
                  color: CrystalGrimoireTheme.celestialGold,
                ),
                title: Text(
                  _formatTime(_preferredTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white54,
                  size: 16,
                ),
                onTap: _selectTime,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Ritual type selection
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: CrystalGrimoireTheme.amethyst,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Ritual Type',
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
                children: _ritualTypes.map((type) {
                  final isSelected = type == _selectedRitualType;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRitualType = type;
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
                          fontSize: 12,
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
        
        // Element selection
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.nature,
                    color: CrystalGrimoireTheme.successGreen,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Primary Element',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _elements.map((element) {
                  final isSelected = element == _selectedElement;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedElement = element;
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isSelected ? LinearGradient(
                              colors: [
                                _getElementColor(element),
                                _getElementColor(element).withOpacity(0.6),
                              ],
                            ) : null,
                            color: isSelected ? null : Colors.white.withOpacity(0.1),
                            border: Border.all(
                              color: isSelected 
                                ? CrystalGrimoireTheme.celestialGold
                                : Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _getElementIcon(element),
                            color: isSelected ? Colors.white : Colors.white70,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          element,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Crystal selection
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
                    'Select Crystals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Choose up to 7 crystals for your ritual',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CrystalDatabase.getAllCrystals().map((crystal) {
                  final isSelected = _selectedCrystals.contains(crystal.name);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedCrystals.remove(crystal.name);
                        } else if (_selectedCrystals.length < 7) {
                          _selectedCrystals.add(crystal.name);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: isSelected ? const LinearGradient(
                          colors: [CrystalGrimoireTheme.amethyst, CrystalGrimoireTheme.etherealBlue],
                        ) : null,
                        color: isSelected ? null : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected 
                            ? CrystalGrimoireTheme.celestialGold
                            : Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.diamond,
                            color: isSelected ? Colors.white : Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            crystal.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              if (_selectedCrystals.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Crystals (${_selectedCrystals.length}/7):',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedCrystals.join(', '),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Intention setting
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: CrystalGrimoireTheme.cosmicViolet,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Ritual Intention',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextField(
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Set your clear intention for this ritual...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: CrystalGrimoireTheme.celestialGold),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _ritualIntention = value;
                  });
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Schedule ritual button
        EnhancedMysticalButton(
          text: 'Schedule Ritual',
          icon: Icons.schedule,
          isPrimary: true,
          isPremium: true,
          width: double.infinity,
          onPressed: _schedulePlannedRitual,
        ),
      ],
    );
  }
  
  Color _getElementColor(String element) {
    switch (element) {
      case 'Earth': return Colors.brown;
      case 'Water': return Colors.blue;
      case 'Fire': return Colors.red;
      case 'Air': return Colors.grey;
      case 'Spirit': return Colors.purple;
      default: return Colors.white;
    }
  }
  
  IconData _getElementIcon(String element) {
    switch (element) {
      case 'Earth': return Icons.terrain;
      case 'Water': return Icons.water_drop;
      case 'Fire': return Icons.local_fire_department;
      case 'Air': return Icons.air;
      case 'Spirit': return Icons.auto_awesome;
      default: return Icons.circle;
    }
  }
  
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: CrystalGrimoireTheme.celestialGold,
              surface: CrystalGrimoireTheme.royalPurple,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _preferredTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: CrystalGrimoireTheme.celestialGold,
              surface: CrystalGrimoireTheme.royalPurple,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _preferredTime = picked;
      });
    }
  }
  
  Widget _buildUpcomingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Next 7 days moon phases
        const Text(
          'Upcoming Moon Phases',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        
        ..._upcomingRituals.map((ritual) {
          final date = ritual['date'] as DateTime;
          final phase = ritual['phase'] as String;
          final illumination = ritual['illumination'] as double;
          final isToday = DateTime.now().day == date.day && 
                         DateTime.now().month == date.month;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: EnhancedMysticalCard(
              isGlowing: isToday,
              glowColor: isToday ? CrystalGrimoireTheme.celestialGold : null,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: CustomPaint(
                    painter: MoonPhasePainter(illumination),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      _formatDate(date),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: CrystalGrimoireTheme.celestialGold,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'TODAY',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$phase (${(illumination * 100).toInt()}%)',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Best for: ${(ritual['recommended_rituals'] as List).join(", ")}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.add_circle,
                    color: CrystalGrimoireTheme.celestialGold,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedDate = date;
                      _selectedRitualType = (ritual['recommended_rituals'] as List).first;
                      _tabController.animateTo(1);
                    });
                  },
                ),
              ),
            ),
          );
        }).toList(),
        
        const SizedBox(height: 20),
        
        // Planned rituals
        if (_plannedRituals.isNotEmpty) ...[
          const Text(
            'Your Planned Rituals',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._plannedRituals.map((planned) {
            final date = planned['date'] as DateTime;
            final time = planned['time'] as TimeOfDay;
            final type = planned['type'] as String;
            final crystals = planned['crystals'] as List<String>;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: EnhancedMysticalCard(
                gradient: LinearGradient(
                  colors: [
                    CrystalGrimoireTheme.successGreen.withOpacity(0.3),
                    CrystalGrimoireTheme.etherealBlue.withOpacity(0.3),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Icon(
                    Icons.event_available,
                    color: CrystalGrimoireTheme.successGreen,
                    size: 32,
                  ),
                  title: Text(
                    type,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_formatDate(date)} at ${_formatTime(time)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Crystals: ${crystals.take(3).join(", ")}${crystals.length > 3 ? "..." : ""}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    color: CrystalGrimoireTheme.royalPurple,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Edit', style: TextStyle(color: Colors.white)),
                        onTap: () {
                          // Edit ritual
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                        onTap: () {
                          setState(() {
                            _plannedRituals.remove(planned);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ],
    );
  }
  
  Widget _buildHistoryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Ritual History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Track your spiritual journey and ritual experiences',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        
        if (_ritualHistory.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No ritual history yet',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete your first ritual to start tracking',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          ..._ritualHistory.map((history) {
            final date = history['date'] as DateTime;
            final type = history['type'] as String;
            final phase = history['phase'] as String;
            final crystals = history['crystals'] as List<String>;
            final outcome = history['outcome'] as String;
            final rating = history['rating'] as int;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: EnhancedMysticalCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              type,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < rating ? Icons.star : Icons.star_border,
                                color: CrystalGrimoireTheme.celestialGold,
                                size: 16,
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: CrystalGrimoireTheme.etherealBlue,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(date),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.brightness_3,
                            color: CrystalGrimoireTheme.moonlightSilver,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            phase,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Crystals Used:',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              crystals.join(', '),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Experience:',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              outcome,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
      ],
    );
  }
}

class StarsPainter extends CustomPainter {
  final double animationValue;
  
  StarsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw twinkling stars
    final random = math.Random(42); // Fixed seed for consistent stars
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.7; // Upper portion only
      final twinkle = math.sin(animationValue * 2 * math.pi + i * 0.1);
      final opacity = 0.3 + (twinkle * 0.4);
      final radius = 1.0 + (twinkle * 0.5);
      
      paint.color = Colors.white.withOpacity(opacity.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MoonPhasePainter extends CustomPainter {
  final double illumination;
  
  MoonPhasePainter(this.illumination);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw full moon (background)
    paint.color = Colors.white.withOpacity(0.3);
    canvas.drawCircle(center, radius, paint);
    
    // Draw illuminated portion
    paint.color = Colors.white.withOpacity(0.9);
    
    if (illumination <= 0.5) {
      // Waxing phases
      final illuminatedWidth = illumination * 2 * radius;
      final rect = Rect.fromCenter(
        center: center,
        width: illuminatedWidth,
        height: radius * 2,
      );
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));
      canvas.drawOval(rect, paint);
    } else {
      // Waning phases
      canvas.drawCircle(center, radius, paint);
      
      paint.color = Colors.black.withOpacity(0.7);
      final shadowWidth = (1 - illumination) * 2 * radius;
      final rect = Rect.fromCenter(
        center: center,
        width: shadowWidth,
        height: radius * 2,
      );
      canvas.drawOval(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}