import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import '../config/enhanced_theme.dart';
import '../widgets/common/enhanced_mystical_widgets.dart';
import '../widgets/animations/enhanced_animations.dart';

class DreamJournalAnalyzer extends StatefulWidget {
  const DreamJournalAnalyzer({Key? key}) : super(key: key);

  @override
  State<DreamJournalAnalyzer> createState() => _DreamJournalAnalyzerState();
}

class _DreamJournalAnalyzerState extends State<DreamJournalAnalyzer>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _floatingController;
  late AnimationController _moonController;
  late AnimationController _pulseController;
  
  final TextEditingController _dreamTextController = TextEditingController();
  
  List<Map<String, dynamic>> _dreamEntries = [];
  List<Map<String, dynamic>> _crystalRecommendations = [];
  String _currentMoonPhase = 'Waxing Crescent';
  
  // Dream analysis state
  String _dreamAnalysis = '';
  List<String> _dreamSymbols = [];
  Map<String, dynamic> _dreamMood = {
    'primary': 'Peaceful',
    'secondary': 'Curious',
    'intensity': 0.7,
  };
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
    
    _moonController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _loadSampleData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _floatingController.dispose();
    _moonController.dispose();
    _pulseController.dispose();
    _dreamTextController.dispose();
    super.dispose();
  }
  
  void _loadSampleData() {
    setState(() {
      _dreamEntries = [
        {
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'title': 'Crystal Cave Discovery',
          'content': 'I found myself in a luminous cave filled with amethyst clusters...',
          'crystals': ['Amethyst', 'Clear Quartz'],
          'mood': 'Mystical',
          'moonPhase': 'Full Moon',
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 3)),
          'title': 'Flying Over Ocean',
          'content': 'I was soaring above crystal-clear waters, feeling completely free...',
          'crystals': ['Aquamarine', 'Selenite'],
          'mood': 'Liberating',
          'moonPhase': 'Waxing Gibbous',
        },
      ];
    });
  }
  
  void _analyzeDream() {
    final dreamText = _dreamTextController.text;
    if (dreamText.isEmpty) return;
    
    setState(() {
      _dreamAnalysis = 'This dream suggests a deep connection with transformation and spiritual growth. The symbols present indicate...';
      
      _dreamSymbols = ['Water', 'Crystal', 'Light', 'Journey'];
      
      _crystalRecommendations = [
        {
          'name': 'Amethyst',
          'reason': 'For dream recall and spiritual insight',
          'color': CrystalGrimoireTheme.amethyst,
        },
        {
          'name': 'Moonstone',
          'reason': 'For intuition and lunar connection',
          'color': CrystalGrimoireTheme.moonlightSilver,
        },
        {
          'name': 'Labradorite',
          'reason': 'For accessing dream wisdom',
          'color': CrystalGrimoireTheme.etherealBlue,
        },
      ];
    });
    
    HapticFeedback.mediumImpact();
  }
  
  void _saveDreamEntry() {
    if (_dreamTextController.text.isEmpty) return;
    
    setState(() {
      _dreamEntries.insert(0, {
        'date': DateTime.now(),
        'title': _generateTitle(_dreamTextController.text),
        'content': _dreamTextController.text,
        'crystals': _crystalRecommendations.map((c) => c['name'] as String).toList(),
        'mood': _dreamMood['primary'],
        'moonPhase': _currentMoonPhase,
        'analysis': _dreamAnalysis,
        'symbols': List.from(_dreamSymbols),
      });
    });
    
    _dreamTextController.clear();
    HapticFeedback.heavyImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ Dream saved to your journal'),
        backgroundColor: CrystalGrimoireTheme.successGreen,
      ),
    );
  }
  
  String _generateTitle(String content) {
    final words = content.split(' ').where((w) => w.length > 3).take(3);
    return words.join(' ');
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
            // Dreamy background
            _buildDreamyBackground(),
            
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildRecordTab(),
                        _buildAnalysisTab(),
                        _buildJournalTab(),
                        _buildInsightsTab(),
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
  
  Widget _buildDreamyBackground() {
    return Stack(
      children: [
        // Floating stars
        AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return CustomPaint(
              painter: DreamStarsPainter(_floatingController.value),
              size: Size.infinite,
            );
          },
        ),
        // Moon
        Positioned(
          top: 50,
          right: 30,
          child: AnimatedBuilder(
            animation: _moonController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _moonController.value * 2 * math.pi * 0.1,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        CrystalGrimoireTheme.moonlightSilver,
                        CrystalGrimoireTheme.moonlightSilver.withOpacity(0.5),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CrystalGrimoireTheme.moonlightSilver.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
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
                  '🌙 Dream Journal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Crystal dream analysis & insights',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: CrystalGrimoireTheme.moonlightSilver.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: CrystalGrimoireTheme.moonlightSilver,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.brightness_3,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _currentMoonPhase,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
            colors: [CrystalGrimoireTheme.amethyst, CrystalGrimoireTheme.deepSpace],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        tabs: const [
          Tab(text: 'Record'),
          Tab(text: 'Analysis'),
          Tab(text: 'Journal'),
          Tab(text: 'Insights'),
        ],
      ),
    );
  }
  
  Widget _buildRecordTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Dream input
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.edit_note,
                    color: CrystalGrimoireTheme.amethyst,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Record Your Dream',
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
                controller: _dreamTextController,
                maxLines: 8,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Describe your dream in detail...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: CrystalGrimoireTheme.amethyst,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: EnhancedMysticalButton(
                      text: 'Analyze Dream',
                      icon: Icons.auto_awesome,
                      onPressed: _analyzeDream,
                    ),
                  ),
                  const SizedBox(width: 12),
                  EnhancedMysticalButton(
                    text: 'Save',
                    icon: Icons.save,
                    isPrimary: true,
                    onPressed: _saveDreamEntry,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Quick mood selector
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dream Mood',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Peaceful', 'Anxious', 'Mystical', 'Adventurous',
                  'Confusing', 'Liberating', 'Prophetic', 'Healing'
                ].map((mood) {
                  final isSelected = mood == _dreamMood['primary'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _dreamMood['primary'] = mood;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected ? const LinearGradient(
                          colors: [CrystalGrimoireTheme.amethyst, CrystalGrimoireTheme.cosmicViolet],
                        ) : null,
                        color: !isSelected ? Colors.white.withOpacity(0.1) : null,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected 
                            ? CrystalGrimoireTheme.celestialGold
                            : Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        mood,
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
      ],
    );
  }
  
  Widget _buildAnalysisTab() {
    if (_dreamAnalysis.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Record a dream to see analysis',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // AI Analysis
        EnhancedMysticalCard(
          isGlowing: true,
          glowColor: CrystalGrimoireTheme.amethyst,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: CrystalGrimoireTheme.amethyst,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Dream Analysis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Text(
                _dreamAnalysis,
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
        
        // Dream Symbols
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Key Symbols',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _dreamSymbols.map((symbol) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CrystalGrimoireTheme.etherealBlue.withOpacity(0.3),
                          CrystalGrimoireTheme.mysticPurple.withOpacity(0.3),
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
                          _getSymbolIcon(symbol),
                          color: CrystalGrimoireTheme.celestialGold,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          symbol,
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
        
        // Crystal Recommendations
        EnhancedMysticalCard(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2A1650),
              Color(0xFF1A0F30),
            ],
          ),
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
              
              ..._crystalRecommendations.map((crystal) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (crystal['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: crystal['color'] as Color,
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
                              crystal['name'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              crystal['reason'] as String,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
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
  
  Widget _buildJournalTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _dreamEntries.length,
      itemBuilder: (context, index) {
        final entry = _dreamEntries[index];
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
                        entry['title'],
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
                        color: CrystalGrimoireTheme.moonlightSilver.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatDate(entry['date']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                Text(
                  entry['content'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Icon(
                      Icons.brightness_3,
                      color: CrystalGrimoireTheme.moonlightSilver,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry['moonPhase'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.mood,
                      color: CrystalGrimoireTheme.crystalRose,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry['mood'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                
                if (entry['crystals'] != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: (entry['crystals'] as List).map((crystal) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: CrystalGrimoireTheme.amethyst.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          crystal,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildInsightsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Dream patterns
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dream Patterns',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildPatternItem('Most Common Mood', 'Mystical', CrystalGrimoireTheme.amethyst),
              _buildPatternItem('Recurring Symbol', 'Water', CrystalGrimoireTheme.etherealBlue),
              _buildPatternItem('Peak Dream Time', '3:33 AM', CrystalGrimoireTheme.celestialGold),
              _buildPatternItem('Lucidity Level', 'Increasing', CrystalGrimoireTheme.successGreen),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Crystal affinity
        EnhancedMysticalCard(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2A1650),
              Color(0xFF1A0F30),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Dream Crystals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                'Based on your dreams, these crystals resonate most with your subconscious:',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCrystalAffinity('Amethyst', 0.9, CrystalGrimoireTheme.amethyst),
                  _buildCrystalAffinity('Moonstone', 0.8, CrystalGrimoireTheme.moonlightSilver),
                  _buildCrystalAffinity('Labradorite', 0.7, CrystalGrimoireTheme.etherealBlue),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Dream tips
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: CrystalGrimoireTheme.celestialGold,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Dream Enhancement Tips',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildTip('Place Amethyst under your pillow for vivid dreams'),
              _buildTip('Keep a Moonstone on your nightstand for dream recall'),
              _buildTip('Meditate with Clear Quartz before sleep for clarity'),
              _buildTip('Use Labradorite for lucid dreaming practice'),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildPatternItem(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCrystalAffinity(String name, double affinity, Color color) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 60 + (_pulseController.value * 5),
              height: 60 + (_pulseController.value * 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 20 + (_pulseController.value * 10),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.diamond,
                  color: color,
                  size: 30,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${(affinity * 100).toInt()}%',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTip(String tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.stars,
            color: CrystalGrimoireTheme.celestialGold,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getSymbolIcon(String symbol) {
    switch (symbol) {
      case 'Water': return Icons.water_drop;
      case 'Crystal': return Icons.diamond;
      case 'Light': return Icons.light_mode;
      case 'Journey': return Icons.explore;
      default: return Icons.auto_awesome;
    }
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${diff.inDays} days ago';
    }
  }
}

class DreamStarsPainter extends CustomPainter {
  final double animation;
  
  DreamStarsPainter(this.animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final random = math.Random(42);
    
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final twinkle = math.sin(animation * 2 * math.pi + i * 0.5);
      final opacity = 0.3 + (twinkle * 0.4);
      final radius = 1.0 + (twinkle * 0.5);
      
      paint.color = Colors.white.withOpacity(opacity.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}