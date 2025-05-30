import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/storage_service.dart';
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
      duration: const Duration(seconds: 20),
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
                particleCount: 30,
                particleColor: CrystalGrimoireTheme.stardustSilver,
              ),
            ),
            
            // Main content
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App bar
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      title: MysticalAnimations.fadeScaleIn(
                        child: ShimmerText(
                          text: 'Crystal Grimoire',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
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
                        
                        // Usage stats
                        MysticalAnimations.slideIn(
                          direction: SlideDirection.left,
                          delay: const Duration(milliseconds: 400),
                          child: _buildUsageStats(),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Main actions grid
                        MysticalAnimations.staggeredList(
                          itemDelay: const Duration(milliseconds: 150),
                          children: [
                            _buildMainActionsGrid(),
                            const SizedBox(height: 24),
                            _buildPremiumActionsGrid(),
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
              opacity: 0.8,
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

  Widget _buildMainActionsGrid() {
    return GridView.count(
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
          subtitle: 'Point & discover',
          icon: Icons.camera_alt_outlined,
          gradient: CrystalGrimoireTheme.primaryButtonGradient,
          onTap: () => _navigateToCamera(),
          isEnabled: _dailyIdentifications < _dailyLimit,
        ),
        
        // Journal
        _buildActionCard(
          title: 'Spiritual Journal',
          subtitle: 'Document journey',
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
            subtitle: 'Manage crystals',
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
            subtitle: 'Spiritual wisdom',
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

  void _navigateToGuidance() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MetaphysicalGuidanceScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(scale: animation, child: child);
        },
      ),
    );
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
}