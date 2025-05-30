import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class CrystalMarketplace extends StatefulWidget {
  const CrystalMarketplace({Key? key}) : super(key: key);

  @override
  _CrystalMarketplaceState createState() => _CrystalMarketplaceState();
}

class _CrystalMarketplaceState extends State<CrystalMarketplace>
    with TickerProviderStateMixin {
  // Controllers
  late TabController _tabController;
  late AnimationController _animationController;
  late AnimationController _filterAnimationController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // State variables
  String selectedCategory = 'All';
  String selectedVendor = 'All Vendors';
  String sortBy = 'Popular';
  bool showFilters = false;
  bool isGridView = true;
  double minPrice = 0;
  double maxPrice = 1000;
  double currentMinPrice = 0;
  double currentMaxPrice = 1000;
  
  // Selected items for comparison
  Set<String> comparisonItems = {};
  Set<String> wishlistItems = {};
  Set<String> favoriteItems = {};

  // Categories
  final List<String> categories = [
    'All',
    'Raw Stones',
    'Tumbled',
    'Clusters',
    'Geodes',
    'Jewelry',
    'Spheres',
    'Points',
    'Rare Specimens',
  ];

  // Sample marketplace data
  final List<Map<String, dynamic>> marketplaceItems = [
    {
      'id': '1',
      'name': 'Amethyst Cluster',
      'vendor': 'Crystal Haven',
      'vendorRating': 4.8,
      'price': 89.99,
      'originalPrice': 120.00,
      'category': 'Clusters',
      'image': '💜',
      'rating': 4.7,
      'reviews': 234,
      'authenticated': true,
      'inStock': true,
      'description': 'Beautiful deep purple amethyst cluster from Brazil',
      'weight': '450g',
      'dimensions': '12x8x6 cm',
      'origin': 'Brazil',
      'chakra': 'Crown',
      'arEnabled': true,
    },
    {
      'id': '2',
      'name': 'Rose Quartz Sphere',
      'vendor': 'Mystic Minerals',
      'vendorRating': 4.9,
      'price': 65.00,
      'category': 'Spheres',
      'image': '💗',
      'rating': 4.9,
      'reviews': 156,
      'authenticated': true,
      'inStock': true,
      'description': 'Premium grade rose quartz sphere with excellent clarity',
      'weight': '320g',
      'dimensions': '7cm diameter',
      'origin': 'Madagascar',
      'chakra': 'Heart',
      'arEnabled': true,
    },
    {
      'id': '3',
      'name': 'Black Tourmaline Points',
      'vendor': 'Earth Elements',
      'vendorRating': 4.6,
      'price': 35.50,
      'originalPrice': 45.00,
      'category': 'Points',
      'image': '⚫',
      'rating': 4.8,
      'reviews': 89,
      'authenticated': true,
      'inStock': true,
      'description': 'Set of 3 protective black tourmaline points',
      'weight': '150g total',
      'dimensions': '5-7cm each',
      'origin': 'Pakistan',
      'chakra': 'Root',
      'arEnabled': false,
    },
    {
      'id': '4',
      'name': 'Labradorite Pendant',
      'vendor': 'Crystal Haven',
      'vendorRating': 4.8,
      'price': 125.00,
      'category': 'Jewelry',
      'image': '🔷',
      'rating': 5.0,
      'reviews': 67,
      'authenticated': true,
      'inStock': true,
      'description': 'Sterling silver wrapped labradorite with blue flash',
      'weight': '25g',
      'dimensions': '3x2cm stone',
      'origin': 'Canada',
      'chakra': 'Third Eye',
      'arEnabled': true,
    },
    {
      'id': '5',
      'name': 'Clear Quartz Generator',
      'vendor': 'Mystic Minerals',
      'vendorRating': 4.9,
      'price': 156.00,
      'category': 'Points',
      'image': '💎',
      'rating': 4.6,
      'reviews': 112,
      'authenticated': true,
      'inStock': false,
      'description': 'Large clear quartz generator point with phantoms',
      'weight': '680g',
      'dimensions': '15x6cm',
      'origin': 'Arkansas, USA',
      'chakra': 'Crown',
      'arEnabled': true,
    },
  ];

  // Nearby crystal shops
  final List<Map<String, dynamic>> nearbyShops = [
    {
      'name': 'Crystal Dreams',
      'distance': '0.8 mi',
      'rating': 4.7,
      'address': '123 Main St',
      'hours': 'Open until 8 PM',
      'phone': '(555) 123-4567',
    },
    {
      'name': 'Earth\'s Treasures',
      'distance': '1.2 mi',
      'rating': 4.9,
      'address': '456 Oak Ave',
      'hours': 'Open until 7 PM',
      'phone': '(555) 234-5678',
    },
    {
      'name': 'Mystic Stone Gallery',
      'distance': '2.5 mi',
      'rating': 4.5,
      'address': '789 Crystal Blvd',
      'hours': 'Open until 6 PM',
      'phone': '(555) 345-6789',
    },
  ];

  // Trade offers
  final List<Map<String, dynamic>> tradeOffers = [
    {
      'id': '1',
      'offering': 'Citrine Cluster',
      'seeking': 'Moldavite or Labradorite',
      'user': 'CrystalCollector92',
      'userRating': 4.8,
      'location': 'New York, NY',
      'image': '🟡',
    },
    {
      'id': '2',
      'offering': 'Set of Tumbled Stones',
      'seeking': 'Raw Amethyst',
      'user': 'GeologyFan',
      'userRating': 4.6,
      'location': 'Los Angeles, CA',
      'image': '🔮',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _filterAnimationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBrowseTab(),
                  _buildCompareTab(),
                  _buildLocalShopsTab(),
                  _buildTradeTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Crystal Marketplace',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          _buildHeaderActions(),
        ],
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      children: [
        _buildIconButton(
          Icons.favorite_outline,
          wishlistItems.isNotEmpty ? Colors.red : Colors.white,
          () => _showWishlist(),
          badge: wishlistItems.isNotEmpty ? wishlistItems.length.toString() : null,
        ),
        const SizedBox(width: 12),
        _buildIconButton(
          Icons.shopping_cart_outlined,
          Colors.white,
          () => _showCart(),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onTap, {String? badge}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          if (badge != null)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white54),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search crystals, vendors, or properties...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          IconButton(
            icon: Icon(
              showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: Colors.white54,
            ),
            onPressed: () {
              setState(() => showFilters = !showFilters);
              if (showFilters) {
                _filterAnimationController.forward();
              } else {
                _filterAnimationController.reverse();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.purpleAccent,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        tabs: const [
          Tab(text: 'Browse'),
          Tab(text: 'Compare'),
          Tab(text: 'Local Shops'),
          Tab(text: 'Trade'),
        ],
      ),
    );
  }

  Widget _buildBrowseTab() {
    return Column(
      children: [
        if (showFilters) _buildFilters(),
        _buildCategoryFilter(),
        _buildSortAndViewOptions(),
        Expanded(
          child: isGridView ? _buildGridView() : _buildListView(),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return AnimatedBuilder(
      animation: _filterAnimationController,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _filterAnimationController,
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white.withOpacity(0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPriceRangeFilter(),
                const SizedBox(height: 16),
                _buildVendorFilter(),
                const SizedBox(height: 16),
                _buildAuthenticationFilter(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Range',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: RangeValues(currentMinPrice, currentMaxPrice),
          min: minPrice,
          max: maxPrice,
          divisions: 20,
          activeColor: Colors.purpleAccent,
          inactiveColor: Colors.white24,
          labels: RangeLabels(
            '\$${currentMinPrice.toStringAsFixed(0)}',
            '\$${currentMaxPrice.toStringAsFixed(0)}',
          ),
          onChanged: (RangeValues values) {
            setState(() {
              currentMinPrice = values.start;
              currentMaxPrice = values.end;
            });
          },
        ),
      ],
    );
  }

  Widget _buildVendorFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vendor',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: selectedVendor,
            dropdownColor: const Color(0xFF1C2333),
            isExpanded: true,
            underline: const SizedBox(),
            style: const TextStyle(color: Colors.white),
            items: ['All Vendors', 'Crystal Haven', 'Mystic Minerals', 'Earth Elements']
                .map((vendor) => DropdownMenuItem(
                      value: vendor,
                      child: Text(vendor),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() => selectedVendor = value!);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAuthenticationFilter() {
    return Row(
      children: [
        Checkbox(
          value: true,
          activeColor: Colors.purpleAccent,
          onChanged: (value) {},
        ),
        const Text(
          'Show only authenticated crystals',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.purpleAccent
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortAndViewOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                'Sort by: ',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              DropdownButton<String>(
                value: sortBy,
                dropdownColor: const Color(0xFF1C2333),
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                items: ['Popular', 'Price: Low to High', 'Price: High to Low', 'Newest']
                    .map((sort) => DropdownMenuItem(
                          value: sort,
                          child: Text(sort),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => sortBy = value!);
                },
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.grid_view,
                  color: isGridView ? Colors.purpleAccent : Colors.white54,
                ),
                onPressed: () => setState(() => isGridView = true),
              ),
              IconButton(
                icon: Icon(
                  Icons.list,
                  color: !isGridView ? Colors.purpleAccent : Colors.white54,
                ),
                onPressed: () => setState(() => isGridView = false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    final filteredItems = _getFilteredItems();
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        return _buildProductCard(filteredItems[index]);
      },
    );
  }

  Widget _buildListView() {
    final filteredItems = _getFilteredItems();
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        return _buildProductListItem(filteredItems[index]);
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredItems() {
    return marketplaceItems.where((item) {
      if (selectedCategory != 'All' && item['category'] != selectedCategory) {
        return false;
      }
      if (selectedVendor != 'All Vendors' && item['vendor'] != selectedVendor) {
        return false;
      }
      if (item['price'] < currentMinPrice || item['price'] > currentMaxPrice) {
        return false;
      }
      if (_searchController.text.isNotEmpty) {
        final searchTerm = _searchController.text.toLowerCase();
        return item['name'].toLowerCase().contains(searchTerm) ||
            item['vendor'].toLowerCase().contains(searchTerm) ||
            item['description'].toLowerCase().contains(searchTerm);
      }
      return true;
    }).toList();
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    final bool isInWishlist = wishlistItems.contains(item['id']);
    final bool isInComparison = comparisonItems.contains(item['id']);
    
    return GestureDetector(
      onTap: () => _showProductDetails(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isInComparison
                ? Colors.purpleAccent
                : Colors.white.withOpacity(0.1),
            width: isInComparison ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and badges
            Stack(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item['image'],
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
                if (item['originalPrice'] != null)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${((1 - item['price'] / item['originalPrice']) * 100).toInt()}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Row(
                    children: [
                      if (item['authenticated'])
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isInWishlist) {
                              wishlistItems.remove(item['id']);
                            } else {
                              wishlistItems.add(item['id']);
                            }
                          });
                          HapticFeedback.lightImpact();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isInWishlist
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isInWishlist ? Colors.red : Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (item['arEnabled'])
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.view_in_ar,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'AR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Product info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['vendor'],
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item['rating'].toString(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${item['reviews']})',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item['originalPrice'] != null)
                          Text(
                            '\$${item['originalPrice'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          '\$${item['price'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Action buttons
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (comparisonItems.contains(item['id'])) {
                            comparisonItems.remove(item['id']);
                          } else {
                            if (comparisonItems.length < 3) {
                              comparisonItems.add(item['id']);
                            } else {
                              _showMessage('Maximum 3 items for comparison');
                            }
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Icon(
                          Icons.compare_arrows,
                          color: isInComparison
                              ? Colors.purpleAccent
                              : Colors.white54,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 20,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _addToCart(item),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Icon(
                          Icons.add_shopping_cart,
                          color: Colors.white54,
                          size: 20,
                        ),
                      ),
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

  Widget _buildProductListItem(Map<String, dynamic> item) {
    final bool isInWishlist = wishlistItems.contains(item['id']);
    
    return GestureDetector(
      onTap: () => _showProductDetails(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  item['image'],
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (item['authenticated'])
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['vendor'],
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item['rating']} (${item['reviews']})',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (item['arEnabled'])
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.view_in_ar,
                                color: Colors.purple,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'AR',
                                style: TextStyle(
                                  color: Colors.purple,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item['originalPrice'] != null)
                            Text(
                              '\$${item['originalPrice'].toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            '\$${item['price'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isInWishlist
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isInWishlist ? Colors.red : Colors.white54,
                            ),
                            onPressed: () {
                              setState(() {
                                if (isInWishlist) {
                                  wishlistItems.remove(item['id']);
                                } else {
                                  wishlistItems.add(item['id']);
                                }
                              });
                              HapticFeedback.lightImpact();
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_shopping_cart,
                              color: Colors.white54,
                            ),
                            onPressed: () => _addToCart(item),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompareTab() {
    if (comparisonItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.compare_arrows,
              size: 64,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            Text(
              'No items selected for comparison',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select up to 3 items from the browse tab',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final compareItems = marketplaceItems
        .where((item) => comparisonItems.contains(item['id']))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header row with images
          Row(
            children: compareItems.map((item) {
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          item['image'],
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          comparisonItems.remove(item['id']);
                        });
                      },
                      child: Text(
                        'Remove',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // Comparison attributes
          _buildComparisonRow('Price', (item) => '\$${item['price']}'),
          _buildComparisonRow('Vendor', (item) => item['vendor']),
          _buildComparisonRow('Rating', (item) => '${item['rating']} ⭐'),
          _buildComparisonRow('Reviews', (item) => '${item['reviews']}'),
          _buildComparisonRow('Weight', (item) => item['weight']),
          _buildComparisonRow('Origin', (item) => item['origin']),
          _buildComparisonRow('Chakra', (item) => item['chakra']),
          _buildComparisonRow('AR Preview', (item) => item['arEnabled'] ? '✓' : '✗'),
          _buildComparisonRow('In Stock', (item) => item['inStock'] ? '✓' : '✗'),
          _buildComparisonRow('Authenticated', (item) => item['authenticated'] ? '✓' : '✗'),
          const SizedBox(height: 24),
          // Action buttons
          Row(
            children: compareItems.map((item) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    onPressed: () => _addToCart(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Add to Cart'),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String attribute, String Function(Map<String, dynamic>) getValue) {
    final compareItems = marketplaceItems
        .where((item) => comparisonItems.contains(item['id']))
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              attribute,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          ...compareItems.map((item) {
            return Expanded(
              flex: 2,
              child: Text(
                getValue(item),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLocalShopsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        size: 48,
                        color: Colors.white24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Interactive Map',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.my_location,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Use My Location',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nearby Crystal Shops',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...nearbyShops.map((shop) => _buildShopCard(shop)).toList(),
        ],
      ),
    );
  }

  Widget _buildShopCard(Map<String, dynamic> shop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.white54,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          shop['distance'],
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          shop['rating'].toString(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  shop['hours'],
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            shop['address'],
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.directions, size: 16),
                  label: const Text('Directions'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white24),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTradeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create trade offer button
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _createTradeOffer,
              icon: const Icon(Icons.add),
              label: const Text('Create Trade Offer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Filter chips
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip('All Trades', true),
              _buildFilterChip('Looking for Amethyst', false),
              _buildFilterChip('Looking for Quartz', false),
              _buildFilterChip('Near Me', false),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Active Trade Offers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...tradeOffers.map((offer) => _buildTradeCard(offer)).toList(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {},
      selectedColor: Colors.purpleAccent,
      backgroundColor: Colors.white.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
      ),
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildTradeCard(Map<String, dynamic> offer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.purpleAccent,
                child: Text(
                  offer['user'][0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer['user'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          offer['userRating'].toString(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.location_on,
                          color: Colors.white54,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          offer['location'],
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offering',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          offer['image'],
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            offer['offering'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.swap_horiz,
                color: Colors.white54,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Seeking',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer['seeking'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Message'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Make Offer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    if (comparisonItems.isNotEmpty) {
      return FloatingActionButton.extended(
        onPressed: () {
          _tabController.animateTo(1);
        },
        backgroundColor: Colors.purpleAccent,
        icon: const Icon(Icons.compare_arrows),
        label: Text('Compare (${comparisonItems.length})'),
      );
    }
    return const SizedBox.shrink();
  }

  void _showProductDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductDetailsSheet(
        item: item,
        onAddToCart: () => _addToCart(item),
        onToggleWishlist: () {
          setState(() {
            if (wishlistItems.contains(item['id'])) {
              wishlistItems.remove(item['id']);
            } else {
              wishlistItems.add(item['id']);
            }
          });
        },
        isInWishlist: wishlistItems.contains(item['id']),
      ),
    );
  }

  void _showWishlist() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C2333),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wishlist',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: wishlistItems.length,
                itemBuilder: (context, index) {
                  final itemId = wishlistItems.elementAt(index);
                  final item = marketplaceItems.firstWhere(
                    (i) => i['id'] == itemId,
                  );
                  return _buildProductListItem(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCart() {
    _showMessage('Cart functionality would be implemented here');
  }

  void _addToCart(Map<String, dynamic> item) {
    HapticFeedback.mediumImpact();
    _showMessage('${item['name']} added to cart');
  }

  void _createTradeOffer() {
    _showMessage('Trade offer creation would be implemented here');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.purpleAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// Product Details Sheet
class _ProductDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onAddToCart;
  final VoidCallback onToggleWishlist;
  final bool isInWishlist;

  const _ProductDetailsSheet({
    Key? key,
    required this.item,
    required this.onAddToCart,
    required this.onToggleWishlist,
    required this.isInWishlist,
  }) : super(key: key);

  @override
  __ProductDetailsSheetState createState() => __ProductDetailsSheetState();
}

class __ProductDetailsSheetState extends State<_ProductDetailsSheet> {
  int selectedImageIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFF1C2333),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image gallery
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            widget.item['image'],
                            style: const TextStyle(fontSize: 100),
                          ),
                        ),
                        if (widget.item['arEnabled'])
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.view_in_ar),
                              label: const Text('View in AR'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                              ),
                            ),
                          ),
                        if (widget.item['authenticated'])
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.verified,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Authenticated',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.item['rating']} (${widget.item['reviews']} reviews)',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (widget.item['originalPrice'] != null)
                            Text(
                              '\$${widget.item['originalPrice'].toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            '\$${widget.item['price'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Vendor info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.purpleAccent,
                          child: Text(
                            widget.item['vendor'][0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.item['vendor'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.item['vendorRating']} Seller Rating',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View Shop'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.purpleAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item['description'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Specifications
                  const Text(
                    'Specifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSpecRow('Weight', widget.item['weight']),
                  _buildSpecRow('Dimensions', widget.item['dimensions']),
                  _buildSpecRow('Origin', widget.item['origin']),
                  _buildSpecRow('Chakra', widget.item['chakra']),
                  const SizedBox(height: 24),
                  // Crystal care guide
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Crystal Care Guide',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• Clean with soft cloth and mild soap\n'
                          '• Avoid direct sunlight for extended periods\n'
                          '• Recharge under moonlight monthly\n'
                          '• Store separately to prevent scratching',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Digital certificate
                  if (widget.item['authenticated'])
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.withOpacity(0.2),
                            Colors.blue.withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.purpleAccent.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.qr_code,
                            color: Colors.purpleAccent,
                            size: 48,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Digital Certificate',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'This crystal comes with a blockchain-verified certificate of authenticity',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Bottom action bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E21),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onToggleWishlist,
                  icon: Icon(
                    widget.isInWishlist
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.isInWishlist ? Colors.red : Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.item['inStock'] ? widget.onAddToCart : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.item['inStock'] ? 'Add to Cart' : 'Out of Stock',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}