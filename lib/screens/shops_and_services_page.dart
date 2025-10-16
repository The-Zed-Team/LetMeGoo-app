import 'package:flutter/material.dart';
import 'package:letmegoo/constants/app_theme.dart';
import 'package:letmegoo/models/shop.dart';
import 'package:letmegoo/widgets/shop_card.dart';
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

  // Dummy data for shops
  final List<Shop> _shops = [
    Shop(
      name: 'Central Perk',
      description:
          'A cozy coffee shop in the heart of the city, perfect for a chat with friends.',
      address: '123 Main St, Anytown, USA',
      latitude: 34.0522,
      longitude: -118.2437,
      phoneNumber: '555-1234',
      email: 'info@centralperk.com',
      website: 'https://centralperk.com',
      category: 'Coffee Shop',
      operatingHours: 'Mon-Fri: 7am - 7pm',
      isActive: true,
      imageUrl: 'https://i.insider.com/5d8b8d9b2e22af1ee8005b87?width=700',
    ),
    Shop(
      name: 'The Good Place',
      description:
          'Serving up delicious, ethically sourced food for good people.',
      address: '456 Oak Ave, Anytown, USA',
      latitude: 34.0532,
      longitude: -118.2447,
      phoneNumber: '555-5678',
      email: 'hello@thegoodplace.com',
      website: 'https://thegoodplace.com',
      category: 'Restaurant',
      operatingHours: 'Tue-Sun: 11am - 10pm',
      isActive: true,
      imageUrl:
          'https://media-cdn.tripadvisor.com/media/photo-s/1a/00/a3/9b/the-good-place.jpg',
    ),
    Shop(
      name: 'Big Bang Burger',
      description: 'Challenge yourself with the biggest burgers in town!',
      address: '789 Pine St, Anytown, USA',
      latitude: 34.0552,
      longitude: -118.2457,
      phoneNumber: '555-9012',
      email: 'contact@bigbangburger.com',
      website: 'https://bigbangburger.com',
      category: 'Restaurant',
      operatingHours: 'Daily: 10am - 11pm',
      isActive: true,
      imageUrl: 'https://i.redd.it/ng93z4jd92j81.jpg',
    ),
    Shop(
      name: 'Gekkoukan High',
      description: 'A prestigious high school with a mysterious secret.',
      address: '101 School Ln, Anytown, USA',
      latitude: 34.1522,
      longitude: -118.3437,
      phoneNumber: '555-3456',
      email: 'admin@gekkoukan.edu',
      website: 'https://gekkoukan.edu',
      category: 'School',
      operatingHours: 'Mon-Fri: 8am - 4pm',
      isActive: true,
      imageUrl:
          'https://static.wikia.nocookie.net/megamitensei/images/3/3b/P3R_Gekkoukan_High_School_foyer.png/revision/latest?cb=20230823155138',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Handle service not enabled
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle permission denied
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle permission permanently denied
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _updateShopDistances();
        });
      }
    } catch (e) {
      // Handle location errors
    }
  }

  void _updateShopDistances() {
    if (_currentPosition == null) return;
    for (var shop in _shops) {
      shop.distance =
          Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            shop.latitude,
            shop.longitude,
          ) /
          1000; // Convert meters to kilometers
    }
    if (mounted) {
      setState(() {});
    }
  }

  List<Shop> get _filteredShops {
    List<Shop> filteredList = _shops.where((shop) => shop.isActive).toList();

    if (_selectedDistance != 'All') {
      final distance = int.parse(_selectedDistance.replaceAll(' km', ''));
      filteredList =
          filteredList
              .where((shop) => (shop.distance ?? 0) <= distance)
              .toList();
    }

    if (_selectedCategory != null) {
      filteredList =
          filteredList
              .where((shop) => shop.category == _selectedCategory)
              .toList();
    }

    // Sort by distance
    filteredList.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));

    return filteredList;
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
                _currentPosition == null
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                    : _filteredShops.isEmpty
                    ? const Center(
                      child: Text("No shops found matching your criteria."),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: _filteredShops.length,
                      itemBuilder: (context, index) {
                        return ShopCard(shop: _filteredShops[index]);
                      },
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
      ..._shops.map((shop) => shop.category).toSet().toList(),
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
      },
      items:
          categories.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
    );
  }
}
