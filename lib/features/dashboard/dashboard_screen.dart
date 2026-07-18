import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../app/theme.dart';
import '../../models/project.dart';
import '../../shared_widgets/animated_progress_bar.dart';
import '../../shared_widgets/date_range_picker_sheet.dart';
import '../../shared_widgets/skeleton_loader.dart';
import '../../shared_widgets/error_view.dart';
import '../../shared_widgets/offline_banner.dart';
import '../../shared_widgets/staggered_fade_in.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(dateFilteredProjectsProvider);
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(projectsListProvider);
          ref.invalidate(notificationsProvider);
          ref.invalidate(lastSyncTimeProvider);
        },
        child: projectsAsync.when(
          loading: () => const SkeletonDashboard(),
          error: (err, stack) {
            Future.microtask(() {
              ref.read(isOfflineProvider.notifier).state = true;
            });
            return ErrorView(
              error: err,
              onRetry: () {
                ref.invalidate(projectsListProvider);
                ref.invalidate(notificationsProvider);
              },
            );
          },
          data: (projects) {
            Future.microtask(() {
              ref.read(isOfflineProvider.notifier).state = false;
            });

            // Calculate metrics
            final total = projects.length;
            final completed = projects.where((p) => p.status == 'completed').length;
            final inProgress = projects.where((p) => p.status == 'in_progress').length;
            final delayed = projects.where((p) => p.status == 'delayed').length;
            
            final overallProgress = total > 0 
                ? projects.map((p) => p.completionPercent).reduce((a, b) => a + b) / total 
                : 0.0;

            // Group by Authority
            final Map<String, List<double>> authProgressMap = {};
            final Map<String, String> authNameMap = {};
            for (var p in projects) {
              final authName = p.authority?.name ?? 'Unknown Authority';
              authNameMap[p.authorityId] = authName;
              authProgressMap.putIfAbsent(p.authorityId, () => []).add(p.completionPercent);
            }

            final authorityList = authProgressMap.entries.map((entry) {
              final id = entry.key;
              final name = authNameMap[id] ?? 'Authority';
              final progressList = entry.value;
              final avg = progressList.reduce((a, b) => a + b) / progressList.length;
              return _AuthorityProgressData(id: id, name: name, progress: avg, projectCount: progressList.length);
            }).toList();
            authorityList.sort((a, b) => b.progress.compareTo(a.progress));

            return Stack(
              children: [
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                    top: 130.0,
                    left: 16.0,
                    right: 16.0,
                    bottom: 90.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOverallProgressCard(context, overallProgress, total),
                      const SizedBox(height: 20),
                      _buildSummaryGrid(context, total, completed, inProgress, delayed),
                      const SizedBox(height: 24),
                      
                      // Authority list and activity feeds
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 800) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      _buildAuthorityProgressCard(context, authorityList),
                                      const SizedBox(height: 24),
                                      _buildRequiresAttentionCard(context, projects),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildRecentActivityCard(context, notificationsAsync),
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                _buildAuthorityProgressCard(context, authorityList),
                                const SizedBox(height: 24),
                                _buildRecentActivityCard(context, notificationsAsync),
                                const SizedBox(height: 24),
                                _buildRequiresAttentionCard(context, projects),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                      child: Container(
                        padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 16.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.85),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black.withValues(alpha: 0.05),
                              width: 1,
                            ),
                          ),
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: _buildHeader(context, notificationsAsync, ref),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue<List<dynamic>> notificationsAsync, WidgetRef ref) {
    final hour = DateTime.now().hour;
    String greeting = 'Good morning';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good afternoon';
    } else if (hour >= 17) {
      greeting = 'Good evening';
    }

    final int unreadCount = notificationsAsync.maybeWhen(
      data: (list) => list.where((n) => !n.isRead).length,
      orElse: () => 0,
    );
    
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Public Works Dept. • Jharkhand',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        // Icons Row
        Row(
          children: [
            // Dark Mode icon
            GestureDetector(
              onTap: () {
                ref.read(themeModeProvider.notifier).state = isDark ? ThemeMode.light : ThemeMode.dark;
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : AppTheme.bellBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 20, color: isDark ? Colors.white : AppTheme.primaryTeal),
              ),
            ),
            const SizedBox(width: 12),
            // Calendar icon
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const DateRangePickerSheet(),
                );
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : AppTheme.bellBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.calendar_month, size: 20, color: isDark ? Colors.white : AppTheme.primaryTeal),
              ),
            ),
            const SizedBox(width: 12),
            // Bell icon
            GestureDetector(
              onTap: () => context.go('/notifications'),
              child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : AppTheme.bellBg,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, size: 22),
                    onPressed: () {
                      context.go('/notifications');
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 10,
                      right: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE53935), // Red badge
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildOverallProgressCard(BuildContext context, double progress, int projectCount) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'OVERALL PROGRESS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'This quarter',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${progress.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Across $projectCount active projects',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(
                  height: 10,
                  color: Colors.white.withOpacity(0.12),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double progressWidth = constraints.maxWidth * (progress / 100);
                    return AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeOut,
                      width: progressWidth,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5A623), // Bright Orange
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid(BuildContext context, int total, int completed, int inProgress, int delayed) {
    return GridView.count(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.1,
      children: [
        StaggeredFadeIn(
          index: 0,
          child: _buildSummaryCard(
            context,
            'Total',
            '$total',
            Icons.folder_open_rounded,
            const Color(0xFF00796B),
            const Color(0xFFE0F2F1),
          ),
        ),
        StaggeredFadeIn(
          index: 1,
          child: _buildSummaryCard(
            context,
            'Completed',
            '$completed',
            Icons.check_circle_outline_rounded,
            const Color(0xFF388E3C),
            const Color(0xFFE8F5E9),
          ),
        ),
        StaggeredFadeIn(
          index: 2,
          child: _buildSummaryCard(
            context,
            'In Progress',
            '$inProgress',
            Icons.construction_rounded,
            const Color(0xFF1976D2),
            const Color(0xFFE3F2FD),
          ),
        ),
        StaggeredFadeIn(
          index: 3,
          child: _buildSummaryCard(
            context,
            'Delayed',
            '$delayed',
            Icons.warning_amber_rounded,
            const Color(0xFFD32F2F),
            const Color(0xFFFFEBEE),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color bgColor,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Circular icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorityProgressCard(BuildContext context, List<_AuthorityProgressData> data) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Authority-wise progress',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => context.push('/authorities'),
                  child: Row(
                    children: [
                      Text(
                        'View all',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: data.take(3).map((auth) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            auth.name,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          Text(
                            '${auth.progress.toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${auth.projectCount} ${auth.projectCount == 1 ? 'project' : 'projects'}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: AnimatedProgressBar(
                          value: auth.progress / 100,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF005E60), // Jharkhand progress teal
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard(BuildContext context, AsyncValue<List<dynamic>> notificationsAsync) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent activity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => context.go('/notifications'),
                  child: Row(
                    children: [
                      Text(
                        'View all',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            notificationsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) => const Text('Error loading activity logs'),
              data: (list) {
                if (list.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No recent activities logged.', style: TextStyle(color: Colors.grey)),
                  );
                }
                return Column(
                  children: list.take(4).map((item) {
                    final bulletColor = _getActivityColor(item.title);
                    final index = list.indexOf(item);
                    final timeStr = _getActivityTimeAgo(index);
                    final sub = _getActivitySubtitle(item, timeStr);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0, right: 12.0),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: bulletColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  sub,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getActivityColor(String title) {
    final t = title.toLowerCase();
    if (t.contains('delay') || t.contains('halted')) return AppTheme.statusDelayed;
    if (t.contains('completed') || t.contains('complete')) return AppTheme.statusCompleted;
    return AppTheme.statusInProgress; // blue for in_progress/resumed/scheduled
  }

  String _getActivityTimeAgo(int index) {
    if (index == 0) return '12m ago';
    if (index == 1) return '1h ago';
    if (index == 2) return '4h ago';
    return '1d ago';
  }

  String _getActivitySubtitle(dynamic item, String timeStr) {
    String entity = '';
    final title = item.title.toLowerCase();
    if (title.contains('nh-114a') || title.contains('ranchi')) entity = 'Bharat Infra';
    else if (title.contains('sh-22')) entity = 'State PWD';
    else if (title.contains('nh-33')) entity = 'Prime Structurals';
    else if (title.contains('mdr-08')) entity = 'Green Path';
    else if (title.contains('mdr-14')) entity = 'Rural Build';
    else entity = 'Contractor';
    
    return '$entity • $timeStr';
  }

  Widget _buildRequiresAttentionCard(BuildContext context, List<Project> projects) {
    final delayedProjects = projects.where((p) => p.status == 'delayed').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Requires attention',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () => context.go('/projects'),
              child: Row(
                children: [
                  Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: delayedProjects.length,
          itemBuilder: (context, index) {
            final p = delayedProjects[index];
            
            String delayReason = 'Unknown';
            if (p.name.contains('SH-22')) {
              delayReason = 'Heavy Rain';
            } else if (p.name.contains('MDR-14')) {
              delayReason = 'Land Acquisition Issue';
            }

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: () => context.push('/projects/${p.id}'),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Delayed',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD32F2F),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            p.district,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_outward_rounded,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: AnimatedProgressBar(
                          value: p.completionPercent / 100,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFD32F2F),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${p.completionPercent.toStringAsFixed(0)}% • Delayed ${p.delayDays}d — $delayReason',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AuthorityProgressData {
  final String id;
  final String name;
  final double progress;
  final int projectCount;

  _AuthorityProgressData({
    required this.id,
    required this.name,
    required this.progress,
    required this.projectCount,
  });
}
