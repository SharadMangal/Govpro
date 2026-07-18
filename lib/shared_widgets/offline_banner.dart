import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../core/utils/formatters.dart';

// Connectivity Provider based on failed/successful REST requests
final isOfflineProvider = StateProvider<bool>((ref) => false);

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineProvider);
    final lastSyncAsync = ref.watch(lastSyncTimeProvider);

    if (!isOffline) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(
              Icons.wifi_off_rounded,
              color: Theme.of(context).colorScheme.onErrorContainer,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Offline Mode Active',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  lastSyncAsync.maybeWhen(
                    data: (time) => time != null
                        ? Text(
                            'Last updated: ${Formatters.formatDate(time)} at ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onErrorContainer.withOpacity(0.8),
                            ),
                          )
                        : Text(
                            'No local cache available.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onErrorContainer.withOpacity(0.8),
                            ),
                          ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              icon: Icon(
                Icons.refresh,
                size: 16,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              label: Text(
                'Retry',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                backgroundColor: Theme.of(context).colorScheme.onErrorContainer.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Invalidate projects to trigger retry request
                ref.invalidate(projectsListProvider);
                ref.invalidate(lastSyncTimeProvider);
              },
            ),
          ],
        ),
      ),
    );
  }
}
