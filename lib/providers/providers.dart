import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/dio_client.dart';
import '../core/cache/cache_manager.dart';

import '../models/project.dart';
import '../models/authority.dart';
import '../models/stage.dart';
import '../models/material_item.dart';
import '../models/monthly_progress.dart';
import '../models/notification_item.dart';

import '../repositories/project_repository.dart';
import '../repositories/authority_repository.dart';
import '../repositories/stage_repository.dart';
import '../repositories/material_repository.dart';
import '../repositories/monthly_progress_repository.dart';
import '../repositories/notification_repository.dart';

// --- CORE UTILITIES PROVIDERS ---
final dioClientProvider = Provider<DioClient>((ref) => DioClient());
final cacheManagerProvider = Provider<CacheManager>((ref) => CacheManager());

// --- REPOSITORIES PROVIDERS ---
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(ref.watch(dioClientProvider), ref.watch(cacheManagerProvider));
});

final authorityRepositoryProvider = Provider<AuthorityRepository>((ref) {
  return AuthorityRepository(ref.watch(dioClientProvider), ref.watch(cacheManagerProvider));
});

final stageRepositoryProvider = Provider<StageRepository>((ref) {
  return StageRepository(ref.watch(dioClientProvider), ref.watch(cacheManagerProvider));
});

final materialRepositoryProvider = Provider<MaterialRepository>((ref) {
  return MaterialRepository(ref.watch(dioClientProvider), ref.watch(cacheManagerProvider));
});

final monthlyProgressRepositoryProvider = Provider<MonthlyProgressRepository>((ref) {
  return MonthlyProgressRepository(ref.watch(dioClientProvider), ref.watch(cacheManagerProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(dioClientProvider), ref.watch(cacheManagerProvider));
});

// --- FILTER STATE ---
class ProjectFilters {
  final String? district;
  final String? authorityId;
  final String? status;
  final String searchQuery;
  final String sortBy; // 'name_asc', 'progress_desc', 'budget_desc', 'delay_desc'

  ProjectFilters({
    this.district,
    this.authorityId,
    this.status,
    this.searchQuery = '',
    this.sortBy = 'name_asc',
  });

  ProjectFilters copyWith({
    String? district,
    String? authorityId,
    String? status,
    String? searchQuery,
    String? sortBy,
    bool clearDistrict = false,
    bool clearAuthority = false,
    bool clearStatus = false,
  }) {
    return ProjectFilters(
      district: clearDistrict ? null : (district ?? this.district),
      authorityId: clearAuthority ? null : (authorityId ?? this.authorityId),
      status: clearStatus ? null : (status ?? this.status),
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

final projectFilterProvider = StateProvider<ProjectFilters>((ref) => ProjectFilters());

// --- CORE DATA STATE PROVIDERS ---

// 1. Projects List Provider
final projectsListProvider = FutureProvider<List<Project>>((ref) async {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.getAllProjects();
});

// 1.5 Global Date Range Provider
class DateRangeState {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? presetLabel;

  DateRangeState({this.startDate, this.endDate, this.presetLabel});
}

final globalDateRangeProvider = StateProvider<DateRangeState>((ref) => DateRangeState());

final dateFilteredProjectsProvider = Provider<AsyncValue<List<Project>>>((ref) {
  final projectsAsync = ref.watch(projectsListProvider);
  final dateRange = ref.watch(globalDateRangeProvider);

  return projectsAsync.whenData((projects) {
    if (dateRange.startDate == null || dateRange.endDate == null) {
      return projects;
    }
    return projects.where((p) {
      // Check if project start date falls within the selected range
      return p.startDate.isAfter(dateRange.startDate!) &&
             p.startDate.isBefore(dateRange.endDate!.add(const Duration(days: 1)));
    }).toList();
  });
});

// 2. Filtered Projects Provider (For Projects Screen - uses dateFilteredProjectsProvider)
final filteredProjectsProvider = Provider<AsyncValue<List<Project>>>((ref) {
  final projectsAsync = ref.watch(dateFilteredProjectsProvider);
  final filters = ref.watch(projectFilterProvider);

  return projectsAsync.whenData((projects) {
    var filtered = projects.where((p) {
      // District filter
      if (filters.district != null && p.district != filters.district) {
        return false;
      }
      // Authority filter
      if (filters.authorityId != null && p.authorityId != filters.authorityId) {
        return false;
      }
      // Status filter
      if (filters.status != null && p.status != filters.status) {
        return false;
      }
      // Search filter
      if (filters.searchQuery.isNotEmpty) {
        final query = filters.searchQuery.toLowerCase();
        final matchesName = p.name.toLowerCase().contains(query);
        final matchesDistrict = p.district.toLowerCase().contains(query);
        final matchesAuthority = p.authority?.name.toLowerCase().contains(query) ?? false;
        final matchesContractor = p.contractor?.name.toLowerCase().contains(query) ?? false;
        if (!matchesName && !matchesDistrict && !matchesAuthority && !matchesContractor) {
          return false;
        }
      }
      return true;
    }).toList();

    // Sorting
    if (filters.sortBy == 'name_asc') {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    } else if (filters.sortBy == 'progress_desc') {
      filtered.sort((a, b) => b.completionPercent.compareTo(a.completionPercent));
    } else if (filters.sortBy == 'budget_desc') {
      filtered.sort((a, b) => b.budget.compareTo(a.budget));
    } else if (filters.sortBy == 'delay_desc') {
      filtered.sort((a, b) => b.delayDays.compareTo(a.delayDays));
    }

    return filtered;
  });
});

// 3. Project Details Data Struct
class ProjectDetailsData {
  final Project project;
  final List<Stage> stages;
  final List<MaterialItem> materials;
  final List<MonthlyProgress> monthlyProgress;

  ProjectDetailsData({
    required this.project,
    required this.stages,
    required this.materials,
    required this.monthlyProgress,
  });
}

// 4. Project Details Provider (Dynamic fetch by ID)
final projectDetailsProvider = FutureProvider.family<ProjectDetailsData, String>((ref, id) async {
  final projectRepo = ref.watch(projectRepositoryProvider);
  final stageRepo = ref.watch(stageRepositoryProvider);
  final materialRepo = ref.watch(materialRepositoryProvider);
  final progressRepo = ref.watch(monthlyProgressRepositoryProvider);

  final results = await Future.wait([
    projectRepo.getProjectById(id),
    stageRepo.getStagesForProject(id),
    materialRepo.getMaterialsForProject(id),
    progressRepo.getMonthlyProgressForProject(id),
  ]);

  return ProjectDetailsData(
    project: results[0] as Project,
    stages: results[1] as List<Stage>,
    materials: results[2] as List<MaterialItem>,
    monthlyProgress: results[3] as List<MonthlyProgress>,
  );
});

// 5. Authorities List Provider
final authoritiesListProvider = FutureProvider<List<Authority>>((ref) async {
  final repo = ref.watch(authorityRepositoryProvider);
  return repo.getAllAuthorities();
});

// 6. Compare Selection Provider (holds max 2 project IDs)
final compareSelectionProvider = StateProvider<List<String>>((ref) => []);

// 7. Dynamic Connection Status / Last Sync Banner Provider
final lastSyncTimeProvider = FutureProvider<DateTime?>((ref) async {
  final cache = ref.watch(cacheManagerProvider);
  return cache.getLastSyncedTime('projects_cache');
});

// --- NOTIFICATIONS STATE NOTIFIER ---
class NotificationsNotifier extends StateNotifier<AsyncValue<List<NotificationItem>>> {
  final NotificationRepository _repository;

  NotificationsNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.getAllNotifications();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      // Refresh local state
      final list = await _repository.getAllNotifications();
      state = AsyncValue.data(list);
    } catch (_) {
      // Fallback: manually toggle read status in the current state
      state.whenData((current) {
        final updated = current.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
        state = AsyncValue.data(updated);
      });
    }
  }

  Future<void> markAllAsRead() async {
    state.whenData((current) async {
      try {
        for (var n in current) {
          if (!n.isRead) {
            await _repository.markAsRead(n.id);
          }
        }
        final list = await _repository.getAllNotifications();
        state = AsyncValue.data(list);
      } catch (_) {}
    });
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, AsyncValue<List<NotificationItem>>>((ref) {
  return NotificationsNotifier(ref.watch(notificationRepositoryProvider));
});

// --- THEME MODE PERSISTENT STATE ---
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_theme') ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
      await prefs.setBool('is_dark_theme', true);
    } else {
      state = ThemeMode.light;
      await prefs.setBool('is_dark_theme', false);
    }
  }
}

final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
