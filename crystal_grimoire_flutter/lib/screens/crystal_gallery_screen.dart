import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../data/crystal_database.dart';
import '../config/enhanced_theme.dart';
import '../widgets/common/enhanced_mystical_widgets.dart';
import '../widgets/animations/enhanced_animations.dart';

class CrystalGalleryScreen extends StatefulWidget {
  const CrystalGalleryScreen({Key? key}) : super(key: key);

  @override
  State<CrystalGalleryScreen> createState() => _CrystalGalleryScreenState();
}

class _CrystalGalleryScreenState extends State<CrystalGalleryScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _filterOptions = [
    'All',
    'Common',
    'Rare',
    'Protection',
    'Love',
    'Healing',
    'Spiritual',
    'Abundance',
  ];

  final List<String> _chakras = [
    'Root',
    'Sacral',
    'Solar Plexus',
    'Heart',
    'Throat',
    'Third Eye',
    'Crown',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<CrystalData> get filteredCrystals {
    var crystals = CrystalDatabase.crystals;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      crystals = CrystalDatabase.searchCrystals(_searchQuery);
    }
    
    // Apply category filter
    switch (_selectedFilter) {
      case 'Common':
        crystals = crystals.where((c) => c.rarity == 'Common' || c.rarity == 'Very Common').toList();
        break;
      case 'Rare':
        crystals = crystals.where((c) => c.rarity.contains('rare')).toList();
        break;
      case 'Protection':
        crystals = crystals.where((c) => c.keywords.contains('protection')).toList();
        break;
      case 'Love':
        crystals = crystals.where((c) => c.keywords.contains('love') || c.keywords.contains('heart')).toList();
        break;
      case 'Healing':
        crystals = crystals.where((c) => c.keywords.contains('healing')).toList();
        break;
      case 'Spiritual':
        crystals = crystals.where((c) => c.keywords.contains('spiritual') || c.keywords.contains('psychic')).toList();
        break;
      case 'Abundance':
        crystals = crystals.where((c) => c.keywords.contains('abundance') || c.keywords.contains('prosperity')).toList();
        break;
    }
    
    return crystals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: CrystalGrimoireTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildFilterChips(),
              Expanded(
                child: _buildCrystalGrid(),
              ),
            ],
          ),
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
          const Text(
            '💎 Crystal Encyclopedia',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search crystals by name, color, or property...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = _selectedFilter == filter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: Colors.white.withOpacity(0.1),
              selectedColor: CrystalGrimoireTheme.mysticPurple,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected 
                    ? CrystalGrimoireTheme.amethyst 
                    : Colors.white.withOpacity(0.3),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCrystalGrid() {
    final crystals = filteredCrystals;
    
    if (crystals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No crystals found',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: crystals.length,
      itemBuilder: (context, index) {
        final crystal = crystals[index];
        return _buildCrystalCard(crystal);
      },
    );
  }

  Widget _buildCrystalCard(CrystalData crystal) {
    return GestureDetector(
      onTap: () => _showCrystalDetails(crystal),
      child: EnhancedMysticalCard(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCrystalColor(crystal).withOpacity(0.3),
            CrystalGrimoireTheme.royalPurple.withOpacity(0.6),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Crystal image placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    _getCrystalColor(crystal).withOpacity(0.6),
                    _getCrystalColor(crystal).withOpacity(0.3),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.diamond,
                      size: 60,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  if (crystal.videoAsset != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.play_circle_filled,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              crystal.name,
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
              crystal.colorDescription,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: crystal.chakras.take(2).map((chakra) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getChakraColor(chakra).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getChakraColor(chakra).withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    chakra,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showCrystalDetails(CrystalData crystal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrystalDetailScreen(crystal: crystal),
      ),
    );
  }

  Color _getCrystalColor(CrystalData crystal) {
    if (crystal.colorDescription.toLowerCase().contains('purple')) {
      return CrystalGrimoireTheme.amethyst;
    } else if (crystal.colorDescription.toLowerCase().contains('pink')) {
      return CrystalGrimoireTheme.crystalRose;
    } else if (crystal.colorDescription.toLowerCase().contains('blue')) {
      return CrystalGrimoireTheme.etherealBlue;
    } else if (crystal.colorDescription.toLowerCase().contains('green')) {
      return Colors.green;
    } else if (crystal.colorDescription.toLowerCase().contains('yellow')) {
      return CrystalGrimoireTheme.celestialGold;
    } else if (crystal.colorDescription.toLowerCase().contains('black')) {
      return Colors.black;
    } else if (crystal.colorDescription.toLowerCase().contains('white')) {
      return CrystalGrimoireTheme.moonlightWhite;
    }
    return CrystalGrimoireTheme.mysticPurple;
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
      default: return CrystalGrimoireTheme.mysticPurple;
    }
  }
}

class CrystalDetailScreen extends StatefulWidget {
  final CrystalData crystal;

  const CrystalDetailScreen({
    Key? key,
    required this.crystal,
  }) : super(key: key);

  @override
  State<CrystalDetailScreen> createState() => _CrystalDetailScreenState();
}

class _CrystalDetailScreenState extends State<CrystalDetailScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  VideoPlayerController? _videoController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Initialize video if available
    if (widget.crystal.videoAsset != null) {
      _videoController = VideoPlayerController.asset(widget.crystal.videoAsset!)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: CrystalGrimoireTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildCrystalHero(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildMetaphysicalTab(),
                    _buildHealingTab(),
                    _buildMeditationTab(),
                  ],
                ),
              ),
            ],
          ),
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
            child: Text(
              widget.crystal.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {
              // Add to favorites
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCrystalHero() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            _getCrystalColor(widget.crystal).withOpacity(0.6),
            _getCrystalColor(widget.crystal).withOpacity(0.3),
          ],
        ),
      ),
      child: Stack(
        children: [
          if (_videoController != null && _videoController!.value.isInitialized)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            )
          else
            Center(
              child: PulsingGlow(
                child: Icon(
                  Icons.diamond,
                  size: 100,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          if (_videoController != null)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.black.withOpacity(0.6),
                onPressed: () {
                  setState(() {
                    if (_videoController!.value.isPlaying) {
                      _videoController!.pause();
                    } else {
                      _videoController!.play();
                    }
                  });
                },
                child: Icon(
                  _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [CrystalGrimoireTheme.mysticPurple, CrystalGrimoireTheme.amethyst],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Metaphysical'),
          Tab(text: 'Healing'),
          Tab(text: 'Meditation'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📖 Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.crystal.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🔬 Scientific Properties',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _buildPropertyRow('Chemical Formula', widget.crystal.scientificName),
              _buildPropertyRow('Hardness', '${widget.crystal.hardness} (Mohs scale)'),
              _buildPropertyRow('Formation', widget.crystal.formation),
              _buildPropertyRow('Rarity', widget.crystal.rarity),
            ],
          ),
        ),
        const SizedBox(height: 16),
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🌈 Chakra Associations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.crystal.chakras.map((chakra) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getChakraColor(chakra).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getChakraColor(chakra),
                      ),
                    ),
                    child: Text(
                      chakra,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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

  Widget _buildMetaphysicalTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '✨ Metaphysical Properties',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ...widget.crystal.metaphysicalProperties.map((property) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(
                          color: CrystalGrimoireTheme.celestialGold,
                          fontSize: 16,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          property,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '♈ Zodiac Associations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.crystal.zodiacSigns.map((sign) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          CrystalGrimoireTheme.cosmicViolet,
                          CrystalGrimoireTheme.mysticPurple,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      sign,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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

  Widget _buildHealingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '💚 Healing Properties',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ...widget.crystal.healing.map((healing) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.healing,
                        color: Colors.green[300],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          healing,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        EnhancedMysticalCard(
          gradient: LinearGradient(
            colors: [
              Colors.green.withOpacity(0.3),
              CrystalGrimoireTheme.royalPurple.withOpacity(0.6),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🌿 How to Use for Healing',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '1. Cleanse your crystal under running water or moonlight\n\n'
                '2. Hold the crystal and set your healing intention\n\n'
                '3. Place on affected area or corresponding chakra\n\n'
                '4. Meditate with the crystal for 10-15 minutes\n\n'
                '5. Thank the crystal and cleanse after use',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMeditationTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.crystal.videoAsset != null)
          EnhancedMysticalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎥 Crystal Meditation Video',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black,
                  ),
                  child: Center(
                    child: IconButton(
                      icon: const Icon(
                        Icons.play_circle_filled,
                        size: 64,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (_videoController != null) {
                          _videoController!.play();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🧘 Meditation Guide',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Find a quiet space and sit comfortably with your ${widget.crystal.name}.\n\n'
                '1. Hold the crystal in your hands or place it on your body\n\n'
                '2. Close your eyes and take three deep breaths\n\n'
                '3. Visualize ${_getCrystalColorName(widget.crystal)} light emanating from the crystal\n\n'
                '4. Feel the crystal\'s energy merging with your own\n\n'
                '5. Focus on your intention or simply be present\n\n'
                '6. Continue for 10-20 minutes\n\n'
                '7. Slowly open your eyes and ground yourself',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        EnhancedMysticalCard(
          gradient: LinearGradient(
            colors: [
              CrystalGrimoireTheme.cosmicViolet.withOpacity(0.3),
              CrystalGrimoireTheme.deepSpace.withOpacity(0.8),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🌙 Affirmations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _getCrystalAffirmation(widget.crystal),
                style: const TextStyle(
                  color: CrystalGrimoireTheme.celestialGold,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCrystalColor(CrystalData crystal) {
    if (crystal.colorDescription.toLowerCase().contains('purple')) {
      return CrystalGrimoireTheme.amethyst;
    } else if (crystal.colorDescription.toLowerCase().contains('pink')) {
      return CrystalGrimoireTheme.crystalRose;
    } else if (crystal.colorDescription.toLowerCase().contains('blue')) {
      return CrystalGrimoireTheme.etherealBlue;
    } else if (crystal.colorDescription.toLowerCase().contains('green')) {
      return Colors.green;
    } else if (crystal.colorDescription.toLowerCase().contains('yellow')) {
      return CrystalGrimoireTheme.celestialGold;
    } else if (crystal.colorDescription.toLowerCase().contains('black')) {
      return Colors.grey[800]!;
    } else if (crystal.colorDescription.toLowerCase().contains('white')) {
      return Colors.white;
    }
    return CrystalGrimoireTheme.mysticPurple;
  }

  String _getCrystalColorName(CrystalData crystal) {
    if (crystal.colorDescription.toLowerCase().contains('purple')) return 'purple';
    if (crystal.colorDescription.toLowerCase().contains('pink')) return 'pink';
    if (crystal.colorDescription.toLowerCase().contains('blue')) return 'blue';
    if (crystal.colorDescription.toLowerCase().contains('green')) return 'green';
    if (crystal.colorDescription.toLowerCase().contains('yellow')) return 'golden';
    if (crystal.colorDescription.toLowerCase().contains('black')) return 'protective black';
    if (crystal.colorDescription.toLowerCase().contains('white')) return 'pure white';
    return 'mystical';
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
      default: return CrystalGrimoireTheme.mysticPurple;
    }
  }

  String _getCrystalAffirmation(CrystalData crystal) {
    switch (crystal.id) {
      case 'amethyst':
        return '"I am connected to my higher self and trust my intuition.\nDivine wisdom flows through me."';
      case 'rose_quartz':
        return '"I am worthy of love and compassion.\nMy heart is open to giving and receiving love."';
      case 'clear_quartz':
        return '"I am clear, focused, and aligned with my highest purpose.\nMy intentions manifest with ease."';
      case 'black_tourmaline':
        return '"I am protected and grounded.\nNegative energies cannot affect my peaceful state."';
      case 'citrine':
        return '"I attract abundance and prosperity.\nSuccess flows to me naturally and effortlessly."';
      case 'selenite':
        return '"I am connected to angelic realms.\nClarity and peace fill my entire being."';
      case 'labradorite':
        return '"I embrace transformation and trust my magic.\nMy true self shines through."';
      case 'malachite':
        return '"I release what no longer serves me.\nTransformation brings positive change."';
      case 'lapis_lazuli':
        return '"I speak my truth with wisdom and clarity.\nMy voice matters and I am heard."';
      case 'obsidian':
        return '"I face my shadows with courage.\nTruth and healing guide my journey."';
      default:
        return '"I am aligned with the crystal\'s energy.\nHealing and transformation flow through me."';
    }
  }
}