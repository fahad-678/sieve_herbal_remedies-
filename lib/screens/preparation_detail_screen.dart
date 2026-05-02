import 'dart:async';
import 'package:flutter/material.dart';
import '../data/preparations_data.dart';
import '../theme/app_colors.dart';

class PreparationDetailScreen extends StatefulWidget {
  final String preparationId;

  const PreparationDetailScreen({
    super.key,
    required this.preparationId,
  });

  @override
  State<PreparationDetailScreen> createState() => _PreparationDetailScreenState();
}

class _PreparationDetailScreenState extends State<PreparationDetailScreen> {
  int _timeLeft = 0;
  bool _isRunning = false;
  Timer? _timer;
  int _totalTime = 0;

  @override
  void initState() {
    super.initState();
    final prep = PreparationsData.getPreparationById(widget.preparationId);
    if (prep != null) {
      _totalTime = prep.timeInSeconds;
      _timeLeft = prep.timeInSeconds;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
        });
      }
    });
  }

  void _toggleTimer() {
    if (_timeLeft == 0) return;
    
    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = _totalTime;
      _isRunning = false;
    });
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString()}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final prep = PreparationsData.getPreparationById(widget.preparationId);

    if (prep == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Preparation Not Found'),
        ),
        body: const Center(
          child: Text('Preparation method not found'),
        ),
      );
    }

    final progress = _totalTime > 0 ? ((_totalTime - _timeLeft) / _totalTime) : 0.0;

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
                      prep.name,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Traditional preparation method',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
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
                      child: Text(
                        prep.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.foreground.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Best For',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: prep.bestFor.map((use) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.15),
                            ),
                          ),
                          child: Text(
                            use,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (_totalTime > 0) ...[
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.card,
                              AppColors.card.withOpacity(0.4),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.1),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.timer,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Preparation Timer',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.foreground,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: 224,
                              height: 224,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 224,
                                    height: 224,
                                    child: CircularProgressIndicator(
                                      value: progress,
                                      strokeWidth: 10,
                                      backgroundColor: AppColors.secondary.withOpacity(0.2),
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                        AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _formatTime(_timeLeft),
                                        style: const TextStyle(
                                          fontSize: 56,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.foreground,
                                          height: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _timeLeft == _totalTime
                                            ? 'Ready to begin'
                                            : _isRunning
                                                ? 'Steeping now...'
                                                : 'Paused',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.mutedForeground,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: _resetTimer,
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withOpacity(0.4),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.border.withOpacity(0.5),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.refresh,
                                      color: AppColors.foreground,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: _toggleTimer,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.accent,
                                          AppColors.accent.withOpacity(0.9),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.accent.withOpacity(0.3),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _isRunning ? Icons.pause : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const SizedBox(width: 56),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      'Step-by-Step Instructions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
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
                        children: List.generate(prep.steps.length, (index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index < prep.steps.length - 1 ? 20 : 0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      prep.steps[index],
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: AppColors.foreground.withOpacity(0.85),
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.primary.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Pro Tips',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...prep.tips.map((tip) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.coffee,
                                      color: AppColors.primary.withOpacity(0.7),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.primary.withOpacity(0.9),
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
