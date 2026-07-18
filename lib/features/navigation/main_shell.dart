import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared_widgets/offline_banner.dart';

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    // Determine current index from GoRouter path
    final GoRouterState state = GoRouterState.of(context);
    final String location = state.uri.toString();
    int selectedIndex = 0;
    if (location.startsWith('/projects')) {
      selectedIndex = 1;
    } else if (location.startsWith('/compare')) {
      selectedIndex = 2;
    } else if (location.startsWith('/authorities')) {
      selectedIndex = 3;
    } else if (location.startsWith('/analytics')) {
      selectedIndex = 4;
    }

    void onTabTapped(int index) {
      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/projects');
          break;
        case 2:
          context.go('/compare');
          break;
        case 3:
          context.go('/authorities');
          break;
        case 4:
          context.go('/analytics');
          break;
      }
    }

    final navLabels = ['Home', 'Projects', 'Compare', 'Authority', 'Analytics'];
    final navIcons = [
      Icons.grid_view_outlined,
      Icons.folder_open_outlined,
      Icons.compare_arrows_rounded,
      Icons.apartment_outlined,
      Icons.bar_chart_outlined,
    ];
    final navSelectedIcons = [
      Icons.grid_view_rounded,
      Icons.folder_rounded,
      Icons.compare_arrows_rounded,
      Icons.apartment_rounded,
      Icons.bar_chart_rounded,
    ];

    final railItems = List.generate(5, (i) => NavigationRailDestination(
      icon: Icon(navIcons[i]),
      selectedIcon: Icon(navSelectedIcons[i]),
      label: Text(navLabels[i]),
    ));

    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: isMobile
                ? child
                : Row(
                    children: [
                      NavigationRail(
                        selectedIndex: selectedIndex,
                        onDestinationSelected: onTabTapped,
                        labelType: NavigationRailLabelType.all,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        indicatorColor: AppTheme.navPillBg,
                        leading: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppTheme.primaryTeal,
                            child: const Icon(Icons.domain, color: Colors.white, size: 18),
                          ),
                        ),
                        destinations: railItems,
                      ),
                      VerticalDivider(thickness: 1, width: 1, color: AppTheme.cardBorder),
                      Expanded(child: child),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile
          ? _buildBottomNav(context, selectedIndex, onTabTapped, navLabels, navIcons, navSelectedIcons)
          : null,
    );
  }

  /// Custom bottom nav with pill-shaped active indicator matching Lovable reference
  Widget _buildBottomNav(
    BuildContext context,
    int selectedIndex,
    void Function(int) onTabTapped,
    List<String> labels,
    List<IconData> icons,
    List<IconData> selectedIcons,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) {
              final isSelected = index == selectedIndex;
              return GestureDetector(
                onTap: () => onTabTapped(index),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        isSelected ? selectedIcons[index] : icons[index],
                        size: 24,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[index],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
