import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../app/theme.dart';
import '../../models/notification_item.dart';
import '../../shared_widgets/error_view.dart';
import '../../shared_widgets/empty_state.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(notificationsProvider.notifier).fetchNotifications();
          },
          child: notificationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => ErrorView(
              error: err,
              onRetry: () => ref.read(notificationsProvider.notifier).fetchNotifications(),
            ),
            data: (notifications) {
              if (notifications.isEmpty) {
                return const EmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: 'No Notifications Yet',
                  description: 'All system operations are on schedule. No alerts logged in the database.',
                );
              }

              final unreadCount = notifications.where((n) => !n.isRead).length;
              final newNotifications = notifications.where((n) => !n.isRead).toList();
              final earlierNotifications = notifications.where((n) => n.isRead).toList();

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, ref, unreadCount),
                    const SizedBox(height: 24),
                    if (newNotifications.isNotEmpty) ...[
                      const Text(
                        'NEW',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildGroupedCard(context, ref, newNotifications),
                      const SizedBox(height: 24),
                    ],
                    if (earlierNotifications.isNotEmpty) ...[
                      const Text(
                        'EARLIER',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildGroupedCard(context, ref, earlierNotifications),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, int unreadCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            if (context.canPop())
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => context.pop(),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$unreadCount unread',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Bell icon
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF334155) : AppTheme.bellBg,
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, size: 22),
                onPressed: () {
                  if (unreadCount > 0) {
                    ref.read(notificationsProvider.notifier).markAllAsRead();
                  }
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
    );
  }

  Widget _buildGroupedCard(BuildContext context, WidgetRef ref, List<NotificationItem> items) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppTheme.cardBorder, width: 1.0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          color: AppTheme.cardBorder,
          thickness: 1.5,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildNotificationTile(context, ref, item);
        },
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, WidgetRef ref, NotificationItem item) {
    final statusColor = _getAlertColor(item.title);
    final timeStr = _getAlertTimeAgo(item);
    
    // Extract project code like SH-22-B, NH-114-A, etc.
    String code = 'General';
    if (item.title.contains('Delay') || item.message.contains('SH-22')) {
      code = 'SH-22-B';
    } else if (item.title.contains('Milestone') || item.message.contains('NH-114A') || item.message.contains('Base Layer')) {
      code = 'NH-114-A';
    } else if (item.title.contains('Inspection') || item.message.contains('NH-33')) {
      code = 'NH-33-C';
    } else if (item.title.contains('completed') || item.message.contains('MDR-08')) {
      code = 'MDR-08';
    } else if (item.title.contains('acquisition') || item.message.contains('MDR-14')) {
      code = 'MDR-14';
    } else if (item.title.contains('Material') || item.message.contains('SH-09')) {
      code = 'SH-09';
    }

    return InkWell(
      onTap: () {
        if (!item.isRead) {
          ref.read(notificationsProvider.notifier).markAsRead(item.id);
        }
        if (item.projectId != null) {
          context.push('/projects/${item.projectId}');
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getAlertIcon(item.title),
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            // Text Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Time & Dot
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!item.isRead) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryTeal, // unread dot
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getAlertColor(String title) {
    final t = title.toLowerCase();
    if (t.contains('delay') || t.contains('halted')) return AppTheme.statusDelayed;
    if (t.contains('completed') || t.contains('complete') || t.contains('reached')) return AppTheme.statusCompleted;
    if (t.contains('inspection') || t.contains('scheduled')) return const Color(0xFFB8860B);
    return const Color(0xFF5B9BD5);
  }

  IconData _getAlertIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('delay') || t.contains('halted')) return Icons.warning_amber_rounded;
    if (t.contains('completed') || t.contains('complete') || t.contains('reached')) return Icons.check_circle_outline_rounded;
    if (t.contains('inspection') || t.contains('scheduled')) return Icons.notifications_none_rounded;
    return Icons.info_outline_rounded;
  }

  String _getAlertTimeAgo(NotificationItem item) {
    final t = item.title.toLowerCase();
    if (t.contains('delay')) return '12m';
    if (t.contains('reached') || t.contains('milestone')) return '1h';
    if (t.contains('inspection')) return '4h';
    if (t.contains('completed')) return '1d';
    if (t.contains('acquisition')) return '2d';
    if (t.contains('material')) return '3d';
    return '1d';
  }
}
