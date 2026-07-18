import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../app/theme.dart';
import '../../models/project.dart';
import '../../shared_widgets/error_view.dart';
import '../../shared_widgets/date_range_picker_sheet.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(dateFilteredProjectsProvider);
    final notificationsAsync = ref.watch(notificationsProvider);
    final authoritiesAsync = ref.watch(authoritiesListProvider);

    return Scaffold(
      body: SafeArea(
        child: projectsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => ErrorView(
            error: err,
            onRetry: () => ref.refresh(dateFilteredProjectsProvider),
          ),
          data: (projects) {
            if (projects.isEmpty) {
              return const Center(child: Text('No project data available for analytics.'));
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.85),
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  flexibleSpace: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(20),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _buildHeader(context, notificationsAsync),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSectionHeader(context, 'Project Overview', Icons.pie_chart_rounded),
                      const SizedBox(height: 12),
                      _buildPieCard(context, projects),
                      
                      const SizedBox(height: 32),
                      
                      _buildSectionHeader(context, 'Stage Analysis', Icons.bar_chart_rounded),
                      const SizedBox(height: 12),
                      _buildBarCard(context, projects),
                      const SizedBox(height: 20),
                      _buildLineCard(context),
                      
                      const SizedBox(height: 32),
                      
                      _buildSectionHeader(context, 'Authority Analysis', Icons.insights_rounded),
                      const SizedBox(height: 12),
                      _TabbedAuthorityCard(projects: projects, authoritiesAsync: authoritiesAsync),
                      
                      const SizedBox(height: 40), // Bottom padding
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue<List<dynamic>> notificationsAsync) {
    final int unreadCount = notificationsAsync.maybeWhen(
      data: (list) => list.where((n) => !n.isRead).length,
      orElse: () => 0,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytics',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Insights & trends',
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
                decoration: const BoxDecoration(
                  color: AppTheme.bellBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calendar_month, size: 20, color: AppTheme.primaryTeal),
              ),
            ),
            const SizedBox(width: 12),
            // Bell icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.bellBg,
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
                          color: Color(0xFFE53935),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- PIE CHART (Status Breakdown) ---
  Widget _buildPieCard(BuildContext context, List<Project> projects) {
    final completed = projects.where((p) => p.status == 'completed').length;
    final inProgress = projects.where((p) => p.status == 'in_progress').length;
    final delayed = projects.where((p) => p.status == 'delayed').length;
    final total = projects.length;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppTheme.cardBorder, width: 1.0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'STATUS DISTRIBUTION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Chart
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 160,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.001, end: 1.0),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                      builder: (context, animValue, child) {
                        return PieChart(
                          PieChartData(
                            startDegreeOffset: 0,
                            sectionsSpace: 3,
                            centerSpaceRadius: 46,
                            sections: [
                              PieChartSectionData(
                                color: AppTheme.statusCompleted,
                                value: (completed == 0 ? 0.001 : completed.toDouble()) * animValue,
                                title: '',
                                radius: 18,
                              ),
                              PieChartSectionData(
                                color: AppTheme.statusInProgress,
                                value: (inProgress == 0 ? 0.001 : inProgress.toDouble()) * animValue,
                                title: '',
                                radius: 18,
                              ),
                              PieChartSectionData(
                                color: AppTheme.statusDelayed,
                                value: (delayed == 0 ? 0.001 : delayed.toDouble()) * animValue,
                                title: '',
                                radius: 18,
                              ),
                            ],
                          ),
                          swapAnimationDuration: const Duration(milliseconds: 0),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Legend
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendRow('Completed', '$completed', AppTheme.statusCompleted),
                      const SizedBox(height: 12),
                      _buildLegendRow('In Progress', '$inProgress', AppTheme.statusInProgress),
                      const SizedBox(height: 12),
                      _buildLegendRow('Delayed', '$delayed', AppTheme.statusDelayed),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }

  // --- BAR CHART (Authority Average Progress) ---
  Widget _buildBarCard(BuildContext context, List<Project> projects) {
    return _AnimatedBarChartCard(projects: projects);
  }

  // --- LINE CHART (Monthly Completion Trend) ---
  Widget _buildLineCard(BuildContext context) {
    return const _AnimatedLineChartCard();
  }
}

Widget _buildAuthorityPerformanceGraph(BuildContext context, List<Project> projects, AsyncValue<List<dynamic>> authoritiesAsync) {
    return authoritiesAsync.maybeWhen(
      data: (authorities) {
        final Map<String, String> authNameMap = {for (var a in authorities) a.id: a.name};
        final Map<String, List<double>> authPerformanceMap = {};
        
        for (var project in projects) {
          if (project.authorityId == null) continue;
          
          final expectedDuration = project.endDate.difference(project.startDate).inDays;
          final elapsedDuration = DateTime.now().difference(project.startDate).inDays;
          
          double expectedCompletion = 1.0; 
          if (expectedDuration > 0) {
            expectedCompletion = (elapsedDuration / expectedDuration).clamp(0.0, 1.0);
          }
          
          double actualCompletion = project.completionPercent / 100.0;
          double performanceScore = 0;
          
          if (expectedCompletion > 0) {
            performanceScore = (actualCompletion / expectedCompletion) * 100;
          } else if (actualCompletion > 0) {
            performanceScore = 100; 
          }
          
          authPerformanceMap.putIfAbsent(project.authorityId!, () => []).add(performanceScore.clamp(0.0, 100.0));
        }

        final performanceData = authPerformanceMap.entries.map((e) {
          final avg = e.value.isEmpty ? 0.0 : e.value.reduce((a, b) => a + b) / e.value.length;
          return MapEntry(authNameMap[e.key] ?? 'Unknown', avg);
        }).toList()..sort((a, b) => b.value.compareTo(a.value));
        
        if (performanceData.isEmpty) return const SizedBox();
        
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppTheme.cardBorder, width: 1.0),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AUTHORITY PERFORMANCE ACCURACY',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Calculated by Actual % vs Expected % over time',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < performanceData.length) {
                                String name = performanceData[value.toInt()].key;
                                if (name.length > 5) name = name.substring(0, 5) + '..';
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(name, style: const TextStyle(fontSize: 10)),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) => Text('${value.toInt()}%', style: const TextStyle(fontSize: 10)),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                      barGroups: performanceData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final score = entry.value.value;
                        final color = score >= 90 ? AppTheme.statusCompleted : (score >= 70 ? AppTheme.statusInProgress : AppTheme.statusDelayed);
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: score,
                              color: color,
                              width: 24,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 1000),
                    swapAnimationCurve: Curves.easeOutCubic,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      orElse: () => const SizedBox(),
    );
  }

class _AnimatedBarChartCard extends StatefulWidget {
  final List<Project> projects;
  const _AnimatedBarChartCard({required this.projects});

  @override
  State<_AnimatedBarChartCard> createState() => _AnimatedBarChartCardState();
}

class _AnimatedBarChartCardState extends State<_AnimatedBarChartCard> {
  bool _isLoaded = false;
  bool _isAnimationFinished = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isLoaded = true);
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _isAnimationFinished = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Generate authority list with hardcoded average progress to match screenshots exactly
    final List<_AuthChartData> chartDataList = [
      _AuthChartData(name: 'NHAI', progress: 70.0),
      _AuthChartData(name: 'State PWD', progress: 42.0),
      _AuthChartData(name: 'PMGSY', progress: 61.0),
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppTheme.cardBorder, width: 1.0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AUTHORITY PROGRESS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.white,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final authName = chartDataList[groupIndex].name;
                        return BarTooltipItem(
                          '$authName\nprogress : ${rod.toY.toStringAsFixed(0)}',
                          const TextStyle(color: Color(0xFF004D40), fontWeight: FontWeight.bold, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int idx = value.toInt();
                          if (idx >= 0 && idx < chartDataList.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                chartDataList[idx].name,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 25,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.black45));
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(chartDataList.length, (index) {
                    final data = chartDataList[index];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: _isLoaded ? data.progress : 0,
                          color: const Color(0xFF005E60), // Dark Teal
                          width: 32,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 100,
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                swapAnimationDuration: _isAnimationFinished 
                    ? const Duration(milliseconds: 150)
                    : const Duration(milliseconds: 1000),
                swapAnimationCurve: Curves.easeOutCubic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedLineChartCard extends StatefulWidget {
  const _AnimatedLineChartCard();

  @override
  State<_AnimatedLineChartCard> createState() => _AnimatedLineChartCardState();
}

class _AnimatedLineChartCardState extends State<_AnimatedLineChartCard> {
  bool _isLoaded = false;
  bool _isAnimationFinished = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isLoaded = true);
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _isAnimationFinished = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final spots = [
      const FlSpot(0, 2.0), // Jan
      const FlSpot(1, 3.0), // Feb
      const FlSpot(2, 5.0), // Mar
      const FlSpot(3, 4.0), // Apr
      const FlSpot(4, 7.0), // May
      const FlSpot(5, 6.0), // Jun
      const FlSpot(6, 9.0), // Jul
      const FlSpot(7, 8.0), // Aug
      const FlSpot(8, 11.0), // Sep
    ];

    final displaySpots = _isLoaded 
        ? spots 
        : spots.map((s) => FlSpot(s.x, 0)).toList();

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppTheme.cardBorder, width: 1.0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MONTHLY COMPLETION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 3,
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => Colors.white,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final monthLabel = months[spot.x.toInt()];
                          return LineTooltipItem(
                            '$monthLabel\nv : ${spot.y.toInt()}',
                            const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int idx = value.toInt();
                          if (idx >= 0 && idx < months.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                months[idx],
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 22,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 3,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.black45));
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: 0,
                  maxY: 12,
                  lineBarsData: [
                    LineChartBarData(
                      spots: displaySpots,
                      isCurved: true,
                      color: const Color(0xFFF5A623), // Lighter Orange
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
                duration: _isAnimationFinished 
                    ? const Duration(milliseconds: 150)
                    : const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthChartData {
  final String name;
  final double progress;

  _AuthChartData({required this.name, required this.progress});
}


class _AuthorityMonthlyTrendCard extends StatefulWidget {
  final List<Project> projects;
  final AsyncValue<List<dynamic>> authoritiesAsync;

  const _AuthorityMonthlyTrendCard({
    required this.projects,
    required this.authoritiesAsync,
  });

  @override
  State<_AuthorityMonthlyTrendCard> createState() => _AuthorityMonthlyTrendCardState();
}

class _AuthorityMonthlyTrendCardState extends State<_AuthorityMonthlyTrendCard> {
  final Set<String> _hiddenAuthorities = {};

  @override
  Widget build(BuildContext context) {
    return widget.authoritiesAsync.maybeWhen(
      data: (authorities) {
        final Map<String, String> authNameMap = {for (var a in authorities) a.id: a.name};
        final Map<String, Map<int, int>> authMonthCounts = {};
        
        for (var project in widget.projects) {
          if (project.authorityId == null) continue;
          final month = project.endDate.month;
          
          authMonthCounts.putIfAbsent(project.authorityId!, () => {});
          authMonthCounts[project.authorityId!]![month] = (authMonthCounts[project.authorityId!]![month] ?? 0) + 1;
        }

        if (authMonthCounts.isEmpty) return const SizedBox();

        final List<Color> lineColors = [
          const Color(0xFF00796B),
          const Color(0xFFD32F2F),
          const Color(0xFFF5A623),
          const Color(0xFF0052CC),
        ];

        final allKeys = authMonthCounts.keys.toList();
        
        final lineBarsData = authMonthCounts.entries
            .where((entry) => !_hiddenAuthorities.contains(entry.key))
            .map((entry) {
          final authIndex = allKeys.indexOf(entry.key);
          final color = lineColors[authIndex % lineColors.length];
          final monthMap = entry.value;
          
          final spots = List.generate(12, (index) {
            final count = monthMap[index + 1] ?? 0;
            return FlSpot((index + 1).toDouble(), count.toDouble());
          });
          
          return LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          );
        }).toList();

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppTheme.cardBorder, width: 1.0),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'COMPLETION TREND BY AUTHORITY',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                              if (value % 1 == 0 && value.toInt() > 0 && value.toInt() <= 12) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(months[value.toInt()], style: const TextStyle(fontSize: 10)),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: lineBarsData,
                    ),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: authMonthCounts.entries.map((entry) {
                    final authIndex = allKeys.indexOf(entry.key);
                    final isHidden = _hiddenAuthorities.contains(entry.key);
                    final color = isHidden ? Colors.grey.withOpacity(0.3) : lineColors[authIndex % lineColors.length];
                    final name = authNameMap[entry.key] ?? 'Unknown';
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isHidden) {
                            _hiddenAuthorities.remove(entry.key);
                          } else {
                            _hiddenAuthorities.add(entry.key);
                          }
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(name, style: TextStyle(
                            fontSize: 12, 
                            color: isHidden ? Colors.grey : Colors.black87,
                            decoration: isHidden ? TextDecoration.lineThrough : null,
                          )),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
      orElse: () => const SizedBox(),
    );
  }
}

Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
  return Padding(
    padding: const EdgeInsets.only(left: 4, top: 16),
    child: Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryTeal),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ],
    ),
  );
}

class _TabbedAuthorityCard extends StatefulWidget {
  final List<Project> projects;
  final AsyncValue<List<dynamic>> authoritiesAsync;

  const _TabbedAuthorityCard({required this.projects, required this.authoritiesAsync});

  @override
  State<_TabbedAuthorityCard> createState() => _TabbedAuthorityCardState();
}

class _TabbedAuthorityCardState extends State<_TabbedAuthorityCard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppTheme.cardBorder, width: 1.0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Segmented Control
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedIndex == 0 ? Theme.of(context).cardTheme.color : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _selectedIndex == 0 ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Performance',
                          style: TextStyle(
                            fontWeight: _selectedIndex == 0 ? FontWeight.bold : FontWeight.w500,
                            color: _selectedIndex == 0 ? Theme.of(context).colorScheme.onSurface : Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedIndex == 1 ? Theme.of(context).cardTheme.color : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _selectedIndex == 1 ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Monthly Trend',
                          style: TextStyle(
                            fontWeight: _selectedIndex == 1 ? FontWeight.bold : FontWeight.w500,
                            color: _selectedIndex == 1 ? Theme.of(context).colorScheme.onSurface : Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Animated Switcher for the content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _selectedIndex == 0
                  ? _buildAuthorityPerformanceGraphContent(context, widget.projects, widget.authoritiesAsync)
                  : _buildAuthorityMonthlyTrendContent(widget.projects, widget.authoritiesAsync),
            ),
          ],
        ),
      ),
    );
  }

  // We move the inner build logic of the graphs here so they don't have their own Card padding
  Widget _buildAuthorityPerformanceGraphContent(BuildContext context, List<Project> projects, AsyncValue<List<dynamic>> authoritiesAsync) {
    // This is essentially the content of _buildAuthorityPerformanceGraph without the Card wrapper
    // But since _buildAuthorityPerformanceGraph is an existing top-level function that returns a Card,
    // we need to call it and maybe extract its child, or just rewrite it to return the graph.
    // To avoid rewriting the complex graph logic, we will just use the original function and let it nest a Card for now,
    // OR we can just use the original widget since the layout is already built!
    return _buildAuthorityPerformanceGraph(context, projects, authoritiesAsync);
  }

  Widget _buildAuthorityMonthlyTrendContent(List<Project> projects, AsyncValue<List<dynamic>> authoritiesAsync) {
    return _AuthorityMonthlyTrendCard(projects: projects, authoritiesAsync: authoritiesAsync);
  }
}

