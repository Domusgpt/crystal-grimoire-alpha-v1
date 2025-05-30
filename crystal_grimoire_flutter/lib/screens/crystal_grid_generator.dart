import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import '../models/crystal.dart';
import '../models/crystal_grid.dart';
import '../services/crystal_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/animated_gradient_background.dart';

class CrystalGridGeneratorScreen extends StatefulWidget {
  const CrystalGridGeneratorScreen({super.key});

  @override
  State<CrystalGridGeneratorScreen> createState() => _CrystalGridGeneratorScreenState();
}

class _CrystalGridGeneratorScreenState extends State<CrystalGridGeneratorScreen>
    with TickerProviderStateMixin {
  final CrystalService _crystalService = CrystalService();
  
  // Animation controllers
  late AnimationController _gridAnimationController;
  late AnimationController _activationController;
  late AnimationController _pulseController;
  
  // Grid properties
  GridPattern _selectedPattern = GridPattern.flowerOfLife;
  String _selectedIntention = 'Protection';
  List<GridPoint> _gridPoints = [];
  List<Crystal> _suggestedCrystals = [];
  List<Crystal> _allCrystals = [];
  Map<int, Crystal?> _placedCrystals = {};
  
  // UI state
  bool _isActivating = false;
  bool _showGuide = false;
  int _currentGuideStep = 0;
  
  // Saved templates
  List<CrystalGridTemplate> _savedTemplates = [];
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCrystals();
    _generateGrid();
  }
  
  void _initializeAnimations() {
    _gridAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _activationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }
  
  void _loadCrystals() {
    _allCrystals = _crystalService.getAllCrystals();
    _updateSuggestedCrystals();
  }
  
  void _updateSuggestedCrystals() {
    // Filter crystals based on selected intention
    _suggestedCrystals = _allCrystals.where((crystal) {
      final properties = crystal.properties.toLowerCase();
      final intention = _selectedIntention.toLowerCase();
      return properties.contains(intention);
    }).toList();
    
    // If no specific matches, suggest versatile crystals
    if (_suggestedCrystals.isEmpty) {
      _suggestedCrystals = _allCrystals.where((crystal) {
        return ['Clear Quartz', 'Amethyst', 'Rose Quartz', 'Black Tourmaline']
            .contains(crystal.name);
      }).toList();
    }
  }
  
  void _generateGrid() {
    _gridPoints.clear();
    _placedCrystals.clear();
    
    switch (_selectedPattern) {
      case GridPattern.flowerOfLife:
        _generateFlowerOfLife();
        break;
      case GridPattern.metatronsCube:
        _generateMetatronsCube();
        break;
      case GridPattern.sriYantra:
        _generateSriYantra();
        break;
      case GridPattern.seedOfLife:
        _generateSeedOfLife();
        break;
      case GridPattern.hexagon:
        _generateHexagonGrid();
        break;
      case GridPattern.spiral:
        _generateSpiralGrid();
        break;
    }
    
    _gridAnimationController.forward(from: 0);
  }
  
  void _generateFlowerOfLife() {
    const center = Offset(0, 0);
    const radius = 50.0;
    
    // Center point
    _gridPoints.add(GridPoint(position: center, type: PointType.center));
    
    // First circle - 6 points
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * math.pi / 180;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);
      _gridPoints.add(GridPoint(
        position: Offset(x, y),
        type: PointType.primary,
      ));
    }
    
    // Second circle - 12 points
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180;
      final x = radius * 1.73 * math.cos(angle);
      final y = radius * 1.73 * math.sin(angle);
      _gridPoints.add(GridPoint(
        position: Offset(x, y),
        type: PointType.secondary,
      ));
    }
  }
  
  void _generateMetatronsCube() {
    const radius = 60.0;
    
    // Center
    _gridPoints.add(GridPoint(position: Offset.zero, type: PointType.center));
    
    // Inner hexagon
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * math.pi / 180;
      final x = radius * 0.6 * math.cos(angle);
      final y = radius * 0.6 * math.sin(angle);
      _gridPoints.add(GridPoint(
        position: Offset(x, y),
        type: PointType.primary,
      ));
    }
    
    // Outer hexagon
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 + 30) * math.pi / 180;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);
      _gridPoints.add(GridPoint(
        position: Offset(x, y),
        type: PointType.secondary,
      ));
    }
  }
  
  void _generateSriYantra() {
    // Simplified Sri Yantra pattern
    const scale = 40.0;
    
    // Center bindu
    _gridPoints.add(GridPoint(position: Offset.zero, type: PointType.center));
    
    // Inner triangle
    for (int i = 0; i < 3; i++) {
      final angle = (i * 120 - 90) * math.pi / 180;
      final x = scale * math.cos(angle);
      final y = scale * math.sin(angle);
      _gridPoints.add(GridPoint(
        position: Offset(x, y),
        type: PointType.primary,
      ));
    }
    
    // Outer triangles
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * math.pi / 180;
      final radius = i % 2 == 0 ? scale * 1.5 : scale * 1.8;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);
      _gridPoints.add(GridPoint(
        position: Offset(x, y),
        type: PointType.secondary,
      ));
    }
  }
  
  void _generateSeedOfLife() {
    const radius = 50.0;
    
    // Center
    _gridPoints.add(GridPoint(position: Offset.zero, type: PointType.center));
    
    // Six surrounding circles
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * math.pi / 180;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);
      _gridPoints.add(GridPoint(
        position: Offset(x, y),
        type: PointType.primary,
      ));
    }
  }
  
  void _generateHexagonGrid() {
    const radius = 50.0;
    
    // Center
    _gridPoints.add(GridPoint(position: Offset.zero, type: PointType.center));
    
    // Three concentric hexagons
    for (int ring = 1; ring <= 3; ring++) {
      for (int i = 0; i < 6; i++) {
        final angle = (i * 60) * math.pi / 180;
        final r = radius * ring * 0.6;
        final x = r * math.cos(angle);
        final y = r * math.sin(angle);
        _gridPoints.add(GridPoint(
          position: Offset(x, y),
          type: ring == 1 ? PointType.primary : PointType.secondary,
        ));
      }
    }
  }
  
  void _generateSpiralGrid() {
    const turns = 3.0;
    const pointsPerTurn = 8;
    const maxRadius = 100.0;
    
    // Center
    _gridPoints.add(GridPoint(position: Offset.zero, type: PointType.center));
    
    // Spiral points
    for (int i = 0; i < turns * pointsPerTurn; i++) {
      final t = i / (turns * pointsPerTurn);
      final angle = t * turns * 2 * math.pi;
      final radius = t * maxRadius;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);
      _gridPoints.add(GridPoint(
        position: Offset(x, y),
        type: i < pointsPerTurn ? PointType.primary : PointType.secondary,
      ));
    }
  }
  
  void _activateGrid() {
    if (_placedCrystals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Place at least one crystal to activate the grid')),
      );
      return;
    }
    
    setState(() {
      _isActivating = true;
    });
    
    HapticFeedback.mediumImpact();
    _activationController.forward(from: 0).then((_) {
      setState(() {
        _isActivating = false;
      });
      _showActivationComplete();
    });
  }
  
  void _showActivationComplete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text(
          'Grid Activated!',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Your ${_selectedPattern.displayName} grid has been activated for $_selectedIntention.',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: _saveTemplate,
            child: const Text('Save Template'),
          ),
        ],
      ),
    );
  }
  
  void _saveTemplate() {
    showDialog(
      context: context,
      builder: (context) {
        String templateName = '';
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text(
            'Save Grid Template',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter template name',
              hintStyle: TextStyle(color: Colors.white38),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white38),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.purple),
              ),
            ),
            onChanged: (value) => templateName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (templateName.isNotEmpty) {
                  final template = CrystalGridTemplate(
                    name: templateName,
                    pattern: _selectedPattern,
                    intention: _selectedIntention,
                    crystalPlacements: Map.from(_placedCrystals),
                    createdAt: DateTime.now(),
                  );
                  
                  setState(() {
                    _savedTemplates.add(template);
                  });
                  
                  Navigator.pop(context);
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Template "$templateName" saved!')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  
  void _loadTemplate(CrystalGridTemplate template) {
    setState(() {
      _selectedPattern = template.pattern;
      _selectedIntention = template.intention;
      _placedCrystals = Map.from(template.crystalPlacements);
    });
    _generateGrid();
    _updateSuggestedCrystals();
  }
  
  void _showGuideDialog() {
    setState(() {
      _showGuide = true;
      _currentGuideStep = 0;
    });
  }
  
  List<GuideStep> _getGuideSteps() {
    return [
      GuideStep(
        title: 'Set Your Intention',
        description: 'Begin by clearly defining what you want to achieve with your crystal grid. Focus on a specific goal or energy you wish to manifest.',
        icon: Icons.psychology,
      ),
      GuideStep(
        title: 'Choose Your Pattern',
        description: 'Select a sacred geometry pattern that resonates with your intention. Each pattern carries unique energetic properties.',
        icon: Icons.grid_on,
      ),
      GuideStep(
        title: 'Select Your Crystals',
        description: 'Choose crystals that align with your intention. The app suggests crystals based on their properties, but trust your intuition.',
        icon: Icons.auto_awesome,
      ),
      GuideStep(
        title: 'Place Center Stone',
        description: 'Start with the center point. This is your master crystal that anchors and directs the energy of the entire grid.',
        icon: Icons.center_focus_strong,
      ),
      GuideStep(
        title: 'Add Supporting Stones',
        description: 'Place crystals on the remaining grid points, working outward from the center. Each placement strengthens the grid\'s energy.',
        icon: Icons.scatter_plot,
      ),
      GuideStep(
        title: 'Activate Your Grid',
        description: 'Once all crystals are placed, activate the grid by connecting the crystals energetically. Visualize light flowing between them.',
        icon: Icons.flash_on,
      ),
    ];
  }
  
  @override
  void dispose() {
    _gridAnimationController.dispose();
    _activationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const AnimatedGradientBackground(),
          SafeArea(
            child: Column(
              children: [
                CustomAppBar(
                  title: 'Crystal Grid Generator',
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.help_outline),
                      onPressed: _showGuideDialog,
                    ),
                    IconButton(
                      icon: const Icon(Icons.bookmark_outline),
                      onPressed: _showSavedTemplates,
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    children: [
                      // Left panel - Controls
                      Container(
                        width: 320,
                        padding: const EdgeInsets.all(16),
                        child: _buildControlPanel(),
                      ),
                      
                      // Center - Grid visualization
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: _buildGridVisualization(),
                        ),
                      ),
                      
                      // Right panel - Crystal suggestions
                      Container(
                        width: 280,
                        padding: const EdgeInsets.all(16),
                        child: _buildCrystalPanel(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Guide overlay
          if (_showGuide) _buildGuideOverlay(),
          
          // Activation overlay
          if (_isActivating) _buildActivationOverlay(),
        ],
      ),
    );
  }
  
  Widget _buildControlPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Grid Configuration',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        
        // Pattern selection
        const Text(
          'Sacred Geometry Pattern',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<GridPattern>(
            value: _selectedPattern,
            isExpanded: true,
            dropdownColor: Colors.grey[900],
            style: const TextStyle(color: Colors.white),
            underline: const SizedBox(),
            onChanged: (pattern) {
              if (pattern != null) {
                setState(() {
                  _selectedPattern = pattern;
                });
                _generateGrid();
              }
            },
            items: GridPattern.values.map((pattern) {
              return DropdownMenuItem(
                value: pattern,
                child: Row(
                  children: [
                    Icon(
                      pattern.icon,
                      color: Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(pattern.displayName),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Intention selection
        const Text(
          'Intention',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: _selectedIntention,
            isExpanded: true,
            dropdownColor: Colors.grey[900],
            style: const TextStyle(color: Colors.white),
            underline: const SizedBox(),
            onChanged: (intention) {
              if (intention != null) {
                setState(() {
                  _selectedIntention = intention;
                });
                _updateSuggestedCrystals();
              }
            },
            items: [
              'Protection',
              'Love',
              'Abundance',
              'Healing',
              'Clarity',
              'Grounding',
              'Spiritual Growth',
              'Manifestation',
              'Peace',
              'Creativity',
            ].map((intention) {
              return DropdownMenuItem(
                value: intention,
                child: Text(intention),
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Grid info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.purple[300],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Grid Information',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Points: ${_gridPoints.length}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Crystals Placed: ${_placedCrystals.length}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Pattern: ${_selectedPattern.displayName}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Action buttons
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _placedCrystals.clear();
            });
          },
          icon: const Icon(Icons.clear),
          label: const Text('Clear Grid'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.withOpacity(0.3),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _placedCrystals.isNotEmpty ? _activateGrid : null,
          icon: const Icon(Icons.flash_on),
          label: const Text('Activate Grid'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }
  
  Widget _buildGridVisualization() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final center = Offset(size.width / 2, size.height / 2);
        
        return Stack(
          children: [
            // Grid lines
            if (_gridPoints.length > 1)
              CustomPaint(
                size: size,
                painter: GridLinesPainter(
                  points: _gridPoints,
                  center: center,
                  animation: _gridAnimationController,
                  isActivating: _isActivating,
                  activationAnimation: _activationController,
                ),
              ),
            
            // Grid points and crystals
            ..._gridPoints.asMap().entries.map((entry) {
              final index = entry.key;
              final point = entry.value;
              final position = center + point.position;
              
              return AnimatedBuilder(
                animation: _gridAnimationController,
                builder: (context, child) {
                  final scale = Curves.elasticOut.transform(
                    (_gridAnimationController.value * _gridPoints.length - index)
                        .clamp(0, 1),
                  );
                  
                  return Positioned(
                    left: position.dx - 30,
                    top: position.dy - 30,
                    child: Transform.scale(
                      scale: scale,
                      child: _buildGridPoint(index, point),
                    ),
                  );
                },
              );
            }),
          ],
        );
      },
    );
  }
  
  Widget _buildGridPoint(int index, GridPoint point) {
    final crystal = _placedCrystals[index];
    final isCenter = point.type == PointType.center;
    final size = isCenter ? 60.0 : 50.0;
    
    return GestureDetector(
      onTap: () {
        if (crystal == null && _suggestedCrystals.isNotEmpty) {
          // Auto-place first suggested crystal
          setState(() {
            _placedCrystals[index] = _suggestedCrystals.first;
          });
          HapticFeedback.lightImpact();
        } else if (crystal != null) {
          // Remove crystal
          setState(() {
            _placedCrystals.remove(index);
          });
          HapticFeedback.lightImpact();
        }
      },
      onLongPress: () {
        if (crystal == null) {
          _showCrystalSelector(index);
        }
      },
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulse = _isActivating
              ? 1.0 + (_pulseController.value * 0.2)
              : 1.0;
          
          return Transform.scale(
            scale: pulse,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: crystal != null
                    ? Color(crystal.color).withOpacity(0.8)
                    : Colors.white.withOpacity(0.1),
                border: Border.all(
                  color: isCenter
                      ? Colors.amber
                      : point.type == PointType.primary
                          ? Colors.purple
                          : Colors.white38,
                  width: isCenter ? 3 : 2,
                ),
                boxShadow: [
                  if (crystal != null)
                    BoxShadow(
                      color: Color(crystal.color).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  if (_isActivating)
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.8),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                ],
              ),
              child: Center(
                child: crystal != null
                    ? Text(
                        crystal.name[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    : Icon(
                        Icons.add,
                        color: Colors.white.withOpacity(0.5),
                        size: 20,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildCrystalPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suggested Crystals',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'For $_selectedIntention',
          style: TextStyle(
            color: Colors.purple[300],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        
        Expanded(
          child: ListView.builder(
            itemCount: _suggestedCrystals.length,
            itemBuilder: (context, index) {
              final crystal = _suggestedCrystals[index];
              return _buildCrystalCard(crystal);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildCrystalCard(Crystal crystal) {
    final isPlaced = _placedCrystals.values.contains(crystal);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isPlaced ? null : () => _showCrystalInfo(crystal),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPlaced
                    ? Colors.green.withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(crystal.color),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(crystal.color).withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crystal.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        crystal.chakra,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPlaced)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showCrystalSelector(int gridIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Crystal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _allCrystals.length,
                  itemBuilder: (context, index) {
                    final crystal = _allCrystals[index];
                    final isPlaced = _placedCrystals.values.contains(crystal);
                    
                    return GestureDetector(
                      onTap: isPlaced
                          ? null
                          : () {
                              setState(() {
                                _placedCrystals[gridIndex] = crystal;
                              });
                              Navigator.pop(context);
                              HapticFeedback.lightImpact();
                            },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(crystal.color),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPlaced
                                ? Colors.grey
                                : Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            crystal.name.split(' ').first,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showCrystalInfo(Crystal crystal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          crystal.name,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Color(crystal.color),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Chakra: ${crystal.chakra}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Properties: ${crystal.properties}',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showSavedTemplates() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Saved Templates',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_savedTemplates.isEmpty)
                const Center(
                  child: Text(
                    'No saved templates yet',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _savedTemplates.length,
                    itemBuilder: (context, index) {
                      final template = _savedTemplates[index];
                      return ListTile(
                        title: Text(
                          template.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '${template.pattern.displayName} - ${template.intention}',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.download, color: Colors.white54),
                              onPressed: () {
                                _loadTemplate(template);
                                Navigator.pop(context);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _savedTemplates.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildGuideOverlay() {
    final steps = _getGuideSteps();
    final currentStep = steps[_currentGuideStep];
    
    return GestureDetector(
      onTap: () {
        if (_currentGuideStep < steps.length - 1) {
          setState(() {
            _currentGuideStep++;
          });
        } else {
          setState(() {
            _showGuide = false;
          });
        }
      },
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.purple.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${_currentGuideStep + 1} of ${steps.length}',
                      style: TextStyle(
                        color: Colors.purple[300],
                        fontSize: 14,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () {
                        setState(() {
                          _showGuide = false;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Icon(
                  currentStep.icon,
                  size: 64,
                  color: Colors.purple,
                ),
                const SizedBox(height: 24),
                Text(
                  currentStep.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  currentStep.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    steps.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentGuideStep
                            ? Colors.purple
                            : Colors.white24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _currentGuideStep < steps.length - 1
                      ? 'Tap to continue'
                      : 'Tap to close',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildActivationOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                AnimatedBuilder(
                  animation: _activationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1 + (_activationController.value * 2),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.purple.withOpacity(
                              1 - _activationController.value,
                            ),
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                // Inner glow
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.purple.withOpacity(0.3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple,
                            blurRadius: 50 * _pulseController.value,
                            spreadRadius: 20 * _pulseController.value,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                // Center icon
                const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 48,
                ),
              ],
            ),
            const SizedBox(height: 48),
            const Text(
              'Activating Grid...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Channeling $_selectedIntention energy',
              style: TextStyle(
                color: Colors.purple[300],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for grid lines
class GridLinesPainter extends CustomPainter {
  final List<GridPoint> points;
  final Offset center;
  final Animation<double> animation;
  final bool isActivating;
  final Animation<double> activationAnimation;
  
  GridLinesPainter({
    required this.points,
    required this.center,
    required this.animation,
    required this.isActivating,
    required this.activationAnimation,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    // Draw connections based on pattern
    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        final p1 = points[i];
        final p2 = points[j];
        final dist = (p1.position - p2.position).distance;
        
        // Connect nearby points
        if (dist < 100) {
          final start = center + p1.position;
          final end = center + p2.position;
          
          // Calculate animation progress for this line
          final lineProgress = ((animation.value * points.length) - i)
              .clamp(0, 1)
              .toDouble();
          
          if (lineProgress > 0) {
            // Line color based on activation state
            if (isActivating) {
              final pulse = math.sin(activationAnimation.value * math.pi * 2);
              paint.color = Colors.purple.withOpacity(0.3 + (pulse * 0.5));
            } else {
              paint.color = Colors.white.withOpacity(0.2 * lineProgress);
            }
            
            // Draw partial line based on animation
            final currentEnd = Offset.lerp(start, end, lineProgress)!;
            canvas.drawLine(start, currentEnd, paint);
            
            // Add glow effect during activation
            if (isActivating) {
              paint
                ..color = Colors.purple.withOpacity(0.1)
                ..strokeWidth = 8;
              canvas.drawLine(start, currentEnd, paint);
              paint.strokeWidth = 2;
            }
          }
        }
      }
    }
  }
  
  @override
  bool shouldRepaint(GridLinesPainter oldDelegate) => true;
}

// Enums and models
enum GridPattern {
  flowerOfLife,
  metatronsCube,
  sriYantra,
  seedOfLife,
  hexagon,
  spiral;
  
  String get displayName {
    switch (this) {
      case GridPattern.flowerOfLife:
        return 'Flower of Life';
      case GridPattern.metatronsCube:
        return 'Metatron\'s Cube';
      case GridPattern.sriYantra:
        return 'Sri Yantra';
      case GridPattern.seedOfLife:
        return 'Seed of Life';
      case GridPattern.hexagon:
        return 'Hexagon Grid';
      case GridPattern.spiral:
        return 'Spiral';
    }
  }
  
  IconData get icon {
    switch (this) {
      case GridPattern.flowerOfLife:
        return Icons.filter_vintage;
      case GridPattern.metatronsCube:
        return Icons.view_in_ar;
      case GridPattern.sriYantra:
        return Icons.change_history;
      case GridPattern.seedOfLife:
        return Icons.spa;
      case GridPattern.hexagon:
        return Icons.hexagon;
      case GridPattern.spiral:
        return Icons.all_inclusive;
    }
  }
}

enum PointType {
  center,
  primary,
  secondary,
}

class GridPoint {
  final Offset position;
  final PointType type;
  
  GridPoint({
    required this.position,
    required this.type,
  });
}

class CrystalGridTemplate {
  final String name;
  final GridPattern pattern;
  final String intention;
  final Map<int, Crystal?> crystalPlacements;
  final DateTime createdAt;
  
  CrystalGridTemplate({
    required this.name,
    required this.pattern,
    required this.intention,
    required this.crystalPlacements,
    required this.createdAt,
  });
}

class GuideStep {
  final String title;
  final String description;
  final IconData icon;
  
  GuideStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}