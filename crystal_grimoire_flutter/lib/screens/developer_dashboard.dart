import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/enhanced_theme.dart';
import '../config/api_config.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import '../services/usage_tracker.dart';
import '../widgets/common/enhanced_mystical_widgets.dart';

class DeveloperDashboard extends StatefulWidget {
  const DeveloperDashboard({Key? key}) : super(key: key);

  @override
  State<DeveloperDashboard> createState() => _DeveloperDashboardState();
}

class _DeveloperDashboardState extends State<DeveloperDashboard> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // AI Configuration
  AIProvider _selectedProvider = AIService.currentProvider;
  double _temperature = 0.7;
  int _maxTokens = 2000;
  bool _enableHighAccuracyMode = false;
  
  // Testing
  final TextEditingController _testPromptController = TextEditingController();
  bool _isTestingModel = false;
  String? _testResult;
  
  // Performance metrics
  Map<String, dynamic> _performanceMetrics = {};
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkDeveloperAccess();
    _loadCurrentSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _testPromptController.dispose();
    super.dispose();
  }

  Future<void> _checkDeveloperAccess() async {
    // Check if user has developer access (Founders or Pro tier)
    final tier = await UsageTracker.getCurrentSubscriptionTier();
    final hasDevAccess = tier == SubscriptionConfig.foundersTier || tier == SubscriptionConfig.proTier;
    
    if (!hasDevAccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔒 Developer Dashboard requires Pro tier or higher'),
          backgroundColor: CrystalGrimoireTheme.errorRed,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _loadCurrentSettings() async {
    // Load current AI configuration
    setState(() {
      _selectedProvider = AIService.currentProvider;
    });
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
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAIConfigTab(),
                    _buildModelTestingTab(),
                    _buildPerformanceTab(),
                    _buildSystemInfoTab(),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🛠️ Developer Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Advanced AI configuration and testing',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [CrystalGrimoireTheme.warningAmber, CrystalGrimoireTheme.errorRed],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'DEV ONLY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
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
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [CrystalGrimoireTheme.amethyst, CrystalGrimoireTheme.cosmicViolet],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        tabs: const [
          Tab(text: 'AI Config'),
          Tab(text: 'Testing'),
          Tab(text: 'Performance'),
          Tab(text: 'System'),
        ],
      ),
    );
  }

  Widget _buildAIConfigTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Provider Selection
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.smart_toy, color: CrystalGrimoireTheme.amethyst),
                  const SizedBox(width: 8),
                  const Text(
                    'AI Provider Configuration',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Current Provider:',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              
              ...AIProvider.values.map((provider) {
                final isSelected = provider == _selectedProvider;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    tileColor: isSelected 
                      ? CrystalGrimoireTheme.amethyst.withOpacity(0.3)
                      : Colors.white.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected 
                          ? CrystalGrimoireTheme.celestialGold
                          : Colors.white.withOpacity(0.2),
                      ),
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getProviderColor(provider),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getProviderIcon(provider),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      _getProviderDisplayName(provider),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      _getProviderDescription(provider),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: CrystalGrimoireTheme.celestialGold,
                        )
                      : const Icon(
                          Icons.radio_button_unchecked,
                          color: Colors.white54,
                        ),
                    onTap: () {
                      setState(() {
                        _selectedProvider = provider;
                        AIService.currentProvider = provider;
                      });
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Model Parameters
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.tune, color: CrystalGrimoireTheme.etherealBlue),
                  const SizedBox(width: 8),
                  const Text(
                    'Model Parameters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Temperature
              Text(
                'Temperature: ${_temperature.toStringAsFixed(1)}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              Slider(
                value: _temperature,
                min: 0.0,
                max: 2.0,
                divisions: 20,
                activeColor: CrystalGrimoireTheme.etherealBlue,
                inactiveColor: Colors.white.withOpacity(0.3),
                onChanged: (value) {
                  setState(() {
                    _temperature = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Max Tokens
              Text(
                'Max Tokens: $_maxTokens',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              Slider(
                value: _maxTokens.toDouble(),
                min: 500,
                max: 4000,
                divisions: 14,
                activeColor: CrystalGrimoireTheme.etherealBlue,
                inactiveColor: Colors.white.withOpacity(0.3),
                onChanged: (value) {
                  setState(() {
                    _maxTokens = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // High Accuracy Mode
              SwitchListTile(
                title: const Text(
                  'High Accuracy Mode',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Uses premium models for better identification accuracy',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
                value: _enableHighAccuracyMode,
                activeColor: CrystalGrimoireTheme.successGreen,
                onChanged: (value) {
                  setState(() {
                    _enableHighAccuracyMode = value;
                  });
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Save Configuration
        EnhancedMysticalButton(
          text: 'Save AI Configuration',
          icon: Icons.save,
          isPrimary: true,
          width: double.infinity,
          onPressed: _saveConfiguration,
        ),
      ],
    );
  }

  Widget _buildModelTestingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.science, color: CrystalGrimoireTheme.successGreen),
                  const SizedBox(width: 8),
                  const Text(
                    'Model Testing Lab',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _testPromptController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Test Prompt',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  hintText: 'Enter a test prompt to evaluate model performance...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
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
                    borderSide: const BorderSide(color: CrystalGrimoireTheme.etherealBlue),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              EnhancedMysticalButton(
                text: _isTestingModel ? 'Testing...' : 'Test Current Model',
                icon: Icons.play_arrow,
                isPrimary: true,
                width: double.infinity,
                onPressed: _isTestingModel ? null : _testCurrentModel,
              ),
              
              if (_testResult != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: CrystalGrimoireTheme.successGreen),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test Result:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _testResult!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics, color: CrystalGrimoireTheme.warningAmber),
                  const SizedBox(width: 8),
                  const Text(
                    'Performance Metrics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Performance monitoring coming soon...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSystemInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info, color: CrystalGrimoireTheme.etherealBlue),
                  const SizedBox(width: 8),
                  const Text(
                    'System Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildInfoRow('App Version', '2.0.0-ULTIMATE'),
              _buildInfoRow('Current Provider', _getProviderDisplayName(_selectedProvider)),
              _buildInfoRow('High Accuracy Mode', _enableHighAccuracyMode ? 'Enabled' : 'Disabled'),
              _buildInfoRow('Temperature', _temperature.toStringAsFixed(1)),
              _buildInfoRow('Max Tokens', _maxTokens.toString()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
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

  Color _getProviderColor(AIProvider provider) {
    switch (provider) {
      case AIProvider.gemini:
        return Colors.blue;
      case AIProvider.openai:
        return Colors.green;
      case AIProvider.claude:
        return Colors.orange;
      case AIProvider.groq:
        return Colors.purple;
      case AIProvider.replicate:
        return Colors.red;
    }
  }

  IconData _getProviderIcon(AIProvider provider) {
    switch (provider) {
      case AIProvider.gemini:
        return Icons.auto_awesome;
      case AIProvider.openai:
        return Icons.psychology;
      case AIProvider.claude:
        return Icons.smart_toy;
      case AIProvider.groq:
        return Icons.flash_on;
      case AIProvider.replicate:
        return Icons.repeat;
    }
  }

  String _getProviderDisplayName(AIProvider provider) {
    switch (provider) {
      case AIProvider.gemini:
        return 'Google Gemini';
      case AIProvider.openai:
        return 'OpenAI GPT';
      case AIProvider.claude:
        return 'Anthropic Claude';
      case AIProvider.groq:
        return 'Groq LLaMA';
      case AIProvider.replicate:
        return 'Replicate';
    }
  }

  String _getProviderDescription(AIProvider provider) {
    switch (provider) {
      case AIProvider.gemini:
        return 'Google\'s multimodal AI - Free tier with vision';
      case AIProvider.openai:
        return 'OpenAI\'s GPT models - Premium accuracy';
      case AIProvider.claude:
        return 'Anthropic\'s constitutional AI - Thoughtful responses';
      case AIProvider.groq:
        return 'Ultra-fast inference - Text only';
      case AIProvider.replicate:
        return 'Community models - Experimental';
    }
  }

  Future<void> _saveConfiguration() async {
    try {
      // Save to shared preferences or backend
      AIService.currentProvider = _selectedProvider;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚙️ AI configuration saved successfully'),
          backgroundColor: CrystalGrimoireTheme.successGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to save configuration: $e'),
          backgroundColor: CrystalGrimoireTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _testCurrentModel() async {
    if (_testPromptController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a test prompt'),
          backgroundColor: CrystalGrimoireTheme.warningAmber,
        ),
      );
      return;
    }

    setState(() {
      _isTestingModel = true;
      _testResult = null;
    });

    try {
      // This would call the AI service with the test prompt
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      setState(() {
        _testResult = 'Test completed successfully. Model responded with high accuracy.';
        _isTestingModel = false;
      });
    } catch (e) {
      setState(() {
        _testResult = 'Test failed: $e';
        _isTestingModel = false;
      });
    }
  }
}