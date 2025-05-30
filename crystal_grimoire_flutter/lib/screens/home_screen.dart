import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../widgets/animations/mystical_animations.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/common/mystical_card.dart';
import 'camera_screen.dart';
import 'collection_screen.dart';
import 'journal_screen.dart';
import 'settings_screen.dart';
import 'metaphysical_guidance_screen.dart';
import 'account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    
    return Scaffold(
      body: Stack(
        children: [
          // Mystical background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.background,
                  theme.colorScheme.background.withBlue(30),
                ],
              ),
            ),
          ),
          
          // Floating particles background
          const FloatingParticles(
            particleCount: 15,
            color: Colors.purpleAccent,
          ),
          
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  // App bar with title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Logo and title
                          FadeScaleIn(
                            delay: const Duration(milliseconds: 200),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.secondary,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.diamond,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // App title
                          FadeScaleIn(
                            delay: const Duration(milliseconds: 400),
                            child: ShimmeringText(
                              text: 'Crystal Grimoire',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Subtitle
                          FadeScaleIn(
                            delay: const Duration(milliseconds: 600),
                            child: Text(
                              'Your Mystical Crystal Companion',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onBackground.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Main action button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: FadeScaleIn(
                        delay: const Duration(milliseconds: 800),
                        child: MysticalButton(
                          onPressed: () => _navigateToIdentify(context),
                          label: 'Identify Crystal',
                          icon: Icons.camera_alt,
                          isPrimary: true,
                          width: double.infinity,
                          height: 64,
                        ),
                      ),
                    ),
                  ),
                  
                  // Usage stats
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: FadeScaleIn(
                        delay: const Duration(milliseconds: 1000),
                        child: _UsageCard(appState: appState),
                      ),
                    ),
                  ),
                  
                  // Feature cards grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.0,
                      ),
                      delegate: SliverChildListDelegate([
                        FadeScaleIn(
                          delay: const Duration(milliseconds: 1200),
                          child: FeatureCard(
                            icon: Icons.collections,
                            title: 'Collection',
                            description: 'Your crystal inventory',
                            iconColor: Colors.amber,
                            isPremium: true,
                            infoText: '0 Crystals',
                            infoSubtext: 'Premium Required',
                            onTap: () => _navigateToCollection(context),
                          ),
                        ),
                        FadeScaleIn(
                          delay: const Duration(milliseconds: 1300),
                          child: FeatureCard(
                            icon: Icons.auto_stories,
                            title: 'Journal',
                            description: 'Your spiritual diary',
                            iconColor: Colors.blue,
                            isPremium: false,
                            infoText: 'Free Access',
                            infoSubtext: 'Start Writing',
                            onTap: () => _navigateToJournal(context),
                          ),
                        ),
                        FadeScaleIn(
                          delay: const Duration(milliseconds: 1400),
                          child: FeatureCard(
                            icon: Icons.auto_fix_high,
                            title: 'Metaphysical Guidance',
                            description: 'AI-powered spiritual wisdom',
                            iconColor: Colors.purple,
                            isPremium: true,
                            infoText: '0/5 Queries',
                            infoSubtext: 'Pro Tier',
                            onTap: () => _navigateToMetaphysicalGuidance(context),
                          ),
                        ),
                        FadeScaleIn(
                          delay: const Duration(milliseconds: 1500),
                          child: FeatureCard(
                            icon: Icons.account_circle,
                            title: 'Account',
                            description: 'Sign in & subscriptions',
                            iconColor: Colors.green,
                            infoText: 'Guest User',
                            infoSubtext: 'Sign In',
                            onTap: () => _navigateToAccount(context),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  
                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Floating action button
      floatingActionButton: FadeScaleIn(
        delay: const Duration(milliseconds: 1600),
        child: CrystalFAB(
          icon: Icons.add_a_photo,
          onPressed: () => _navigateToIdentify(context),
          tooltip: 'Quick Identify',
        ),
      ),
    );
  }
  
  void _navigateToIdentify(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraScreen(),
      ),
    );
  }
  
  void _navigateToCollection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CollectionScreen(),
      ),
    );
  }
  
  void _navigateToJournal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const JournalScreen(),
      ),
    );
  }
  
  void _navigateToMetaphysicalGuidance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MetaphysicalGuidanceScreen(),
      ),
    );
  }
  
  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
  
  void _navigateToAccount(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AccountScreen(),
      ),
    );
  }
}

/// Usage card showing identification limits
class _UsageCard extends StatelessWidget {
  final AppState appState;

  const _UsageCard({required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usageData = appState.currentMonthUsage;
    final isFreeTier = appState.subscriptionTier == 'free';
    final limit = appState.monthlyLimit;
    final remaining = limit - usageData['identifications']!;
    final percentage = limit > 0 ? usageData['identifications']! / limit : 0.0;
    
    return MysticalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isFreeTier ? 'Free Tier' : 'Premium',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isFreeTier)
                MysticalButton(
                  onPressed: () {
                    // TODO: Navigate to subscription screen
                  },
                  label: 'Upgrade',
                  height: 32,
                  backgroundColor: theme.colorScheme.secondary,
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Usage progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Identifications',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    isFreeTier ? '$remaining/$limit remaining' : 'Unlimited',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              if (isFreeTier) ...[
                // Progress bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Benefits of upgrading
                Text(
                  '✨ Upgrade for unlimited identifications, spiritual chat, and more!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ] else ...[
                // Premium benefits
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _BenefitChip(label: '∞ Unlimited IDs'),
                    _BenefitChip(label: '💬 Spiritual Chat'),
                    _BenefitChip(label: '🔮 Priority Support'),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Small benefit chip
class _BenefitChip extends StatelessWidget {
  final String label;

  const _BenefitChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.secondary.withOpacity(0.1),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.secondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Enhanced feature card for home screen menu with useful info
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isPremium;
  final String? infoText;
  final String? infoSubtext;

  const FeatureCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
    required this.onTap,
    this.isPremium = false,
    this.infoText,
    this.infoSubtext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200, // Fixed height for consistency
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.9),
            ],
          ),
          border: Border.all(
            color: isPremium 
              ? Colors.amber.withOpacity(0.6)
              : theme.colorScheme.outline.withOpacity(0.2),
            width: isPremium ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isPremium 
                ? Colors.amber.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Large centered icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          iconColor.withOpacity(0.2),
                          iconColor.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: iconColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 48,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Title
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  
                  // Description
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Useful info section
                  if (infoText != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: iconColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            infoText!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: iconColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (infoSubtext != null)
                            Text(
                              infoSubtext!,
                              style: TextStyle(
                                fontSize: 10,
                                color: iconColor.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isPremium)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 12,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'PRO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}