import 'dart:async';
import 'package:flutter/material.dart';

import 'drm_watermark_config.dart';
import 'drm_watermark_painter.dart';

/// Dynamic forensic watermark overlay widget that wraps any child widget
/// (such as WebRTC video feeds, PDF viewers, or confidential dashboards)
/// with a low-overhead, hardware-accelerated DRM watermark.
class DrmWatermarkOverlay extends StatefulWidget {
  /// Configuration for styling, typography, opacity, and user metadata.
  final DrmWatermarkConfig config;

  /// The underlying content to be protected by the forensic watermark.
  final Widget child;

  /// Whether the watermark overlay is currently enabled and painted.
  ///
  /// Defaults to `true`.
  final bool enabled;

  /// Interval between dynamic timestamp ticks.
  ///
  /// Defaults to 1 second (`Duration(seconds: 1)`).
  /// Set to [Duration.zero] to disable the periodic timer and keep the watermark static.
  final Duration updateInterval;

  /// Creates a [DrmWatermarkOverlay].
  const DrmWatermarkOverlay({
    super.key,
    required this.config,
    required this.child,
    this.enabled = true,
    this.updateInterval = const Duration(seconds: 1),
  });

  @override
  State<DrmWatermarkOverlay> createState() => _DrmWatermarkOverlayState();
}

class _DrmWatermarkOverlayState extends State<DrmWatermarkOverlay> {
  Timer? _timer;
  late DateTime _currentTimestamp;

  @override
  void initState() {
    super.initState();
    _currentTimestamp = DateTime.now();
    _initTimer();
  }

  @override
  void didUpdateWidget(covariant DrmWatermarkOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.updateInterval != widget.updateInterval ||
        oldWidget.enabled != widget.enabled) {
      _timer?.cancel();
      _initTimer();
    }
  }

  void _initTimer() {
    if (!widget.enabled || widget.updateInterval == Duration.zero) return;
    _timer = Timer.periodic(widget.updateInterval, (_) {
      if (mounted) {
        setState(() {
          _currentTimestamp = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: DrmWatermarkPainter(
                  config: widget.config,
                  text: widget.config.formatText(_currentTimestamp),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Standalone forensic watermark grid widget without wrapping a child widget.
///
/// Useful when embedding within custom [Stack], [ShaderMask], or custom video layouts.
class DrmWatermarkGrid extends StatelessWidget {
  /// Configuration for styling, typography, opacity, and user metadata.
  final DrmWatermarkConfig config;

  /// Explicit timestamp to format. Defaults to [DateTime.now()] when null.
  final DateTime? timestamp;

  /// Creates a [DrmWatermarkGrid].
  const DrmWatermarkGrid({
    super.key,
    required this.config,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: CustomPaint(
        painter: DrmWatermarkPainter(
          config: config,
          text: config.formatText(timestamp ?? DateTime.now()),
        ),
      ),
    );
  }
}
