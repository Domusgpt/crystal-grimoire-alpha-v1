import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/enhanced_theme.dart';
import '../widgets/common/enhanced_mystical_widgets.dart';
import '../widgets/animations/enhanced_animations.dart';
import '../data/crystal_database.dart';

class DreamJournalAnalyzer extends StatefulWidget {
  const DreamJournalAnalyzer({Key? key}) : super(key: key);

  @override
  State<DreamJournalAnalyzer> createState() => _DreamJournalAnalyzerState();
}

class _DreamJournalAnalyzerState extends State<DreamJournalAnalyzer>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _floatingController;
  final TextEditingController _dreamController = TextEditingController();
  
  bool _isRecording = false;
  bool _isAnalyzing = false;
  String _selectedMoodTab = 'Journal';
  
  final List<Map<String, dynamic>> _dreamEntries = [];
  final List<Map<String, dynamic>> _dreamPatterns = [];
  final List<Map<String, dynamic>> _communityDreams = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _floatingController.repeat(reverse: true);
    _loadMockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _floatingController.dispose();
    _dreamController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    // Mock dream entries
    _dreamEntries.addAll([
      {
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'title': 'Flying Over Crystal Mountains',
        'content': 'I was soaring above magnificent purple crystal formations...',
        'mood': 'Euphoric',
        'symbols': ['Flying', 'Crystals', 'Mountains', 'Purple'],
        'crystals': ['Amethyst', 'Clear Quartz'],
        'moonPhase': 'Waxing Gibbous',
        'lucidity': 7,
        'emotions': ['Wonder', 'Freedom', 'Peace'],
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'title': 'Underground Crystal Cave',
        'content': 'Exploring a vast cave filled with glowing crystals...',
        'mood': 'Curious',
        'symbols': ['Cave', 'Glowing', 'Underground', 'Discovery'],
        'crystals': ['Selenite', 'Labradorite'],
        'moonPhase': 'Full Moon',
        'lucidity': 4,
        'emotions': ['Curiosity', 'Anticipation'],
      },
    ]);

    // Mock community dreams
    _communityDreams.addAll([
      {
        'username': 'CrystalSeeker88',
        'title': 'Healing Rose Quartz Dream',
        'preview': 'I was in a garden made entirely of rose quartz...',
        'likes': 23,
        'comments': 8,
        'crystals': ['Rose Quartz'],
        'timeAgo': '2 hours ago',
      },
      {
        'username': 'MoonDancer',
        'title': 'Nightmare Transformed',
        'preview': 'Black tourmaline appeared and protected me...',
        'likes': 45,
        'comments': 12,
        'crystals': ['Black Tourmaline'],
        'timeAgo': '1 day ago',
      },
    ]);
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
            // Floating dream particles
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _floatingController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: DreamParticlesPainter(_floatingController.value),
                  );
                },
              ),
            ),
            
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildJournalTab(),
                        _buildAnalysisTab(),
                        _buildPatternsTab(),
                        _buildCommunityTab(),
                        _buildLucidTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedMoodTab == 'Journal'
          ? FloatingActionButton.extended(
              onPressed: _startVoiceRecording,
              backgroundColor: CrystalGrimoireTheme.amethyst,
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording ? 'Stop Recording' : 'Record Dream'),
            )
          : null,
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
                  'Crystal-guided dream analysis',
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
              gradient: LinearGradient(
                colors: [
                  CrystalGrimoireTheme.moonlightWhite.withOpacity(0.2),
                  CrystalGrimoireTheme.amethyst.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getMoonPhaseIcon(),
                  color: CrystalGrimoireTheme.moonlightWhite,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _getCurrentMoonPhase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
            colors: [CrystalGrimoireTheme.amethyst, CrystalGrimoireTheme.cosmicViolet],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        onTap: (index) {
          final tabs = ['Journal', 'Analysis', 'Patterns', 'Community', 'Lucid'];
          setState(() {
            _selectedMoodTab = tabs[index];
          });
        },
        tabs: const [
          Tab(text: 'Journal'),
          Tab(text: 'Analysis'),
          Tab(text: 'Patterns'),
          Tab(text: 'Community'),
          Tab(text: 'Lucid'),
        ],
      ),
    );
  }

  Widget _buildJournalTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick record card
        EnhancedMysticalCard(
          gradient: LinearGradient(
            colors: [
              CrystalGrimoireTheme.amethyst.withOpacity(0.3),
              CrystalGrimoireTheme.royalPurple.withOpacity(0.6),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bedtime,
                    color: CrystalGrimoireTheme.moonlightWhite,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Record New Dream',
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
                controller: _dreamController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Describe your dream in detail...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
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
                    borderSide: const BorderSide(color: CrystalGrimoireTheme.amethyst),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: EnhancedMysticalButton(
                      text: _isAnalyzing ? 'Analyzing...' : 'Analyze Dream',
                      icon: Icons.psychology,
                      isPrimary: true,
                      onPressed: _isAnalyzing ? null : _analyzeDream,
                    ),
                  ),
                  const SizedBox(width: 12),
                  EnhancedMysticalButton(
                    text: 'Save',
                    icon: Icons.save,
                    onPressed: _saveDream,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Recent dreams
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Dreams',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All',
                style: TextStyle(color: CrystalGrimoireTheme.amethyst),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        ..._dreamEntries.map((dream) => _buildDreamEntryCard(dream)).toList(),
      ],
    );
  }

  Widget _buildDreamEntryCard(Map<String, dynamic> dream) {
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
                    dream['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getMoodColor(dream['mood']).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dream['mood'],
                    style: TextStyle(
                      color: _getMoodColor(dream['mood']),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              dream['content'],
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 12),
            
            // Dream symbols
            if (dream['symbols'] != null)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (dream['symbols'] as List<String>).map((symbol) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CrystalGrimoireTheme.cosmicViolet.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      symbol,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  );
                }).toList(),
              ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.white.withOpacity(0.6),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(dream['date']),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.brightness_2,
                  color: Colors.white.withOpacity(0.6),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  dream['moonPhase'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white.withOpacity(0.6),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Lucidity: ${dream['lucidity']}/10',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // AI Analysis card
        EnhancedMysticalCard(
          gradient: LinearGradient(
            colors: [
              CrystalGrimoireTheme.etherealBlue.withOpacity(0.3),
              CrystalGrimoireTheme.royalPurple.withOpacity(0.6),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: CrystalGrimoireTheme.etherealBlue,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Dream Symbol Analysis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildSymbolAnalysis(),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Crystal recommendations
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
                    'Recommended Crystals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildCrystalRecommendations(),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Sleep quality insights
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.nights_stay,
                    color: CrystalGrimoireTheme.moonlightWhite,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Sleep Quality Insights',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildSleepQualityChart(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatternsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Dream frequency chart
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dream Frequency Patterns',
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
                      CrystalGrimoireTheme.amethyst.withOpacity(0.2),
                      CrystalGrimoireTheme.cosmicViolet.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Dream Frequency Chart\n(Interactive visualization)',
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
        
        const SizedBox(height: 16),
        
        // Moon phase correlation
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Moon Phase Correlation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildMoonPhaseCorrelation(),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Most common symbols
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Most Common Dream Symbols',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildCommonSymbols(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Community header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dream Community',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            EnhancedMysticalButton(
              text: 'Share Dream',
              icon: Icons.share,
              onPressed: _shareDream,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Community dreams
        ..._communityDreams.map((dream) => _buildCommunityDreamCard(dream)).toList(),
      ],
    );
  }

  Widget _buildLucidTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Lucid dreaming guide
        EnhancedMysticalCard(
          gradient: LinearGradient(
            colors: [
              CrystalGrimoireTheme.celestialGold.withOpacity(0.3),
              CrystalGrimoireTheme.royalPurple.withOpacity(0.6),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: CrystalGrimoireTheme.celestialGold,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Lucid Dreaming Enhancement',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildLucidDreamingGuide(),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Crystal placements for lucid dreaming
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crystal Placements for Lucid Dreams',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildCrystalPlacements(),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Nightmare protection
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.shield,
                    color: CrystalGrimoireTheme.successGreen,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Nightmare Protection',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildNightmareProtection(),
            ],
          ),
        ),
      ],
    );
  }

  // Helper methods for building various sections
  Widget _buildSymbolAnalysis() {
    final symbols = [
      {'symbol': 'Flying', 'meaning': 'Freedom, transcendence, spiritual elevation'},
      {'symbol': 'Crystals', 'meaning': 'Healing, spiritual awakening, clarity'},
      {'symbol': 'Water', 'meaning': 'Emotions, unconscious mind, purification'},
      {'symbol': 'Mountains', 'meaning': 'Challenges, achievement, higher perspective'},
    ];
    
    return Column(
      children: symbols.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CrystalGrimoireTheme.etherealBlue.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['symbol']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['meaning']!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        height: 1.3,
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

  Widget _buildCrystalRecommendations() {
    final crystals = [
      {'name': 'Amethyst', 'purpose': 'Enhance dream recall and spiritual insight'},
      {'name': 'Moonstone', 'purpose': 'Connect with lunar energy and intuition'},
      {'name': 'Clear Quartz', 'purpose': 'Amplify dream messages and clarity'},
      {'name': 'Labradorite', 'purpose': 'Access higher realms and transformation'},
    ];
    
    return Column(
      children: crystals.map((crystal) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CrystalGrimoireTheme.amethyst.withOpacity(0.2),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CrystalGrimoireTheme.amethyst.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [CrystalGrimoireTheme.amethyst, CrystalGrimoireTheme.cosmicViolet],
                  ),
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
                      crystal['name']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      crystal['purpose']!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.add_shopping_cart,
                  color: CrystalGrimoireTheme.amethyst,
                  size: 20,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSleepQualityChart() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CrystalGrimoireTheme.etherealBlue.withOpacity(0.2),
            CrystalGrimoireTheme.amethyst.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSleepMetric('Deep Sleep', '65%', Icons.bedtime),
          _buildSleepMetric('REM Sleep', '23%', Icons.psychology),
          _buildSleepMetric('Light Sleep', '12%', Icons.brightness_low),
        ],
      ),
    );
  }

  Widget _buildSleepMetric(String label, String value, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMoonPhaseCorrelation() {
    final phases = [
      {'phase': 'New Moon', 'dreamCount': 2, 'intensity': 'Low'},
      {'phase': 'Waxing Crescent', 'dreamCount': 4, 'intensity': 'Medium'},
      {'phase': 'First Quarter', 'dreamCount': 6, 'intensity': 'High'},
      {'phase': 'Full Moon', 'dreamCount': 8, 'intensity': 'Very High'},
    ];
    
    return Column(
      children: phases.map((phase) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                _getMoonPhaseIcon(),
                color: CrystalGrimoireTheme.moonlightWhite,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  phase['phase'] as String,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Text(
                '${phase['dreamCount']} dreams',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getIntensityColor(phase['intensity'] as String).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  phase['intensity'] as String,
                  style: TextStyle(
                    color: _getIntensityColor(phase['intensity'] as String),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCommonSymbols() {
    final symbols = [
      {'symbol': 'Flying', 'count': 15, 'percentage': 0.8},
      {'symbol': 'Water', 'count': 12, 'percentage': 0.6},
      {'symbol': 'Animals', 'count': 10, 'percentage': 0.5},
      {'symbol': 'Crystals', 'count': 8, 'percentage': 0.4},
    ];
    
    return Column(
      children: symbols.map((symbol) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  symbol['symbol'] as String,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Expanded(
                flex: 3,
                child: LinearProgressIndicator(
                  value: symbol['percentage'] as double,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(CrystalGrimoireTheme.amethyst),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${symbol['count']}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCommunityDreamCard(Map<String, dynamic> dream) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: EnhancedMysticalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: CrystalGrimoireTheme.amethyst,
                  child: Text(
                    dream['username'][0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dream['username'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        dream['timeAgo'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Text('Report'),
                    ),
                    const PopupMenuItem(
                      value: 'follow',
                      child: Text('Follow User'),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              dream['title'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              dream['preview'],
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(
                  Icons.favorite_border,
                  color: Colors.white.withOpacity(0.6),
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${dream['likes']}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.comment_outlined,
                  color: Colors.white.withOpacity(0.6),
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${dream['comments']}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                ...(dream['crystals'] as List<String>).map((crystal) {
                  return Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: CrystalGrimoireTheme.amethyst.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLucidDreamingGuide() {
    final techniques = [
      'Reality checks throughout the day',
      'Keep a detailed dream journal',
      'Practice meditation with crystals',
      'Set clear intentions before sleep',
      'Use wake-back-to-bed technique',
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Techniques for Lucid Dreaming:',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        ...techniques.map((technique) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: CrystalGrimoireTheme.celestialGold,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    technique,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCrystalPlacements() {
    final placements = [
      {'location': 'Under pillow', 'crystal': 'Amethyst', 'purpose': 'Enhanced dream recall'},
      {'location': 'Nightstand', 'crystal': 'Moonstone', 'purpose': 'Lunar energy connection'},
      {'location': 'Four corners', 'crystal': 'Clear Quartz', 'purpose': 'Dream amplification'},
      {'location': 'Third eye', 'crystal': 'Labradorite', 'purpose': 'Lucidity trigger'},
    ];
    
    return Column(
      children: placements.map((placement) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: CrystalGrimoireTheme.celestialGold,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${placement['crystal']} - ${placement['location']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      placement['purpose']!,
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
    );
  }

  Widget _buildNightmareProtection() {
    final protections = [
      {'crystal': 'Black Tourmaline', 'method': 'Place at foot of bed for grounding protection'},
      {'crystal': 'Smoky Quartz', 'method': 'Hold before sleep to transmute negative energy'},
      {'crystal': 'Hematite', 'method': 'Create a protective circle around bed'},
      {'crystal': 'Apache Tear', 'method': 'Carry for emotional healing and protection'},
    ];
    
    return Column(
      children: protections.map((protection) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CrystalGrimoireTheme.successGreen.withOpacity(0.2),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CrystalGrimoireTheme.successGreen.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.shield,
                color: CrystalGrimoireTheme.successGreen,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      protection['crystal']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      protection['method']!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
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

  // Helper methods
  void _startVoiceRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    
    HapticFeedback.mediumImpact();
    
    if (_isRecording) {
      // Simulate voice recording
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎤 Recording dream... Speak now'),
          backgroundColor: CrystalGrimoireTheme.amethyst,
        ),
      );
    } else {
      // Simulate transcription
      _dreamController.text = 'I was flying over a vast landscape filled with glowing purple crystals. The sky was painted in shades of violet and gold, and I felt a deep sense of peace and connection to something greater than myself...';
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Dream transcribed successfully!'),
          backgroundColor: CrystalGrimoireTheme.successGreen,
        ),
      );
    }
  }

  void _analyzeDream() {
    if (_dreamController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a dream first'),
          backgroundColor: CrystalGrimoireTheme.errorRed,
        ),
      );
      return;
    }
    
    setState(() {
      _isAnalyzing = true;
    });
    
    // Simulate AI analysis
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isAnalyzing = false;
      });
      
      _tabController.animateTo(1); // Switch to Analysis tab
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔮 Dream analysis complete! Check the Analysis tab'),
          backgroundColor: CrystalGrimoireTheme.successGreen,
        ),
      );
    });
  }

  void _saveDream() {
    if (_dreamController.text.isEmpty) return;
    
    final newDream = {
      'date': DateTime.now(),
      'title': 'New Dream Entry',
      'content': _dreamController.text,
      'mood': 'Peaceful',
      'symbols': ['Flying', 'Crystals'],
      'crystals': ['Amethyst'],
      'moonPhase': _getCurrentMoonPhase(),
      'lucidity': 5,
      'emotions': ['Wonder'],
    };
    
    setState(() {
      _dreamEntries.insert(0, newDream);
      _dreamController.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('💾 Dream saved to journal'),
        backgroundColor: CrystalGrimoireTheme.successGreen,
      ),
    );
  }

  void _shareDream() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CrystalGrimoireTheme.royalPurple,
        title: const Text(
          'Share Dream',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Share your dream with the community for insights and connections?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🌟 Dream shared with community!'),
                  backgroundColor: CrystalGrimoireTheme.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CrystalGrimoireTheme.amethyst,
            ),
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  String _getCurrentMoonPhase() {
    final phases = [
      'New Moon', 'Waxing Crescent', 'First Quarter', 'Waxing Gibbous',
      'Full Moon', 'Waning Gibbous', 'Last Quarter', 'Waning Crescent'
    ];
    final daysSinceNewMoon = DateTime.now().difference(DateTime(2024, 1, 11)).inDays % 29.5;
    final phaseIndex = (daysSinceNewMoon / 29.5 * 8).round() % 8;
    return phases[phaseIndex];
  }

  IconData _getMoonPhaseIcon() {
    switch (_getCurrentMoonPhase()) {
      case 'New Moon': return Icons.brightness_1_outlined;
      case 'Full Moon': return Icons.brightness_1;
      case 'Waxing Crescent':
      case 'Waxing Gibbous': return Icons.brightness_2;
      case 'Waning Crescent':
      case 'Waning Gibbous': return Icons.brightness_3;
      default: return Icons.brightness_4;
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'euphoric': return CrystalGrimoireTheme.celestialGold;
      case 'peaceful': return CrystalGrimoireTheme.successGreen;
      case 'curious': return CrystalGrimoireTheme.etherealBlue;
      case 'anxious': return CrystalGrimoireTheme.warningAmber;
      case 'scared': return CrystalGrimoireTheme.errorRed;
      default: return CrystalGrimoireTheme.amethyst;
    }
  }

  Color _getIntensityColor(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'low': return CrystalGrimoireTheme.successGreen;
      case 'medium': return CrystalGrimoireTheme.warningAmber;
      case 'high': return CrystalGrimoireTheme.etherealBlue;
      case 'very high': return CrystalGrimoireTheme.amethyst;
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final difference = DateTime.now().difference(date).inDays;
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return '${difference} days ago';
  }
}

class DreamParticlesPainter extends CustomPainter {
  final double animationValue;
  
  DreamParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CrystalGrimoireTheme.stardustSilver.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Draw floating dream particles
    for (int i = 0; i < 20; i++) {
      final x = (size.width * (i / 20) + animationValue * 50) % size.width;
      final y = (size.height * ((i * 0.618) % 1) + animationValue * 30) % size.height;
      final radius = 2 + (animationValue * 3);
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}