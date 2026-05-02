import 'package:flutter/material.dart';
import '../data/ailments_data.dart';
import '../data/herbs_data.dart';
import '../models/herb.dart';
import '../theme/app_colors.dart';
import 'herb_detail_screen.dart';

class AilmentDetailScreen extends StatelessWidget {
  final String ailmentId;

  const AilmentDetailScreen({
    super.key,
    required this.ailmentId,
  });

  @override
  Widget build(BuildContext context) {
    final ailment = AilmentsData.getAilmentById(ailmentId);

    if (ailment == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ailment Not Found'),
        ),
        body: const Center(
          child: Text('Ailment not found'),
        ),
      );
    }

    final recommendedHerbs = ailment.recommendedHerbIds
        .map(HerbsData.getHerbById)
        .whereType<Herb>()
        .toList();

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
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      ailment.name,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.chart3.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.chart3.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.show_chart,
                            color: AppColors.chart3,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ailment.severity.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.chart3,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildCard(
                      title: 'Description',
                      content: ailment.description,
                    ),
                    const SizedBox(height: 16),
                    _buildListCard(
                      title: 'Common Symptoms',
                      items: ailment.symptoms,
                    ),
                    const SizedBox(height: 16),
                    _buildListCard(
                      title: 'Lifestyle Support',
                      items: ailment.lifestyleTips,
                      isPrimary: true,
                    ),
                    const SizedBox(height: 16),
                    _buildListCard(
                      title: 'When To Seek Medical Care',
                      items: ailment.redFlags,
                      isWarning: true,
                    ),
                    if (recommendedHerbs.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recommended Herbs',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.foreground,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: recommendedHerbs.map((herb) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HerbDetailScreen(
                                          herbId: herb.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.secondary.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: AppColors.border),
                                    ),
                                    child: Text(
                                      herb.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
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
    bool isPrimary = false,
    bool isWarning = false,
  }) {
    final primaryColors = [
      AppColors.primary.withOpacity(0.1),
      AppColors.primary.withOpacity(0.05),
    ];

    final warningColors = [
      const Color(0xFFFFF1F1),
      const Color(0xFFFFFAFA),
    ];

    final defaultColors = [
      AppColors.card,
      AppColors.card.withOpacity(0.4),
    ];

    final cardColors = isWarning
        ? warningColors
        : isPrimary
            ? primaryColors
            : defaultColors;

    final accentColor = isWarning
        ? const Color(0xFFC84B4B)
        : isPrimary
            ? AppColors.primary
            : AppColors.foreground;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: cardColors,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPrimary || isWarning
              ? accentColor.withOpacity(0.2)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          color: accentColor.withOpacity(0.9),
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
