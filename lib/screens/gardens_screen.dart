import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/garden.dart';
import '../theme/app_colors.dart';
import '../services/places_service.dart';

class GardensScreen extends StatefulWidget {
  const GardensScreen({super.key, this.launchUri});
  final Future<bool> Function(Uri uri)? launchUri;

  @override
  State<GardensScreen> createState() => _GardensScreenState();
}

class _GardensScreenState extends State<GardensScreen> {
  String? _selectedGardenId;
  List<Garden> _gardens = [];
  bool _isLoading = true;
  String? _error;
  
  // We will capture the Autocomplete controller to use for our clear button
  TextEditingController? _searchController;
  String _currentSearchLocation = "Current Location";

  @override
  void initState() {
    super.initState();
    _loadGardens();
  }

  // UPDATED: Now accepts a full LocationSuggestion so we don't have to geocode twice!
  Future<void> _loadGardens({String? searchQuery, LocationSuggestion? suggestion}) async {
    FocusManager.instance.primaryFocus?.unfocus(); 
    
    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _selectedGardenId = null; 
      });
      
      final placesService = PlacesService();
      List<Garden> fetchedGardens;

      if (suggestion != null) {
        // 1. User clicked an autocomplete suggestion (Fastest)
        fetchedGardens = await placesService.fetchNearbyGardens(
          customLat: suggestion.lat, 
          customLng: suggestion.lng
        );
        _currentSearchLocation = suggestion.shortName;
      } else if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        // 2. User just hit Enter without picking a suggestion (Requires geocode)
        final coords = await placesService.getCoordinatesFromQuery(searchQuery);
        fetchedGardens = await placesService.fetchNearbyGardens(
          customLat: coords['lat'], 
          customLng: coords['lng']
        );
        _currentSearchLocation = searchQuery;
      } else {
        // 3. Fetch by device GPS
        fetchedGardens = await placesService.fetchNearbyGardens();
        _currentSearchLocation = "Current Location";
        _searchController?.clear();
      }
      
      setState(() {
        _gardens = fetchedGardens;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<bool> _launchUri(Uri uri) {
    if (widget.launchUri != null) return widget.launchUri!(uri);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openDirections(Garden garden) async {
    // We use the standard Google Maps URL scheme
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${garden.lat},${garden.lng}');

    bool didLaunch = false;
    
    // Attempt to launch the maps URL
    try {
      didLaunch = await _launchUri(uri);
    } catch (e) {
      // Catch any exceptions thrown by url_launcher
      debugPrint('Error launching map: $e');
    }

    if (!mounted) return;

    if (!didLaunch) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open maps on this device.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _selectGarden(String gardenId) => setState(() => _selectedGardenId = gardenId);
  void _clearSelection() => setState(() => _selectedGardenId = null);

  @override
  Widget build(BuildContext context) {
    final selectedGarden = _selectedGardenId != null
        ? _gardens.firstWhere((g) => g.id == _selectedGardenId, orElse: () => _gardens.first)
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // HEADER & SEARCH BAR
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.background,
                      AppColors.background.withValues(alpha: 0),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nearby Herb Gardens',
                      style: TextStyle(
                        fontSize: 32, fontWeight: FontWeight.w600,
                        color: AppColors.primary, height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Showing gardens near: $_currentSearchLocation',
                      style: const TextStyle(fontSize: 14, color: AppColors.mutedForeground),
                    ),
                    const SizedBox(height: 16),
                    // AUTOCOMPLETE SEARCH BAR
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          const Icon(Icons.search, color: AppColors.mutedForeground, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Autocomplete<LocationSuggestion>(
                              optionsBuilder: (TextEditingValue textEditingValue) async {
                                return await PlacesService().fetchCitySuggestions(textEditingValue.text);
                              },
                              displayStringForOption: (LocationSuggestion option) => option.displayName,
                              onSelected: (LocationSuggestion selection) {
                                // Trigger load instantly when an option is tapped
                                _loadGardens(suggestion: selection);
                              },
                              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                // Save reference to controller so our X button works
                                _searchController = controller;
                                
                                return TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  style: const TextStyle(color: AppColors.foreground, fontSize: 15),
                                  decoration: const InputDecoration(
                                    hintText: 'Search city or area...',
                                    hintStyle: TextStyle(color: AppColors.mutedForeground),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  onSubmitted: (value) {
                                    onFieldSubmitted();
                                    _loadGardens(searchQuery: value);
                                  },
                                );
                              },
                              optionsViewBuilder: (context, onSelected, options) {
                                // The floating dropdown list UI
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    elevation: 8.0,
                                    borderRadius: BorderRadius.circular(16),
                                    color: AppColors.card,
                                    clipBehavior: Clip.antiAlias,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: 250, 
                                        maxWidth: MediaQuery.of(context).size.width - 48, // Match search bar width
                                      ),
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        itemCount: options.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          final option = options.elementAt(index);
                                          return InkWell(
                                            onTap: () => onSelected(option),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                                              decoration: BoxDecoration(
                                                border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
                                              ),
                                              child: Text(
                                                option.displayName,
                                                style: const TextStyle(color: AppColors.foreground, fontSize: 14),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Close/Clear button
                          ListenableBuilder(
                            listenable: _searchController ?? ChangeNotifier(),
                            builder: (context, _) {
                              if (_searchController?.text.isNotEmpty == true) {
                                return IconButton(
                                  icon: const Icon(Icons.close, color: AppColors.mutedForeground, size: 20),
                                  onPressed: () => _searchController?.clear(),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          // Go button
                          Container(
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(15)),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
                              onPressed: () => _loadGardens(searchQuery: _searchController?.text),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // THE MAP
            Positioned.fill(
              top: 150, 
              bottom: selectedGarden != null ? 346 : 80,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.4),
                      AppColors.card.withValues(alpha: 0.9),
                      AppColors.primary.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : _error != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 14)),
                              ),
                            )
                          : _gardens.isEmpty
                              ? const Center(
                                  child: Text('No gardens found in this area.', style: TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
                                )
                              : LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Stack(
                                      children: [
                                        CustomPaint(painter: GridPainter(), size: Size.infinite),
                                        ..._gardens.map((garden) => _buildMapMarker(constraints: constraints, garden: garden)),
                                        Positioned(
                                          top: 16,
                                          right: 16,
                                          child: GestureDetector(
                                            onTap: () => _loadGardens(), // Reloads with GPS
                                            child: Container(
                                              width: 48, height: 48,
                                              decoration: BoxDecoration(
                                                color: AppColors.card,
                                                shape: BoxShape.circle,
                                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))],
                                              ),
                                              child: const Icon(Icons.my_location, color: AppColors.primary, size: 22),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                ),
              ),
            ),
            
            // DETAILS CARD
            if (selectedGarden != null)
              Positioned(
                bottom: 80, left: 24, right: 24,
                child: _GardenDetailsCard(
                  garden: selectedGarden,
                  onClose: _clearSelection,
                  onDirectionsTap: () => _openDirections(selectedGarden),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapMarker({required BoxConstraints constraints, required Garden garden}) {
    final markerTop = (constraints.maxHeight * garden.mapTop - 64).clamp(0.0, constraints.maxHeight - 64);
    final markerLeft = (constraints.maxWidth * garden.mapLeft - 24).clamp(0.0, constraints.maxWidth - 48);
    final isSelected = _selectedGardenId == garden.id;

    return Positioned(
      top: markerTop, left: markerLeft,
      child: GestureDetector(
        onTap: () => _selectGarden(garden.id),
        child: Column(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: isSelected ? [AppColors.accent, AppColors.accent] : [AppColors.accent.withValues(alpha: 0.9), AppColors.accent.withValues(alpha: 0.7)],
                ),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.eco, color: Colors.white, size: 24),
            ),
            if (!isSelected)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(garden.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.foreground)),
              ),
          ],
        ),
      ),
    );
  }
}

class _GardenDetailsCard extends StatelessWidget {
  const _GardenDetailsCard({
    required this.garden,
    required this.onClose,
    required this.onDirectionsTap,
  });

  final Garden garden;
  final VoidCallback onClose;
  final VoidCallback onDirectionsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card,
            AppColors.card.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.eco,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.foreground,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            garden.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            garden.description,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.foreground.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '${garden.distanceLabel} away',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              const Text('•', style: TextStyle(color: AppColors.muted)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '${garden.herbVarieties} herb varieties',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.schedule,
                size: 16,
                color: AppColors.mutedForeground,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  garden.hours,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedForeground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.place,
                size: 16,
                color: AppColors.mutedForeground,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  garden.address,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedForeground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDirectionsTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.navigation, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Get Directions',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    const gridSize = 40.0;
    
    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }
    
    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}