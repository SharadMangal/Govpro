import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../shared_widgets/animated_progress_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../app/theme.dart';
import '../../models/project.dart';
import '../../core/utils/formatters.dart';
import '../../shared_widgets/skeleton_loader.dart';
import '../../shared_widgets/error_view.dart';
import '../../shared_widgets/empty_state.dart';
import '../../shared_widgets/staggered_fade_in.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Pre-populate search controller if there is already a filter state
    Future.microtask(() {
      final filters = ref.read(projectFilterProvider);
      _searchController.text = filters.searchQuery;
    });

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      ref.read(projectFilterProvider.notifier).update(
            (state) => state.copyWith(searchQuery: value),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProjectFilters>(projectFilterProvider, (previous, next) {
      if (next.searchQuery.isEmpty && _searchController.text.isNotEmpty) {
        _searchController.clear();
      }
    });

    final filteredProjectsAsync = ref.watch(filteredProjectsProvider);
    final filters = ref.watch(projectFilterProvider);
    final compareSelection = ref.watch(compareSelectionProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(projectsListProvider);
            ref.invalidate(lastSyncTimeProvider);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchAndFilterBar(context, filters),
              _buildStatusFilterChips(context, filters),
              _buildActiveFilters(context, filters),
              _buildCompareSelectorStatus(context, compareSelection),
              Expanded(
              child: filteredProjectsAsync.when(
                loading: () => ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) => const SkeletonCard(),
                ),
                error: (err, stack) => ErrorView(
                  error: err,
                  onRetry: () => ref.refresh(projectsListProvider),
                ),
                data: (projects) {
                  if (projects.isEmpty) {
                    return EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No Projects Found',
                      description: 'No projects match your current search, filter, or sorting criteria.',
                      actionLabel: 'Clear All Filters',
                      onActionPressed: () {
                        _searchController.clear();
                        ref.read(projectFilterProvider.notifier).state = ProjectFilters();
                      },
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 700) {
                        // Grid layout on tablets
                        return GridView.builder(
                          padding: const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 120),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 220,
                          ),
                          itemCount: projects.length,
                          itemBuilder: (context, index) {
                            return StaggeredFadeIn(
                              index: index,
                              child: _buildProjectCard(context, projects[index], compareSelection),
                            );
                          },
                        );
                      } else {
                        // List layout on phones
                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 8, bottom: 120),
                          itemCount: projects.length + 1,
                          itemBuilder: (context, index) {
                            if (index == projects.length) {
                              return _buildPagination(context, projects.length);
                            }
                            return StaggeredFadeIn(
                              index: index,
                              child: _buildProjectCard(context, projects[index], compareSelection),
                            );
                          },
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildSearchAndFilterBar(BuildContext context, ProjectFilters filters) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search project, contractor, district',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(projectFilterProvider.notifier).update(
                          (state) => state.copyWith(searchQuery: ''),
                        );
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          filled: true,
          fillColor: Theme.of(context).cardTheme.color,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppTheme.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppTheme.cardBorder),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilterChips(BuildContext context, ProjectFilters filters) {
    final currentStatus = filters.status;

    Widget buildChip(String label, String? statusValue) {
      final isSelected = currentStatus == statusValue;
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              ref.read(projectFilterProvider.notifier).update(
                (state) => state.copyWith(
                  status: statusValue,
                  clearStatus: statusValue == null,
                ),
              );
            }
          },
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          selectedColor: AppTheme.primaryTeal,
          backgroundColor: Theme.of(context).cardTheme.color,
          elevation: 0,
          pressElevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: isSelected ? Colors.transparent : AppTheme.cardBorder),
          ),
        ),
      );
    }

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          buildChip('All', null),
          buildChip('In Progress', 'in_progress'),
          buildChip('Delayed', 'delayed'),
          buildChip('Completed', 'completed'),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              avatar: const Icon(Icons.tune, size: 14),
              label: const Text('Filters'),
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => _showFilterBottomSheet(context),
              backgroundColor: Theme.of(context).cardTheme.color,
              elevation: 0,
              pressElevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppTheme.cardBorder),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(BuildContext context, ProjectFilters filters) {
    final List<Widget> chips = [];

    if (filters.district != null) {
      chips.add(
        InputChip(
          label: Text('District: ${filters.district}'),
          onDeleted: () => ref.read(projectFilterProvider.notifier).update(
                (state) => state.copyWith(clearDistrict: true),
              ),
        ),
      );
    }
    if (filters.status != null) {
      chips.add(
        InputChip(
          label: Text('Status: ${AppTheme.getStatusLabel(filters.status!)}'),
          onDeleted: () => ref.read(projectFilterProvider.notifier).update(
                (state) => state.copyWith(clearStatus: true),
              ),
        ),
      );
    }
    if (filters.authorityId != null) {
      final authoritiesAsync = ref.watch(authoritiesListProvider);
      final authName = authoritiesAsync.maybeWhen(
        data: (list) => list.firstWhere((a) => a.id == filters.authorityId).name,
        orElse: () => 'Authority',
      );
      chips.add(
        InputChip(
          label: Text(authName, overflow: TextOverflow.ellipsis),
          onDeleted: () => ref.read(projectFilterProvider.notifier).update(
                (state) => state.copyWith(clearAuthority: true),
              ),
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: chips
            .map((chip) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: chip,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCompareSelectorStatus(BuildContext context, List<String> compareSelection) {
    if (compareSelection.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              '${compareSelection.length}/2 selected',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => ref.read(compareSelectionProvider.notifier).state = [],
                child: const Text('Clear'),
              ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: compareSelection.length == 2
                    ? () => context.push('/compare')
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Compare'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context, int totalCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        children: [
          const Divider(color: AppTheme.cardBorder),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Showing 3 of\n$totalCount projects',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A5568)),
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: const Icon(Icons.chevron_left, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF0052CC), // Blue accent
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: const Text('2', style: TextStyle(color: Color(0xFF4A5568), fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: const Text('3', style: TextStyle(color: Color(0xFF4A5568), fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: const Icon(Icons.chevron_right, color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project, List<String> compareSelection) {
    final statusColor = AppTheme.getStatusColor(project.status);
    final isSelectedForCompare = compareSelection.contains(project.id);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppTheme.cardBorder, width: 1.0),
        borderRadius: BorderRadius.circular(24),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/projects/${project.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header with Badge overlay
            if (project.sitePhotoUrl != null)
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: project.sitePhotoUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(height: 180, color: Colors.grey.shade200),
                    errorWidget: (context, url, error) => Container(height: 180, color: Colors.grey.shade200),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.getStatusBadgeBg(project.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.getStatusDotColor(project.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppTheme.getStatusLabel(project.status),
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.getStatusColor(project.status)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and ID row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Hero(
                          tag: 'project-title-${project.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              project.name,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: Colors.black87, height: 1.2),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ID: PROJ-${project.id.substring(0, 4).toUpperCase()}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0052CC)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        project.district,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Authority & Contractor
                  Row(
                    children: [
                      Icon(Icons.account_balance_outlined, size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        project.authority?.name ?? 'Authority',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.engineering_outlined, size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          project.contractor?.name ?? 'Contractor',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Completion Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Completion Status',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF4A5568)),
                      ),
                      Text(
                        '${project.completionPercent.toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0052CC)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: AnimatedProgressBar(
                      value: project.completionPercent / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0052CC)), // Blue accent
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Footer: Avatars + View Details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Fake avatars
                      Row(
                        children: [
                          CircleAvatar(radius: 14, backgroundColor: Colors.green.shade100, child: const Text('JD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87))),
                          Transform.translate(offset: const Offset(-8, 0), child: CircleAvatar(radius: 14, backgroundColor: Colors.blue.shade100, child: const Text('AS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)))),
                          Transform.translate(offset: const Offset(-16, 0), child: CircleAvatar(radius: 14, backgroundColor: Colors.orange.shade100, child: const Text('+4', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)))),
                        ],
                      ),
                      Row(
                        children: const [
                          Text(
                            'View Details',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0052CC)),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 20, color: Color(0xFF0052CC)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const _FilterBottomSheetContent();
      },
    );
  }
}

// Separate widget for sheet content so it has its own Consumer state
class _FilterBottomSheetContent extends ConsumerWidget {
  const _FilterBottomSheetContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(projectFilterProvider);
    final authoritiesAsync = ref.watch(authoritiesListProvider);

    final districts = ['All', 'Jaipur', 'Jodhpur', 'Udaipur', 'Ajmer', 'Kota'];
    final statuses = [
      {'label': 'All Statuses', 'value': null},
      {'label': 'Completed', 'value': 'completed'},
      {'label': 'Under Progress', 'value': 'in_progress'},
      {'label': 'Delayed', 'value': 'delayed'},
    ];
    final sorts = [
      {'label': 'Project Name', 'value': 'name_asc'},
      {'label': 'Completion Progress', 'value': 'progress_desc'},
      {'label': 'Project Budget', 'value': 'budget_desc'},
      {'label': 'Delay Duration', 'value': 'delay_desc'},
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputDeco = InputDecoration(
      filled: true,
      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );

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
                'Filter Monitored Projects',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 12),

          // 1. Status Filter
          const Text('Project Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            value: filters.status,
            decoration: inputDeco,
            items: statuses
                .map((s) => DropdownMenuItem<String?>(
                      value: s['value'] as String?,
                      child: Text(s['label'] as String),
                    ))
                .toList(),
            onChanged: (val) {
              ref.read(projectFilterProvider.notifier).update(
                    (state) => val == null
                        ? state.copyWith(clearStatus: true)
                        : state.copyWith(status: val),
                  );
            },
          ),
          const SizedBox(height: 16),

          // 2. District Filter
          const Text('District Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: filters.district ?? 'All',
            decoration: inputDeco,
            items: districts
                .map((d) => DropdownMenuItem<String>(
                      value: d,
                      child: Text(d),
                    ))
                .toList(),
            onChanged: (val) {
              ref.read(projectFilterProvider.notifier).update(
                    (state) => val == 'All'
                        ? state.copyWith(clearDistrict: true)
                        : state.copyWith(district: val),
                  );
            },
          ),
          const SizedBox(height: 16),

          // 3. Authority Filter
          const Text('Supervising Authority', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          authoritiesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (err, stack) => const Text('Error loading authorities'),
            data: (authList) {
              final items = [
                const DropdownMenuItem<String?>(value: null, child: Text('All Authorities'))
              ];
              items.addAll(authList.map((a) => DropdownMenuItem<String?>(
                    value: a.id,
                    child: Text(a.name, overflow: TextOverflow.ellipsis),
                  )));

              return DropdownButtonFormField<String?>(
                value: filters.authorityId,
                isExpanded: true,
                decoration: inputDeco,
                items: items,
                onChanged: (val) {
                  ref.read(projectFilterProvider.notifier).update(
                        (state) => val == null
                            ? state.copyWith(clearAuthority: true)
                            : state.copyWith(authorityId: val),
                      );
                },
              );
            },
          ),
          const SizedBox(height: 16),

          // 4. Sort By Filter
          const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: filters.sortBy,
            decoration: inputDeco,
            items: sorts
                .map((s) => DropdownMenuItem<String>(
                      value: s['value'] as String,
                      child: Text(s['label'] as String),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                ref.read(projectFilterProvider.notifier).update(
                      (state) => state.copyWith(sortBy: val),
                    );
              }
            },
          ),
          const SizedBox(height: 24),

          // Reset & Apply Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(projectFilterProvider.notifier).state = ProjectFilters();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Reset All', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
  }
}
