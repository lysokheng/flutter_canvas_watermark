## 1.0.0

- Initial release of `flutter_canvas_watermark`.
- Hardware-accelerated `DrmWatermarkPainter` with center-origin radial grid layout and configurable rotation angle, spacing, and opacity.
- Auto-refreshing `DrmWatermarkOverlay` widget with low-overhead periodic UTC timestamp updates.
- Lightweight standalone `DrmWatermarkGrid` widget for custom layouts and canvas composition.
- Robust `DrmWatermarkConfig` supporting authenticated user IDs, client IPs, session tokens, custom typography, and dynamic `WatermarkTextBuilder` callbacks.
- Production-tested for confidential enterprise dashboards, high-security video streams (WebRTC, Mediasoup, Agora, LiveKit), and sensitive document previewers.
- 100% test coverage with automated unit and widget test suites.
