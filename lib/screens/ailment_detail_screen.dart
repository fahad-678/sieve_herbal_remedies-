import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AilmentDetailScreen extends StatelessWidget {
  const AilmentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    const Text(
                      'Tension Headache',
                      style: TextStyle(
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
                          Icon(
                            Icons.show_chart,
                            color: AppColors.chart3,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'MODERATE',
                            style: TextStyle(
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
                      content: 'Tension headaches are the most common type of headache, characterized by a dull, aching pain and tightness across the forehead, temples, or back of the head and neck.',
                    ),
                    const SizedBox(height: 16),
                    _buildListCard(
                      title: 'Common Symptoms',
                      items: [
                        'Dull, aching head pain on both sides',
                        'Tight band-like pressure around the forehead',
                        'Tenderness in scalp, neck, and shoulder muscles',
                        'Mild to moderate pain (not throbbing)',
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildListCard(
                      title: 'Lifestyle Support',
                      items: [
                        'Practice regular stress-reduction techniques',
                        'Maintain good posture throughout the day',
                        'Stay hydrated and eat balanced meals',
                        'Take regular breaks from screens',
                      ],
                      isPrimary: true,
                    ),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPrimary
              ? [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ]
              : [
                  AppColors.card,
                  AppColors.card.withOpacity(0.4),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPrimary ? AppColors.primary.withOpacity(0.2) : AppColors.border,
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
          Row(
            children: [
              if (isPrimary)
                Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 20,
                ),
              if (isPrimary) const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? AppColors.primary : AppColors.foreground,
                ),
              ),
            ],
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
                        color: isPrimary ? AppColors.primary : AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          color: isPrimary
                              ? AppColors.primary.withOpacity(0.9)
                              : AppColors.foreground.withOpacity(0.85),
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
