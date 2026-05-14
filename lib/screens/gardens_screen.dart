import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/gardens_data.dart';
import '../models/garden.dart';
import '../theme/app_colors.dart';

class GardensScreen extends StatefulWidget {
  const GardensScreen({
    super.key,
    this.launchUri,
  });

  final Future<bool> Function(Uri uri)? launchUri;

  @override
  State<GardensScreen> createState() => _GardensScreenState();
}

class _GardensScreenState extends State<GardensScreen> {
  int? _selectedGardenId;

  List<Garden> get _gardens => GardensData.gardens;

  Future<bool> _launchUri(Uri uri) {
    if (widget.launchUri != null) {
      return widget.launchUri!(uri);
    }
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openDirections(Garden garden) async {
    final encodedQuery = Uri.encodeComponent(garden.address);
    final candidates = [
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedQuery'),
      Uri.parse('geo:0,0?q=$encodedQuery'),
    ];

    bool didLaunch = false;
    for (final uri in candidates) {
      didLaunch = await _launchUri(uri);
      if (didLaunch) {
        break;
      }
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

  void _selectGarden(int gardenId) {
    setState(() {
      _selectedGardenId = gardenId;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedGardenId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedGarden =
        _selectedGardenId != null ? GardensData.getById(_selectedGardenId!) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
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
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nearby Herb Gardens',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Discover local botanical spaces',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              top: 96,
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
                  child: _gardens.isEmpty
                      ? const Center(
                          child: Text(
                            'No gardens available yet.',
                            style: TextStyle(
                              color: AppColors.mutedForeground,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: [
                                CustomPaint(
                                  painter: GridPainter(),
                                  size: Size.infinite,
                                ),
                                ..._gardens.map(
                                  (garden) => _buildMapMarker(
                                    constraints: constraints,
                                    garden: garden,
                                  ),
                                ),
                                Positioned(
                                  top: 24,
                                  right: 24,
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.accent,
                                          AppColors.accent.withValues(alpha: 0.9),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.accent.withValues(alpha: 0.3),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.my_location,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 24,
                                  left: 24,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.background.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.border.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: const Text(
                                      'Interactive Map View',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.mutedForeground,
                                        letterSpacing: 0.5,
                                      ),
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
            if (selectedGarden != null)
              Positioned(
                bottom: 80,
                left: 24,
                right: 24,
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

  Widget _buildMapMarker({
    required BoxConstraints constraints,
    required Garden garden,
  }) {
    final markerTop =
        (constraints.maxHeight * garden.mapTop - 64).clamp(0.0, constraints.maxHeight - 64);
    final markerLeft =
        (constraints.maxWidth * garden.mapLeft - 24).clamp(0.0, constraints.maxWidth - 48);

    final isSelected = _selectedGardenId == garden.id;

    return Positioned(
      top: markerTop,
      left: markerLeft,
      child: GestureDetector(
        onTap: () => _selectGarden(garden.id),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? [AppColors.accent, AppColors.accent]
                      : [
                          AppColors.accent.withValues(alpha: 0.9),
                          AppColors.accent.withValues(alpha: 0.7),
                        ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.eco,
                color: Colors.white,
                size: 24,
              ),
            ),
            if (!isSelected)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  garden.name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.foreground,
                  ),
                ),
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
