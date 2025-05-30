import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../models/crystal_collection.dart';
import '../models/crystal.dart';
import '../models/crystal_v2.dart' as v2;
import '../services/collection_service.dart';
import '../config/theme.dart';
import '../config/mystical_theme.dart';
import '../widgets/common/mystical_card.dart';
import '../widgets/animations/mystical_animations.dart';
import 'add_crystal_screen.dart';
import 'crystal_detail_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({Key? key}) : super(key: key);

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _parallaxController;
  late AnimationController _floatingController;
  late AnimationController _breathingController;
  
  String _searchQuery = '';
  String _filterBy = 'all';
  bool _showStats = false;
  
  // Color schemes for different sections
  static const Map<int, List<Color>> _sectionColors = {
    0: [Color(0xFF6B46C1), Color(0xFF8B5CF6), Color(0xFFA78BFA)], // Purple - Journal
    1: [Color(0xFF0EA5E9), Color(0xFF3B82F6), Color(0xFF6366F1)], // Blue - Insights
    2: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399)], // Green - Progress
    3: [Color(0xFF7C3AED), Color(0xFF8B5CF6), Color(0xFFA855F7)], // Purple - Rituals
    4: [Color(0xFFDC2626), Color(0xFFEF4444), Color(0xFFF87171)], // Red - Goals
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    
    // Initialize animation controllers
    _parallaxController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _loadCollection();
  }

  Future<void> _loadCollection() async {
    await CollectionService.initialize();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          final currentIndex = _tabController.index;
          final colors = _sectionColors[currentIndex] ?? _sectionColors[0]!;
          
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  colors[0].withOpacity(0.3),
                  colors[1].withOpacity(0.2),
                  colors[2].withOpacity(0.1),
                  const Color(0xFF0F0F23),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated background particles
                _buildParallaxBackground(colors),
                
                // Main content with parallax effect
                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildSearchBar(),
                      _buildTabs(),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildJournalView(),
                            _buildInsightsView(),
                            _buildProgressView(),
                            _buildRitualsView(),
                            _buildGoalsView(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _breathingController,
        builder: (context, child) {
          final breathe = 1.0 + (_breathingController.value * 0.1);
          return Transform.scale(
            scale: breathe,
            child: FloatingActionButton.extended(
              onPressed: _addNewCrystal,
              backgroundColor: _getCurrentColors()[1],
              icon: const Icon(Icons.add),
              label: const Text('Add Crystal'),
              heroTag: 'add_crystal',
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    final stats = CollectionService.getStats();
    final colors = _getCurrentColors();
    
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PulsingGlow(
                    glowColor: colors[1],
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  ShimmeringText(
                    text: '✨ Crystal Collection ✨',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PulsingGlow(
                    glowColor: colors[2],
                    child: IconButton(
                      icon: Icon(
                        _showStats ? Icons.grid_view : Icons.insights,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() => _showStats = !_showStats);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors[0].withOpacity(0.3),
                      colors[1].withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors[1].withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: colors[1],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${stats.totalCrystals} crystals in your grimoire',
                      style: TextStyle(
                        color: colors[1],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    final colors = _getCurrentColors();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors[0].withOpacity(0.2),
                  colors[1].withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: colors[1].withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors[1].withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) {
                HapticFeedback.selectionClick();
                setState(() => _searchQuery = value);
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search your mystical collection...',
                hintStyle: TextStyle(color: colors[2].withOpacity(0.6)),
                prefixIcon: PulsingGlow(
                  glowColor: colors[1],
                  child: Icon(
                    Icons.search,
                    color: colors[1],
                  ),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _searchQuery = '');
                        },
                        child: Icon(
                          Icons.clear,
                          color: colors[1],
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          final colors = _getCurrentColors();
          return TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: colors[1],
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [colors[0], colors[1]],
              ),
            ),
            tabs: [
              _buildAnimatedTab('Journal', Icons.book),
              _buildAnimatedTab('Insights', Icons.insights),
              _buildAnimatedTab('Progress', Icons.trending_up, isPremium: true),
              _buildAnimatedTab('Rituals', Icons.spa, isPremium: true),
              _buildAnimatedTab('Goals', Icons.track_changes, isPremium: true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildJournalView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildRecentEntries(),
        const SizedBox(height: 24),
        _buildJournalPrompts(),
        const SizedBox(height: 24),
        _buildDailyReflection(),
      ],
    );
  }

  Widget _buildCollectionView() {
    return _buildPaywallWrapper(
      child: _buildCollectionGrid(),
      feature: "Crystal Collection",
      description: "Organize and track your crystal collection with detailed metadata.",
    );
  }

  Widget _buildInsightsView() {
    return _buildStatsView(); // Reuse existing stats view
  }

  Widget _buildProgressView() {
    return _buildPaywallWrapper(
      child: _buildProgressContent(),
      feature: "Spiritual Progress",
      description: "Track your spiritual journey and growth over time.",
    );
  }

  Widget _buildRitualsView() {
    return _buildPaywallWrapper(
      child: _buildRitualsContent(),
      feature: "Ritual Guidance",
      description: "Access guided rituals, ceremonies, and spiritual practices.",
    );
  }

  Widget _buildGoalsView() {
    return _buildPaywallWrapper(
      child: _buildGoalsContent(),
      feature: "Spiritual Goals",
      description: "Set and track your spiritual intentions and manifestations.",
    );
  }

  Widget _buildPaywallWrapper({
    required Widget child,
    required String feature,
    required String description,
  }) {
    // For now, show a premium upgrade prompt
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withOpacity(0.1),
                  Colors.orange.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.diamond,
                  size: 64,
                  color: Colors.amber,
                ),
                const SizedBox(height: 16),
                Text(
                  'Unlock $feature',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement premium upgrade
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Premium features coming soon!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Upgrade to Premium',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEntries() {
    return MysticalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories, color: Colors.purple[300]),
              const SizedBox(width: 8),
              const Text(
                'Recent Journal Entries',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Show recent crystal identifications as journal entries
          ...CollectionService.collection.take(3).map((entry) => _buildJournalEntryCard(entry)),
          if (CollectionService.collection.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, color: Colors.white.withOpacity(0.6)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Start your crystal journey by identifying your first crystal!',
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildJournalEntryCard(CollectionEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getChakraColor(entry.crystal.chakras.isNotEmpty ? entry.crystal.chakras.first : 'Crown'),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                entry.crystal.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(entry.dateAdded),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.notes ?? 'A powerful crystal ally has joined your collection.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildJournalPrompts() {
    final prompts = [
      'How did this crystal make you feel when you first held it?',
      'What intentions do you set when working with your crystals?',
      'Describe your meditation experience with your favorite crystal.',
      'What changes have you noticed since adding crystals to your practice?',
    ];
    
    return MysticalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber[300]),
              const SizedBox(width: 8),
              const Text(
                'Reflection Prompts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...prompts.map((prompt) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.edit, size: 16, color: Colors.white.withOpacity(0.6)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    prompt,
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDailyReflection() {
    return MysticalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.self_improvement, color: Colors.green[300]),
              const SizedBox(width: 8),
              const Text(
                'Daily Reflection',
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
              gradient: LinearGradient(
                colors: [
                  Colors.green.withOpacity(0.1),
                  Colors.blue.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Crystal Focus',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Clear Quartz - Amplification & Clarity',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Take a moment to reflect on your intentions and how this crystal can support your spiritual journey today.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MysticalCard(
          child: Column(
            children: [
              Text('Spiritual Progress Tracking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              // Progress charts and metrics would go here
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRitualsContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MysticalCard(
          child: Column(
            children: [
              Text('Guided Rituals & Ceremonies', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              // Ritual guides would go here
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MysticalCard(
          child: Column(
            children: [
              Text('Spiritual Goals & Intentions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              // Goal tracking would go here
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.month}/${date.day}';
  }

  Color _getChakraColor(String chakra) {
    switch (chakra.toLowerCase()) {
      case 'root': return Colors.red;
      case 'sacral': return Colors.orange;
      case 'solar plexus': return Colors.yellow;
      case 'heart': return Colors.green;
      case 'throat': return Colors.blue;
      case 'third eye': return Colors.indigo;
      case 'crown': return Colors.purple;
      default: return Colors.white;
    }
  }

  Widget _buildCollectionGrid() {
    final collection = _searchQuery.isEmpty
        ? CollectionService.collection
        : CollectionService.searchCollection(_searchQuery);

    if (collection.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: collection.length,
          itemBuilder: (context, index) {
            return FadeScaleIn(
              delay: Duration(milliseconds: index * 50),
              child: _buildCrystalCard(collection[index], index),
            );
          },
        );
      },
    );
  }

  Widget _buildFavoritesGrid() {
    final favorites = CollectionService.getFavorites();
    final colors = _getCurrentColors();
    
    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _breathingController,
              builder: (context, child) {
                final scale = 1.0 + (_breathingController.value * 0.1);
                return Transform.scale(
                  scale: scale,
                  child: Icon(
                    Icons.favorite_border, 
                    size: 64, 
                    color: colors[1].withOpacity(0.4),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ShimmeringText(
              text: 'No favorite crystals yet',
              style: TextStyle(color: colors[0], fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart on any crystal to add it',
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            return FadeScaleIn(
              delay: Duration(milliseconds: index * 50),
              child: _buildCrystalCard(favorites[index], index),
            );
          },
        );
      },
    );
  }

  Widget _buildByPurposeView() {
    final purposes = [
      {'name': 'meditation', 'icon': Icons.self_improvement, 'color': Colors.purple},
      {'name': 'healing', 'icon': Icons.healing, 'color': Colors.green},
      {'name': 'protection', 'icon': Icons.shield, 'color': Colors.blue},
      {'name': 'manifestation', 'icon': Icons.auto_fix_high, 'color': Colors.amber},
      {'name': 'grounding', 'icon': Icons.landscape, 'color': Colors.brown},
    ];
    final colors = _getCurrentColors();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: purposes.length,
      itemBuilder: (context, index) {
        final purpose = purposes[index];
        final purposeName = purpose['name'] as String;
        final icon = purpose['icon'] as IconData;
        final color = purpose['color'] as Color;
        final crystals = CollectionService.getCrystalsByPurpose(purposeName);
        
        return FadeScaleIn(
          delay: Duration(milliseconds: index * 100),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                final offset = math.sin(_floatingController.value * 2 * math.pi + index * 0.8) * 1;
                return Transform.translate(
                  offset: Offset(0, offset),
                  child: MysticalCard(
                    gradientColors: [
                      colors[0].withOpacity(0.4),
                      colors[1].withOpacity(0.3),
                      color.withOpacity(0.2),
                    ],
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        expansionTileTheme: const ExpansionTileThemeData(
                          iconColor: Colors.white,
                          collapsedIconColor: Colors.white70,
                        ),
                      ),
                      child: ExpansionTile(
                        leading: PulsingGlow(
                          glowColor: color,
                          child: Icon(icon, color: color, size: 24),
                        ),
                        title: ShimmeringText(
                          text: purposeName.substring(0, 1).toUpperCase() + purposeName.substring(1),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          '${crystals.length} crystals in collection',
                          style: TextStyle(color: color.withOpacity(0.8)),
                        ),
                        children: crystals.asMap().entries.map((mapEntry) {
                          final entryIndex = mapEntry.key;
                          final entry = mapEntry.value;
                          return FadeScaleIn(
                            delay: Duration(milliseconds: entryIndex * 50),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: color.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [color.withOpacity(0.6), color.withOpacity(0.3)],
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      entry.crystal.name.substring(0, 1),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  entry.crystal.name,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                                subtitle: Row(
                                  children: [
                                    Icon(Icons.auto_awesome, size: 12, color: color),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Used ${entry.usageCount} times',
                                      style: TextStyle(color: color.withOpacity(0.8)),
                                    ),
                                    if (entry.crystal.chakras.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Icon(Icons.brightness_7, size: 12, color: colors[1]),
                                      const SizedBox(width: 2),
                                      Text(
                                        entry.crystal.chakras.first,
                                        style: TextStyle(color: colors[1], fontSize: 10),
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (entry.userRating > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star, color: Colors.amber, size: 12),
                                            const SizedBox(width: 2),
                                            Text(
                                              entry.userRating.toStringAsFixed(1),
                                              style: const TextStyle(color: Colors.amber, fontSize: 10),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    AnimatedBuilder(
                                      animation: _breathingController,
                                      builder: (context, child) {
                                        final scale = entry.isFavorite 
                                            ? 1.0 + (_breathingController.value * 0.15)
                                            : 1.0;
                                        return Transform.scale(
                                          scale: scale,
                                          child: GestureDetector(
                                            onTap: () async {
                                              HapticFeedback.mediumImpact();
                                              await CollectionService.toggleFavorite(entry.id);
                                              setState(() {});
                                            },
                                            child: Icon(
                                              entry.isFavorite ? Icons.favorite : Icons.favorite_border,
                                              color: entry.isFavorite ? Colors.pink : Colors.white54,
                                              size: 20,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () => _openCrystalDetail(entry),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsView() {
    final stats = CollectionService.getStats();
    final mostUsed = CollectionService.getMostUsed();
    final colors = _getCurrentColors();
    
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FadeScaleIn(
              delay: const Duration(milliseconds: 0),
              child: _buildStatsCard(
                'Collection Overview',
                Icons.dashboard,
                colors[0],
                [
                  _buildStatRow('Total Crystals', stats.totalCrystals.toString()),
                  _buildStatRow('Favorite Crystals', stats.favoriteCrystals.length.toString()),
                  _buildStatRow('Total Uses', CollectionService.usageLogs.length.toString()),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FadeScaleIn(
              delay: const Duration(milliseconds: 200),
              child: _buildStatsCard(
                'Most Used Crystals',
                Icons.trending_up,
                colors[1],
                mostUsed.map((entry) => _buildStatRow(
                  entry.crystal.name,
                  '${entry.usageCount} uses',
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            FadeScaleIn(
              delay: const Duration(milliseconds: 400),
              child: _buildStatsCard(
                'Chakra Coverage',
                Icons.brightness_7,
                colors[2],
                v2.ChakraType.values.map((chakra) {
                  final count = stats.crystalsByChakra[chakra.name] ?? 0;
                  return _buildStatRow(
                    chakra.name,
                    count > 0 ? '$count crystals' : 'None yet',
                    color: count > 0 ? Colors.green : Colors.orange,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            FadeScaleIn(
              delay: const Duration(milliseconds: 600),
              child: _buildStatsCard(
                'Collection Insights',
                Icons.insights,
                colors[0],
                [
                  if (stats.effectivenessRatings.isNotEmpty)
                    ...stats.effectivenessRatings.entries.take(3).map((e) =>
                      _buildStatRow(
                        'Best for mood: ${e.key}',
                        '+${e.value.toStringAsFixed(1)} avg',
                        color: Colors.green,
                      ),
                    ),
                  if (stats.totalCrystals < 5)
                    _buildStatRow(
                      'Tip',
                      'Add more crystals to unlock insights',
                      color: Colors.blue,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsCard(String title, IconData icon, Color accentColor, List<Widget> children) {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        final offset = math.sin(_floatingController.value * 2 * math.pi + title.hashCode * 0.01) * 1.5;
        return Transform.translate(
          offset: Offset(0, offset),
          child: MysticalCard(
            gradientColors: [
              accentColor.withOpacity(0.3),
              accentColor.withOpacity(0.1),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PulsingGlow(
                        glowColor: accentColor,
                        child: Icon(icon, color: accentColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      ShimmeringText(
                        text: title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...children,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrystalCard(CollectionEntry entry, int index) {
    final colors = _getCurrentColors();
    
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        final offset = math.sin(_floatingController.value * 2 * math.pi + index * 0.5) * 2;
        
        return Transform.translate(
          offset: Offset(0, offset),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              _openCrystalDetail(entry);
            },
            child: Hero(
              tag: 'crystal_${entry.id}',
              child: MysticalCard(
                gradientColors: [
                  colors[0].withOpacity(0.3),
                  colors[1].withOpacity(0.2),
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Crystal image with shimmer effect
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colors[0].withOpacity(0.8),
                            colors[1].withOpacity(0.6),
                            colors[2].withOpacity(0.4),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: PulsingGlow(
                              glowColor: colors[1],
                              child: Icon(
                                Icons.diamond,
                                size: 48,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                          // Chakra indicators
                          if (entry.crystal.chakras.isNotEmpty)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: _buildChakraIndicators(entry.crystal.chakras),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.crystal.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${entry.size} • ${entry.quality}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors[1].withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Primary use display
                                if (entry.primaryUses.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colors[1].withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      entry.primaryUses.first,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.auto_awesome, size: 14, color: colors[1]),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${entry.usageCount}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colors[1],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                AnimatedBuilder(
                                  animation: _breathingController,
                                  builder: (context, child) {
                                    final scale = entry.isFavorite 
                                        ? 1.0 + (_breathingController.value * 0.1)
                                        : 1.0;
                                    return Transform.scale(
                                      scale: scale,
                                      child: GestureDetector(
                                        onTap: () async {
                                          HapticFeedback.lightImpact();
                                          await CollectionService.toggleFavorite(entry.id);
                                          setState(() {});
                                        },
                                        child: Icon(
                                          entry.isFavorite ? Icons.favorite : Icons.favorite_border,
                                          size: 20,
                                          color: entry.isFavorite ? Colors.pink : Colors.white54,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your crystal collection awaits',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add your first crystal to begin your journey',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _addNewCrystal,
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Crystal'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _addNewCrystal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCrystalScreen(),
      ),
    ).then((_) => _loadCollection());
  }

  void _openCrystalDetail(CollectionEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrystalDetailScreen(entry: entry),
      ),
    ).then((_) => _loadCollection());
  }

  // Helper methods for the enhanced design
  List<Color> _getCurrentColors() {
    return _sectionColors[_tabController.index] ?? _sectionColors[0]!;
  }
  
  Widget _buildParallaxBackground(List<Color> colors) {
    return AnimatedBuilder(
      animation: _parallaxController,
      builder: (context, child) {
        return Stack(
          children: [
            // Floating particles with different speeds
            ...List.generate(15, (index) {
              final speed = 0.5 + (index % 3) * 0.3;
              final size = 2.0 + (index % 4) * 2.0;
              final opacity = 0.1 + (index % 3) * 0.1;
              
              return Positioned(
                left: (index * 47) % MediaQuery.of(context).size.width,
                top: (50 + index * 31) % MediaQuery.of(context).size.height,
                child: Transform.translate(
                  offset: Offset(
                    math.sin(_parallaxController.value * 2 * math.pi * speed) * 30,
                    math.cos(_parallaxController.value * 2 * math.pi * speed * 0.7) * 20,
                  ),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors[index % colors.length].withOpacity(opacity),
                      boxShadow: [
                        BoxShadow(
                          color: colors[index % colors.length].withOpacity(opacity * 0.5),
                          blurRadius: size * 2,
                          spreadRadius: size * 0.5,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
  
  Widget _buildAnimatedTab(String text, IconData icon, {bool isPremium = false}) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 12)),
          if (isPremium) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildChakraIndicators(List<String> chakras) {
    final colors = _getCurrentColors();
    return Wrap(
      spacing: 2,
      children: chakras.take(3).map((chakra) {
        final chakraColors = {
          'Root': Colors.red,
          'Sacral': Colors.orange,
          'Solar Plexus': Colors.yellow,
          'Heart': Colors.green,
          'Throat': Colors.blue,
          'Third Eye': const Color(0xFF4B0082),
          'Crown': Colors.purple,
        };
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: chakraColors[chakra] ?? colors[1],
            boxShadow: [
              BoxShadow(
                color: (chakraColors[chakra] ?? colors[1]).withOpacity(0.6),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _parallaxController.dispose();
    _floatingController.dispose();
    _breathingController.dispose();
    super.dispose();
  }
}