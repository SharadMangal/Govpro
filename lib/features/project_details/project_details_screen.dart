import 'dart:ui';
import 'package:flutter/material.dart';
import '../../shared_widgets/animated_progress_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/providers.dart';
import '../../app/theme.dart';
import '../../models/project.dart';
import '../../models/stage.dart';
import '../../models/material_item.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/pdf_generator.dart';
import '../../shared_widgets/error_view.dart';

class ProjectDetailsScreen extends ConsumerWidget {
  final String projectId;

  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(projectDetailsProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        actions: [
          detailsAsync.maybeWhen(
            data: (data) => IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Export PDF Report',
              onPressed: () => PdfGenerator.exportProjectSummary(data),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(projectDetailsProvider(projectId));
        },
        child: detailsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => ErrorView(
            error: err,
            onRetry: () => ref.refresh(projectDetailsProvider(projectId)),
          ),
          data: (data) {
            final project = data.project;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhotoHeader(context, project),
                  const SizedBox(height: 20),
                  _buildMetricsGrid(context, project),
                  const SizedBox(height: 20),
                  _buildPartiesSection(context, project),
                  const SizedBox(height: 20),
                  _buildStagesTimeline(context, data.stages, project),
                  const SizedBox(height: 20),
                  _buildMaterialsTable(context, data.materials),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPhotoHeader(BuildContext context, Project project) {
    final statusColor = AppTheme.getStatusColor(project.status);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Photo Background
          project.sitePhotoUrl != null
              ? CachedNetworkImage(
                  imageUrl: project.sitePhotoUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                  ),
                )
              : Container(
                  height: 200,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: const Center(child: Icon(Icons.landscape, size: 48)),
                ),
          // Gradient Overlay
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          AppTheme.getStatusLabel(project.status).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Hero(
                        tag: 'project-title-${project.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            project.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${project.district} District Segment',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Completion circle at top-right
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  Text(
                    '${project.completionPercent.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Complete',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, Project project) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth < 600 ? 2 : 4;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: cols,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: [
            _buildMetricTile(
              context,
              'Financial Budget',
              Formatters.formatCurrency(project.budget),
              Icons.currency_rupee,
            ),
            _buildMetricTile(
              context,
              'Segment Length',
              '${project.lengthKm} KM',
              Icons.straighten,
            ),
            _buildMetricTile(
              context,
              'Time Schedule',
              '${Formatters.formatDate(project.startDate)} - ${Formatters.formatDate(project.endDate)}',
              Icons.date_range,
              isSmallText: true,
            ),
            _buildMetricTile(
              context,
              'Timeline Delay',
              project.delayDays > 0 ? '${project.delayDays} Days' : 'On Schedule',
              Icons.schedule,
              colorOverride: project.delayDays > 0 ? AppTheme.statusDelayed : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricTile(BuildContext context, String label, String value, IconData icon, {bool isSmallText = false, Color? colorOverride}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = colorOverride ?? theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withOpacity(0.05),
            primary.withOpacity(0.15),
          ],
        ),
        border: Border.all(
          color: primary.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: isSmallText ? 12 : 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartiesSection(BuildContext context, Project project) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stakeholders & Execution team',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Authority Card
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Text(
                          project.authority?.name.substring(0, 2).toUpperCase() ?? 'AU',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('AUTHORITY', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(
                              project.authority?.name ?? 'N/A',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Contractor Card
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        child: Text(
                          project.contractor?.name.substring(0, 2).toUpperCase() ?? 'CO',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CONTRACTOR', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(
                              project.contractor?.name ?? 'N/A',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildStagesTimeline(BuildContext context, List<Stage> stages, Project project) {
    final statusColor = AppTheme.getStatusColor(project.status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monitored Construction Stages',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stages.length,
              itemBuilder: (context, index) {
                final stage = stages[index];
                final isCompleted = stage.completionPercent >= 100.0;
                final isLast = index == stages.length - 1;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Timeline indicator column
                      Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isCompleted 
                                  ? AppTheme.statusCompleted 
                                  : (stage.completionPercent > 0 ? statusColor : Colors.grey.shade300),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isCompleted
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : Text(
                                      '${stage.sequenceOrder}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: stage.completionPercent > 0 ? Colors.white : Colors.grey.shade600,
                                      ),
                                    ),
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: isCompleted ? AppTheme.statusCompleted : Colors.grey.shade300,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Details card column
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stage.stageName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Started: ${Formatters.formatDate(stage.startDate)} ${stage.endDate != null ? '• Finished: ${Formatters.formatDate(stage.endDate!)}' : ''}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: AnimatedProgressBar(
                                        value: stage.completionPercent / 100,
                                        minHeight: 6,
                                        backgroundColor: isCompleted 
                                            ? AppTheme.statusCompleted.withOpacity(0.1) 
                                            : (stage.completionPercent > 0 ? statusColor.withOpacity(0.1) : Colors.grey.shade200),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          isCompleted 
                                              ? AppTheme.statusCompleted 
                                              : (stage.completionPercent > 0 ? statusColor : Colors.grey.shade400),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    Formatters.formatPercentage(stage.completionPercent),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isCompleted 
                                          ? AppTheme.statusCompleted 
                                          : (stage.completionPercent > 0 ? statusColor : Colors.grey.shade600),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsTable(BuildContext context, List<MaterialItem> materials) {
    if (materials.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Material Inventory Utilised',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Table(
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                  width: 0.5,
                ),
              ),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                // Header row
                TableRow(
                  children: [
                    _tableHeaderCell(context, 'Material'),
                    _tableHeaderCell(context, 'Quantity'),
                    _tableHeaderCell(context, 'Unit'),
                  ],
                ),
                // Rows
                ...materials.map((item) => TableRow(
                      children: [
                        _tableDataCell(context, item.materialName),
                        _tableDataCell(context, item.quantity.toStringAsFixed(1)),
                        _tableDataCell(context, item.unit),
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeaderCell(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _tableDataCell(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}
