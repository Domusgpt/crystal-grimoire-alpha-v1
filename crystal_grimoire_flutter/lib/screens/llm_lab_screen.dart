import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../config/mystical_theme.dart';
import '../services/storage_service.dart';
import '../services/backend_service.dart';
import '../widgets/common/mystical_card.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/animations/mystical_animations.dart';

class LLMLabScreen extends StatefulWidget {
  const LLMLabScreen({Key? key}) : super(key: key);

  @override
  State<LLMLabScreen> createState() => _LLMLabScreenState();
}

class _LLMLabScreenState extends State<LLMLabScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  String _selectedModel = 'gemini-1.5-flash';
  String _selectedPromptTemplate = 'crystal_identification';
  double _temperature = 0.7;
  int _maxTokens = 2000;
  
  final TextEditingController _customPromptController = TextEditingController();
  final TextEditingController _testInputController = TextEditingController();
  
  bool _isLoading = false;
  String? _lastResponse;
  Map<String, dynamic>? _responseMetrics;
  
  List<Map<String, dynamic>> _testResults = [];
  
  final Map<String, String> _availableModels = {
    'gemini-1.5-flash': 'Gemini 1.5 Flash (Fast, Cost-effective)',
    'gemini-1.5-pro': 'Gemini 1.5 Pro (Balanced)',
    'gemini-2.0-flash': 'Gemini 2.0 Flash (Latest, Experimental)',
    'gpt-4o-mini': 'GPT-4o Mini (OpenAI)',
    'gpt-4o': 'GPT-4o (OpenAI Premium)',
    'claude-3.5-sonnet': 'Claude 3.5 Sonnet (Anthropic)',
  };
  
  final Map<String, String> _promptTemplates = {
    'crystal_identification': 'Crystal Identification Expert',
    'spiritual_guidance': 'Spiritual Advisor',
    'metaphysical_properties': 'Metaphysical Properties Analyzer',
    'chakra_healing': 'Chakra Healing Guide',
    'meditation_guide': 'Meditation & Mindfulness Coach',
    'custom': 'Custom Prompt',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkFoundersAccess();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customPromptController.dispose();
    _testInputController.dispose();
    super.dispose();
  }

  Future<void> _checkFoundersAccess() async {
    final isFounders = await StorageService.isFoundersAccountEnabled();
    if (!isFounders) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Founders access required for LLM Lab'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              Colors.deepPurple.withOpacity(0.3),
              Colors.indigo.withOpacity(0.2),
              Colors.blue.withOpacity(0.1),
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
                    _buildModelTestingView(),
                    _buildPromptEngineeringView(),
                    _buildAnalyticsView(),
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
                  '🧪 LLM Laboratory',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Experiment with models, prompts & fine-tuning',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFFFD700), Colors.amber],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'FOUNDERS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
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
            colors: [Colors.deepPurple, Colors.indigo],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        tabs: const [
          Tab(text: 'Models'),
          Tab(text: 'Prompts'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildModelTestingView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology, color: Colors.blue[300]),
                  const SizedBox(width: 8),
                  const Text(
                    'Model Configuration',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Model selection
              const Text(
                'Select AI Model:',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedModel,
                    onChanged: (value) => setState(() => _selectedModel = value!),
                    dropdownColor: const Color(0xFF1A1A2E),
                    style: const TextStyle(color: Colors.white),
                    items: _availableModels.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                entry.value,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Temperature slider
              const Text(
                'Temperature (Creativity):',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _temperature,
                      onChanged: (value) => setState(() => _temperature = value),
                      min: 0.0,
                      max: 2.0,
                      divisions: 20,
                      activeColor: Colors.blue,
                      inactiveColor: Colors.blue.withOpacity(0.3),
                    ),
                  ),
                  Text(
                    _temperature.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Max tokens
              const Text(
                'Max Tokens:',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _maxTokens.toDouble(),
                      onChanged: (value) => setState(() => _maxTokens = value.round()),
                      min: 100,
                      max: 4000,
                      divisions: 39,
                      activeColor: Colors.green,
                      inactiveColor: Colors.green.withOpacity(0.3),
                    ),
                  ),
                  Text(
                    _maxTokens.toString(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Test input
        MysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.science, color: Colors.orange[300]),
                  const SizedBox(width: 8),
                  const Text(
                    'Test Input',
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
                controller: _testInputController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter test prompt or question...',
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
                    borderSide: const BorderSide(color: Colors.orange),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: MysticalButton(
                      onPressed: _isLoading ? () {} : () => _runTest(),
                      label: _isLoading ? 'Testing...' : 'Run Test',
                      icon: Icons.play_arrow,
                      isPrimary: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  MysticalButton(
                    onPressed: _addToComparison,
                    label: 'Add to Comparison',
                    icon: Icons.add_chart,
                    backgroundColor: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Response display
        if (_lastResponse != null) ...[
          const SizedBox(height: 16),
          MysticalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.chat_bubble, color: Colors.green[300]),
                    const SizedBox(width: 8),
                    const Text(
                      'Response',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Metrics row
                if (_responseMetrics != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetric('Time', '${_responseMetrics!['responseTime'] ?? 0}ms'),
                        _buildMetric('Tokens', '${_responseMetrics!['tokens'] ?? 0}'),
                        _buildMetric('Cost', '\$${(_responseMetrics!['cost'] ?? 0.0).toStringAsFixed(4)}'),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                
                // Response text
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Text(
                    _lastResponse!,
                    style: const TextStyle(
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPromptEngineeringView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.edit_note, color: Colors.purple[300]),
                  const SizedBox(width: 8),
                  const Text(
                    'Prompt Templates',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Template selection
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _promptTemplates.entries.map((entry) {
                  final isSelected = entry.key == _selectedPromptTemplate;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPromptTemplate = entry.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected 
                          ? LinearGradient(colors: [Colors.purple, Colors.indigo])
                          : null,
                        color: isSelected ? null : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              
              // Custom prompt editor
              const Text(
                'Custom Prompt:',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _customPromptController,
                maxLines: 8,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: _getPromptTemplate(_selectedPromptTemplate),
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
                    borderSide: const BorderSide(color: Colors.purple),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: MysticalButton(
                      onPressed: _loadTemplate,
                      label: 'Load Template',
                      icon: Icons.file_download,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MysticalButton(
                      onPressed: _saveTemplate,
                      label: 'Save Template',
                      icon: Icons.save,
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Prompt engineering tips
        MysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.tips_and_updates, color: Colors.amber[300]),
                  const SizedBox(width: 8),
                  const Text(
                    'Prompt Engineering Tips',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              ..._getPromptTips().map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics, color: Colors.cyan[300]),
                  const SizedBox(width: 8),
                  const Text(
                    'Test Results',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (_testResults.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.science, size: 64, color: Colors.white.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'No test results yet',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Run tests to see performance analytics',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ..._testResults.asMap().entries.map((entry) {
                  final index = entry.key;
                  final result = entry.value;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Test #${index + 1}',
                              style: TextStyle(
                                color: Colors.cyan,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              result['timestamp'],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        Text(
                          'Model: ${result['model']}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        
                        Row(
                          children: [
                            _buildMetric('Time', '${result['responseTime']}ms'),
                            const SizedBox(width: 16),
                            _buildMetric('Tokens', '${result['tokens']}'),
                            const SizedBox(width: 16),
                            _buildMetric('Cost', '\$${result['cost'].toStringAsFixed(4)}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            result['response'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              
              if (_testResults.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: MysticalButton(
                        onPressed: _exportResults,
                        label: 'Export Results',
                        icon: Icons.file_download,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MysticalButton(
                        onPressed: _clearResults,
                        label: 'Clear Results',
                        icon: Icons.clear_all,
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _getPromptTemplate(String template) {
    switch (template) {
      case 'crystal_identification':
        return '''You are a world-renowned crystal expert and mineralogist. Analyze the provided crystal image or description with scientific precision and mystical insight.

IDENTIFICATION APPROACH:
1. Examine visual characteristics (color, transparency, crystal system, habits)
2. Consider physical properties (hardness, luster, fracture)
3. Provide scientific mineral name and common names
4. Share formation process and geological context

METAPHYSICAL PROPERTIES:
- Chakra associations and energy work
- Healing properties and therapeutic uses
- Spiritual significance and meditation benefits
- Astrological connections

FORMAT: Provide clear, confident identification with both scientific and metaphysical perspectives.''';
        
      case 'spiritual_guidance':
        return '''You are the CrystalGrimoire Spiritual Advisor, a wise and compassionate guide with deep knowledge of crystal healing, metaphysics, and spiritual growth.

GUIDANCE STYLE:
- Warm, supportive, and non-judgmental tone
- Blend ancient wisdom with practical advice
- Personalize responses based on user's spiritual journey
- Encourage empowerment and self-discovery

AREAS OF EXPERTISE:
- Crystal healing and energy work
- Chakra balancing and meditation
- Manifestation and intention setting
- Spiritual protection and cleansing
- Intuitive development and psychic abilities

Always end with an affirmation or blessing that resonates with the guidance provided.''';
        
      case 'metaphysical_properties':
        return '''You are an expert in crystal metaphysics and energy healing. Provide detailed analysis of crystal properties from both traditional and modern perspectives.

ANALYSIS FRAMEWORK:
1. Vibrational frequency and energy signature
2. Chakra resonance and energy centers
3. Elemental associations (Earth, Air, Fire, Water)
4. Planetary and astrological influences
5. Color therapy and chromotherapy effects

HEALING APPLICATIONS:
- Physical healing properties
- Emotional and mental balance
- Spiritual development and awareness
- Protection and purification
- Manifestation and abundance work

Provide practical usage instructions and safety considerations.''';
        
      default:
        return 'Enter your custom prompt here...';
    }
  }

  List<String> _getPromptTips() {
    return [
      'Be specific about the desired output format and structure',
      'Use clear, unambiguous language and avoid contradictions',
      'Provide context and background information when relevant',
      'Use examples to illustrate the expected response style',
      'Include constraints and limitations to guide the AI',
      'Test different temperature settings for creativity vs consistency',
      'Iterate and refine prompts based on actual outputs',
      'Consider the model\'s strengths and optimize accordingly',
    ];
  }

  // Action methods
  Future<void> _runTest() async {
    if (_testInputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter test input')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
      _lastResponse = null;
      _responseMetrics = null;
    });
    
    try {
      final startTime = DateTime.now();
      
      // Simulate API call with different models
      await Future.delayed(Duration(milliseconds: 500 + (DateTime.now().millisecond % 1000)));
      
      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime).inMilliseconds;
      
      // Mock response based on selected model
      final response = _generateMockResponse(_testInputController.text);
      final tokens = response.split(' ').length * 1.3; // Approximate token count
      final cost = _calculateCost(_selectedModel, tokens.round());
      
      setState(() {
        _lastResponse = response;
        _responseMetrics = {
          'responseTime': responseTime,
          'tokens': tokens.round(),
          'cost': cost,
        };
      });
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _generateMockResponse(String input) {
    // Generate different responses based on selected model
    final responses = {
      'gemini-1.5-flash': 'Gemini Flash Response: Fast and efficient analysis of your query about "$input". This model provides quick, accurate responses with good balance of speed and quality.',
      'gemini-1.5-pro': 'Gemini Pro Response: Comprehensive analysis of "$input" with enhanced reasoning capabilities. This model offers deeper insights and more nuanced understanding.',
      'gpt-4o-mini': 'GPT-4o Mini Response: Concise and cost-effective analysis of "$input". Optimized for efficiency while maintaining high quality outputs.',
      'gpt-4o': 'GPT-4o Response: Advanced analysis of "$input" with superior reasoning and creative capabilities. This premium model delivers exceptional quality and depth.',
      'claude-3.5-sonnet': 'Claude 3.5 Sonnet Response: Thoughtful and well-structured analysis of "$input". Known for excellent writing quality and nuanced understanding.',
    };
    
    return responses[_selectedModel] ?? 'Mock response for model $_selectedModel analyzing: $input';
  }

  double _calculateCost(String model, int tokens) {
    // Mock cost calculation based on typical pricing
    final costs = {
      'gemini-1.5-flash': 0.000075,
      'gemini-1.5-pro': 0.00125,
      'gpt-4o-mini': 0.00015,
      'gpt-4o': 0.005,
      'claude-3.5-sonnet': 0.003,
    };
    
    return (costs[model] ?? 0.001) * tokens;
  }

  void _addToComparison() {
    if (_lastResponse == null || _responseMetrics == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Run a test first')),
      );
      return;
    }
    
    setState(() {
      _testResults.add({
        'model': _selectedModel,
        'prompt': _testInputController.text,
        'response': _lastResponse!,
        'responseTime': _responseMetrics!['responseTime'],
        'tokens': _responseMetrics!['tokens'],
        'cost': _responseMetrics!['cost'],
        'timestamp': DateTime.now().toString().split('.')[0],
        'temperature': _temperature,
        'maxTokens': _maxTokens,
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Result added to comparison'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _loadTemplate() {
    final template = _getPromptTemplate(_selectedPromptTemplate);
    _customPromptController.text = template;
  }

  void _saveTemplate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Template saved! (Feature coming soon)')),
    );
  }

  void _exportResults() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Results exported! (Feature coming soon)')),
    );
  }

  void _clearResults() {
    setState(() {
      _testResults.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Results cleared')),
    );
  }
}