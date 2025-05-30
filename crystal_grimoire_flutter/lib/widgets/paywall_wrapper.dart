import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/ads_service.dart';
import '../widgets/common/mystical_card.dart';
import '../widgets/common/mystical_button.dart';
import '../screens/auth_account_screen.dart';

class PaywallWrapper extends StatefulWidget {
  final Widget child;
  final String feature;
  final String requiredTier; // 'premium', 'pro', or 'founders'
  final bool showAd; // Show ad for free tier
  
  const PaywallWrapper({
    Key? key,
    required this.child,
    required this.feature,
    required this.requiredTier,
    this.showAd = false,
  }) : super(key: key);

  @override
  State<PaywallWrapper> createState() => _PaywallWrapperState();
}

class _PaywallWrapperState extends State<PaywallWrapper> {
  bool _hasAccess = false;
  bool _isLoading = true;
  String _currentTier = 'free';
  bool _adWatched = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
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
          _hasAccess = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_hasAccess || _adWatched) {
      return widget.child;
    }
    
    // Show paywall
    return _buildPaywall(context);
  }

  Widget _buildPaywall(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              Colors.purple.withOpacity(0.3),
              Colors.indigo.withOpacity(0.2),
              Colors.deepPurple.withOpacity(0.1),
              const Color(0xFF0F0F23),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Premium feature icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'Premium Feature',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Feature name
                Text(
                  widget.feature,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.amber,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Description
                MysticalCard(
                  child: Column(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 32,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getFeatureDescription(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      
                      // Required tier info
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: Text(
                          'Requires ${_getTierName(widget.requiredTier)} or higher',
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Upgrade button
                MysticalButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AuthAccountScreen(),
                      ),
                    );
                  },
                  label: 'Unlock ${_getTierName(widget.requiredTier)}',
                  icon: Icons.rocket_launch,
                  isPrimary: true,
                  width: double.infinity,
                  height: 56,
                ),
                
                // Watch ad option for free tier
                if (widget.showAd && _currentTier == 'free') ...[
                  const SizedBox(height: 16),
                  MysticalButton(
                    onPressed: _watchAdForAccess,
                    label: 'Watch Ad for One-Time Access',
                    icon: Icons.play_circle_outline,
                    backgroundColor: Colors.green,
                    width: double.infinity,
                    height: 48,
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Benefits list
                _buildBenefitsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitsList() {
    final benefits = _getTierBenefits();
    
    return Column(
      children: benefits.map((benefit) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                benefit,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  String _getFeatureDescription() {
    switch (widget.feature) {
      case 'Crystal Collection':
        return 'Build and manage your personal crystal collection. Track your stones, add notes, and organize by properties.';
      case 'Metaphysical Guidance':
        return 'Get personalized spiritual guidance powered by AI. Ask questions, receive insights, and explore your spiritual path.';
      case 'Advanced Journal':
        return 'Access premium journal features including guided prompts, mood tracking, and astrological insights.';
      case 'Crystal Details':
        return 'View comprehensive crystal information including metaphysical properties, chakra associations, and healing uses.';
      default:
        return 'Unlock this premium feature to enhance your crystal journey.';
    }
  }

  String _getTierName(String tier) {
    switch (tier) {
      case 'premium':
        return 'Premium';
      case 'pro':
        return 'Pro';
      case 'founders':
        return 'Founders';
      default:
        return 'Premium';
    }
  }

  List<String> _getTierBenefits() {
    switch (widget.requiredTier) {
      case 'premium':
        return [
          '5 crystal identifications per day',
          'Build your crystal collection',
          'Ad-free experience',
          'Premium support',
        ];
      case 'pro':
        return [
          '20 crystal identifications per day',
          'All Premium features',
          '5 AI guidance queries daily',
          'Advanced spiritual tools',
          'Priority support',
        ];
      case 'founders':
        return [
          'Unlimited everything',
          'All current & future features',
          'Exclusive founders badge',
          'Direct developer access',
          'Shape the app\'s future',
        ];
      default:
        return [];
    }
  }

  Future<void> _watchAdForAccess() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      // Load and show rewarded ad
      await AdsService.loadRewardedAd();
      await AdsService.showRewardedAd(
        onUserEarnedReward: (amount) {
          Navigator.pop(context); // Close loading
          setState(() {
            _adWatched = true;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Access granted! Enjoy this premium feature.'),
              backgroundColor: Colors.green,
            ),
          );
        },
        onAdDismissed: () {
          Navigator.pop(context); // Close loading
          if (!_adWatched) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please watch the full ad to unlock access.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
      );
    } catch (e) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ad not available: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}