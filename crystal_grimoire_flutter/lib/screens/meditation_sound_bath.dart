import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MeditationSoundBathScreen extends StatefulWidget {
  @override
  _MeditationSoundBathScreenState createState() => _MeditationSoundBathScreenState();
}

class _MeditationSoundBathScreenState extends State<MeditationSoundBathScreen>
    with TickerProviderStateMixin {
  // Audio players
  final AudioPlayer _bowlPlayer = AudioPlayer();
  final AudioPlayer _binauralPlayer = AudioPlayer();
  final AudioPlayer _naturePlayer = AudioPlayer();
  final AudioPlayer _guidedPlayer = AudioPlayer();
  
  // Animation controllers
  late AnimationController _breathingController;
  late AnimationController _chakraController;
  late AnimationController _visualController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _chakraAnimation;
  late Animation<double> _visualAnimation;
  
  // Timer
  Timer? _meditationTimer;
  int _timerDuration = 600; // 10 minutes default
  int _remainingTime = 600;
  bool _timerRunning = false;
  
  // Selected values
  String _selectedChakra = 'Root';
  String _selectedCrystal = 'Clear Quartz';
  String _selectedNatureSound = 'None';
  String _selectedGuidedMeditation = 'None';
  double _bowlVolume = 0.7;
  double _binauralVolume = 0.5;
  double _natureVolume = 0.3;
  double _guidedVolume = 0.8;
  bool _visualsEnabled = true;
  Color _visualColor = Colors.purple;
  
  // Chakra frequencies (Hz)
  final Map<String, double> chakraFrequencies = {
    'Root': 396.0,
    'Sacral': 417.0,
    'Solar Plexus': 528.0,
    'Heart': 639.0,
    'Throat': 741.0,
    'Third Eye': 852.0,
    'Crown': 963.0,
  };
  
  // Crystal bowl frequencies
  final Map<String, double> crystalBowlFrequencies = {
    'Clear Quartz': 440.0,
    'Rose Quartz': 528.0,
    'Amethyst': 852.0,
    'Citrine': 417.0,
    'Black Tourmaline': 396.0,
    'Selenite': 963.0,
    'Labradorite': 741.0,
  };
  
  // Nature sounds
  final List<String> natureSounds = [
    'None',
    'Ocean Waves',
    'Rain',
    'Forest',
    'Thunder',
    'Birds',
    'Fire Crackling',
    'Wind',
  ];
  
  // Guided meditations
  final List<String> guidedMeditations = [
    'None',
    'Crystal Healing',
    'Chakra Balancing',
    'Deep Relaxation',
    'Energy Cleansing',
    'Manifestation',
    'Sleep Journey',
    'Anxiety Relief',
  ];
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPreferences();
  }
  
  void _initializeAnimations() {
    _breathingController = AnimationController(
      duration: Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
    
    _chakraController = AnimationController(
      duration: Duration(seconds: 6),
      vsync: this,
    )..repeat();
    
    _visualController = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _breathingAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    _chakraAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_chakraController);
    
    _visualAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_visualController);
  }
  
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _timerDuration = prefs.getInt('meditation_duration') ?? 600;
      _remainingTime = _timerDuration;
      _bowlVolume = prefs.getDouble('bowl_volume') ?? 0.7;
      _binauralVolume = prefs.getDouble('binaural_volume') ?? 0.5;
      _natureVolume = prefs.getDouble('nature_volume') ?? 0.3;
      _guidedVolume = prefs.getDouble('guided_volume') ?? 0.8;
      _visualsEnabled = prefs.getBool('visuals_enabled') ?? true;
      _visualColor = Color(prefs.getInt('visual_color') ?? Colors.purple.value);
    });
  }
  
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('meditation_duration', _timerDuration);
    await prefs.setDouble('bowl_volume', _bowlVolume);
    await prefs.setDouble('binaural_volume', _binauralVolume);
    await prefs.setDouble('nature_volume', _natureVolume);
    await prefs.setDouble('guided_volume', _guidedVolume);
    await prefs.setBool('visuals_enabled', _visualsEnabled);
    await prefs.setInt('visual_color', _visualColor.value);
  }
  
  void _startMeditation() {
    setState(() {
      _timerRunning = true;
      _remainingTime = _timerDuration;
    });
    
    // Start sounds
    _playBowlSound();
    _playBinauralBeats();
    if (_selectedNatureSound != 'None') _playNatureSound();
    if (_selectedGuidedMeditation != 'None') _playGuidedMeditation();
    
    // Start timer
    _meditationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _stopMeditation();
        }
      });
    });
  }
  
  void _stopMeditation() {
    setState(() {
      _timerRunning = false;
    });
    
    _meditationTimer?.cancel();
    _bowlPlayer.stop();
    _binauralPlayer.stop();
    _naturePlayer.stop();
    _guidedPlayer.stop();
  }
  
  void _pauseMeditation() {
    if (_timerRunning) {
      _meditationTimer?.cancel();
      _bowlPlayer.pause();
      _binauralPlayer.pause();
      _naturePlayer.pause();
      _guidedPlayer.pause();
    } else {
      _startMeditation();
    }
    
    setState(() {
      _timerRunning = !_timerRunning;
    });
  }
  
  Future<void> _playBowlSound() async {
    final frequency = crystalBowlFrequencies[_selectedCrystal] ?? 440.0;
    // In a real app, you would generate or load the appropriate sound file
    // For now, we'll use a placeholder
    await _bowlPlayer.play(AssetSource('sounds/bowl_${frequency.toInt()}.mp3'));
    await _bowlPlayer.setVolume(_bowlVolume);
    await _bowlPlayer.setReleaseMode(ReleaseMode.loop);
  }
  
  Future<void> _playBinauralBeats() async {
    final frequency = chakraFrequencies[_selectedChakra] ?? 396.0;
    // Generate binaural beats based on chakra frequency
    await _binauralPlayer.play(AssetSource('sounds/binaural_${frequency.toInt()}.mp3'));
    await _binauralPlayer.setVolume(_binauralVolume);
    await _binauralPlayer.setReleaseMode(ReleaseMode.loop);
  }
  
  Future<void> _playNatureSound() async {
    final soundFile = _selectedNatureSound.toLowerCase().replaceAll(' ', '_');
    await _naturePlayer.play(AssetSource('sounds/nature/$soundFile.mp3'));
    await _naturePlayer.setVolume(_natureVolume);
    await _naturePlayer.setReleaseMode(ReleaseMode.loop);
  }
  
  Future<void> _playGuidedMeditation() async {
    final meditationFile = _selectedGuidedMeditation.toLowerCase().replaceAll(' ', '_');
    await _guidedPlayer.play(AssetSource('sounds/guided/$meditationFile.mp3'));
    await _guidedPlayer.setVolume(_guidedVolume);
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background visuals
          if (_visualsEnabled) _buildVisualBackground(),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _timerRunning
                      ? _buildMeditationView()
                      : _buildSetupView(),
                ),
                _buildControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVisualBackground() {
    return AnimatedBuilder(
      animation: _visualAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: MeditationVisualPainter(
            animation: _visualAnimation.value,
            color: _visualColor,
            chakra: _selectedChakra,
          ),
          size: Size.infinite,
        );
      },
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (_timerRunning) _stopMeditation();
              Navigator.pop(context);
            },
          ),
          Text(
            'Sound Bath Meditation',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
    );
  }
  
  Widget _buildMeditationView() {
    return Column(
      children: [
        // Timer display
        Container(
          margin: EdgeInsets.all(32),
          child: Column(
            children: [
              Text(
                _formatTime(_remainingTime),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 16),
              LinearProgressIndicator(
                value: (_timerDuration - _remainingTime) / _timerDuration,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(_visualColor),
              ),
            ],
          ),
        ),
        
        // Breathing guide
        Expanded(
          child: Center(
            child: AnimatedBuilder(
              animation: _breathingAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _breathingAnimation.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _visualColor.withOpacity(0.6),
                          _visualColor.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.self_improvement,
                            color: Colors.white,
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            _breathingAnimation.value > 1.0 ? 'Breathe In' : 'Breathe Out',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        
        // Current settings display
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoChip('Chakra', _selectedChakra),
              _buildInfoChip('Crystal', _selectedCrystal),
              if (_selectedNatureSound != 'None')
                _buildInfoChip('Nature', _selectedNatureSound),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSetupView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timer duration
          _buildSection(
            'Meditation Duration',
            Slider(
              value: _timerDuration.toDouble(),
              min: 60,
              max: 3600,
              divisions: 59,
              activeColor: _visualColor,
              label: _formatTime(_timerDuration),
              onChanged: (value) {
                setState(() {
                  _timerDuration = value.toInt();
                  _remainingTime = _timerDuration;
                });
              },
            ),
          ),
          
          // Chakra selection
          _buildSection(
            'Chakra Focus',
            Wrap(
              spacing: 8,
              children: chakraFrequencies.keys.map((chakra) {
                return ChoiceChip(
                  label: Text(chakra),
                  selected: _selectedChakra == chakra,
                  selectedColor: _visualColor,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedChakra = chakra;
                        _visualColor = _getChakraColor(chakra);
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ),
          
          // Crystal selection
          _buildSection(
            'Crystal Bowl',
            Wrap(
              spacing: 8,
              children: crystalBowlFrequencies.keys.map((crystal) {
                return ChoiceChip(
                  label: Text(crystal),
                  selected: _selectedCrystal == crystal,
                  selectedColor: _visualColor,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCrystal = crystal;
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ),
          
          // Nature sounds
          _buildSection(
            'Nature Sounds',
            DropdownButton<String>(
              value: _selectedNatureSound,
              dropdownColor: Colors.grey[800],
              style: TextStyle(color: Colors.white),
              items: natureSounds.map((sound) {
                return DropdownMenuItem(
                  value: sound,
                  child: Text(sound),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedNatureSound = value!;
                });
              },
            ),
          ),
          
          // Guided meditation
          _buildSection(
            'Guided Meditation',
            DropdownButton<String>(
              value: _selectedGuidedMeditation,
              dropdownColor: Colors.grey[800],
              style: TextStyle(color: Colors.white),
              items: guidedMeditations.map((meditation) {
                return DropdownMenuItem(
                  value: meditation,
                  child: Text(meditation),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGuidedMeditation = value!;
                });
              },
            ),
          ),
          
          // Volume controls
          _buildVolumeControls(),
        ],
      ),
    );
  }
  
  Widget _buildVolumeControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Text(
          'Volume Controls',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        _buildVolumeSlider('Crystal Bowl', _bowlVolume, (value) {
          setState(() {
            _bowlVolume = value;
          });
        }),
        _buildVolumeSlider('Binaural Beats', _binauralVolume, (value) {
          setState(() {
            _binauralVolume = value;
          });
        }),
        _buildVolumeSlider('Nature Sounds', _natureVolume, (value) {
          setState(() {
            _natureVolume = value;
          });
        }),
        _buildVolumeSlider('Guided Voice', _guidedVolume, (value) {
          setState(() {
            _guidedVolume = value;
          });
        }),
      ],
    );
  }
  
  Widget _buildVolumeSlider(String label, double value, Function(double) onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(color: Colors.white70),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0.0,
            max: 1.0,
            activeColor: _visualColor,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            '${(value * 100).toInt()}%',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        child,
        SizedBox(height: 24),
      ],
    );
  }
  
  Widget _buildInfoChip(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildControls() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (_timerRunning) ...[
            IconButton(
              icon: Icon(
                _timerRunning ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
              onPressed: _pauseMeditation,
            ),
            IconButton(
              icon: Icon(
                Icons.stop,
                color: Colors.white,
                size: 32,
              ),
              onPressed: _stopMeditation,
            ),
          ] else ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _visualColor,
                padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _startMeditation,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Begin Meditation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text(
                'Visual Effects',
                style: TextStyle(color: Colors.white),
              ),
              value: _visualsEnabled,
              activeColor: _visualColor,
              onChanged: (value) {
                setState(() {
                  _visualsEnabled = value;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                'Visual Color',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _visualColor,
                  shape: BoxShape.circle,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showColorPicker();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _savePreferences();
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: TextStyle(color: _visualColor),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Choose Color',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _visualColor,
            onColorChanged: (color) {
              setState(() {
                _visualColor = color;
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Done',
              style: TextStyle(color: _visualColor),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getChakraColor(String chakra) {
    switch (chakra) {
      case 'Root':
        return Colors.red;
      case 'Sacral':
        return Colors.orange;
      case 'Solar Plexus':
        return Colors.yellow;
      case 'Heart':
        return Colors.green;
      case 'Throat':
        return Colors.blue;
      case 'Third Eye':
        return Colors.indigo;
      case 'Crown':
        return Colors.purple;
      default:
        return Colors.purple;
    }
  }
  
  @override
  void dispose() {
    _meditationTimer?.cancel();
    _breathingController.dispose();
    _chakraController.dispose();
    _visualController.dispose();
    _bowlPlayer.dispose();
    _binauralPlayer.dispose();
    _naturePlayer.dispose();
    _guidedPlayer.dispose();
    super.dispose();
  }
}

class MeditationVisualPainter extends CustomPainter {
  final double animation;
  final Color color;
  final String chakra;
  
  MeditationVisualPainter({
    required this.animation,
    required this.color,
    required this.chakra,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw energy waves
    for (int i = 0; i < 5; i++) {
      final radius = (size.width / 4) + (i * 20) + (math.sin(animation + i) * 30);
      paint.color = color.withOpacity(0.1 - (i * 0.02));
      canvas.drawCircle(center, radius, paint);
    }
    
    // Draw chakra symbol
    _drawChakraSymbol(canvas, center, chakra);
    
    // Draw floating particles
    _drawParticles(canvas, size);
  }
  
  void _drawChakraSymbol(Canvas canvas, Offset center, String chakra) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    switch (chakra) {
      case 'Root':
        _drawSquare(canvas, center, paint);
        break;
      case 'Sacral':
        _drawCrescent(canvas, center, paint);
        break;
      case 'Solar Plexus':
        _drawTriangle(canvas, center, paint);
        break;
      case 'Heart':
        _drawStar(canvas, center, paint);
        break;
      case 'Throat':
        _drawCircle(canvas, center, paint);
        break;
      case 'Third Eye':
        _drawEye(canvas, center, paint);
        break;
      case 'Crown':
        _drawLotus(canvas, center, paint);
        break;
    }
  }
  
  void _drawSquare(Canvas canvas, Offset center, Paint paint) {
    final rect = Rect.fromCenter(center: center, width: 60, height: 60);
    canvas.drawRect(rect, paint);
  }
  
  void _drawCrescent(Canvas canvas, Offset center, Paint paint) {
    final path = Path();
    path.addArc(Rect.fromCenter(center: center, width: 60, height: 60), 0, math.pi);
    canvas.drawPath(path, paint);
  }
  
  void _drawTriangle(Canvas canvas, Offset center, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - 30);
    path.lineTo(center.dx - 25, center.dy + 20);
    path.lineTo(center.dx + 25, center.dy + 20);
    path.close();
    canvas.drawPath(path, paint);
  }
  
  void _drawStar(Canvas canvas, Offset center, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi) / 3;
      final x = center.dx + 30 * math.cos(angle);
      final y = center.dy + 30 * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
  
  void _drawCircle(Canvas canvas, Offset center, Paint paint) {
    canvas.drawCircle(center, 30, paint);
  }
  
  void _drawEye(Canvas canvas, Offset center, Paint paint) {
    // Draw eye shape
    final path = Path();
    path.moveTo(center.dx - 30, center.dy);
    path.quadraticBezierTo(center.dx, center.dy - 15, center.dx + 30, center.dy);
    path.quadraticBezierTo(center.dx, center.dy + 15, center.dx - 30, center.dy);
    canvas.drawPath(path, paint);
    
    // Draw pupil
    final pupilPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, pupilPaint);
  }
  
  void _drawLotus(Canvas canvas, Offset center, Paint paint) {
    // Draw lotus petals
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * math.pi) / 8;
      final petalCenter = Offset(
        center.dx + 20 * math.cos(angle),
        center.dy + 20 * math.sin(angle),
      );
      canvas.drawCircle(petalCenter, 10, paint);
    }
    // Draw center
    canvas.drawCircle(center, 15, paint);
  }
  
  void _drawParticles(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    final random = math.Random(42); // Fixed seed for consistent animation
    
    for (int i = 0; i < 20; i++) {
      final x = (size.width * random.nextDouble()) + 
          (30 * math.sin(animation + i));
      final y = (size.height * random.nextDouble()) + 
          (20 * math.cos(animation + i * 0.7));
      final radius = 2 + (3 * math.sin(animation + i * 0.5));
      
      canvas.drawCircle(Offset(x, y), radius.abs(), paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}