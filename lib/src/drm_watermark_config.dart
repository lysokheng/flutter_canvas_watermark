import 'package:flutter/material.dart';

/// Function signature for dynamic forensic watermark text generation.
typedef WatermarkTextBuilder = String Function(
  DrmWatermarkConfig config,
  DateTime timestamp,
);

/// Configuration parameters for rendering the forensic canvas DRM watermark.
class DrmWatermarkConfig {
  /// Unique identifier of the authenticated user or session (e.g. "usr_948192").
  final String userId;

  /// Optional client IP address or network identifier (e.g. "192.168.1.42").
  final String? clientIp;

  /// Optional session token or organization identifier.
  final String? sessionToken;

  /// Opacity multiplier for the watermark overlay (range: 0.0 to 1.0).
  ///
  /// Defaults to `0.18`, subtle enough not to obstruct video or reading while
  /// remaining clearly visible in forensic screen-capture analysis.
  final double opacity;

  /// Rotation angle of the watermark grid in radians.
  ///
  /// Defaults to `-0.35` (~ -20 degrees).
  final double angle;

  /// Typography styling applied to each watermark text cell.
  final TextStyle textStyle;

  /// Additional horizontal spacing (in logical pixels) between text grid items.
  ///
  /// Defaults to `80.0`.
  final double horizontalSpacing;

  /// Additional vertical spacing (in logical pixels) between text grid rows.
  ///
  /// Defaults to `70.0`.
  final double verticalSpacing;

  /// Whether to include the dynamic ticking UTC timestamp in the default watermark text.
  ///
  /// Defaults to `true`.
  final bool showTimestamp;

  /// Optional custom text builder to completely customize the rendered string.
  ///
  /// When `null`, the default format is:
  /// `"${userId} | ${clientIp ?? '127.0.0.1'} | ${formattedUtcTimestamp}"`.
  final WatermarkTextBuilder? textBuilder;

  /// Creates a configuration instance for [DrmWatermarkPainter] and [DrmWatermarkOverlay].
  const DrmWatermarkConfig({
    required this.userId,
    this.clientIp,
    this.sessionToken,
    this.opacity = 0.18,
    this.angle = -0.35,
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
      fontFamily: 'monospace',
    ),
    this.horizontalSpacing = 80.0,
    this.verticalSpacing = 70.0,
    this.showTimestamp = true,
    this.textBuilder,
  });

  /// Formats the watermark display text given the current [timestamp].
  String formatText(DateTime timestamp) {
    if (textBuilder != null) {
      return textBuilder!(this, timestamp);
    }

    final buffer = StringBuffer(userId);

    if (clientIp != null && clientIp!.isNotEmpty) {
      buffer.write(' | $clientIp');
    }

    if (sessionToken != null && sessionToken!.isNotEmpty) {
      buffer.write(' | $sessionToken');
    }

    if (showTimestamp) {
      final utc = timestamp.toUtc();
      final formattedTime =
          '${utc.year}-${_pad(utc.month)}-${_pad(utc.day)} '
          '${_pad(utc.hour)}:${_pad(utc.minute)}:${_pad(utc.second)} UTC';
      buffer.write(' | $formattedTime');
    }

    return buffer.toString();
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');

  /// Creates a copy of this configuration with given fields replaced.
  DrmWatermarkConfig copyWith({
    String? userId,
    String? clientIp,
    String? sessionToken,
    double? opacity,
    double? angle,
    TextStyle? textStyle,
    double? horizontalSpacing,
    double? verticalSpacing,
    bool? showTimestamp,
    WatermarkTextBuilder? textBuilder,
  }) {
    return DrmWatermarkConfig(
      userId: userId ?? this.userId,
      clientIp: clientIp ?? this.clientIp,
      sessionToken: sessionToken ?? this.sessionToken,
      opacity: opacity ?? this.opacity,
      angle: angle ?? this.angle,
      textStyle: textStyle ?? this.textStyle,
      horizontalSpacing: horizontalSpacing ?? this.horizontalSpacing,
      verticalSpacing: verticalSpacing ?? this.verticalSpacing,
      showTimestamp: showTimestamp ?? this.showTimestamp,
      textBuilder: textBuilder ?? this.textBuilder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrmWatermarkConfig &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          clientIp == other.clientIp &&
          sessionToken == other.sessionToken &&
          opacity == other.opacity &&
          angle == other.angle &&
          textStyle == other.textStyle &&
          horizontalSpacing == other.horizontalSpacing &&
          verticalSpacing == other.verticalSpacing &&
          showTimestamp == other.showTimestamp &&
          textBuilder == other.textBuilder;

  @override
  int get hashCode => Object.hash(
        userId,
        clientIp,
        sessionToken,
        opacity,
        angle,
        textStyle,
        horizontalSpacing,
        verticalSpacing,
        showTimestamp,
        textBuilder,
      );
}
