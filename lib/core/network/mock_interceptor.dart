import 'dart:async';
import 'package:dio/dio.dart';
import 'mock_data.dart';

class MockInterceptor extends Interceptor {
  // In-memory notifications to support interactive reading/unread changes during session
  static final List<Map<String, dynamic>> _inMemoryNotifications = 
      List.from(MockData.notifications);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final path = options.path;
    final queryParams = {
      ...options.uri.queryParameters,
      ...options.queryParameters,
    };
    final method = options.method.toUpperCase();

    // 1. PROJECTS
    if (path.contains('/projects')) {
      if (method == 'GET') {
        // Check if fetching single project by ID: /projects?id=eq.UUID
        final idFilter = queryParams['id'];
        if (idFilter != null && idFilter.startsWith('eq.')) {
          final id = idFilter.substring(3);
          final project = _findProjectById(id);
          if (project != null) {
            handler.resolve(Response(
              requestOptions: options,
              data: [project], // Supabase returns arrays for queries
              statusCode: 200,
            ));
            return;
          } else {
            handler.resolve(Response(
              requestOptions: options,
              data: [],
              statusCode: 200,
            ));
            return;
          }
        }

        // Return all projects, decorated with joined relations (authorities & contractors)
        final results = MockData.projects.map((p) => _joinedProjectJson(p)).toList();
        handler.resolve(Response(
          requestOptions: options,
          data: results,
          statusCode: 200,
        ));
        return;
      }
    }

    // 2. AUTHORITIES
    if (path.contains('/authorities')) {
      if (method == 'GET') {
        handler.resolve(Response(
          requestOptions: options,
          data: MockData.authorities,
          statusCode: 200,
        ));
        return;
      }
    }

    // 3. CONTRACTORS
    if (path.contains('/contractors')) {
      if (method == 'GET') {
        handler.resolve(Response(
          requestOptions: options,
          data: MockData.contractors,
          statusCode: 200,
        ));
        return;
      }
    }

    // 4. STAGES
    if (path.contains('/stages')) {
      if (method == 'GET') {
        final projectIdFilter = queryParams['project_id'];
        if (projectIdFilter != null && projectIdFilter.startsWith('eq.')) {
          final projectId = projectIdFilter.substring(3);
          
          // Get seeded stages + generate dynamic ones if not explicitly seeded
          List<Map<String, dynamic>> projectStages = MockData.stages
              .where((s) => s['project_id'] == projectId)
              .toList();

          if (projectStages.isEmpty) {
            projectStages = MockData.getInitialStagesForOtherProjects()
                .where((s) => s['project_id'] == projectId)
                .toList();
          }

          // Sort by sequence_order
          projectStages.sort((a, b) => (a['sequence_order'] as int).compareTo(b['sequence_order'] as int));

          handler.resolve(Response(
            requestOptions: options,
            data: projectStages,
            statusCode: 200,
          ));
          return;
        }
      }
    }

    // 5. MATERIALS
    if (path.contains('/materials')) {
      if (method == 'GET') {
        final projectIdFilter = queryParams['project_id'];
        if (projectIdFilter != null && projectIdFilter.startsWith('eq.')) {
          final projectId = projectIdFilter.substring(3);
          final projectMaterials = MockData.materials
              .where((m) => m['project_id'] == projectId)
              .toList();

          handler.resolve(Response(
            requestOptions: options,
            data: projectMaterials,
            statusCode: 200,
          ));
          return;
        }
      }
    }

    // 6. MONTHLY PROGRESS
    if (path.contains('/monthly_progress')) {
      if (method == 'GET') {
        final projectIdFilter = queryParams['project_id'];
        if (projectIdFilter != null && projectIdFilter.startsWith('eq.')) {
          final projectId = projectIdFilter.substring(3);
          
          List<Map<String, dynamic>> progressList = MockData.monthlyProgress
              .where((mp) => mp['project_id'] == projectId)
              .toList();

          if (progressList.isEmpty) {
            progressList = MockData.getInitialMonthlyProgressForOtherProjects()
                .where((mp) => mp['project_id'] == projectId)
                .toList();
          }

          // Sort by month date
          progressList.sort((a, b) => (a['month'] as String).compareTo(b['month'] as String));

          handler.resolve(Response(
            requestOptions: options,
            data: progressList,
            statusCode: 200,
          ));
          return;
        }

        // Aggregate query (all progress values)
        final allProgress = [
          ...MockData.monthlyProgress,
          ...MockData.getInitialMonthlyProgressForOtherProjects()
        ];
        handler.resolve(Response(
          requestOptions: options,
          data: allProgress,
          statusCode: 200,
        ));
        return;
      }
    }

    // 7. NOTIFICATIONS
    if (path.contains('/notifications')) {
      if (method == 'GET') {
        // Return notifications sorted by date desc
        final sorted = List<Map<String, dynamic>>.from(_inMemoryNotifications);
        sorted.sort((a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String));

        handler.resolve(Response(
          requestOptions: options,
          data: sorted,
          statusCode: 200,
        ));
        return;
      }

      if (method == 'PATCH') {
        // Mark as read: /notifications?id=eq.UUID
        final idFilter = queryParams['id'];
        if (idFilter != null && idFilter.startsWith('eq.')) {
          final id = idFilter.substring(3);
          final index = _inMemoryNotifications.indexWhere((n) => n['id'] == id);
          if (index != -1) {
            final requestBody = options.data as Map<String, dynamic>;
            if (requestBody.containsKey('is_read')) {
              _inMemoryNotifications[index]['is_read'] = requestBody['is_read'];
            }
            handler.resolve(Response(
              requestOptions: options,
              data: [_inMemoryNotifications[index]],
              statusCode: 200,
            ));
            return;
          }
        }
      }
    }

    // Default fallback
    super.onRequest(options, handler);
  }

  // Helper: Decorate project with Authority and Contractor
  Map<String, dynamic> _joinedProjectJson(Map<String, dynamic> project) {
    final Map<String, dynamic> joined = Map.from(project);
    
    final authId = project['authority_id'];
    final authority = MockData.authorities.firstWhere(
      (a) => a['id'] == authId,
      orElse: () => {'id': authId, 'name': 'Unknown Authority'},
    );
    joined['authorities'] = authority;
    joined['authority'] = authority; // supporting both singular/plural

    final contrId = project['contractor_id'];
    final contractor = MockData.contractors.firstWhere(
      (c) => c['id'] == contrId,
      orElse: () => {'id': contrId, 'name': 'Unknown Contractor'},
    );
    joined['contractors'] = contractor;
    joined['contractor'] = contractor;

    return joined;
  }

  Map<String, dynamic>? _findProjectById(String id) {
    try {
      final project = MockData.projects.firstWhere((p) => p['id'] == id);
      return _joinedProjectJson(project);
    } catch (_) {
      return null;
    }
  }
}
