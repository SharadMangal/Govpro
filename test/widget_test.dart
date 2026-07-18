// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:govpro/models/project.dart';
import 'package:govpro/models/notification_item.dart';
import 'package:govpro/repositories/project_repository.dart';
import 'package:govpro/repositories/notification_repository.dart';
import 'package:govpro/providers/providers.dart';
import 'package:govpro/main.dart';

void main() {
  setUpAll(() {
    // Override HTTP operations globally for tests to resolve network images
    HttpOverrides.global = MockHttpOverrides();
  });

  testWidgets('Dashboard boots smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectRepositoryProvider.overrideWithValue(MockProjectRepo()),
          notificationRepositoryProvider.overrideWithValue(MockNotificationRepo()),
        ],
        child: const GovProApp(),
      ),
    );

    // Fast-forward simulated delay
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    // Verify that our dashboard header is rendered.
    expect(find.text('Public Works Dept. • Jharkhand'), findsOneWidget);
  });
}

// --- MOCK REPOSITORIES ---
class MockProjectRepo implements ProjectRepository {
  @override
  Future<List<Project>> getAllProjects({bool forceRefresh = false}) async {
    return [
      Project(
        id: 'p0101010-1010-1010-1010-101010101010',
        name: 'NH-114A Ranchi Bypass Widening',
        district: 'Ranchi',
        authorityId: 'a1111111-1111-1111-1111-111111111111',
        contractorId: 'c1111111-1111-1111-1111-111111111111',
        status: 'in_progress',
        completionPercent: 62,
        budget: 3200000000,
        lengthKm: 42.5,
        startDate: DateTime(2024, 6, 15),
        endDate: DateTime(2026, 1, 20),
        delayDays: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockNotificationRepo implements NotificationRepository {
  @override
  Future<List<NotificationItem>> getAllNotifications() async {
    return [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// --- MOCK HTTP CLIENT TO MOCK NETWORK IMAGES IN TESTS ---
class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();
  
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _MockHttpClientRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  // A transparent 1x1 PNG pixel
  static final List<int> _transparentImage = [
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
  ];

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _transparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  List<RedirectInfo> get redirects => const [];

  @override
  bool get persistentConnection => true;

  @override
  bool get isRedirect => false;

  @override
  String get reasonPhrase => 'OK';

  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  List<Cookie> get cookies => const [];

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_transparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
