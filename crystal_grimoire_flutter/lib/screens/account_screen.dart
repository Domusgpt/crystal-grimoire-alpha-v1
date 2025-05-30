import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../config/mystical_theme.dart';
import '../services/storage_service.dart';
import '../widgets/common/mystical_card.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/animations/mystical_animations.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  
  bool _isSignedIn = false;
  String _userEmail = '';
  String _currentTier = 'free';
  bool _isFoundersEnabled = false;
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _loadAccountData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadAccountData() async {
    final tier = await StorageService.getSubscriptionTier();
    final foundersEnabled = await StorageService.isFoundersAccountEnabled();
    
    setState(() {
      _currentTier = tier;
      _isFoundersEnabled = foundersEnabled;
      // For demo purposes, simulate sign-in status
      _isSignedIn = tier != 'free' || foundersEnabled;
      _userEmail = _isSignedIn ? 'demo@crystalgrimoire.com' : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              Colors.green.withOpacity(0.3),
              Colors.teal.withOpacity(0.2),
              Colors.cyan.withOpacity(0.1),
              const Color(0xFF0F0F23),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSignInView(),
                    _buildSubscriptionView(),
                    _buildProfileView(),
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
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '👤 Account & Billing',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _isSignedIn ? 'Welcome back, Crystal Seeker' : 'Sign in to unlock premium features',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (_isSignedIn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isFoundersEnabled 
                    ? [const Color(0xFFFFD700), Colors.amber]
                    : _currentTier == 'pro' 
                      ? [Colors.purple, Colors.indigo]
                      : _currentTier == 'premium'
                        ? [Colors.blue, Colors.cyan]
                        : [Colors.grey, Colors.blueGrey],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isFoundersEnabled ? 'FOUNDERS' : _currentTier.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.teal],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        tabs: const [
          Tab(text: 'Sign In'),
          Tab(text: 'Plans'),
          Tab(text: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildSignInView() {
    if (_isSignedIn) {
      return _buildSignedInView();
    }
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.login, color: Colors.green[300]),
                  const SizedBox(width: 8),
                  const Text(
                    'Sign In to Crystal Grimoire',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Email field
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: Icon(Icons.email, color: Colors.green[300]),
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
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Password field
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: Icon(Icons.lock, color: Colors.green[300]),
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
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Sign in button
              MysticalButton(
                onPressed: _signIn,
                label: 'Sign In',
                icon: Icons.login,
                isPrimary: true,
                width: double.infinity,
              ),
              const SizedBox(height: 16),
              
              // Demo sign in button
              MysticalButton(
                onPressed: _demoSignIn,
                label: 'Demo Sign In (No Account Required)',
                icon: Icons.science,
                backgroundColor: Colors.orange,
                width: double.infinity,
              ),
              const SizedBox(height: 16),
              
              // Social sign in options
              const Text(
                'Or continue with:',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildSocialButton(
                      'Google',
                      Icons.g_mobiledata,
                      Colors.red,
                      () => _socialSignIn('google'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSocialButton(
                      'Apple',
                      Icons.apple,
                      Colors.black,
                      () => _socialSignIn('apple'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignedInView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MysticalCard(
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.green.withOpacity(0.3),
                child: const Icon(
                  Icons.person,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _userEmail,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isFoundersEnabled 
                      ? [const Color(0xFFFFD700), Colors.amber]
                      : [Colors.green, Colors.teal],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isFoundersEnabled ? 'Founders Member' : '${_currentTier.toUpperCase()} Member',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Account actions
              _buildAccountAction(
                'Subscription Settings',
                Icons.credit_card,
                () => _tabController.animateTo(1),
              ),
              _buildAccountAction(
                'Billing History',
                Icons.receipt_long,
                _showBillingHistory,
              ),
              _buildAccountAction(
                'Export Data',
                Icons.download,
                _exportData,
              ),
              _buildAccountAction(
                'Sign Out',
                Icons.logout,
                _signOut,
                isDestructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Current plan card
        MysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.diamond, color: Colors.amber[300]),
                  const SizedBox(width: 8),
                  const Text(
                    'Current Plan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCurrentPlanInfo(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Available plans
        MysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available Plans',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildPlanOption(
                'Premium',
                '\$8.99/month',
                [
                  '5 crystal IDs per day',
                  'Crystal collection',
                  'Ad-free experience',
                  'Premium support',
                ],
                Colors.blue,
                _currentTier == 'premium',
              ),
              const SizedBox(height: 12),
              
              _buildPlanOption(
                'Pro',
                '\$19.99/month',
                [
                  '20 crystal IDs per day',
                  'All Premium features',
                  '5 metaphysical queries per day',
                  'Advanced AI models',
                  'Priority support',
                ],
                Colors.purple,
                _currentTier == 'pro',
              ),
              const SizedBox(height: 12),
              
              _buildPlanOption(
                'Founders',
                '\$499 lifetime',
                [
                  'Unlimited everything',
                  'All future features',
                  'Founders badge',
                  'Direct developer access',
                  'Beta testing privileges',
                ],
                const Color(0xFFFFD700),
                _isFoundersEnabled,
                isSpecial: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Developer Tools',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              // Founders toggle
              _buildDevTool(
                'Founders Dev Mode',
                'Enable unlimited access for testing',
                _isFoundersEnabled,
                (value) async {
                  if (value) {
                    await StorageService.enableFoundersAccount();
                  } else {
                    await StorageService.disableFoundersAccount();
                  }
                  await _loadAccountData();
                },
              ),
              
              const SizedBox(height: 16),
              const Text(
                'App Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildInfoRow('Version', '1.0.0'),
              _buildInfoRow('Build', 'Alpha v1'),
              _buildInfoRow('Developer', 'Paul Phillips'),
              _buildInfoRow('Contact', 'phillips.paul.email@gmail.com'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(String name, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountAction(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.white70,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.white,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }

  Widget _buildCurrentPlanInfo() {
    String planName = _isFoundersEnabled ? 'Founders' : _currentTier;
    Color planColor = _isFoundersEnabled 
      ? const Color(0xFFFFD700)
      : _currentTier == 'pro' 
        ? Colors.purple
        : _currentTier == 'premium'
          ? Colors.blue
          : Colors.grey;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [planColor.withOpacity(0.2), planColor.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: planColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                planName.toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: planColor,
                ),
              ),
              if (_currentTier != 'free' && !_isFoundersEnabled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getPlanDescription(planName),
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          if (_currentTier != 'free' && !_isFoundersEnabled) ...[
            const SizedBox(height: 12),
            Text(
              'Next billing: ${DateTime.now().add(const Duration(days: 30)).toString().split(' ')[0]}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanOption(String name, String price, List<String> features, Color color, bool isActive, {bool isSpecial = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isSpecial 
          ? LinearGradient(
              colors: [color.withOpacity(0.2), Colors.amber.withOpacity(0.1)],
            )
          : null,
        color: isSpecial ? null : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? color : Colors.white.withOpacity(0.2),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    price,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (isActive)
                Icon(Icons.check_circle, color: color, size: 24)
              else
                MysticalButton(
                  onPressed: () => _upgradeToPlan(name.toLowerCase()),
                  label: 'Select',
                  backgroundColor: color,
                  height: 36,
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(Icons.check, color: color, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature,
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

  Widget _buildDevTool(String title, String description, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFFFFD700),
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
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getPlanDescription(String plan) {
    switch (plan.toLowerCase()) {
      case 'premium':
        return '5 crystal identifications per day with collection features';
      case 'pro':
        return '20 IDs + 5 AI guidance queries with advanced features';
      case 'founders':
        return 'Unlimited access to all features forever';
      default:
        return '3 crystal identifications per day with ads';
    }
  }

  // Action methods
  void _signIn() {
    // TODO: Implement real authentication
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sign in functionality coming soon!')),
    );
  }

  void _demoSignIn() async {
    await StorageService.saveSubscriptionTier('premium');
    await _loadAccountData();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo sign in successful! Premium features unlocked.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _socialSignIn(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider sign in coming soon!')),
    );
  }

  void _showBillingHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Billing history coming soon!')),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export coming soon!')),
    );
  }

  void _signOut() async {
    await StorageService.saveSubscriptionTier('free');
    await StorageService.disableFoundersAccount();
    await _loadAccountData();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signed out successfully!')),
    );
  }

  void _upgradeToPlan(String plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MysticalTheme.cardColor,
        title: Text(
          'Upgrade to ${plan.toUpperCase()}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'Payment integration coming soon! For now, use the demo mode in the Profile tab.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}