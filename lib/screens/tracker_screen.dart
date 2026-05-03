import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/storage.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  bool _isLoading = true;
  List<_TrackerLog> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final rawLogs = await Storage.getTrackerLogs();
    final parsed = rawLogs.map(_TrackerLog.fromStorage).toList();
    parsed.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (mounted) {
      setState(() {
        _logs = parsed;
        _isLoading = false;
      });
    }
  }

  Future<void> _addLog() async {
    final herbController = TextEditingController();
    final dosageController = TextEditingController();
    final notesController = TextEditingController();

    final log = await showDialog<_TrackerLog>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('Add Remedy Log'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: herbController,
                  decoration: const InputDecoration(
                    labelText: 'Herb name',
                    hintText: 'Example: Chamomile',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage (optional)',
                    hintText: 'Example: 1 cup tea',
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final herb = herbController.text.trim();
                if (herb.isEmpty) return;

                Navigator.pop(
                  context,
                  _TrackerLog(
                    herbName: herb,
                    dosage: dosageController.text.trim(),
                    notes: notesController.text.trim(),
                    timestamp: DateTime.now(),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (log == null) {
      return;
    }

    await Storage.addTrackerLog(log.toStorage());
    await _loadLogs();
  }

  Future<void> _deleteLog(int index) async {
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

    if (shouldClear != true) {
      return;
    }

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Remedy Tracker',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Monitor your herbal wellness journey',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: _logs.isEmpty ? null : _confirmClearAll,
                          child: Opacity(
                            opacity: _logs.isEmpty ? 0.5 : 1,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.15),
                                    AppColors.primary.withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                ),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: AppColors.primary,
                                size: 20,
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
                            child: _buildStatCard('$_todayCount', 'Today')),
                        const SizedBox(width: 12),
                        Expanded(
                            child:
                                _buildStatCard('$_weekCount', 'Last 7 Days')),
                        const SizedBox(width: 12),
                        Expanded(
                            child:
                                _buildStatCard('$_monthCount', 'This Month')),
                      ],
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
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              )
            else if (_logs.isEmpty)
              SliverToBoxAdapter(
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
                          'Start tracking your herbal remedy intake\nto monitor patterns and support your\nwellness journey',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.mutedForeground,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withValues(alpha: 0.1),
                                AppColors.primary.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Text(
                            'Tap the + button below to add\nyour first remedy log',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 100),
                sliver: SliverList.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildLogCard(log, index),
                    );
                  },
                ),
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

  Widget _buildLogCard(_TrackerLog log, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  log.herbName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _deleteLog(index),
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
            _formatTimestamp(log.timestamp),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.mutedForeground,
            ),
          ),
          if (log.dosage.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Dosage: ${log.dosage}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
          ],
          if (log.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              log.notes,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.foreground.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary,
            AppColors.secondary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.mutedForeground,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} $hour:$minute $period';
  }
}

class _TrackerLog {
  final String herbName;
  final String dosage;
  final String notes;
  final DateTime timestamp;

  const _TrackerLog({
    required this.herbName,
    required this.dosage,
    required this.notes,
    required this.timestamp,
  });

  String toStorage() {
    return jsonEncode({
      'herbName': herbName,
      'dosage': dosage,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
    });
  }

  static _TrackerLog fromStorage(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return _TrackerLog(
        herbName: (map['herbName'] ?? '').toString(),
        dosage: (map['dosage'] ?? '').toString(),
        notes: (map['notes'] ?? '').toString(),
        timestamp: DateTime.tryParse((map['timestamp'] ?? '').toString()) ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
    } catch (_) {
      return _TrackerLog(
        herbName: raw,
        dosage: '',
        notes: '',
        timestamp: DateTime.fromMillisecondsSinceEpoch(0),
      );
    }
  }
}
