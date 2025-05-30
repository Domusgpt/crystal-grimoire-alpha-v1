import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import '../config/enhanced_theme.dart';
import '../widgets/common/enhanced_mystical_widgets.dart';
import '../widgets/animations/enhanced_animations.dart';

class MeditationSoundBathScreen extends StatefulWidget {
  const MeditationSoundBathScreen({Key? key}) : super(key: key);

  @override
  State<MeditationSoundBathScreen> createState() => _MeditationSoundBathScreenState();
}

class _MeditationSoundBathScreenState extends State<MeditationSoundBathScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _breathingController;
  late AnimationController _chakraController;
  late AnimationController _waveController;
  
  // Timer state
  Timer? _meditationTimer;
  int _selectedDuration = 600; // 10 minutes default
  int _remainingTime = 600;
  bool _isPlaying = false;
  
  // Selected values
  String _selectedChakra = 'Heart';
  String _selectedCrystal = 'Clear Quartz';
  String _selectedSoundscape = 'Ocean Waves';
  double _masterVolume = 0.7;
  
  // Chakra data
  final Map<String, Map<String, dynamic>> _chakraData = {
    'Root': {
      'frequency': 396.0,
      'color': Colors.red,
      'note': 'C',
      'description': 'Grounding & Security',
    },
    'Sacral': {
      'frequency': 417.0,
      'color': Colors.orange,
      'note': 'D',
      'description': 'Creativity & Emotion',
    },
    'Solar Plexus': {
      'frequency': 528.0,
      'color': Colors.yellow,
      'note': 'E',
      'description': 'Personal Power',
    },
    'Heart': {
      'frequency': 639.0,
      'color': Colors.green,
      'note': 'F',
      'description': 'Love & Compassion',
    },
    'Throat': {
      'frequency': 741.0,
      'color': Colors.blue,
      'note': 'G',
      'description': 'Communication & Truth',
    },
    'Third Eye': {
      'frequency': 852.0,
      'color': Colors.indigo,
      'note': 'A',
      'description': 'Intuition & Wisdom',
    },
    'Crown': {
      'frequency': 963.0,
      'color': Colors.purple,
      'note': 'B',
      'description': 'Spiritual Connection',
    },
  };
  
  // Crystal bowl frequencies
  final Map<String, double> _crystalFrequencies = {
    'Clear Quartz': 440.0,
    'Rose Quartz': 528.0,
    'Amethyst': 852.0,
    'Citrine': 417.0,
    'Black Tourmaline': 396.0,
    'Selenite': 963.0,
    'Labradorite': 741.0,
  };
  
  // Soundscapes
  final List<String> _soundscapes = [
    'Ocean Waves',
    'Rain Forest',
    'Crystal Cave',
    'Tibetan Bowls',
    'Deep Space',
    'Sacred Chimes',
    'Theta Waves',
    'Nature Symphony',
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _chakraController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _breathingController.dispose();
    _chakraController.dispose();
    _waveController.dispose();
    _meditationTimer?.cancel();
    super.dispose();
  }
  
  void _startMeditation() {
    setState(() {
      _isPlaying = true;
      _remainingTime = _selectedDuration;
    });
    
    _breathingController.repeat(reverse: true);
    _chakraController.repeat();
    _waveController.repeat();
    
    _meditationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _stopMeditation();
        }
      });
    });
    
    HapticFeedback.mediumImpact();
  }
  
  void _stopMeditation() {
    setState(() {
      _isPlaying = false;
    });
    
    _breathingController.stop();
    _chakraController.stop();
    _waveController.stop();
    _meditationTimer?.cancel();
    
    HapticFeedback.heavyImpact();
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: CrystalGrimoireTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Animated background
            if (_isPlaying) _buildAnimatedBackground(),
            
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSoundBathTab(),
                        _buildBreathingTab(),
                        _buildVisualizerTab(),
                      ],
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
  
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          painter: WaveBackgroundPainter(
            waveAnimation: _waveController.value,
            color: _chakraData[_selectedChakra]!['color'].withOpacity(0.3),
          ),
          size: Size.infinite,
        );
      },
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
                  '🎵 Crystal Sound Bath',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  _isPlaying ? 'Session Active' : 'Healing frequencies & meditation',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (_isPlaying)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: CrystalGrimoireTheme.successGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: CrystalGrimoireTheme.successGreen,
                ),
              ),
              child: Text(
                _formatTime(_remainingTime),
                style: const TextStyle(
                  color: Colors.white,
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
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [CrystalGrimoireTheme.amethyst, CrystalGrimoireTheme.etherealBlue],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        tabs: const [
          Tab(text: 'Sound Bath'),
          Tab(text: 'Breathing'),
          Tab(text: 'Visualizer'),
        ],
      ),
    );
  }
  
  Widget _buildSoundBathTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Duration selector
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Session Duration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDurationButton(300, '5 min'),
                  _buildDurationButton(600, '10 min'),
                  _buildDurationButton(900, '15 min'),
                  _buildDurationButton(1800, '30 min'),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Chakra selector
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Focus Chakra',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _chakraData.length,
                  itemBuilder: (context, index) {
                    final chakra = _chakraData.keys.elementAt(index);
                    final data = _chakraData[chakra]!;
                    final isSelected = chakra == _selectedChakra;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedChakra = chakra;
                        });
                      },
                      child: Container(
                        width: 70,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          gradient: isSelected ? LinearGradient(
                            colors: [
                              data['color'].withOpacity(0.5),
                              data['color'].withOpacity(0.3),
                            ],
                          ) : null,
                          color: !isSelected ? Colors.white.withOpacity(0.1) : null,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                              ? data['color']
                              : Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: data['color'],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              chakra,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _chakraData[_selectedChakra]!['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.music_note,
                      color: _chakraData[_selectedChakra]!['color'],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_chakraData[_selectedChakra]!['frequency']} Hz - Note ${_chakraData[_selectedChakra]!['note']}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Crystal bowl selector
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crystal Bowl',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _crystalFrequencies.keys.map((crystal) {
                  final isSelected = crystal == _selectedCrystal;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCrystal = crystal;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected ? const LinearGradient(
                          colors: [CrystalGrimoireTheme.amethyst, CrystalGrimoireTheme.etherealBlue],
                        ) : null,
                        color: !isSelected ? Colors.white.withOpacity(0.1) : null,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected 
                            ? CrystalGrimoireTheme.celestialGold
                            : Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        crystal,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Soundscape selector
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Background Soundscape',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedSoundscape,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: CrystalGrimoireTheme.royalPurple,
                style: const TextStyle(color: Colors.white),
                items: _soundscapes.map((sound) {
                  return DropdownMenuItem(
                    value: sound,
                    child: Text(sound),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSoundscape = value!;
                  });
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Volume control
        EnhancedMysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Master Volume',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${(_masterVolume * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              Slider(
                value: _masterVolume,
                onChanged: (value) {
                  setState(() {
                    _masterVolume = value;
                  });
                },
                activeColor: CrystalGrimoireTheme.amethyst,
                inactiveColor: Colors.white.withOpacity(0.3),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Play/Stop button
        EnhancedMysticalButton(
          text: _isPlaying ? 'Stop Session' : 'Start Sound Bath',
          icon: _isPlaying ? Icons.stop : Icons.play_arrow,
          isPrimary: true,
          isPremium: !_isPlaying,
          width: double.infinity,
          onPressed: _isPlaying ? _stopMeditation : _startMeditation,
        ),
      ],
    );
  }
  
  Widget _buildBreathingTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Breathing circle
          AnimatedBuilder(
            animation: _breathingController,
            builder: (context, child) {
              final scale = 1.0 + (_breathingController.value * 0.3);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _chakraData[_selectedChakra]!['color'].withOpacity(0.6),
                        _chakraData[_selectedChakra]!['color'].withOpacity(0.3),
                        _chakraData[_selectedChakra]!['color'].withOpacity(0.1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _chakraData[_selectedChakra]!['color'].withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _breathingController.value < 0.5 ? 'Breathe In' : 'Breathe Out',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 48),
          
          // Breathing pattern info
          EnhancedMysticalCard(
            child: Column(
              children: [
                const Text(
                  '4-4-4-4 Box Breathing',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Inhale 4s • Hold 4s • Exhale 4s • Hold 4s',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Synchronize your breath with the expanding circle',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVisualizerTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Chakra visualizer
          AnimatedBuilder(
            animation: _chakraController,
            builder: (context, child) {
              return CustomPaint(
                painter: ChakraVisualizerPainter(
                  animation: _chakraController.value,
                  chakraColors: _chakraData.values.map((d) => d['color'] as Color).toList(),
                ),
                size: const Size(300, 300),
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          Text(
            _selectedChakra,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          Text(
            _chakraData[_selectedChakra]!['description'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDurationButton(int duration, String label) {
    final isSelected = duration == _selectedDuration;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDuration = duration;
          if (!_isPlaying) {
            _remainingTime = duration;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? const LinearGradient(
            colors: [CrystalGrimoireTheme.amethyst, CrystalGrimoireTheme.etherealBlue],
          ) : null,
          color: !isSelected ? Colors.white.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
              ? CrystalGrimoireTheme.celestialGold
              : Colors.white.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class WaveBackgroundPainter extends CustomPainter {
  final double waveAnimation;
  final Color color;
  
  WaveBackgroundPainter({
    required this.waveAnimation,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    for (int i = 0; i < 3; i++) {
      final yOffset = size.height * (0.3 + i * 0.2);
      final amplitude = 30.0 + (i * 10);
      final frequency = 0.02 - (i * 0.005);
      
      path.moveTo(0, yOffset);
      
      for (double x = 0; x <= size.width; x++) {
        final y = yOffset + amplitude * math.sin((x * frequency) + (waveAnimation * 2 * math.pi));
        path.lineTo(x, y);
      }
      
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      
      paint.color = color.withOpacity(0.1 - (i * 0.03));
      canvas.drawPath(path, paint);
      path.reset();
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ChakraVisualizerPainter extends CustomPainter {
  final double animation;
  final List<Color> chakraColors;
  
  ChakraVisualizerPainter({
    required this.animation,
    required this.chakraColors,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw chakra circles
    for (int i = 0; i < chakraColors.length; i++) {
      final angle = (i / chakraColors.length) * 2 * math.pi - (math.pi / 2);
      final radius = 80.0;
      final chakraCenter = Offset(
        center.dx + radius * math.cos(angle + animation * 2 * math.pi),
        center.dy + radius * math.sin(angle + animation * 2 * math.pi),
      );
      
      // Glow effect
      final glowPaint = Paint()
        ..color = chakraColors[i].withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      
      canvas.drawCircle(chakraCenter, 30, glowPaint);
      
      // Main circle
      final paint = Paint()
        ..color = chakraColors[i]
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(chakraCenter, 20, paint);
      
      // Inner light
      final innerPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(chakraCenter, 10, innerPaint);
    }
    
    // Central energy
    final centralPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.8),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 40));
    
    canvas.drawCircle(center, 40, centralPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}