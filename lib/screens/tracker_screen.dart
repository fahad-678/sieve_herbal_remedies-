import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/ailments_data.dart';
import '../data/herbs_data.dart';
import '../models/ailment.dart';
import '../models/herb.dart';
import '../theme/app_colors.dart';
import '../utils/storage.dart';
import '../widgets/optimized_herb_image.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  bool _isLoading = true;
  List<_TrackerLog> _logs = [];

  String _selectedCategory = 'All';
  String _selectedAilmentId = 'All';

  late List<String> _categoryOptions;
  late List<Ailment> _ailments;

  @override
  void initState() {
    super.initState();
    _initializeFilters();
    _loadLogs();
  }

  void _initializeFilters() {
    _categoryOptions = ['All', ...HerbsData.getAllCategories()];
    _ailments = AilmentsData.ailments;
  }

  Future<void> _loadLogs() async {
    final rawLogs = await Storage.getTrackerLogs();
    final parsed = rawLogs.map(_TrackerLog.fromStorage).toList();
    parsed.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (!mounted) return;

    setState(() {
      _logs = parsed;
      _isLoading = false;
    });
  }

  Future<void> _addLog() async {
    final selectedHerb = await _showHerbSelectionDialog();
    if (selectedHerb == null || !mounted) return;

    final dosageController = TextEditingController();
    final notesController = TextEditingController();
    String? selectedAilmentId;

    final log = await showDialog<_TrackerLog>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              title: const Text('Add Remedy Log'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: OptimizedHerbImage(
                              herb: selectedHerb,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(8),
                              showPlaceholder: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedHerb.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.foreground,
                                  ),
                                ),
                                if (selectedHerb.primaryBenefits.isNotEmpty)
                                  Text(
                                    selectedHerb.primaryBenefits.first,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String?>(
                      initialValue: selectedAilmentId,
                      decoration: const InputDecoration(
                        labelText: 'Ailment (optional)',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('None'),
                        ),
                        ..._ailments.map(
                          (ailment) => DropdownMenuItem<String?>(
                            value: ailment.id,
                            child: Text(ailment.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedAilmentId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: dosageController,
                      decoration: const InputDecoration(
                        labelText: 'Dosage (optional)',
                        hintText: 'Example: 1 cup (240ml)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        hintText: 'How you felt, timing, etc.',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final ailmentName = selectedAilmentId == null
                        ? null
                        : AilmentsData.getAilmentById(selectedAilmentId!)?.name;

                    Navigator.pop(
                      dialogContext,
                      _TrackerLog(
                        herbId: selectedHerb.id,
                        herbName: selectedHerb.name,
                        category: selectedHerb.category,
                        primaryBenefit: selectedHerb.primaryBenefits.isNotEmpty
                            ? selectedHerb.primaryBenefits.first
                            : '',
                        dosage: dosageController.text.trim(),
                        notes: notesController.text.trim(),
                        timestamp: DateTime.now(),
                        nextIntakeAt:
                            DateTime.now().add(const Duration(days: 1)),
                        ailmentId: selectedAilmentId,
                        ailmentName: ailmentName,
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (log == null) return;

    await Storage.addTrackerLog(log.toStorage());
    await _loadLogs();
  }

  Future<void> _deleteLog(_TrackerLog log) async {
    final index = _logs.indexWhere((item) => item.storageKey == log.storageKey);
    if (index < 0) return;

    await Storage.deleteTrackerLog(index);
    await _loadLogs();
  }

  Future<void> _confirmClearAll() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear all logs?'),
          content:
              const Text('This will permanently remove every tracker entry.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Clear',
                style: TextStyle(color: AppColors.destructive),
              ),
            ),
          ],
        );
      },
    );

    if (shouldClear != true) return;

    await Storage.clearAllTrackerLogs();
    await _loadLogs();
  }

  int get _todayCount {
    final now = DateTime.now();
    return _logs.where((log) {
      return log.timestamp.year == now.year &&
          log.timestamp.month == now.month &&
          log.timestamp.day == now.day;
    }).length;
  }

  int get _weekCount {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _logs.where((log) => log.timestamp.isAfter(weekAgo)).length;
  }

  int get _monthCount {
    final now = DateTime.now();
    return _logs.where((log) {
      return log.timestamp.year == now.year && log.timestamp.month == now.month;
    }).length;
  }

  List<_TrackerLog> get _filteredLogs {
    return _logs.where((log) {
      final categoryMatch =
          _selectedCategory == 'All' || log.category == _selectedCategory;
      final ailmentMatch =
          _selectedAilmentId == 'All' || log.ailmentId == _selectedAilmentId;
      return categoryMatch && ailmentMatch;
    }).toList();
  }

  Future<Herb?> _showHerbSelectionDialog() async {
    final allHerbs = HerbsData.herbs;
    Herb? selectedHerb;
    String searchQuery = '';

    return showDialog<Herb?>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filtered = searchQuery.trim().isEmpty
                ? allHerbs
                : allHerbs.where((herb) {
                    final q = searchQuery.toLowerCase();
                    return herb.name.toLowerCase().contains(q) ||
                        herb.category.toLowerCase().contains(q) ||
                        herb.primaryBenefits.any(
                            (benefit) => benefit.toLowerCase().contains(q));
                  }).toList();

            return AlertDialog(
              backgroundColor: AppColors.card,
              title: const Text('Select Herb'),
              content: SizedBox(
                width: double.maxFinite,
                height: 420,
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search herbs...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final herb = filtered[index];
                          final isSelected = selectedHerb?.id == herb.id;

                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedHerb = herb;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.12)
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: OptimizedHerbImage(
                                      herb: herb,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      borderRadius: BorderRadius.circular(8),
                                      showPlaceholder: true,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          herb.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.foreground,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          herb.primaryBenefits.isNotEmpty
                                              ? herb.primaryBenefits.first
                                              : herb.category,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.primary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.primary,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedHerb == null
                      ? null
                      : () => Navigator.pop(context, selectedHerb),
                  child: const Text('Select'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              top: 260,
              left: -70,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.45),
                ),
              ),
            ),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Remedy Tracker',
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      height: 0.95,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Track consistency, symptoms, and progress over time',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.mutedForeground,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: _logs.isEmpty ? null : _confirmClearAll,
                              child: Opacity(
                                opacity: _logs.isEmpty ? 0.5 : 1,
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.2),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.08),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                '$_todayCount',
                                'Today',
                                Icons.today_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                '$_weekCount',
                                'Last 7 Days',
                                Icons.date_range_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                '$_monthCount',
                                'This Month',
                                Icons.calendar_month_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.border,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              DropdownButtonFormField<String>(
                                initialValue: _selectedCategory,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  prefixIcon: Icon(Icons.category_outlined),
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                items: _categoryOptions
                                    .map(
                                      (category) => DropdownMenuItem<String>(
                                        value: category,
                                        child: Text(category),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedAilmentId,
                                decoration: const InputDecoration(
                                  labelText: 'Ailment',
                                  prefixIcon:
                                      Icon(Icons.medical_information_outlined),
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: 'All',
                                    child: Text('All'),
                                  ),
                                  ..._ailments.map(
                                    (ailment) => DropdownMenuItem<String>(
                                      value: ailment.id,
                                      child: Text(ailment.name),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _selectedAilmentId = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary),
                      ),
                    ),
                  )
                else if (_logs.isEmpty)
                  _buildEmptyState()
                else if (_filteredLogs.isEmpty)
                  _buildNoFilterResultsState()
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 100),
                    sliver: SliverList.builder(
                      itemCount: _filteredLogs.length,
                      itemBuilder: (context, index) {
                        final log = _filteredLogs[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildLogCard(log),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addLog,
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  SliverToBoxAdapter _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primary.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.calendar_today,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Logs Yet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Select herbs from your database and start tracking\nyour remedy journey.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.mutedForeground,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildNoFilterResultsState() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
        child: Center(
          child: Column(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: const Icon(
                  Icons.filter_alt_off,
                  size: 42,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Logs Match Filters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try changing category or ailment filters.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogCard(_TrackerLog log) {
    final herb = HerbsData.getHerbById(log.herbId);
    final displayHerb = herb ?? HerbsData.herbs.first;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                child: OptimizedHerbImage(
                  herb: displayHerb,
                  width: 112,
                  height: 132,
                  fit: BoxFit.cover,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                  showPlaceholder: true,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              log.herbName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.foreground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _deleteLog(log),
                            child: const Icon(
                              Icons.delete_outline,
                              color: AppColors.destructive,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        log.primaryBenefit.isEmpty
                            ? 'Benefit unavailable'
                            : log.primaryBenefit,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.event_outlined,
                            size: 14,
                            color: AppColors.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(log.timestamp),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.alarm_rounded,
                            size: 14,
                            color: AppColors.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Next: ${_formatDateTime(log.nextIntakeAt)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.mutedForeground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (log.ailmentName != null &&
                          log.ailmentName!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              log.ailmentName!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.foreground,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (log.dosage.isNotEmpty || log.notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 12, color: AppColors.border),
                  if (log.dosage.isNotEmpty)
                    Text(
                      'Dosage: ${log.dosage}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (log.notes.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      log.notes,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.foreground.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary,
            AppColors.secondary.withValues(alpha: 0.72),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.mutedForeground,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Not set';
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${_formatDate(dt)} $hour:$minute $period';
  }
}

class _TrackerLog {
  final String herbId;
  final String herbName;
  final String category;
  final String primaryBenefit;
  final String dosage;
  final String notes;
  final DateTime timestamp;
  final DateTime? nextIntakeAt;
  final String? ailmentId;
  final String? ailmentName;

  const _TrackerLog({
    required this.herbId,
    required this.herbName,
    required this.category,
    required this.primaryBenefit,
    required this.dosage,
    required this.notes,
    required this.timestamp,
    required this.nextIntakeAt,
    required this.ailmentId,
    required this.ailmentName,
  });

  String get storageKey {
    return '$herbId|${timestamp.toIso8601String()}|$dosage|$notes';
  }

  String toStorage() {
    return jsonEncode({
      'herbId': herbId,
      'herbName': herbName,
      'category': category,
      'primaryBenefit': primaryBenefit,
      'dosage': dosage,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
      'nextIntakeAt': nextIntakeAt?.toIso8601String(),
      'ailmentId': ailmentId,
      'ailmentName': ailmentName,
    });
  }

  static _TrackerLog fromStorage(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return _TrackerLog(
        herbId: (map['herbId'] ?? '').toString(),
        herbName: (map['herbName'] ?? '').toString(),
        category: (map['category'] ?? '').toString(),
        primaryBenefit: (map['primaryBenefit'] ?? '').toString(),
        dosage: (map['dosage'] ?? '').toString(),
        notes: (map['notes'] ?? '').toString(),
        timestamp: DateTime.tryParse((map['timestamp'] ?? '').toString()) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        nextIntakeAt: DateTime.tryParse((map['nextIntakeAt'] ?? '').toString()),
        ailmentId: map['ailmentId'] == null
            ? null
            : (map['ailmentId'] as Object).toString(),
        ailmentName: map['ailmentName'] == null
            ? null
            : (map['ailmentName'] as Object).toString(),
      );
    } catch (_) {
      return _TrackerLog(
        herbId: '',
        herbName: raw,
        category: '',
        primaryBenefit: '',
        dosage: '',
        notes: '',
        timestamp: DateTime.fromMillisecondsSinceEpoch(0),
        nextIntakeAt: null,
        ailmentId: null,
        ailmentName: null,
      );
    }
  }
}
