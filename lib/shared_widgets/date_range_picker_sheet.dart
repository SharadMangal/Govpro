import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../app/theme.dart';
import '../providers/providers.dart';

class DateRangePickerSheet extends ConsumerStatefulWidget {
  const DateRangePickerSheet({super.key});

  @override
  ConsumerState<DateRangePickerSheet> createState() => _DateRangePickerSheetState();
}

class _DateRangePickerSheetState extends ConsumerState<DateRangePickerSheet> {
  void _setPreset(int months, String label) {
    final now = DateTime.now();
    // Rough estimation of months
    final start = DateTime(now.year, now.month - months, now.day);
    
    ref.read(globalDateRangeProvider.notifier).state = DateRangeState(
      startDate: start,
      endDate: now,
      presetLabel: label,
    );
    Navigator.pop(context);
  }

  Future<void> _pickCustomRange() async {
    final currentRange = ref.read(globalDateRangeProvider);
    final initialRange = (currentRange.startDate != null && currentRange.endDate != null)
        ? DateTimeRange(start: currentRange.startDate!, end: currentRange.endDate!)
        : null;

    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: initialRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryTeal,
              onPrimary: Colors.white,
              surface: AppTheme.bgLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      ref.read(globalDateRangeProvider.notifier).state = DateRangeState(
        startDate: result.start,
        endDate: result.end,
        presetLabel: 'Custom',
      );
      if (mounted) Navigator.pop(context);
    }
  }

  void _clearFilter() {
    ref.read(globalDateRangeProvider.notifier).state = DateRangeState();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentFilter = ref.watch(globalDateRangeProvider);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          color: isDark ? AppTheme.bgDark.withValues(alpha: 0.85) : AppTheme.bgLight.withValues(alpha: 0.85),
          padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Date Range',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (currentFilter.startDate != null)
                    TextButton(
                      onPressed: _clearFilter,
                      child: const Text('Clear', style: TextStyle(color: Colors.red)),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              
              // Section 1: Presets
              const Text('Quick Select', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildPresetChip('1 Month', 1, currentFilter.presetLabel),
                  _buildPresetChip('3 Months', 3, currentFilter.presetLabel),
                  _buildPresetChip('6 Months', 6, currentFilter.presetLabel),
                  _buildPresetChip('9 Months', 9, currentFilter.presetLabel),
                  _buildPresetChip('12 Months', 12, currentFilter.presetLabel),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Section 2: Custom Range
              const Text('Custom Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickCustomRange,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: currentFilter.presetLabel == 'Custom' 
                        ? AppTheme.primaryTeal.withValues(alpha: 0.1)
                        : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: currentFilter.presetLabel == 'Custom' 
                          ? AppTheme.primaryTeal 
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, 
                        color: currentFilter.presetLabel == 'Custom' ? AppTheme.primaryTeal : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select specific dates',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: currentFilter.presetLabel == 'Custom' ? AppTheme.primaryTeal : null,
                              ),
                            ),
                            if (currentFilter.presetLabel == 'Custom' && currentFilter.startDate != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${DateFormat('MMM d, yyyy').format(currentFilter.startDate!)} - ${DateFormat('MMM d, yyyy').format(currentFilter.endDate!)}',
                                style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, int months, String? activeLabel) {
    final isActive = label == activeLabel;
    return ChoiceChip(
      label: Text(label),
      selected: isActive,
      onSelected: (_) => _setPreset(months, label),
      selectedColor: AppTheme.primaryTeal,
      labelStyle: TextStyle(
        color: isActive ? Colors.white : null,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? Colors.white.withValues(alpha: 0.1) 
          : Colors.black.withValues(alpha: 0.05),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
