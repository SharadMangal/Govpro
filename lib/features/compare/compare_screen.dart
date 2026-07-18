import 'package:flutter/material.dart';
import '../../shared_widgets/animated_progress_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../app/theme.dart';
import '../../models/project.dart';
import '../../shared_widgets/error_view.dart';

class CompareScreen extends ConsumerWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsListProvider);
    final selection = ref.watch(compareSelectionProvider);

    return Scaffold(
      body: SafeArea(
        child: projectsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => ErrorView(
            error: err,
            onRetry: () => ref.refresh(projectsListProvider),
          ),
          data: (projects) {
            if (projects.isEmpty) {
              return const Center(child: Text('No projects available to compare.'));
            }

            List<String> activeSelection = selection;
            if (selection.length < 2) {
              if (projects.length >= 2) {
                activeSelection = [projects[0].id, projects[1].id];
              } else {
                return const Center(child: Text('Add more projects to compare.'));
              }
            }

            final proj1 = projects.firstWhere((p) => p.id == activeSelection[0], orElse: () => projects[0]);
            final proj2 = projects.firstWhere((p) => p.id == activeSelection[1], orElse: () => projects[1]);

            final double delta = proj1.completionPercent - proj2.completionPercent;
            final String deltaSign = delta >= 0 ? '+' : '';
            final String deltaText = '$deltaSign${delta.toStringAsFixed(0)}%';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  _buildDropdownRow(context, ref, projects, activeSelection),
                  const SizedBox(height: 20),
                  _buildProgressDeltaCard(context, deltaText),
                  const SizedBox(height: 20),
                  _buildSideBySideCards(context, proj1, proj2),
                  const SizedBox(height: 20),
                  _buildComparisonBars(context, proj1, proj2),
                  const SizedBox(height: 20),
                  _buildMetadataGrid(context, proj1, proj2),
                  const SizedBox(height: 20),
                  _buildAIPerformanceVerdict(context),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compare',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Side-by-side performance',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        _buildBellIcon(context),
      ],
    );
  }

  Widget _buildBellIcon(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/notifications'),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF334155) : AppTheme.bellBg,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.notifications_none_rounded, size: 22, color: Theme.of(context).colorScheme.onSurface),
            Positioned(
              top: 11,
              right: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.bellRedDot,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownRow(BuildContext context, WidgetRef ref, List<Project> projects, List<String> activeSelection) {
    return Row(
      children: [
        Expanded(
          child: _buildProjectDropdown(
            context, 'Project A', projects, activeSelection[0],
            const Color(0xFF1A5C5E), false,
            (newVal) {
              if (newVal != null) {
                ref.read(compareSelectionProvider.notifier).state = [newVal, activeSelection[1]];
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildProjectDropdown(
            context, 'Project B', projects, activeSelection[1],
            AppTheme.compareOrange, true,
            (newVal) {
              if (newVal != null) {
                ref.read(compareSelectionProvider.notifier).state = [activeSelection[0], newVal];
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProjectDropdown(
    BuildContext context,
    String label,
    List<Project> projects,
    String selectedId,
    Color dotColor,
    bool isOrangeBorder,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOrangeBorder ? AppTheme.compareOrange : AppTheme.cardBorder,
          width: isOrangeBorder ? 2.0 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedId,
              isExpanded: true,
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black45, size: 20),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
              items: projects.map((p) {
                return DropdownMenuItem<String>(
                  value: p.id,
                  child: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDeltaCard(BuildContext context, String deltaText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.compare_arrows_rounded, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                'Progress delta',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            deltaText,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'NH-114-A vs SH-22-B',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideBySideCards(BuildContext context, Project p1, Project p2) {
    return Row(
      children: [
        Expanded(child: _buildProjectPreviewCard(context, p1, AppTheme.primaryTeal)),
        const SizedBox(width: 12),
        Expanded(child: _buildProjectPreviewCard(context, p2, AppTheme.compareOrange)),
      ],
    );
  }

  Widget _buildProjectPreviewCard(BuildContext context, Project project, Color barColor) {
    final statusColor = AppTheme.getStatusColor(project.status);
    final statusLabel = AppTheme.getStatusLabel(project.status);
    final statusBg = AppTheme.getStatusBadgeBg(project.status);
    final dotColor = AppTheme.getStatusDotColor(project.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            project.name,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Text(
            '${project.completionPercent.toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AnimatedProgressBar(
              value: project.completionPercent / 100,
              minHeight: 6,
              backgroundColor: AppTheme.progressBarTrack,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${project.district} · ₹${(project.budget / 10000000).toStringAsFixed(0)} Cr',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonBars(BuildContext context, Project p1, Project p2) {
    final double budget1 = p1.completionPercent;
    final double budget2 = 51.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStackedBarMetric(context, 'Physical progress',
              p1.completionPercent, '${p1.completionPercent.toStringAsFixed(0)}%',
              p2.completionPercent, '${p2.completionPercent.toStringAsFixed(0)}%',
              100),
          const SizedBox(height: 24),
          _buildStackedBarMetric(context, 'Budget utilised',
              budget1, '${budget1.toStringAsFixed(0)}%',
              budget2, '${budget2.toStringAsFixed(0)}%',
              100),
          const SizedBox(height: 24),
          _buildStackedBarMetric(context, 'Length',
              p1.lengthKm, '${p1.lengthKm} km',
              p2.lengthKm, '${p2.lengthKm} km',
              p1.lengthKm > p2.lengthKm ? p1.lengthKm : p2.lengthKm),
          const SizedBox(height: 24),
          _buildStackedBarMetric(context, 'Delay',
              p1.delayDays.toDouble(), '${p1.delayDays}d',
              p2.delayDays.toDouble(), '${p2.delayDays}d',
              18.0),
        ],
      ),
    );
  }

  Widget _buildStackedBarMetric(
    BuildContext context,
    String label,
    double val1, String text1,
    double val2, String text2,
    double maxVal,
  ) {
    final f1 = maxVal > 0 ? (val1 / maxVal).clamp(0.0, 1.0) : 0.0;
    final f2 = maxVal > 0 ? (val2 / maxVal).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        // Bar 1 (teal)
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: AnimatedProgressBar(
                  value: f1,
                  minHeight: 10,
                  backgroundColor: AppTheme.progressBarTrack,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 60,
              child: Text(
                text1,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryTeal,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Bar 2 (orange)
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: AnimatedProgressBar(
                  value: f2,
                  minHeight: 10,
                  backgroundColor: AppTheme.progressBarTrack,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.compareOrange),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 60,
              child: Text(
                text2,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetadataGrid(BuildContext context, Project p1, Project p2) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          _buildMetaRow(context, p1.contractor?.name ?? 'N/A', 'CONTRACTOR', p2.contractor?.name ?? 'N/A'),
          const Divider(height: 20, color: AppTheme.cardBorder),
          _buildMetaRow(context, p1.authority?.name ?? 'N/A', 'AUTHORITY', p2.authority?.name ?? 'N/A'),
          const Divider(height: 20, color: AppTheme.cardBorder),
          _buildMetaRow(context, p1.district, 'DISTRICT', p2.district),
          const Divider(height: 20, color: AppTheme.cardBorder),
          _buildMetaRow(context, 'Base Layer', 'CURRENT STAGE', 'Foundation'),
        ],
      ),
    );
  }

  Widget _buildMetaRow(BuildContext context, String left, String centerLabel, String right) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF334155) : const Color(0xFFF5F0EB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            centerLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: Text(
            right,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildAIPerformanceVerdict(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFF0052CC), // AppTheme.primaryBlue
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.insert_chart_outlined, color: Colors.white, size: 28),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Coming Soon',
                    style: TextStyle(
                      color: Color(0xFF0052CC),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'AI Performance Verdict',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Machine learning insights and automated verdict will be available here soon.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
