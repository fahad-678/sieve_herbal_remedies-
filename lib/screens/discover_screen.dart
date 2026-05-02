import 'package:flutter/material.dart';
import '../models/herb.dart';
import '../data/herbs_data.dart';
import '../theme/app_colors.dart';
import '../utils/storage.dart';
import 'herb_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _activeTab = 'herbs';
  String _selectedCategory = 'All';
  String _searchQuery = '';
  Set<String> _favoriteHerbs = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await Storage.getFavorites();
    if (mounted) {
      setState(() {
        _favoriteHerbs = favorites;
      });
    }
  }

  Future<void> _toggleFavorite(String herbId) async {
    final newStatus = await Storage.toggleFavorite(herbId);
    if (mounted) {
      setState(() {
        if (newStatus) {
          _favoriteHerbs.add(herbId);
        } else {
          _favoriteHerbs.remove(herbId);
        }
      });
    }
  }

  List<Herb> get _filteredHerbs {
    var herbs = HerbsData.herbs;
    
    if (_selectedCategory != 'All') {
      herbs = herbs.where((h) => h.category == _selectedCategory).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      herbs = HerbsData.searchHerbs(_searchQuery);
    }
    
    return herbs;
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...HerbsData.getAllCategories()];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        border: Border.all(
                          color: AppColors.border,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: AppColors.primary.withOpacity(0.6),
                            size: 20,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search herbs, ailments & preparations...',
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.mutedForeground.withOpacity(0.7),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.foreground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildMainTab('Herbs'),
                          _buildMainTab('Ailments'),
                          _buildMainTab('Preparations'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_activeTab == 'herbs') ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: categories.map((category) {
                            final isSelected = _selectedCategory == category;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.secondary.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary.withOpacity(0.3),
                                              blurRadius: 8,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.mutedForeground,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            _selectedCategory == 'All' ? 'All Herbs' : _selectedCategory,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.foreground,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${_filteredHerbs.length})',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final herb = _filteredHerbs[index];
                      final isFavorite = _favoriteHerbs.contains(herb.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildHerbCard(herb, isFavorite),
                      );
                    },
                    childCount: _filteredHerbs.length,
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTab(String label) {
    final isSelected = _activeTab == label.toLowerCase();
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = label.toLowerCase();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHerbCard(Herb herb, bool isFavorite) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HerbDetailScreen(herbId: herb.id),
          ),
        ).then((_) => _loadFavorites());
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.card,
              AppColors.card.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
                child: Image.asset(
                  herb.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.secondary.withOpacity(0.3),
                      child: const Icon(
                        Icons.local_florist,
                        color: AppColors.muted,
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            herb.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.foreground,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            herb.category,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      herb.scientificName,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.mutedForeground.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      herb.primaryBenefits.isNotEmpty ? herb.primaryBenefits[0] : '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => _toggleFavorite(herb.id),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.accent : AppColors.muted,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
