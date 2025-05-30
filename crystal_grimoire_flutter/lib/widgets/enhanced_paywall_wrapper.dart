import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/ads_service.dart';
import '../config/enhanced_theme.dart';
import '../widgets/common/enhanced_mystical_widgets.dart';
import '../widgets/animations/enhanced_animations.dart';
import '../screens/auth_account_screen.dart';

class EnhancedPaywallWrapper extends StatefulWidget {
  final Widget child;
  final String feature;
  final String requiredTier; // 'premium', 'pro', or 'founders'
  final bool showAd; // Show ad for free tier
  final String? customMessage;
  
  const EnhancedPaywallWrapper({
    Key? key,
    required this.child,
    required this.feature,
    required this.requiredTier,
    this.showAd = false,
    this.customMessage,
  }) : super(key: key);

  @override
  State<EnhancedPaywallWrapper> createState() => _EnhancedPaywallWrapperState();
}

class _EnhancedPaywallWrapperState extends State<EnhancedPaywallWrapper>
    with TickerProviderStateMixin {
  bool _hasAccess = false;
  bool _isLoading = true;
  String _currentTier = 'free';
  bool _adWatched = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticOut,
    ));
    _checkAccess();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _checkAccess() async {
    final tier = await StorageService.getSubscriptionTier();
    
    setState(() {
      _currentTier = tier;
      _isLoading = false;
      
      // Check if user has required access
      switch (widget.requiredTier) {
        case 'premium':
          _hasAccess = tier == 'premium' || tier == 'pro' || tier == 'founders';
          break;
        case 'pro':
          _hasAccess = tier == 'pro' || tier == 'founders';
          break;
        case 'founders':
          _hasAccess = tier == 'founders';
          break;
        default:
          _hasAccess = true; // Free features
      }
    });
  }

  void _handlePaywallTap() {
    _shakeController.forward().then((_) => _shakeController.reset());
    
    // Show upgrade dialog
    _showUpgradeDialog();
  }

  Future<void> _showUpgradeDialog() async {
    await showDialog(
      context: context,
      builder: (context) => _buildUpgradeDialog(),
    );
  }

  Widget _buildUpgradeDialog() {
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: EnhancedMysticalCard(
        isPremium: widget.requiredTier == 'founders',
        isGlowing: true,
        glowColor: widget.requiredTier == 'founders'
            ? CrystalGrimoireTheme.celestialGold
            : CrystalGrimoireTheme.mysticPurple,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with tier icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: widget.requiredTier == 'founders'
                    ? CrystalGrimoireTheme.premiumGradient
                    : CrystalGrimoireTheme.primaryButtonGradient,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                _getTierIcon(widget.requiredTier),
                color: CrystalGrimoireTheme.moonlightWhite,
                size: 32,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            ShimmerText(
              text: '${widget.requiredTier.toUpperCase()} Feature',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Feature description
            Text(
              widget.customMessage ?? 
              'Unlock ${widget.feature} with ${widget.requiredTier} subscription',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: CrystalGrimoireTheme.stardustSilver.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Benefits list
            _buildBenefitsList(),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Column(
              children: [
                EnhancedMysticalButton(
                  text: 'Upgrade to ${widget.requiredTier.toUpperCase()}',
                  isPremium: widget.requiredTier == 'founders',
                  isPrimary: widget.requiredTier != 'founders',
                  width: double.infinity,
                  onPressed: _navigateToUpgrade,
                ),
                
                const SizedBox(height: 12),
                
                // Watch ad option for free users
                if (widget.showAd && _currentTier == 'free') ...[
                  EnhancedMysticalButton(
                    text: 'Watch Ad for Temporary Access',
                    icon: Icons.play_circle_outline,
                    isPrimary: false,
                    width: double.infinity,
                    onPressed: _watchAdForAccess,
                  ),
                  const SizedBox(height: 12),
                ],
                
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Maybe Later',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: CrystalGrimoireTheme.stardustSilver.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsList() {
    final benefits = _getTierBenefits(widget.requiredTier);
    final theme = Theme.of(context);
    
    return Column(
      children: benefits.map((benefit) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: widget.requiredTier == 'founders'
                    ? CrystalGrimoireTheme.celestialGold
                    : CrystalGrimoireTheme.successGreen,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  benefit,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: CrystalGrimoireTheme.stardustSilver,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<String> _getTierBenefits(String tier) {
    switch (tier) {
      case 'premium':
        return [
          '5 crystal identifications daily',
          'Complete collection management',
          'Ad-free experience',
          'Premium journal features',
        ];
      case 'pro':
        return [
          '20 crystal identifications daily',
          'AI metaphysical guidance',
          'All Premium features',
          'Priority customer support',
        ];
      case 'founders':
        return [
          'Unlimited everything',
          'LLM experimentation lab',
          'Beta feature access',
          'Direct developer contact',
          'Lifetime access',
        ];
      default:
        return [];
    }
  }

  IconData _getTierIcon(String tier) {
    switch (tier) {
      case 'premium':
        return Icons.diamond_outlined;
      case 'pro':
        return Icons.auto_awesome;
      case 'founders':
        return Icons.emoji_events_outlined;
      default:
        return Icons.lock_outline;
    }
  }

  void _navigateToUpgrade() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthAccountScreen(),
      ),
    );
  }

  Future<void> _watchAdForAccess() async {
    Navigator.pop(context);
    
    try {
      final adShown = await AdsService.showRewardedAd();
      if (adShown) {
        setState(() {
          _adWatched = true;
          _hasAccess = true;
        });
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: CrystalGrimoireTheme.successGreen,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Temporary access granted! Enjoy ${widget.feature}',
                    style: const TextStyle(
                      color: CrystalGrimoireTheme.moonlightWhite,
                    ),
                  ),
                ],
              ),
              backgroundColor: CrystalGrimoireTheme.royalPurple,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: CrystalGrimoireTheme.errorRed,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Ad not available. Please try again later.',
                  style: TextStyle(
                    color: CrystalGrimoireTheme.moonlightWhite,
                  ),
                ),
              ],
            ),
            backgroundColor: CrystalGrimoireTheme.royalPurple,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MysticalLoadingIndicator(
        message: 'Checking access...',
      );
    }

    if (_hasAccess || _adWatched) {
      return MysticalAnimations.fadeScaleIn(
        child: widget.child,
      );
    }

    // Show paywall
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final shake = _shakeAnimation.value * 10;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: _buildPaywallOverlay(),
        );
      },
    );
  }

  Widget _buildPaywallOverlay() {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: _handlePaywallTap,
      child: Stack(
        children: [
          // Blurred/disabled content
          Opacity(
            opacity: 0.3,
            child: widget.child,
          ),
          
          // Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: CrystalGrimoireTheme.deepSpace.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lock icon with glow
                  PulsingGlow(
                    glowColor: widget.requiredTier == 'founders'
                        ? CrystalGrimoireTheme.celestialGold
                        : CrystalGrimoireTheme.mysticPurple,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: widget.requiredTier == 'founders'
                            ? CrystalGrimoireTheme.premiumGradient
                            : CrystalGrimoireTheme.primaryButtonGradient,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: CrystalGrimoireTheme.moonlightWhite,
                        size: 32,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tier badge
                  TierBadge(
                    tier: widget.requiredTier,
                    isActive: true,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Required',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: CrystalGrimoireTheme.stardustSilver.withOpacity(0.7),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Tap to upgrade',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: widget.requiredTier == 'founders'
                          ? CrystalGrimoireTheme.celestialGold
                          : CrystalGrimoireTheme.mysticPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}