import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_canvas_watermark/flutter_canvas_watermark.dart';

void main() {
  group('DrmWatermarkConfig', () {
    test('default parameters are properly initialized', () {
      const config = DrmWatermarkConfig(userId: 'usr_1001');

      expect(config.userId, equals('usr_1001'));
      expect(config.clientIp, isNull);
      expect(config.sessionToken, isNull);
      expect(config.opacity, equals(0.18));
      expect(config.angle, equals(-0.35));
      expect(config.horizontalSpacing, equals(80.0));
      expect(config.verticalSpacing, equals(70.0));
      expect(config.showTimestamp, isTrue);
      expect(config.textBuilder, isNull);
    });

    test('formatText formats standard forensic string correctly', () {
      const config = DrmWatermarkConfig(
        userId: 'usr_882',
        clientIp: '192.168.1.100',
        sessionToken: 'SES_XYZ',
      );

      final testDate = DateTime.utc(2026, 10, 3, 14, 30, 45);
      final formatted = config.formatText(testDate);

      expect(
        formatted,
        equals('usr_882 | 192.168.1.100 | SES_XYZ | 2026-10-03 14:30:45 UTC'),
      );
    });

    test('formatText respects showTimestamp = false', () {
      const config = DrmWatermarkConfig(
        userId: 'usr_882',
        clientIp: '10.0.0.1',
        showTimestamp: false,
      );

      final testDate = DateTime.utc(2026, 10, 3, 14, 30, 45);
      expect(config.formatText(testDate), equals('usr_882 | 10.0.0.1'));
    });

    test('formatText executes custom textBuilder callback', () {
      final config = DrmWatermarkConfig(
        userId: 'admin_01',
        textBuilder: (cfg, ts) => 'CONFIDENTIAL // ${cfg.userId} // ${ts.year}',
      );

      final testDate = DateTime.utc(2026, 5, 1);
      expect(config.formatText(testDate), equals('CONFIDENTIAL // admin_01 // 2026'));
    });

    test('copyWith updates specified fields', () {
      const config = DrmWatermarkConfig(userId: 'usr_1');
      final updated = config.copyWith(
        userId: 'usr_2',
        clientIp: '127.0.0.1',
        opacity: 0.25,
      );

      expect(updated.userId, equals('usr_2'));
      expect(updated.clientIp, equals('127.0.0.1'));
      expect(updated.opacity, equals(0.25));
      expect(updated.angle, equals(config.angle));
    });

    test('equality and hashcode match equivalent configurations', () {
      const c1 = DrmWatermarkConfig(userId: 'u1', clientIp: '1.1.1.1');
      const c2 = DrmWatermarkConfig(userId: 'u1', clientIp: '1.1.1.1');
      const c3 = DrmWatermarkConfig(userId: 'u2', clientIp: '1.1.1.1');

      expect(c1, equals(c2));
      expect(c1.hashCode, equals(c2.hashCode));
      expect(c1, isNot(equals(c3)));
    });
  });

  group('DrmWatermarkPainter', () {
    test('paint handles empty sizes and empty text without exceptions', () {
      const config = DrmWatermarkConfig(userId: 'usr_test');
      final painter = DrmWatermarkPainter(config: config, text: 'test');

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      expect(() => painter.paint(canvas, Size.zero), returnsNormally);

      final emptyTextPainter = DrmWatermarkPainter(config: config, text: '');
      expect(() => emptyTextPainter.paint(canvas, const Size(200, 200)), returnsNormally);
    });

    test('paint renders on non-empty canvas without crashing', () {
      const config = DrmWatermarkConfig(userId: 'usr_test');
      final painter = DrmWatermarkPainter(config: config, text: 'SAMPLE WATERMARK');

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      expect(() => painter.paint(canvas, const Size(400, 800)), returnsNormally);
      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('shouldRepaint detects changes in text or config', () {
      const config1 = DrmWatermarkConfig(userId: 'u1');
      const config2 = DrmWatermarkConfig(userId: 'u2');

      final p1 = DrmWatermarkPainter(config: config1, text: 'TXT1');
      final p1Same = DrmWatermarkPainter(config: config1, text: 'TXT1');
      final p1DiffText = DrmWatermarkPainter(config: config1, text: 'TXT2');
      final p1DiffConfig = DrmWatermarkPainter(config: config2, text: 'TXT1');

      expect(p1.shouldRepaint(p1Same), isFalse);
      expect(p1.shouldRepaint(p1DiffText), isTrue);
      expect(p1.shouldRepaint(p1DiffConfig), isTrue);
    });
  });

  group('DrmWatermarkOverlay Widget', () {
    testWidgets('renders child widget and CustomPaint overlay when enabled', (tester) async {
      const config = DrmWatermarkConfig(userId: 'usr_widget_test');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DrmWatermarkOverlay(
              config: config,
              child: Center(
                child: Text('Protected Video Player'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Protected Video Player'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is CustomPaint && w.painter is DrmWatermarkPainter),
        findsOneWidget,
      );
    });

    testWidgets('skips CustomPaint overlay when enabled is false', (tester) async {
      const config = DrmWatermarkConfig(userId: 'usr_widget_test');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DrmWatermarkOverlay(
              config: config,
              enabled: false,
              child: Center(
                child: Text('Raw Player'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Raw Player'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is CustomPaint && w.painter is DrmWatermarkPainter),
        findsNothing,
      );
    });

    testWidgets('updates timer tick when periodic', (tester) async {
      const config = DrmWatermarkConfig(userId: 'usr_ticker');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DrmWatermarkOverlay(
              config: config,
              updateInterval: Duration(milliseconds: 500),
              child: Text('Content'),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 600));
      expect(
        find.byWidgetPredicate((w) => w is CustomPaint && w.painter is DrmWatermarkPainter),
        findsOneWidget,
      );
    });
  });

  group('DrmWatermarkGrid Widget', () {
    testWidgets('renders CustomPaint with explicit timestamp', (tester) async {
      const config = DrmWatermarkConfig(userId: 'usr_grid');
      final timestamp = DateTime.utc(2026, 1, 1, 12, 0, 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 300,
              child: DrmWatermarkGrid(
                config: config,
                timestamp: timestamp,
              ),
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate((w) => w is CustomPaint && w.painter is DrmWatermarkPainter),
        findsOneWidget,
      );
    });
  });
}
