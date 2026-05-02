import 'package:flutter/material.dart';
import '../data/herbs_data.dart';
import '../theme/app_colors.dart';
import '../utils/storage.dart';

class HerbDetailScreen extends StatefulWidget {
  final String herbId;

  const HerbDetailScreen({super.key, required this.herbId});

  @override
  State<HerbDetailScreen> createState() => _HerbDetailScreenState();
}

class _HerbDetailScreenState extends State<HerbDetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final isFav = await Storage.isFavorite(widget.herbId);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final newStatus = await Storage.toggleFavorite(widget.herbId);
    if (mounted) {
      setState(() {
        _isFavorite = newStatus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final herb = HerbsData.getHerbById(widget.herbId);

    if (herb == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Herb Not Found'),
        ),
        body: const Center(
          child: Text('Herb not found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    herb.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.secondary,
                      child: const Icon(
                        Icons.local_florist,
                        size: 64,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          herb.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          herb.scientificName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(
                    title: 'About',
                    content: herb.detailedInformation,
                  ),
                  const SizedBox(height: 16),
                  _buildListCard(
                    title: 'Primary Benefits',
                    items: herb.primaryBenefits,
                    icon: Icons.check_circle_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'How to Use',
                    content: herb.howToUse,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Dosage',
                    content: herb.dosage,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Best Time to Take',
                    content: herb.bestTimeToTake,
                  ),
                  const SizedBox(height: 16),
                  _buildListCard(
                    title: 'Active Compounds',
                    items: herb.activeCompounds,
                    icon: Icons.science_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildListCard(
                    title: 'Contraindications',
                    items: [herb.contraindications],
                    icon: Icons.warning_amber_outlined,
                    isWarning: true,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Side Effects',
                    content: herb.sideEffects,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Drug Interactions',
                    content: herb.drugInteractions,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Pregnancy Warning',
                    content: herb.pregnancyWarning,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Storage',
                    content: herb.storage,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.foreground.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard({
    required String title,
    required List<String> items,
    required IconData icon,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWarning ? const Color(0xFFFEF2F2) : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWarning ? const Color(0xFFFEE2E2) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isWarning)
                const Icon(
                  Icons.warning_amber,
                  color: Color(0xFFDC2626),
                  size: 20,
                ),
              if (isWarning) const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isWarning ? const Color(0xFFDC2626) : AppColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: isWarning ? const Color(0xFFDC2626) : AppColors.accent,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          color: isWarning
                              ? const Color(0xFFDC2626)
                              : AppColors.foreground.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
