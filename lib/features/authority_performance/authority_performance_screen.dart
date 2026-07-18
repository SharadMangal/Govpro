import 'package:flutter/material.dart';
import '../../shared_widgets/animated_progress_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../app/theme.dart';
import '../../models/project.dart';
import '../../shared_widgets/error_view.dart';
import '../../shared_widgets/empty_state.dart';

class AuthorityPerformanceScreen extends ConsumerWidget {
  const AuthorityPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsListProvider);

    return Scaffold(
      body: SafeArea(
        child: projectsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => ErrorView(
            error: err,
            onRetry: () => ref.refresh(projectsListProvider),
          ),
          data: (projects) {
            final Map<String, List<Project>> grouped = {};
            for (var p in projects) {
              grouped.putIfAbsent(p.authorityId, () => []).add(p);
            }

            final performanceList = grouped.entries.map((entry) {
              final authId = entry.key;
              final authProjects = entry.value;
              final authority = authProjects.first.authority;
              final name = authority?.name ?? 'Unknown Authority';
              final totalCount = authProjects.length;
              final completedCount = authProjects.where((p) => p.status == 'completed').length;
              final delayedCount = authProjects.where((p) => p.status == 'delayed').length;
              final avgProgress = authProjects.map((p) => p.completionPercent).reduce((a, b) => a + b) / totalCount;

              return _AuthPerformanceData(
                id: authId,
                name: name,
                totalProjects: totalCount,
                completedProjects: completedCount,
                delayedProjects: delayedCount,
                averageProgress: avgProgress,
              );
            }).toList();

            performanceList.sort((a, b) => b.averageProgress.compareTo(a.averageProgress));

            if (performanceList.isEmpty) {
              return const EmptyState(
                icon: Icons.bar_chart,
                title: 'No Performance Data',
                description: 'There are currently no projects recorded.',
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  ...performanceList.map((data) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildAuthorityCard(context, ref, data),
                  )),
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
              'Authorities',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Performance overview',
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
        decoration: const BoxDecoration(
          color: AppTheme.bellBg,
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

  Widget _buildAuthorityCard(BuildContext context, WidgetRef ref, _AuthPerformanceData data) {
    String fullName = data.name;
    if (data.name == 'NHAI') {
      fullName = 'National Highways Authority';
    } else if (data.name == 'State PWD') {
      fullName = 'State Public Works Dept.';
    } else if (data.name == 'PMGSY') {
      fullName = 'Pradhan Mantri Gram Sadak Yojana';
    }

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
          // Header: Icon + Name + Count badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.navPillBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.apartment_rounded, color: AppTheme.primaryTeal, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fullName,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0EB),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${data.totalProjects}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Stat boxes row
          Row(
            children: [
              Expanded(child: _buildStatBox(context, 'PROJECTS', '${data.totalProjects}', null)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatBox(context, 'COMPLETED', '${data.completedProjects}', Icons.check_circle_outline)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatBox(context, 'AVG\nPROGRESS', '${data.averageProgress.toStringAsFixed(0)}%', Icons.trending_up_rounded)),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AnimatedProgressBar(
              value: data.averageProgress / 100,
              minHeight: 8,
              backgroundColor: AppTheme.progressBarTrack,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
            ),
          ),
          const SizedBox(height: 8),

          // Label row: "Average completion" + delayed count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Average completion',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade500),
              ),
              if (data.delayedProjects > 0)
                Text(
                  '${data.delayedProjects} delayed',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.statusDelayed),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // View projects button
          GestureDetector(
            onTap: () {
              ref.read(projectFilterProvider.notifier).state = ProjectFilters(
                authorityId: data.id,
              );
              context.go('/projects');
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      'View projects',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(BuildContext context, String label, String value, IconData? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: AppTheme.statusCompleted),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}

class _AuthPerformanceData {
  final String id;
  final String name;
  final int totalProjects;
  final int completedProjects;
  final int delayedProjects;
  final double averageProgress;

  _AuthPerformanceData({
    required this.id,
    required this.name,
    required this.totalProjects,
    required this.completedProjects,
    required this.delayedProjects,
    required this.averageProgress,
  });
}
