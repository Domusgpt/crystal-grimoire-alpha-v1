import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../config/mystical_theme.dart';
import '../config/api_config.dart';
import '../services/usage_tracker.dart';
import '../services/backend_service.dart';
import '../services/collection_service.dart';
import '../widgets/common/mystical_card.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/animations/mystical_animations.dart';
import '../services/storage_service.dart';
import '../models/birth_chart.dart';
import 'birth_chart_screen.dart';
import 'developer_dashboard.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentPlan = 'free';
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // Load saved settings
    // In production, these would be loaded from secure storage
    setState(() {
      _currentPlan = 'free'; // Default plan
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: MysticalTheme.backgroundGradient,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildHeader(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSubscriptionSection(),
                      const SizedBox(height: 24),
                      _buildIdentificationTierSection(),
                      const SizedBox(height: 24),
                      _buildUsageStatsSection(),
                      const SizedBox(height: 24),
                      _buildBirthChartSection(),
                      const SizedBox(height: 24),
                      _buildAppSettingsSection(),
                      const SizedBox(height: 24),
                      _buildDataManagementSection(),
                      const SizedBox(height: 24),
                      _buildAboutSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          '⚙️ Mystical Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MysticalTheme.primaryColor.withOpacity(0.8),
                MysticalTheme.secondaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionSection() {
    return MysticalCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '✨ Subscription',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                _buildPlanBadge(_currentPlan),
              ],
            ),
            const SizedBox(height: 16),
            _buildSubscriptionTier(
              'Free',
              '3 IDs/day • Journal Only',
              _currentPlan == 'free',
              () => _changePlan('free'),
            ),
            const SizedBox(height: 12),
            _buildSubscriptionTier(
              'Premium',
              '\$8.99/month • 5 IDs/day • Crystal Collection',
              _currentPlan == 'premium',
              () => _changePlan('premium'),
            ),
            const SizedBox(height: 12),
            _buildSubscriptionTier(
              'Pro',
              '\$19.99/month • 20 IDs/day • 5 Metaphysical Queries',
              _currentPlan == 'pro',
              () => _changePlan('pro'),
            ),
            const SizedBox(height: 12),
            _buildSubscriptionTier(
              'Founders',
              '\$499 lifetime • All features forever',
              _currentPlan == 'founders',
              () => _changePlan('founders'),
              isSpecial: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentificationTierSection() {
    return FutureBuilder<IdentificationTier>(
      future: UsageTracker.getIdentificationTier(),
      builder: (context, tierSnapshot) {
        if (!tierSnapshot.hasData) {
          return const MysticalCard(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final tier = tierSnapshot.data!;
        return FutureBuilder<int>(
          future: UsageTracker.getNewUserBonusRemaining(),
          builder: (context, bonusSnapshot) {
            final bonusRemaining = bonusSnapshot.data ?? 0;
            
            return MysticalCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '🔮 Crystal Identification',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        _buildTierBadge(tier),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTierDescription(tier),
                    
                    if (bonusRemaining > 0) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.withOpacity(0.3),
                              Colors.orange.withOpacity(0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '🎁 New User Bonus',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '$bonusRemaining premium identifications remaining',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    if (_currentPlan == 'founders' || _currentPlan == 'pro')
                      MysticalButton(
                        label: 'Developer Dashboard',
                        icon: Icons.developer_mode,
                        onPressed: () => _openDeveloperDashboard(),
                        width: double.infinity,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTierBadge(IdentificationTier tier) {
    Color color;
    String text;
    
    switch (tier) {
      case IdentificationTier.premium:
        color = Colors.purple;
        text = 'PREMIUM';
        break;
      case IdentificationTier.enhanced:
        color = Colors.blue;
        text = 'ENHANCED';
        break;
      case IdentificationTier.basic:
      default:
        color = Colors.grey;
        text = 'BASIC';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTierDescription(IdentificationTier tier) {
    String description;
    String model;
    String features;
    
    switch (tier) {
      case IdentificationTier.premium:
        description = 'Highest accuracy crystal identification with premium AI models';
        model = 'GPT-4o / Claude 3.5 / Gemini Pro';
        features = 'AI Oracle, Moon Rituals, Energy Healing, Dream Analysis';
        break;
      case IdentificationTier.enhanced:
        description = 'Enhanced crystal identification with spiritual guidance features';
        model = 'Gemini Pro';
        features = 'AI Chat, Birth Charts, Meditation, Crystal Journal';
        break;
      case IdentificationTier.basic:
      default:
        description = 'Basic crystal identification with modern AI';
        model = 'Gemini 2.0 Flash (Latest)';
        features = 'Crystal Database, Community Support';
        break;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'AI Model: $model',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Features: $features',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _openDeveloperDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DeveloperDashboard(),
      ),
    );
  }

  Widget _buildUsageStatsSection() {
    final usage = {'monthlyCount': 0, 'totalCount': 0, 'averageAccuracy': 'N/A'};
    final limit = 10; // Default free tier limit
    
    return MysticalCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Usage Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildUsageBar(
              'Monthly Identifications',
              (usage['monthlyCount'] ?? 0) as int,
              limit,
            ),
            const SizedBox(height: 12),
            _buildStatRow('Total Identifications', '${usage['totalCount'] ?? 0}'),
            _buildStatRow('This Month', '${usage['monthlyCount'] ?? 0}'),
            _buildStatRow('Average Accuracy', '${usage['averageAccuracy'] ?? 'N/A'}%'),
            _buildStatRow('Crystals in Collection', '${CollectionService.collection.length}'),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthChartSection() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: StorageService.getBirthChart(),
      builder: (context, snapshot) {
        final hasChart = snapshot.hasData && snapshot.data != null;
        
        return MysticalCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        PulsingGlow(
                          glowColor: Colors.amber,
                          child: const Icon(
                            Icons.stars,
                            color: Colors.amber,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Birth Chart',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (_currentPlan == 'premium' || _currentPlan == 'pro' || _currentPlan == 'founders')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withOpacity(0.5)),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (hasChart) ...[
                  // Display existing chart info
                  FutureBuilder<BirthChart>(
                    future: Future.value(BirthChart.fromJson(snapshot.data!)),
                    builder: (context, chartSnapshot) {
                      if (!chartSnapshot.hasData) return const SizedBox();
                      
                      final chart = chartSnapshot.data!;
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                // Sun sign
                                _buildMiniZodiac('Sun', chart.sunSign),
                                const SizedBox(width: 16),
                                // Moon sign
                                _buildMiniZodiac('Moon', chart.moonSign),
                                const SizedBox(width: 16),
                                // Rising sign
                                _buildMiniZodiac('Rising', chart.ascendant),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          MysticalButton(
                            onPressed: () => _navigateToBirthChart(),
                            label: 'View Full Chart',
                            icon: Icons.open_in_new,
                            width: double.infinity,
                          ),
                        ],
                      );
                    },
                  ),
                ] else ...[
                  // No chart yet
                  Text(
                    _currentPlan == 'free' 
                      ? 'Upgrade to Premium to unlock personalized astrological guidance'
                      : 'Add your birth details for personalized crystal recommendations',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  MysticalButton(
                    onPressed: _currentPlan == 'free' ? _showUpgradeDialog : _navigateToBirthChart,
                    label: _currentPlan == 'free' ? 'Upgrade to Unlock' : 'Add Birth Chart',
                    icon: _currentPlan == 'free' ? Icons.lock : Icons.add,
                    isPrimary: true,
                    width: double.infinity,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildMiniZodiac(String label, ZodiacSign sign) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sign.symbol,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.amber,
            ),
          ),
          Text(
            sign.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsSection() {
    return MysticalCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚡ App Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildToggleSetting(
              'Push Notifications',
              'Get mystical insights and reminders',
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
            ),
            _buildToggleSetting(
              'Dark Mode',
              'Embrace the mystical darkness',
              _darkModeEnabled,
              (value) => setState(() => _darkModeEnabled = value),
            ),
            _buildToggleSetting(
              'Auto-Save Photos',
              'Save crystal photos to gallery',
              true,
              (value) {},
            ),
            _buildToggleSetting(
              'Show Confidence Levels',
              'Display AI confidence in results',
              true,
              (value) {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementSection() {
    return MysticalCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💾 Data Management',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              'Export Collection',
              'Download your crystal data',
              Icons.download,
              _exportData,
            ),
            _buildActionButton(
              'Import Collection',
              'Restore from backup',
              Icons.upload,
              _importData,
            ),
            _buildActionButton(
              'Clear Cache',
              'Free up storage space',
              Icons.cleaning_services,
              _clearCache,
            ),
            _buildActionButton(
              'Delete Account',
              'Remove all data permanently',
              Icons.delete_forever,
              _deleteAccount,
              isDangerous: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return MysticalCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔮 About Crystal Grimoire',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Version', '1.0.0'),
            _buildInfoRow('Developer', 'Paul Phillips'),
            _buildInfoRow('Contact', 'phillips.paul.email@gmail.com'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: _openPrivacyPolicy,
                  child: const Text('Privacy Policy'),
                ),
                TextButton(
                  onPressed: _openTerms,
                  child: const Text('Terms of Service'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanBadge(String plan) {
    Color color;
    switch (plan) {
      case 'premium':
        color = Colors.blue;
        break;
      case 'pro':
        color = Colors.purple;
        break;
      case 'founders':
        color = Colors.amber;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        plan.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSubscriptionTier(
    String name,
    String description,
    bool isSelected,
    VoidCallback onTap, {
    bool isSpecial = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
            ? MysticalTheme.primaryColor.withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
              ? MysticalTheme.primaryColor
              : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          gradient: isSpecial ? LinearGradient(
            colors: [
              Colors.amber.withOpacity(0.1),
              Colors.purple.withOpacity(0.1),
            ],
          ) : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? MysticalTheme.primaryColor : Colors.white54,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSpecial)
              const Icon(Icons.star, color: Colors.amber),
          ],
        ),
      ),
    );
  }


  Widget _buildUsageBar(String label, int current, int max) {
    final percentage = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    final isNearLimit = percentage > 0.8;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              '$current / $max',
              style: TextStyle(
                color: isNearLimit ? Colors.orange : Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.white.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(
            isNearLimit ? Colors.orange : MysticalTheme.accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
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
    );
  }

  Widget _buildToggleSetting(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: MysticalTheme.accentColor,
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onPressed, {
    bool isDangerous = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDangerous ? Colors.red : Colors.white70,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDangerous ? Colors.red : Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: (isDangerous ? Colors.red : Colors.white).withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
        onTap: onPressed,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Action methods
  void _changePlan(String plan) {
    if (plan == _currentPlan) return;
    
    // Show upgrade dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MysticalTheme.cardColor,
        title: const Text(
          'Upgrade Subscription',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Upgrade to $plan to unlock more features?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement payment flow
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment integration coming soon!')),
              );
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _exportData() async {
    // TODO: Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting collection...')),
    );
  }

  void _importData() async {
    // TODO: Implement data import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import feature coming soon!')),
    );
  }

  void _clearCache() async {
    // TODO: Implement cache clearing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared successfully!')),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MysticalTheme.cardColor,
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will permanently delete all your data. This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement account deletion
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openPrivacyPolicy() {
    // TODO: Open privacy policy
  }

  void _openTerms() {
    // TODO: Open terms of service
  }

  void _navigateToBirthChart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BirthChartScreen(),
      ),
    );
  }
  
  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MysticalTheme.cardColor,
        title: Row(
          children: [
            const Icon(Icons.stars, color: Colors.amber),
            const SizedBox(width: 8),
            const Text(
              'Unlock Astrological Guidance',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Premium features include:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            _buildFeatureRow('Personalized birth chart analysis'),
            _buildFeatureRow('Crystal recommendations based on your astrology'),
            _buildFeatureRow('Enhanced spiritual guidance'),
            _buildFeatureRow('Unlimited crystal identifications'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _changePlan('premium');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
            ),
            child: const Text('Upgrade to Premium'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureRow(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}