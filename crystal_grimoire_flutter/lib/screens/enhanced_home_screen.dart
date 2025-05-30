import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/storage_service.dart';
import '../services/usage_tracker.dart';
import '../config/api_config.dart';
import '../config/enhanced_theme.dart';
import '../widgets/animations/enhanced_animations.dart';
import '../widgets/common/enhanced_mystical_widgets.dart';
import '../widgets/enhanced_paywall_wrapper.dart';
import 'camera_screen.dart';
import 'collection_screen.dart';
import 'journal_screen.dart';
import 'settings_screen.dart';
import 'metaphysical_guidance_screen.dart';
import 'account_screen.dart';
import 'auth_account_screen.dart';
import 'llm_lab_screen.dart';
import 'crystal_gallery_screen.dart';
import '../widgets/daily_crystal_card.dart';
import '../widgets/enhanced_app_title.dart';
import 'crystal_ai_oracle.dart';
import 'dream_journal_analyzer.dart';
import 'crystal_marketplace.dart';
import 'meditation_sound_bath.dart';
import 'astro_crystal_matcher.dart';
import 'crystal_energy_healing.dart';
import 'moon_ritual_planner.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  String _userTier = 'free';
  int _dailyIdentifications = 0;
  int _dailyLimit = 3;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    _particleController.repeat();
    _loadUserData();
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final tier = await StorageService.getSubscriptionTier();
    final identifications = await StorageService.getDailyIdentifications();
    
    setState(() {
      _userTier = tier;
      _dailyIdentifications = identifications;
      _dailyLimit = _getDailyLimit(tier);
    });
  }

  int _getDailyLimit(String tier) {
    switch (tier) {
      case 'premium':
        return 5;
      case 'pro':
        return 20;
      case 'founders':
        return 999;
      default:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: CrystalGrimoireTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Floating particles background
            const Positioned.fill(
              child: FloatingParticles(
                particleCount: 15,
                particleColor: CrystalGrimoireTheme.stardustSilver,
              ),
            ),
            
            // Main content
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Enhanced App bar with logo
                  SliverAppBar(
                    expandedHeight: 260,
                    floating: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: const FlexibleSpaceBar(
                      title: Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: EnhancedAppTitle(
                          fontSize: 52,
                          showLogo: true,
                        ),
                      ),
                      centerTitle: true,
                    ),
                    actions: [
                      MysticalAnimations.fadeScaleIn(
                        delay: const Duration(milliseconds: 300),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: TierBadge(
                            tier: _userTier,
                            isActive: true,
                            onTap: () => _navigateToAccount(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Welcome message
                        MysticalAnimations.slideIn(
                          direction: SlideDirection.top,
                          delay: const Duration(milliseconds: 200),
                          child: _buildWelcomeCard(),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        
                        // Daily Spiritual Insights (replacing usage stats)
                        MysticalAnimations.slideIn(
                          direction: SlideDirection.left,
                          delay: const Duration(milliseconds: 400),
                          child: _buildDailySpiritualInsights(),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Crystal of the Day (moved down)
                        MysticalAnimations.slideIn(
                          direction: SlideDirection.right,
                          delay: const Duration(milliseconds: 500),
                          child: _buildEnhancedCrystalOfDay(),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Main actions grid
                        MysticalAnimations.staggeredList(
                          itemDelay: const Duration(milliseconds: 150),
                          children: [
                            _buildMainActionsGrid(),
                            const SizedBox(height: 24),
                            _buildPremiumActionsGrid(),
                            const SizedBox(height: 24),
                            _buildUltimateActionsGrid(),
                            const SizedBox(height: 32),
                            _buildQuickActions(),
                          ],
                        ),
                      ]),
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

  Widget _buildWelcomeCard() {
    return EnhancedMysticalCard(
      isGlowing: _userTier != 'free',
      glowColor: _userTier == 'founders' 
          ? CrystalGrimoireTheme.celestialGold
          : CrystalGrimoireTheme.mysticPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, Crystal Seeker',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Discover the mystical properties of crystals through AI-powered identification and spiritual guidance.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: CrystalGrimoireTheme.stardustSilver.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStats() {
    final remainingUses = _dailyLimit - _dailyIdentifications;
    final percentage = _dailyIdentifications / _dailyLimit;
    
    return EnhancedMysticalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Usage',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              StatusIndicator(
                text: '$remainingUses left',
                type: remainingUses > 0 ? StatusType.success : StatusType.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: CrystalGrimoireTheme.royalPurple.withOpacity(0.3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: percentage >= 1.0
                      ? const LinearGradient(
                          colors: [
                            CrystalGrimoireTheme.errorRed,
                            CrystalGrimoireTheme.warningAmber,
                          ],
                        )
                      : CrystalGrimoireTheme.primaryButtonGradient,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          Text(
            '$_dailyIdentifications / $_dailyLimit identifications used',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildDailySpiritualInsights() {
    final now = DateTime.now();
    final moonPhases = ['🌑 New Moon', '🌒 Waxing Crescent', '🌓 First Quarter', '🌔 Waxing Gibbous', '🌕 Full Moon', '🌖 Waning Gibbous', '🌗 Last Quarter', '🌘 Waning Crescent'];
    final currentMoonPhase = moonPhases[now.day % 8];
    
    final spiritualInsights = [
      'Trust your intuition - the universe is guiding you',
      'Your crystal allies are amplifying your intentions today',
      'Perfect time for manifestation and crystal charging',
      'Your aura is especially receptive to healing energies',
      'The cosmic energies support your spiritual growth',
    ];
    
    final dailyInsight = spiritualInsights[now.day % spiritualInsights.length];
    
    return EnhancedMysticalCard(
      isGlowing: true,
      glowColor: CrystalGrimoireTheme.amethyst,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: CrystalGrimoireTheme.celestialGold,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Daily Spiritual Insights',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Moon phase
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  CrystalGrimoireTheme.moonlightSilver.withOpacity(0.2),
                  CrystalGrimoireTheme.etherealBlue.withOpacity(0.2),
                ],
              ),
            ),
            child: Row(
              children: [
                Text(
                  currentMoonPhase,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Lunar Energy',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Daily insight
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  CrystalGrimoireTheme.amethyst.withOpacity(0.2),
                  CrystalGrimoireTheme.cosmicViolet.withOpacity(0.2),
                ],
              ),
            ),
            child: Text(
              dailyInsight,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCrystalOfDay() {
    final crystals = [
      {'name': 'Black Obsidian', 'property': 'Psychic Protection', 'element': 'Earth', 'chakra': 'Root'},
      {'name': 'Amethyst', 'property': 'Spiritual Awareness', 'element': 'Air', 'chakra': 'Crown'},
      {'name': 'Rose Quartz', 'property': 'Unconditional Love', 'element': 'Water', 'chakra': 'Heart'},
      {'name': 'Citrine', 'property': 'Abundance & Joy', 'element': 'Fire', 'chakra': 'Solar Plexus'},
      {'name': 'Clear Quartz', 'property': 'Amplification', 'element': 'All', 'chakra': 'Crown'},
    ];
    
    final todaysCrystal = crystals[DateTime.now().day % crystals.length];
    
    return EnhancedMysticalCard(
      isGlowing: true,
      glowColor: CrystalGrimoireTheme.celestialGold,
      child: Row(
        children: [
          // Crystal icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  CrystalGrimoireTheme.celestialGold.withOpacity(0.3),
                  CrystalGrimoireTheme.warningAmber.withOpacity(0.5),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: CrystalGrimoireTheme.celestialGold.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.diamond,
              color: Colors.white,
              size: 36,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Crystal info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.wb_sunny,
                      color: CrystalGrimoireTheme.celestialGold,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Crystal of the Day',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: CrystalGrimoireTheme.celestialGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  todaysCrystal['name']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  todaysCrystal['property']!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPropertyTag(todaysCrystal['element']!, CrystalGrimoireTheme.successGreen),
                    const SizedBox(width: 8),
                    _buildPropertyTag(todaysCrystal['chakra']!, CrystalGrimoireTheme.mysticPurple),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPropertyTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMainActionsGrid() {
    return Column(
      children: [
        // Crystal Gallery - Made bigger (full width)
        _buildActionCard(
          title: 'Crystal Gallery',
          subtitle: 'Explore our comprehensive collection of crystals with detailed properties, metaphysical meanings, and spiritual guidance',
          icon: Icons.diamond_outlined,
          gradient: const LinearGradient(
            colors: [
              CrystalGrimoireTheme.amethyst,
              CrystalGrimoireTheme.crystalRose,
            ],
          ),
          onTap: () => _navigateToCrystalGallery(),
        ),
        
        const SizedBox(height: 16),
        
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          children: [
            // Crystal Identification
            _buildActionCard(
              title: 'Identify Crystal',
              subtitle: 'Point camera & discover mystical properties instantly',
              icon: Icons.camera_alt_outlined,
              gradient: CrystalGrimoireTheme.primaryButtonGradient,
              onTap: () => _navigateToCamera(),
              isEnabled: _dailyIdentifications < _dailyLimit,
            ),
            
            // Spiritual Journal
            _buildActionCard(
              title: 'Spiritual Journal',
              subtitle: 'Document your crystal journey & insights',
              icon: Icons.book_outlined,
              gradient: const LinearGradient(
                colors: [
                  CrystalGrimoireTheme.etherealBlue,
                  CrystalGrimoireTheme.mysticPurple,
                ],
              ),
              onTap: () => _navigateToJournal(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          children: [
            // Quick Guide
            _buildActionCard(
              title: 'Quick Guide',
              subtitle: 'Essential crystal meanings & usage tips',
              icon: Icons.auto_stories_outlined,
              gradient: const LinearGradient(
                colors: [
                  CrystalGrimoireTheme.successGreen,
                  CrystalGrimoireTheme.etherealBlue,
                ],
              ),
              onTap: () => _showQuickGuide(),
            ),
            
            // Settings & Account
            _buildActionCard(
              title: 'Account',
              subtitle: 'Subscription, settings & preferences',
              icon: Icons.person_outline,
              gradient: const LinearGradient(
                colors: [
                  CrystalGrimoireTheme.moonlightSilver,
                  CrystalGrimoireTheme.stardustSilver,
                ],
              ),
              onTap: () => _navigateToAccount(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPremiumActionsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: [
        // Collection (Premium)
        EnhancedPaywallWrapper(
          feature: 'Collection Management',
          requiredTier: 'premium',
          child: _buildActionCard(
            title: 'My Collection',
            subtitle: 'Organize & track your crystal inventory with AI insights',
            icon: Icons.inventory_2_outlined,
            gradient: CrystalGrimoireTheme.premiumGradient,
            onTap: () => _navigateToCollection(),
            isPremium: true,
          ),
        ),
        
        // Metaphysical Guidance (Pro)
        EnhancedPaywallWrapper(
          feature: 'Metaphysical Guidance',
          requiredTier: 'pro',
          child: _buildActionCard(
            title: 'AI Guidance',
            subtitle: 'Personalized spiritual wisdom & crystal recommendations',
            icon: Icons.psychology_outlined,
            gradient: const LinearGradient(
              colors: [
                CrystalGrimoireTheme.amethyst,
                CrystalGrimoireTheme.cosmicViolet,
              ],
            ),
            onTap: () => _navigateToGuidance(),
            isPremium: true,
          ),
        ),
      ],
    );
  }

  Widget _buildUltimateActionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '✨ ULTIMATE Features',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: CrystalGrimoireTheme.celestialGold,
          ),
        ),
        const SizedBox(height: 16),
        
        // First row of ULTIMATE features
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          children: [
            // Crystal AI Oracle
            _buildActionCard(
              title: 'AI Oracle',
              subtitle: 'Advanced crystal readings & divine guidance',
              icon: Icons.psychology_alt_outlined,
              gradient: const LinearGradient(
                colors: [
                  CrystalGrimoireTheme.cosmicViolet,
                  CrystalGrimoireTheme.mysticPurple,
                ],
              ),
              onTap: () => _navigateToOracle(),
              isPremium: true,
            ),
            
            // Moon Ritual Planner
            _buildActionCard(
              title: 'Moon Rituals',
              subtitle: 'Lunar-powered crystal ceremonies & intentions',
              icon: Icons.brightness_3,
              gradient: const LinearGradient(
                colors: [
                  CrystalGrimoireTheme.moonlightSilver,
                  CrystalGrimoireTheme.etherealBlue,
                ],
              ),
              onTap: () => _navigateToMoonRituals(),
              isPremium: true,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Second row
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          children: [
            // Dream Journal
            _buildActionCard(
              title: 'Dream Journal',
              subtitle: 'AI-powered dream analysis with crystal insights',
              icon: Icons.nights_stay_outlined,
              gradient: const LinearGradient(
                colors: [
                  CrystalGrimoireTheme.amethyst,
                  CrystalGrimoireTheme.deepSpace,
                ],
              ),
              onTap: () => _navigateToDreamJournal(),
              isPremium: true,
            ),
            
            // Energy Healing
            _buildActionCard(
              title: 'Energy Healing',
              subtitle: 'Chakra balancing with crystal frequency therapy',
              icon: Icons.healing_outlined,
              gradient: const LinearGradient(
                colors: [
                  CrystalGrimoireTheme.successGreen,
                  CrystalGrimoireTheme.etherealBlue,
                ],
              ),
              onTap: () => _navigateToEnergyHealing(),
              isPremium: true,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Third row
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          children: [
            // Astro Crystal Matcher
            _buildActionCard(
              title: 'Astro Crystals',
              subtitle: 'Birth chart-aligned crystal recommendations',
              icon: Icons.star_outline,
              gradient: const LinearGradient(
                colors: [
                  CrystalGrimoireTheme.celestialGold,
                  CrystalGrimoireTheme.warningAmber,
                ],
              ),
              onTap: () => _navigateToAstroMatcher(),
              isPremium: true,
            ),
            
            // Meditation Sound Bath
            _buildActionCard(
              title: 'Sound Bath',
              subtitle: 'Healing frequencies & crystal-tuned meditations',
              icon: Icons.music_note_outlined,
              gradient: const LinearGradient(
                colors: [
                  CrystalGrimoireTheme.crystalRose,
                  CrystalGrimoireTheme.amethyst,
                ],
              ),
              onTap: () => _navigateToSoundBath(),
              isPremium: true,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Crystal Marketplace (full width)
        _buildActionCard(
          title: 'Crystal Marketplace',
          subtitle: 'Find authentic crystals & connect with sellers',
          icon: Icons.shopping_bag_outlined,
          gradient: CrystalGrimoireTheme.premiumGradient,
          onTap: () => _navigateToMarketplace(),
          isPremium: true,
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: EnhancedMysticalButton(
                text: 'Account',
                icon: Icons.person_outline,
                isPrimary: false,
                onPressed: _navigateToAccount,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: EnhancedMysticalButton(
                text: 'Settings',
                icon: Icons.settings_outlined,
                isPrimary: false,
                onPressed: _navigateToSettings,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Founders exclusive
        if (_userTier == 'founders') ...[
          EnhancedMysticalButton(
            text: 'LLM Experimentation Lab',
            icon: Icons.science_outlined,
            isPremium: true,
            width: double.infinity,
            onPressed: _navigateToLLMLab,
          ),
        ],
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
    bool isPremium = false,
    bool isEnabled = true,
  }) {
    return EnhancedMysticalCard(
      isPremium: isPremium,
      isGlowing: isPremium,
      onTap: isEnabled ? onTap : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: isEnabled ? gradient : null,
              color: !isEnabled 
                  ? CrystalGrimoireTheme.stardustSilver.withOpacity(0.3)
                  : null,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              color: isEnabled 
                  ? CrystalGrimoireTheme.moonlightWhite
                  : CrystalGrimoireTheme.stardustSilver.withOpacity(0.5),
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isEnabled 
                  ? null
                  : CrystalGrimoireTheme.stardustSilver.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isEnabled 
                  ? CrystalGrimoireTheme.stardustSilver.withOpacity(0.7)
                  : CrystalGrimoireTheme.stardustSilver.withOpacity(0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToCamera() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const CameraScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToCollection() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const CollectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateToJournal() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const JournalScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToGuidance() async {
    // Spiritual Advisor Chat requires premium tier
    if (await UsageTracker.canAccessFeature('spiritual_advisor_chat')) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MetaphysicalGuidanceScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(scale: animation, child: child);
          },
        ),
      );
    } else {
      _showUpgradeDialog('Spiritual Advisor Chat', 'premium');
    }
  }

  void _navigateToAccount() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AuthAccountScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateToLLMLab() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LLMLabScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, -1.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToCrystalGallery() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const CrystalGalleryScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _showQuickGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CrystalGrimoireTheme.royalPurple,
              CrystalGrimoireTheme.deepSpace,
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Crystal Quick Guide',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildQuickGuideSection(
                    'Protection Crystals',
                    'Black Tourmaline, Obsidian, Hematite',
                    Icons.shield_outlined,
                    Colors.grey[800]!,
                  ),
                  _buildQuickGuideSection(
                    'Love & Relationships',
                    'Rose Quartz, Rhodonite, Garnet',
                    Icons.favorite_outline,
                    CrystalGrimoireTheme.crystalRose,
                  ),
                  _buildQuickGuideSection(
                    'Abundance & Success',
                    'Citrine, Pyrite, Green Aventurine',
                    Icons.star_outline,
                    CrystalGrimoireTheme.celestialGold,
                  ),
                  _buildQuickGuideSection(
                    'Intuition & Spirituality',
                    'Amethyst, Labradorite, Moonstone',
                    Icons.visibility_outlined,
                    CrystalGrimoireTheme.amethyst,
                  ),
                  _buildQuickGuideSection(
                    'Healing & Balance',
                    'Clear Quartz, Selenite, Jade',
                    Icons.spa_outlined,
                    CrystalGrimoireTheme.successGreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickGuideSection(String title, String crystals, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  crystals,
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
    );
  }
  
  // ULTIMATE Feature Navigation Methods with Tier Restrictions
  void _navigateToOracle() async {
    // Crystal AI Oracle requires premium or pro tier
    if (await UsageTracker.canAccessFeature('crystal_ai_oracle')) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const CrystalAIOracleScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.9,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
        ),
      );
    } else {
      _showUpgradeDialog('Crystal AI Oracle', 'pro');
    }
  }
  
  void _navigateToMoonRituals() async {
    // Moon Ritual Planner requires pro tier
    if (await UsageTracker.canAccessFeature('moon_ritual_planner')) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MoonRitualPlannerScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, -1.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      );
    } else {
      _showUpgradeDialog('Moon Ritual Planner', 'pro');
    }
  }
  
  void _navigateToDreamJournal() async {
    // Dream Journal Analyzer requires premium tier
    if (await UsageTracker.canAccessFeature('dream_journal_analyzer')) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const DreamJournalAnalyzer(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    } else {
      _showUpgradeDialog('Dream Journal Analyzer', 'premium');
    }
  }
  
  void _navigateToEnergyHealing() async {
    // Energy Healing Sessions require pro tier
    if (await UsageTracker.canAccessFeature('energy_healing_sessions')) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const CrystalEnergyHealingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
    } else {
      _showUpgradeDialog('Energy Healing Sessions', 'pro');
    }
  }
  
  void _navigateToAstroMatcher() async {
    // Astro Crystal Matcher requires pro tier  
    if (await UsageTracker.canAccessFeature('astro_crystal_matcher')) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const AstroCrystalMatcher(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.5,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
            )),
            child: child,
          );
        },
      ),
    );
    } else {
      _showUpgradeDialog('Astro Crystal Matcher', 'pro');
    }
  }
  
  void _navigateToSoundBath() async {
    // Meditation Sound Bath requires premium tier
    if (await UsageTracker.canAccessFeature('meditation_patterns')) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MeditationSoundBathScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.3),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
        ),
      );
    } else {
      _showUpgradeDialog('Meditation Sound Bath', 'premium');
    }
  }
  
  void _navigateToMarketplace() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const CrystalMarketplace(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      ),
    );
  }

  // Upgrade dialog for restricted features
  void _showUpgradeDialog(String featureName, String requiredTier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CrystalGrimoireTheme.royalPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.star, color: CrystalGrimoireTheme.celestialGold),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Unlock $featureName',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This powerful AI guidance feature requires ${requiredTier == 'premium' ? 'Premium' : 'Pro'} tier to access.',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              requiredTier == 'premium' 
                  ? '✨ Premium: \$8.99/month\n• Unlimited crystal identifications\n• AI spiritual guidance\n• Dream analysis\n• Birth chart integration'
                  : '🚀 Pro: \$19.99/month\n• All Premium features\n• Premium AI models (GPT-4, Claude)\n• Advanced spiritual tools\n• Crystal AI Oracle\n• Priority support',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToSettings(); // Navigate to subscription settings
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CrystalGrimoireTheme.celestialGold,
              foregroundColor: CrystalGrimoireTheme.deepSpace,
            ),
            child: Text('Upgrade to ${requiredTier == 'premium' ? 'Premium' : 'Pro'}'),
          ),
        ],
      ),
    );
  }
}