import 'package:flutter/material.dart';
import 'package:letmegoo/constants/app_theme.dart';
import 'package:letmegoo/models/shop.dart';
import 'package:letmegoo/widgets/shop_card.dart';
import 'package:letmegoo/services/auth_service.dart';
import 'package:geolocator/geolocator.dart';

class ShopsAndServicesPage extends StatefulWidget {
  final Function(int)? onNavigate;
  final VoidCallback? onAddPressed;
  const ShopsAndServicesPage({super.key, this.onNavigate, this.onAddPressed});

  @override
  State<ShopsAndServicesPage> createState() => _ShopsAndServicesPageState();
}

class _ShopsAndServicesPageState extends State<ShopsAndServicesPage> {
  String _selectedDistance = 'All';
  String? _selectedCategory;
  Position? _currentPosition;

  List<Shop> _allShops = [];
  List<Shop> _filteredShops = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  // Pagination variables
  int _currentOffset = 0;
  int _limit = 20; // Increased from 10
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Get location first, then load shops
    await _getCurrentLocation();
    await _loadShops();
  }

  Future<void> _loadShops({bool loadMore = false}) async {
    try {
      setState(() {
        if (loadMore) {
          _isLoadingMore = true;
        } else {
          _isLoading = true;
          _errorMessage = null;
        }
      });

      final shops = await AuthService.getShopsWithDistance(
        offset: loadMore ? _currentOffset : 0,
        limit: _limit,
        userLatitude: _currentPosition?.latitude,
        userLongitude: _currentPosition?.longitude,
      );

      if (mounted) {
        setState(() {
          if (loadMore) {
            _allShops.addAll(shops);
            _isLoadingMore = false;
          } else {
            _allShops = shops;
            _isLoading = false;
          }

          // Check if we have more data
          _hasMoreData = shops.length == _limit;
          _currentOffset = loadMore ? _currentOffset + _limit : _limit;
        });

        // Apply filters after loading
        _applyFilters();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (loadMore) {
            _isLoadingMore = false;
          } else {
            _isLoading = false;
            _errorMessage = 'Failed to load shops: ${e.toString()}';
          }
        });
      }
    }
  }

  Future<void> _loadMoreShops() async {
    if (!_isLoadingMore && _hasMoreData) {
      await _loadShops(loadMore: true);
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      // Handle location errors
      print('Location error: $e');
    }
  }

  void _applyFilters() {
    List<Shop> filteredList = List.from(
      _allShops.where((shop) => shop.isActive),
    );

    // Apply distance filter
    if (_selectedDistance != 'All') {
      final distanceLimit = int.parse(_selectedDistance.replaceAll(' km', ''));
      filteredList =
          filteredList.where((shop) {
            // If distance is not calculated yet, include the shop
            if (shop.distance == null) return true;
            return shop.distance! <= distanceLimit;
          }).toList();
    }

    // Apply category filter
    if (_selectedCategory != null && _selectedCategory != 'All') {
      filteredList =
          filteredList
              .where((shop) => shop.category == _selectedCategory)
              .toList();
    }

    // Sort by distance (shops without distance go to the end)
    filteredList.sort((a, b) {
      if (a.distance == null && b.distance == null) return 0;
      if (a.distance == null) return 1;
      if (b.distance == null) return -1;
      return a.distance!.compareTo(b.distance!);
    });

    if (mounted) {
      setState(() {
        _filteredShops = filteredList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Shops and Services'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                    : _errorMessage != null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_errorMessage!),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _loadShops(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                    : _filteredShops.isEmpty
                    ? const Center(
                      child: Text("No shops found matching your criteria."),
                    )
                    : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: _filteredShops.length,
                            itemBuilder: (context, index) {
                              return ShopCard(shop: _filteredShops[index]);
                            },
                          ),
                        ),
                        // Load More Button
                        if (_hasMoreData && !_isLoadingMore)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _loadMoreShops,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Load More Shops',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // Loading indicator for "Load More"
                        if (_isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: AppColors.background,
      child: Row(
        children: [
          Expanded(child: _buildDistanceFilter()),
          const SizedBox(width: 16),
          Expanded(child: _buildCategoryFilter()),
        ],
      ),
    );
  }

  Widget _buildDistanceFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedDistance,
      decoration: InputDecoration(
        labelText: 'Distance',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedDistance = newValue;
          });
          _applyFilters();
        }
      },
      items:
          <String>[
            'All',
            '1 km',
            '5 km',
            '10 km',
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      'All',
      ..._allShops.map((shop) => shop.category).toSet().toList(),
    ];
    return DropdownButtonFormField<String>(
      value: _selectedCategory ?? 'All',
      hint: const Text('Category'),
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCategory = (newValue == 'All') ? null : newValue;
        });
        _applyFilters();
      },
      items:
          categories.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
    );
  }
}
