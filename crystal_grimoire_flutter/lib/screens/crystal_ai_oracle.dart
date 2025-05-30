import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/enhanced_theme.dart';
import '../widgets/common/enhanced_mystical_widgets.dart';
import '../widgets/animations/enhanced_animations.dart';
import '../data/crystal_database.dart';

class CrystalAIOracleScreen extends StatefulWidget {
  const CrystalAIOracleScreen({Key? key}) : super(key: key);

  @override
  State<CrystalAIOracleScreen> createState() => _CrystalAIOracleScreenState();
}

class _CrystalAIOracleScreenState extends State<CrystalAIOracleScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _oracleController;
  late AnimationController _cardController;
  
  final TextEditingController _questionController = TextEditingController();
  
  bool _isChanneling = false;
  bool _showReading = false;
  String _currentReading = '';
  List<Map<String, dynamic>> _selectedCards = [];
  List<Map<String, dynamic>> _pastReadings = [];
  
  final List<Map<String, dynamic>> _crystalCards = [
    {
      'id': 'love',
      'name': 'Love & Relationships',
      'crystal': 'Rose Quartz',
      'color': CrystalGrimoireTheme.crystalRose,
      'meanings': ['Unconditional love', 'Heart healing', 'Emotional balance', 'Self-acceptance'],
      'keywords': ['love', 'heart', 'relationships', 'romance', 'compassion']
    },
    {
      'id': 'wisdom',
      'name': 'Wisdom & Insight',
      'crystal': 'Amethyst',
      'color': CrystalGrimoireTheme.amethyst,
      'meanings': ['Spiritual wisdom', 'Intuitive insight', 'Third eye opening', 'Divine connection'],
      'keywords': ['wisdom', 'intuition', 'spiritual', 'insight', 'guidance']
    },
    {
      'id': 'protection',
      'name': 'Protection & Grounding',
      'crystal': 'Black Tourmaline',
      'color': Colors.grey[800],
      'meanings': ['Psychic protection', 'Energy shielding', 'Grounding force', 'Negative energy clearing'],
      'keywords': ['protection', 'shield', 'grounding', 'safety', 'boundaries']
    },
    {
      'id': 'abundance',
      'name': 'Abundance & Success',
      'crystal': 'Citrine',
      'color': CrystalGrimoireTheme.celestialGold,
      'meanings': ['Material abundance', 'Career success', 'Manifestation power', 'Golden opportunities'],
      'keywords': ['abundance', 'success', 'wealth', 'career', 'manifestation']
    },
    {
      'id': 'healing',
      'name': 'Healing & Balance',
      'crystal': 'Clear Quartz',
      'color': Colors.white,
      'meanings': ['Universal healing', 'Energy amplification', 'Chakra balancing', 'Physical vitality'],
      'keywords': ['healing', 'balance', 'health', 'energy', 'vitality']
    },
    {
      'id': 'transformation',
      'name': 'Transformation & Change',
      'crystal': 'Labradorite',
      'color': CrystalGrimoireTheme.etherealBlue,
      'meanings': ['Life transformation', 'Hidden potential', 'Mystical awakening', 'Personal evolution'],
      'keywords': ['transformation', 'change', 'evolution', 'potential', 'awakening']
    },
    {
      'id': 'communication',
      'name': 'Communication & Truth',
      'crystal': 'Lapis Lazuli',
      'color': Colors.blue[700],
      'meanings': ['Truth speaking', 'Clear communication', 'Throat chakra activation', 'Honest expression'],
      'keywords': ['communication', 'truth', 'voice', 'expression', 'honesty']
    },
    {
      'id': 'peace',
      'name': 'Peace & Tranquility',
      'crystal': 'Selenite',
      'color': CrystalGrimoireTheme.moonlightWhite,
      'meanings': ['Divine peace', 'Mental clarity', 'Spiritual cleansing', 'Inner calm'],
      'keywords': ['peace', 'calm', 'tranquility', 'serenity', 'clarity']
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _oracleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _oracleController.repeat(reverse: true);
    _loadPastReadings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _oracleController.dispose();
    _cardController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  void _loadPastReadings() {
    _pastReadings.addAll([
      {
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'question': 'What should I focus on for career growth?',
        'cards': ['Abundance & Success', 'Wisdom & Insight'],
        'reading': 'The crystals reveal that your career path is illuminated by the golden light of Citrine and the wisdom of Amethyst...',
        'summary': 'Focus on manifestation and trust your intuition',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'question': 'How can I improve my relationships?',
        'cards': ['Love & Relationships', 'Communication & Truth'],
        'reading': 'Rose Quartz and Lapis Lazuli unite to show you the path of heart-centered communication...',
        'summary': 'Open your heart and speak your truth with love',
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
            // Mystical background with floating orbs
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _oracleController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: MysticalOrbsPainter(_oracleController.value),
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
                        _buildOracleTab(),
                        _buildCardSpreadTab(),
                        _buildReadingsTab(),
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
                  '🔮 Crystal AI Oracle',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'AI-powered crystal wisdom & guidance',
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
                  CrystalGrimoireTheme.amethyst.withOpacity(0.3),
                  CrystalGrimoireTheme.cosmicViolet.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: CrystalGrimoireTheme.celestialGold,
                  size: 16,
                ),
                const SizedBox(width: 4),
                const Text(
                  'AI ORACLE',
                  style: TextStyle(
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
            colors: [CrystalGrimoireTheme.amethyst, CrystalGrimoireTheme.cosmicViolet],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        tabs: const [
          Tab(text: 'Oracle'),
          Tab(text: 'Card Spread'),
          Tab(text: 'Readings'),
          Tab(text: 'Insights'),
        ],
      ),
    );
  }

  Widget _buildOracleTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Question input
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
                    Icons.help_outline,
                    color: CrystalGrimoireTheme.celestialGold,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Ask the Crystal Oracle',
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
                controller: _questionController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'What guidance do you seek from the crystals?',
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
              
              // Example questions
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Love & Relationships',
                  'Career Path',
                  'Spiritual Growth',
                  'Health & Healing',
                  'Life Purpose',
                ].map((topic) {
                  return GestureDetector(
                    onTap: () => _setExampleQuestion(topic),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: CrystalGrimoireTheme.cosmicViolet.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: CrystalGrimoireTheme.cosmicViolet.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        topic,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 20),
              
              EnhancedMysticalButton(
                text: _isChanneling ? 'Channeling...' : 'Channel Crystal Wisdom',
                icon: Icons.auto_awesome,
                isPrimary: true,
                isPremium: true,
                width: double.infinity,
                onPressed: _isChanneling ? null : _channelWisdom,
              ),
            ],
          ),
        ),
        
        if (_showReading) ...[
          const SizedBox(height: 24),
          _buildOracleReading(),
        ],
      ],
    );
  }

  Widget _buildCardSpreadTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Spread selection
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Your Crystal Spread',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildSpreadOption('Single Crystal', 'One crystal for focused guidance', 1),
              _buildSpreadOption('Past Present Future', 'Three crystals for timeline insight', 3),
              _buildSpreadOption('Chakra Alignment', 'Seven crystals for energy balance', 7),
              _buildSpreadOption('Life Path', 'Five crystals for major life areas', 5),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Crystal cards grid
        const Text(
          'Crystal Cards',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _crystalCards.length,
          itemBuilder: (context, index) {
            final card = _crystalCards[index];
            final isSelected = _selectedCards.any((c) => c['id'] == card['id']);
            
            return GestureDetector(
              onTap: () => _toggleCardSelection(card),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (card['color'] as Color).withOpacity(0.3),
                      CrystalGrimoireTheme.royalPurple.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected 
                        ? CrystalGrimoireTheme.celestialGold
                        : Colors.white.withOpacity(0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: CrystalGrimoireTheme.celestialGold.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ] : null,
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            card['color'] as Color,
                            (card['color'] as Color).withOpacity(0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.diamond,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      card['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      card['crystal'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isSelected)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Icon(
                          Icons.check_circle,
                          color: CrystalGrimoireTheme.celestialGold,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        
        if (_selectedCards.isNotEmpty) ...[
          const SizedBox(height: 24),
          EnhancedMysticalButton(
            text: 'Perform Reading',
            icon: Icons.auto_awesome,
            isPrimary: true,
            width: double.infinity,
            onPressed: _performCardReading,
          ),
        ],
      ],
    );
  }

  Widget _buildReadingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Reading history
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Past Readings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: _clearReadings,
              child: const Text(
                'Clear All',
                style: TextStyle(color: CrystalGrimoireTheme.amethyst),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        if (_pastReadings.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.auto_stories,
                  size: 64,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No readings yet',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ask the oracle for wisdom and guidance',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          ..._pastReadings.map((reading) => _buildPastReadingCard(reading)).toList(),
      ],
    );
  }

  Widget _buildInsightsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Crystal wisdom insights
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
                    'Crystal Wisdom Insights',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildInsightItem(
                'Most Frequently Asked About',
                'Love & Relationships (45%)',
                Icons.favorite,
                CrystalGrimoireTheme.crystalRose,
              ),
              _buildInsightItem(
                'Most Powerful Crystal',
                'Clear Quartz (Universal Healer)',
                Icons.diamond,
                Colors.white,
              ),
              _buildInsightItem(
                'Best Time for Readings',
                'Full Moon Energy (2x more accurate)',
                Icons.brightness_1,
                CrystalGrimoireTheme.moonlightWhite,
              ),
              _buildInsightItem(
                'Your Reading Accuracy',
                '89% Resonance Rate',
                Icons.precision_manufacturing,
                CrystalGrimoireTheme.successGreen,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Crystal combinations
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Powerful Crystal Combinations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildCombinationItem(
                'Love Triangle',
                'Rose Quartz + Green Aventurine + Moonstone',
                'For attracting soulmate love',
              ),
              _buildCombinationItem(
                'Success Trio',
                'Citrine + Tiger\'s Eye + Pyrite',
                'For career and financial abundance',
              ),
              _buildCombinationItem(
                'Protection Shield',
                'Black Tourmaline + Hematite + Obsidian',
                'For psychic protection and grounding',
              ),
              _buildCombinationItem(
                'Wisdom Gateway',
                'Amethyst + Lapis Lazuli + Clear Quartz',
                'For spiritual insight and truth',
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Daily affirmations
        EnhancedMysticalCard(
          gradient: LinearGradient(
            colors: [
              CrystalGrimoireTheme.celestialGold.withOpacity(0.3),
              CrystalGrimoireTheme.amethyst.withOpacity(0.3),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today\'s Crystal Affirmation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: CrystalGrimoireTheme.celestialGold,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '"I am aligned with the crystal frequencies that bring harmony, wisdom, and abundance into my life. The Earth\'s ancient wisdom flows through me."',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Powered by Clear Quartz & Amethyst Energy',
                      style: TextStyle(
                        color: CrystalGrimoireTheme.celestialGold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOracleReading() {
    return EnhancedMysticalCard(
      gradient: LinearGradient(
        colors: [
          CrystalGrimoireTheme.cosmicViolet.withOpacity(0.3),
          CrystalGrimoireTheme.deepSpace.withOpacity(0.8),
        ],
      ),
      isGlowing: true,
      glowColor: CrystalGrimoireTheme.amethyst,
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
                'Oracle Reading',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _currentReading,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.6,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: EnhancedMysticalButton(
                  text: 'Save Reading',
                  icon: Icons.bookmark_add,
                  onPressed: _saveReading,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: EnhancedMysticalButton(
                  text: 'Share Wisdom',
                  icon: Icons.share,
                  onPressed: _shareReading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpreadOption(String name, String description, int cards) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        tileColor: Colors.white.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [CrystalGrimoireTheme.amethyst, CrystalGrimoireTheme.cosmicViolet],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$cards',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
          size: 16,
        ),
        onTap: () => _selectSpread(cards),
      ),
    );
  }

  Widget _buildPastReadingCard(Map<String, dynamic> reading) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: EnhancedMysticalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(reading['date']),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Text('Share'),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              reading['question'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Selected cards
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (reading['cards'] as List<String>).map((card) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CrystalGrimoireTheme.amethyst.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    card,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              reading['summary'],
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String label, String value, IconData icon, Color color) {
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
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

  Widget _buildCombinationItem(String name, String crystals, String purpose) {
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
        border: Border.all(
          color: CrystalGrimoireTheme.amethyst.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            crystals,
            style: TextStyle(
              color: CrystalGrimoireTheme.amethyst,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            purpose,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Action methods
  void _setExampleQuestion(String topic) {
    final questions = {
      'Love & Relationships': 'How can I attract more love into my life?',
      'Career Path': 'What career direction should I pursue?',
      'Spiritual Growth': 'How can I deepen my spiritual practice?',
      'Health & Healing': 'What do I need for optimal health and wellness?',
      'Life Purpose': 'What is my soul\'s purpose in this lifetime?',
    };
    
    _questionController.text = questions[topic] ?? '';
  }

  void _channelWisdom() async {
    if (_questionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please ask a question first'),
          backgroundColor: CrystalGrimoireTheme.errorRed,
        ),
      );
      return;
    }
    
    setState(() {
      _isChanneling = true;
      _showReading = false;
    });
    
    HapticFeedback.mediumImpact();
    
    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 4));
    
    _currentReading = _generateOracleReading(_questionController.text);
    
    setState(() {
      _isChanneling = false;
      _showReading = true;
    });
  }

  String _generateOracleReading(String question) {
    final readings = [
      'The crystals speak of transformation ahead. Amethyst reveals that your spiritual journey is entering a powerful phase of awakening. Trust your intuition and allow the universe to guide your path. Rose Quartz whispers of love that approaches from unexpected directions. Clear Quartz amplifies your manifestation abilities - now is the time to set clear intentions.',
      'Selenite illuminates a path of clarity through current confusion. The answer you seek lies within your heart chakra. Labradorite shows hidden potentials awakening within you. Trust the process of change, for it brings gifts beyond your current understanding. Black Tourmaline offers protection as you navigate this transition.',
      'Citrine\'s golden light reveals abundance flowing toward you. Your hard work is about to bear fruit. The universe has heard your prayers and is aligning circumstances in your favor. Green Aventurine speaks of new opportunities in unexpected places. Stay open to receiving the blessings that await.',
      'The moon phases align with your question, revealing cycles of renewal. Moonstone guides you to honor your emotions while Fluorite brings mental clarity. This is a time for healing old wounds and embracing your authentic self. The crystals see strength where you see weakness.',
    ];
    
    return readings[DateTime.now().millisecond % readings.length];
  }

  void _toggleCardSelection(Map<String, dynamic> card) {
    setState(() {
      final index = _selectedCards.indexWhere((c) => c['id'] == card['id']);
      if (index >= 0) {
        _selectedCards.removeAt(index);
      } else if (_selectedCards.length < 3) {
        _selectedCards.add(card);
      }
    });
    
    HapticFeedback.selectionClick();
  }

  void _selectSpread(int cardCount) {
    setState(() {
      _selectedCards.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Select $cardCount crystal${cardCount > 1 ? 's' : ''} for your reading'),
        backgroundColor: CrystalGrimoireTheme.amethyst,
      ),
    );
  }

  void _performCardReading() {
    if (_selectedCards.isEmpty) return;
    
    final cardNames = _selectedCards.map((c) => c['name'] as String).toList();
    final reading = _generateCardReading(_selectedCards);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CrystalGrimoireTheme.royalPurple,
        title: const Text(
          'Crystal Card Reading',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selected cards
              Wrap(
                spacing: 8,
                children: _selectedCards.map((card) {
                  return Container(
                    width: 60,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (card['color'] as Color),
                          (card['color'] as Color).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.diamond,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          card['crystal'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                reading,
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveCardReading(cardNames, reading);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CrystalGrimoireTheme.amethyst,
            ),
            child: const Text('Save Reading'),
          ),
        ],
      ),
    );
  }

  String _generateCardReading(List<Map<String, dynamic>> cards) {
    if (cards.length == 1) {
      final card = cards.first;
      return 'The ${card['crystal']} crystal speaks to you of ${(card['meanings'] as List<String>).join(', ')}. This is a time to focus on ${card['name'].toLowerCase()} in your life.';
    } else {
      final crystalNames = cards.map((c) => c['crystal']).join(', ');
      return 'The crystals $crystalNames work together to bring you guidance. Each stone contributes its unique wisdom to illuminate your path forward.';
    }
  }

  void _saveReading() {
    final newReading = {
      'date': DateTime.now(),
      'question': _questionController.text,
      'cards': ['Oracle Wisdom'],
      'reading': _currentReading,
      'summary': 'Trust your intuition and embrace the guidance',
    };
    
    setState(() {
      _pastReadings.insert(0, newReading);
      _questionController.clear();
      _showReading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reading saved to your collection'),
        backgroundColor: CrystalGrimoireTheme.successGreen,
      ),
    );
  }

  void _saveCardReading(List<String> cardNames, String reading) {
    final newReading = {
      'date': DateTime.now(),
      'question': 'Card Spread Reading',
      'cards': cardNames,
      'reading': reading,
      'summary': 'Crystal wisdom from ${cardNames.join(', ')}',
    };
    
    setState(() {
      _pastReadings.insert(0, newReading);
      _selectedCards.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Card reading saved'),
        backgroundColor: CrystalGrimoireTheme.successGreen,
      ),
    );
  }

  void _shareReading() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reading shared with the crystal community'),
        backgroundColor: CrystalGrimoireTheme.successGreen,
      ),
    );
  }

  void _clearReadings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CrystalGrimoireTheme.royalPurple,
        title: const Text(
          'Clear All Readings',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete all past readings?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _pastReadings.clear();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CrystalGrimoireTheme.errorRed,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final difference = DateTime.now().difference(date).inDays;
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return '${difference} days ago';
  }
}

class MysticalOrbsPainter extends CustomPainter {
  final double animationValue;
  
  MysticalOrbsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw mystical orbs
    for (int i = 0; i < 15; i++) {
      final x = (size.width * (i / 15) + animationValue * 60) % size.width;
      final y = (size.height * ((i * 0.618) % 1) + animationValue * 40) % size.height;
      final radius = 3 + (animationValue * 4);
      
      paint.color = CrystalGrimoireTheme.amethyst.withOpacity(0.2 + animationValue * 0.3);
      canvas.drawCircle(Offset(x, y), radius, paint);
      
      paint.color = CrystalGrimoireTheme.celestialGold.withOpacity(0.1 + animationValue * 0.2);
      canvas.drawCircle(Offset(x, y), radius * 0.7, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}