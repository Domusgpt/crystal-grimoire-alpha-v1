/// Comprehensive crystal database with preloaded information
class CrystalData {
  final String id;
  final String name;
  final String scientificName;
  final String description;
  final List<String> metaphysicalProperties;
  final List<String> chakras;
  final String colorDescription;
  final String formation;
  final double hardness; // Mohs scale
  final List<String> healing;
  final List<String> zodiacSigns;
  final String rarity;
  final String imageAsset;
  final String? videoAsset;
  final List<String> keywords;

  const CrystalData({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.metaphysicalProperties,
    required this.chakras,
    required this.colorDescription,
    required this.formation,
    required this.hardness,
    required this.healing,
    required this.zodiacSigns,
    required this.rarity,
    required this.imageAsset,
    this.videoAsset,
    required this.keywords,
  });
}

class CrystalDatabase {
  static const List<CrystalData> crystals = [
    CrystalData(
      id: 'amethyst',
      name: 'Amethyst',
      scientificName: 'SiO₂ (Silicon Dioxide)',
      description: 'A violet variety of quartz known for its stunning purple color, ranging from light lavender to deep royal purple. Forms in geodes and clusters.',
      metaphysicalProperties: [
        'Enhances intuition and psychic abilities',
        'Promotes spiritual growth and protection',
        'Calms the mind and reduces anxiety',
        'Facilitates meditation and connection to higher realms',
        'Transmutes negative energy into positive',
      ],
      chakras: ['Third Eye', 'Crown'],
      colorDescription: 'Purple, violet, lavender',
      formation: 'Forms in volcanic rocks when silica-rich solutions deposit in gas cavities',
      hardness: 7.0,
      healing: [
        'Relieves stress and anxiety',
        'Helps with insomnia and nightmares',
        'Supports sobriety and addiction recovery',
        'Eases headaches and migraines',
        'Strengthens immune system',
      ],
      zodiacSigns: ['Pisces', 'Virgo', 'Aquarius', 'Capricorn'],
      rarity: 'Common',
      imageAsset: 'assets/images/crystals/amethyst.jpg',
      videoAsset: 'assets/videos/amethyst_meditation.mp4',
      keywords: ['purple', 'intuition', 'spiritual', 'protection', 'calm'],
    ),
    
    CrystalData(
      id: 'rose_quartz',
      name: 'Rose Quartz',
      scientificName: 'SiO₂ (Silicon Dioxide)',
      description: 'The stone of unconditional love, with a soft pink essence that embodies compassion, peace, and healing.',
      metaphysicalProperties: [
        'Opens the heart chakra to all forms of love',
        'Promotes self-love and acceptance',
        'Attracts romantic love and strengthens relationships',
        'Heals emotional wounds and trauma',
        'Encourages forgiveness and compassion',
      ],
      chakras: ['Heart'],
      colorDescription: 'Soft pink to rose red',
      formation: 'Forms in pegmatites and hydrothermal veins',
      hardness: 7.0,
      healing: [
        'Supports heart health and circulation',
        'Aids in healing emotional trauma',
        'Promotes peaceful sleep',
        'Enhances fertility',
        'Soothes skin conditions',
      ],
      zodiacSigns: ['Taurus', 'Libra'],
      rarity: 'Common',
      imageAsset: 'assets/images/crystals/rose_quartz.jpg',
      keywords: ['pink', 'love', 'heart', 'compassion', 'healing'],
    ),
    
    CrystalData(
      id: 'clear_quartz',
      name: 'Clear Quartz',
      scientificName: 'SiO₂ (Silicon Dioxide)',
      description: 'Known as the "Master Healer," clear quartz is a powerful amplifying stone that enhances energy and thought.',
      metaphysicalProperties: [
        'Amplifies energy and intention',
        'Enhances psychic abilities',
        'Aids in manifestation',
        'Clears and balances all chakras',
        'Stores, releases, and regulates energy',
      ],
      chakras: ['All Chakras'],
      colorDescription: 'Colorless, transparent to translucent',
      formation: 'Forms in many geological environments',
      hardness: 7.0,
      healing: [
        'Stimulates immune system',
        'Brings body into balance',
        'Enhances mental clarity',
        'Amplifies healing energy',
        'Harmonizes all chakras',
      ],
      zodiacSigns: ['All Signs'],
      rarity: 'Very Common',
      imageAsset: 'assets/images/crystals/clear_quartz.jpg',
      keywords: ['clear', 'amplify', 'master healer', 'energy', 'clarity'],
    ),
    
    CrystalData(
      id: 'black_tourmaline',
      name: 'Black Tourmaline',
      scientificName: 'Na(Fe,Mn)₃Al₆(BO₃)₃Si₆O₁₈(OH)₄',
      description: 'A powerful protective stone that shields against negative energies, EMF radiation, and psychic attacks.',
      metaphysicalProperties: [
        'Provides psychic protection',
        'Grounds spiritual energy',
        'Shields against EMF radiation',
        'Transmutes negative energy',
        'Promotes emotional stability',
      ],
      chakras: ['Root'],
      colorDescription: 'Black, sometimes with striations',
      formation: 'Forms in granite and granite pegmatites',
      hardness: 7.5,
      healing: [
        'Strengthens immune system',
        'Relieves pain and tension',
        'Detoxifies the body',
        'Improves circulation',
        'Reduces anxiety and stress',
      ],
      zodiacSigns: ['Capricorn', 'Scorpio'],
      rarity: 'Common',
      imageAsset: 'assets/images/crystals/black_tourmaline.jpg',
      keywords: ['black', 'protection', 'grounding', 'shield', 'EMF'],
    ),
    
    CrystalData(
      id: 'citrine',
      name: 'Citrine',
      scientificName: 'SiO₂ (Silicon Dioxide)',
      description: 'The "Merchant\'s Stone" - a golden crystal of abundance, prosperity, and personal power.',
      metaphysicalProperties: [
        'Attracts wealth and prosperity',
        'Enhances creativity and imagination',
        'Promotes joy and positivity',
        'Increases self-confidence',
        'Manifests success and abundance',
      ],
      chakras: ['Solar Plexus', 'Sacral'],
      colorDescription: 'Yellow to golden brown',
      formation: 'Heat-treated amethyst or naturally occurring',
      hardness: 7.0,
      healing: [
        'Aids digestion',
        'Boosts metabolism',
        'Enhances physical stamina',
        'Supports thyroid function',
        'Relieves depression',
      ],
      zodiacSigns: ['Gemini', 'Leo', 'Aries'],
      rarity: 'Natural citrine is rare',
      imageAsset: 'assets/images/crystals/citrine.jpg',
      keywords: ['yellow', 'abundance', 'prosperity', 'joy', 'success'],
    ),
    
    CrystalData(
      id: 'selenite',
      name: 'Selenite',
      scientificName: 'CaSO₄·2H₂O (Calcium Sulfate Dihydrate)',
      description: 'A high-vibration crystal that brings mental clarity, spiritual development, and angelic connections.',
      metaphysicalProperties: [
        'Cleanses and charges other crystals',
        'Opens crown and higher chakras',
        'Facilitates angelic communication',
        'Promotes mental clarity',
        'Creates protective grids',
      ],
      chakras: ['Crown', 'Third Eye'],
      colorDescription: 'White, translucent, pearly luster',
      formation: 'Forms in sedimentary deposits',
      hardness: 2.0,
      healing: [
        'Aligns spinal column',
        'Promotes flexibility',
        'Clears energy blockages',
        'Enhances telepathy',
        'Brings deep peace',
      ],
      zodiacSigns: ['Taurus', 'Cancer'],
      rarity: 'Common',
      imageAsset: 'assets/images/crystals/selenite.jpg',
      keywords: ['white', 'cleansing', 'angelic', 'clarity', 'peace'],
    ),
    
    CrystalData(
      id: 'labradorite',
      name: 'Labradorite',
      scientificName: '(Ca,Na)(Al,Si)₄O₈',
      description: 'A mystical stone of transformation with iridescent flashes of blue, green, gold, and violet.',
      metaphysicalProperties: [
        'Enhances psychic abilities',
        'Protects aura from energy leaks',
        'Facilitates transformation',
        'Strengthens intuition',
        'Reveals hidden truths',
      ],
      chakras: ['Third Eye', 'Throat'],
      colorDescription: 'Gray with iridescent flashes',
      formation: 'Forms in igneous rocks',
      hardness: 6.5,
      healing: [
        'Regulates metabolism',
        'Treats eye and brain disorders',
        'Relieves anxiety and stress',
        'Lowers blood pressure',
        'Aids in digestion',
      ],
      zodiacSigns: ['Leo', 'Scorpio', 'Sagittarius'],
      rarity: 'Common',
      imageAsset: 'assets/images/crystals/labradorite.jpg',
      videoAsset: 'assets/videos/labradorite_transformation.mp4',
      keywords: ['iridescent', 'transformation', 'psychic', 'intuition', 'mystical'],
    ),
    
    CrystalData(
      id: 'malachite',
      name: 'Malachite',
      scientificName: 'Cu₂CO₃(OH)₂',
      description: 'A powerful stone of transformation with vibrant green bands, known for protection and healing.',
      metaphysicalProperties: [
        'Absorbs negative energies',
        'Encourages risk-taking and change',
        'Opens the heart to love',
        'Enhances intuition',
        'Protects during travel',
      ],
      chakras: ['Heart', 'Solar Plexus'],
      colorDescription: 'Bright green with banded patterns',
      formation: 'Secondary mineral in copper deposits',
      hardness: 4.0,
      healing: [
        'Draws out impurities',
        'Supports liver detoxification',
        'Eases menstrual cramps',
        'Strengthens immune system',
        'Reduces inflammation',
      ],
      zodiacSigns: ['Capricorn', 'Scorpio'],
      rarity: 'Moderately common',
      imageAsset: 'assets/images/crystals/malachite.jpg',
      keywords: ['green', 'transformation', 'protection', 'heart', 'healing'],
    ),
    
    CrystalData(
      id: 'lapis_lazuli',
      name: 'Lapis Lazuli',
      scientificName: '(Na,Ca)₈(AlSiO₄)₆(SO₄,S,Cl)₂',
      description: 'The stone of royalty and wisdom, prized for its deep celestial blue with gold flecks of pyrite.',
      metaphysicalProperties: [
        'Enhances intellectual ability',
        'Stimulates wisdom and truth',
        'Opens third eye chakra',
        'Encourages self-expression',
        'Reveals inner truth',
      ],
      chakras: ['Third Eye', 'Throat'],
      colorDescription: 'Deep blue with gold pyrite flecks',
      formation: 'Contact metamorphic rock',
      hardness: 5.5,
      healing: [
        'Boosts immune system',
        'Alleviates insomnia',
        'Relieves migraines',
        'Benefits respiratory system',
        'Reduces inflammation',
      ],
      zodiacSigns: ['Sagittarius', 'Libra'],
      rarity: 'Moderately rare',
      imageAsset: 'assets/images/crystals/lapis_lazuli.jpg',
      keywords: ['blue', 'wisdom', 'truth', 'royalty', 'third eye'],
    ),
    
    CrystalData(
      id: 'obsidian',
      name: 'Black Obsidian',
      scientificName: 'Volcanic Glass (SiO₂ + MgO, Fe₃O₄)',
      description: 'A powerful volcanic glass that provides deep soul healing and protection against negativity.',
      metaphysicalProperties: [
        'Provides psychic protection',
        'Reveals hidden truths',
        'Cuts energetic cords',
        'Grounds spiritual energy',
        'Facilitates past life healing',
      ],
      chakras: ['Root'],
      colorDescription: 'Black, glassy appearance',
      formation: 'Rapidly cooled volcanic lava',
      hardness: 5.5,
      healing: [
        'Aids in digestion',
        'Detoxifies body',
        'Reduces arthritis pain',
        'Improves circulation',
        'Dissolves emotional blockages',
      ],
      zodiacSigns: ['Scorpio', 'Sagittarius'],
      rarity: 'Common',
      imageAsset: 'assets/images/crystals/obsidian.jpg',
      keywords: ['black', 'protection', 'grounding', 'truth', 'healing'],
    ),
  ];

  static List<CrystalData> getAllCrystals() {
    return crystals;
  }

  static CrystalData? getCrystalById(String id) {
    try {
      return crystals.firstWhere((crystal) => crystal.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<CrystalData> searchCrystals(String query) {
    final lowerQuery = query.toLowerCase();
    return crystals.where((crystal) {
      return crystal.name.toLowerCase().contains(lowerQuery) ||
             crystal.keywords.any((keyword) => keyword.toLowerCase().contains(lowerQuery)) ||
             crystal.colorDescription.toLowerCase().contains(lowerQuery) ||
             crystal.chakras.any((chakra) => chakra.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  static List<CrystalData> getCrystalsByChakra(String chakra) {
    return crystals.where((crystal) => crystal.chakras.contains(chakra)).toList();
  }

  static List<CrystalData> getCrystalsByZodiac(String zodiacSign) {
    return crystals.where((crystal) => crystal.zodiacSigns.contains(zodiacSign)).toList();
  }
}