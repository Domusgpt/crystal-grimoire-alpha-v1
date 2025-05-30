import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:universal_platform/universal_platform.dart';
import '../config/theme.dart';
import '../config/mystical_theme.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import '../services/storage_service.dart';
import '../widgets/common/mystical_card.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/animations/mystical_animations.dart';

class AuthAccountScreen extends StatefulWidget {
  const AuthAccountScreen({Key? key}) : super(key: key);

  @override
  State<AuthAccountScreen> createState() => _AuthAccountScreenState();
}

class _AuthAccountScreenState extends State<AuthAccountScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  SubscriptionStatus? _subscriptionStatus;
  
  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _initializeAuth();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _initializeAuth() async {
    // Listen to auth state changes
    AuthService.authStateChanges.listen((user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
        if (user != null) {
          _loadSubscriptionStatus();
        }
      }
    });
    
    // Check current user
    _currentUser = AuthService.currentUser;
    if (_currentUser != null) {
      await _loadSubscriptionStatus();
    }
  }

  Future<void> _loadSubscriptionStatus() async {
    try {
      final status = await PaymentService.getSubscriptionStatus();
      if (mounted) {
        setState(() {
          _subscriptionStatus = status;
        });
      }
    } catch (e) {
      print('Error loading subscription status: $e');
    }
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
                    _currentUser == null ? _buildSignInView() : _buildSignedInView(),
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
                  _currentUser != null 
                    ? 'Welcome back, ${_currentUser!.displayName ?? 'Crystal Seeker'}'
                    : 'Sign in to unlock premium features',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (_currentUser != null && _subscriptionStatus != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getSubscriptionColors(_subscriptionStatus!.tier),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _subscriptionStatus!.tier.toUpperCase(),
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

  List<Color> _getSubscriptionColors(String tier) {
    switch (tier) {
      case 'founders':
        return [const Color(0xFFFFD700), Colors.amber];
      case 'pro':
        return [Colors.purple, Colors.indigo];
      case 'premium':
        return [Colors.blue, Colors.cyan];
      default:
        return [Colors.grey, Colors.blueGrey];
    }
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
          Tab(text: 'Account'),
          Tab(text: 'Plans'),
          Tab(text: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildSignInView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_isSignUp ? Icons.person_add : Icons.login, color: Colors.green[300]),
                  const SizedBox(width: 8),
                  Text(
                    _isSignUp ? 'Create Account' : 'Sign In to Crystal Grimoire',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_isSignUp)
                      TextFormField(
                        controller: _displayNameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Display Name',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          prefixIcon: Icon(Icons.person, color: Colors.green[300]),
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
                        validator: (value) {
                          if (_isSignUp && (value == null || value.isEmpty)) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                    if (_isSignUp) const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                        prefixIcon: Icon(Icons.lock, color: Colors.green[300]),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (_isSignUp && value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      MysticalButton(
                        onPressed: _handleEmailAuth,
                        label: _isSignUp ? 'Create Account' : 'Sign In',
                        icon: _isSignUp ? Icons.person_add : Icons.login,
                        isPrimary: true,
                        width: double.infinity,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isSignUp = !_isSignUp;
                            _errorMessage = null;
                          });
                        },
                        child: Text(
                          _isSignUp 
                            ? 'Already have an account? Sign In'
                            : "Don't have an account? Sign Up",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
              
              if (!_isSignUp) ...[
                TextButton(
                  onPressed: _handleForgotPassword,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
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
                      _handleGoogleSignIn,
                    ),
                  ),
                  if (UniversalPlatform.isIOS || UniversalPlatform.isMacOS) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSocialButton(
                        'Apple',
                        Icons.apple,
                        Colors.black,
                        _handleAppleSignIn,
                      ),
                    ),
                  ],
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
                backgroundImage: _currentUser?.photoURL != null
                  ? NetworkImage(_currentUser!.photoURL!)
                  : null,
                child: _currentUser?.photoURL == null
                  ? const Icon(Icons.person, size: 48, color: Colors.white)
                  : null,
              ),
              const SizedBox(height: 16),
              Text(
                _currentUser?.displayName ?? 'Crystal Seeker',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _currentUser?.email ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              
              if (_subscriptionStatus != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getSubscriptionColors(_subscriptionStatus!.tier),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_subscriptionStatus!.tier.toUpperCase()} Member',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              
              if (!AuthService.isEmailVerified && 
                  _currentUser?.providerData.any((p) => p.providerId == 'password') == true)
                _buildAccountAction(
                  'Verify Email',
                  Icons.email_outlined,
                  _handleSendVerification,
                  color: Colors.orange,
                ),
              
              _buildAccountAction(
                'Subscription Settings',
                Icons.credit_card,
                () => _tabController.animateTo(1),
              ),
              _buildAccountAction(
                'Restore Purchases',
                Icons.restore,
                _handleRestorePurchases,
              ),
              _buildAccountAction(
                'Export Data',
                Icons.download,
                _handleExportData,
              ),
              _buildAccountAction(
                'Delete Account',
                Icons.delete_forever,
                _handleDeleteAccount,
                isDestructive: true,
              ),
              _buildAccountAction(
                'Sign Out',
                Icons.logout,
                _handleSignOut,
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
        if (_subscriptionStatus != null)
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
                _buildCurrentPlanInfo(_subscriptionStatus!),
              ],
            ),
          ),
        const SizedBox(height: 16),
        
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
                _subscriptionStatus?.tier == 'premium',
                () => _handlePurchase('premium'),
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
                _subscriptionStatus?.tier == 'pro',
                () => _handlePurchase('pro'),
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
                _subscriptionStatus?.tier == 'founders',
                () => _handlePurchase('founders'),
                isSpecial: true,
              ),
              
              if (_subscriptionStatus?.tier != 'free' && 
                  _subscriptionStatus?.tier != 'founders') ...[
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _handleCancelSubscription,
                    child: const Text(
                      'Cancel Subscription',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
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
                'Account Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              if (_currentUser != null && 
                  _currentUser!.providerData.any((p) => p.providerId == 'password'))
                _buildAccountAction(
                  'Change Password',
                  Icons.lock_outline,
                  _handleChangePassword,
                ),
              
              _buildAccountAction(
                'Privacy Policy',
                Icons.privacy_tip_outlined,
                _handlePrivacyPolicy,
              ),
              
              _buildAccountAction(
                'Terms of Service',
                Icons.description_outlined,
                _handleTermsOfService,
              ),
              
              const SizedBox(height: 24),
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
              _buildInfoRow('Build', 'Production'),
              _buildInfoRow('Developer', 'Paul Phillips'),
              _buildInfoRow('Contact', 'support@crystalgrimoire.com'),
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
        onTap: _isLoading ? null : onTap,
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

  Widget _buildAccountAction(String title, IconData icon, VoidCallback onTap, {
    bool isDestructive = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: color ?? (isDestructive ? Colors.red : Colors.white70),
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

  Widget _buildCurrentPlanInfo(SubscriptionStatus status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getSubscriptionColors(status.tier)[0].withOpacity(0.2),
            _getSubscriptionColors(status.tier)[1].withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getSubscriptionColors(status.tier)[0].withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status.tier.toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _getSubscriptionColors(status.tier)[0],
                ),
              ),
              if (status.isActive)
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
            _getPlanDescription(status.tier),
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          if (status.expiresAt != null) ...[
            const SizedBox(height: 12),
            Text(
              'Next billing: ${status.expiresAt}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            if (!status.willRenew)
              Text(
                'Will not renew',
                style: TextStyle(
                  color: Colors.orange.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanOption(
    String name, 
    String price, 
    List<String> features, 
    Color color, 
    bool isActive,
    VoidCallback onSelect,
    {bool isSpecial = false}
  ) {
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
                  onPressed: onSelect,
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

  // Action handlers
  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      if (_isSignUp) {
        await AuthService.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _displayNameController.text.trim(),
        );
        
        // Send verification email
        await AuthService.sendEmailVerification();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created! Please check your email for verification.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await AuthService.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome back!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await AuthService.signInWithGoogle();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await AuthService.signInWithApple();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MysticalTheme.cardColor,
        title: const Text('Sign Out?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await AuthService.signOut();
      Navigator.pop(context);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email first';
      });
      return;
    }
    
    try {
      await AuthService.resetPassword(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _handleSendVerification() async {
    try {
      await AuthService.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MysticalTheme.cardColor,
        title: const Text(
          'Delete Account?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await AuthService.deleteAccount();
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handlePurchase(String tier) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      PurchaseResult result;
      switch (tier) {
        case 'premium':
          result = await PaymentService.purchasePremium();
          break;
        case 'pro':
          result = await PaymentService.purchasePro();
          break;
        case 'founders':
          result = await PaymentService.purchaseFounders();
          break;
        default:
          return;
      }
      
      if (result.success) {
        await _loadSubscriptionStatus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase successful!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Purchase failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRestorePurchases() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final restored = await PaymentService.restorePurchases();
      if (restored) {
        await _loadSubscriptionStatus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchases restored!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No purchases to restore'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleCancelSubscription() async {
    try {
      await PaymentService.cancelSubscription();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _handleExportData() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export coming soon!')),
    );
  }

  Future<void> _handleChangePassword() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password change coming soon!')),
    );
  }

  Future<void> _handlePrivacyPolicy() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening privacy policy...')),
    );
    // TODO: Open privacy policy URL
  }

  Future<void> _handleTermsOfService() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening terms of service...')),
    );
    // TODO: Open terms of service URL
  }
}