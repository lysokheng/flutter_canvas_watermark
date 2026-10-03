import 'package:flutter/material.dart';
import 'package:flutter_canvas_watermark/flutter_canvas_watermark.dart';

void main() {
  runApp(const WatermarkDemoApp());
}

class WatermarkDemoApp extends StatelessWidget {
  const WatermarkDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Canvas Watermark Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const WatermarkDemoScreen(),
    );
  }
}

class WatermarkDemoScreen extends StatefulWidget {
  const WatermarkDemoScreen({super.key});

  @override
  State<WatermarkDemoScreen> createState() => _WatermarkDemoScreenState();
}

class _WatermarkDemoScreenState extends State<WatermarkDemoScreen> {
  bool _watermarkEnabled = true;
  double _opacity = 0.18;
  double _angle = -0.35;
  String _userId = 'lysokheng@codingate.com';
  String _clientIp = '203.189.145.22';

  @override
  Widget build(BuildContext context) {
    final config = DrmWatermarkConfig(
      userId: _userId,
      clientIp: _clientIp,
      sessionToken: 'CONFIDENTIAL-STAGE',
      opacity: _opacity,
      angle: _angle,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forensic Canvas DRM Watermark'),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          Row(
            children: [
              const Text('DRM Active: ', style: TextStyle(fontSize: 12)),
              Switch(
                value: _watermarkEnabled,
                onChanged: (val) => setState(() => _watermarkEnabled = val),
              ),
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          // Left: Video/Document Viewer protected by Watermark
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: DrmWatermarkOverlay(
                  enabled: _watermarkEnabled,
                  config: config,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0284C7), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.videocam_rounded,
                            size: 80,
                            color: Colors.white70,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'LIVE WebRTC Media Stream (Mediasoup SFU)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Protected by Hardware-Accelerated Dynamic Forensic Canvas',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Right: Configuration Panel
          Expanded(
            flex: 4,
            child: Container(
              color: const Color(0xFF1E293B),
              padding: const EdgeInsets.all(24),
              child: ListView(
                children: [
                  const Text(
                    'Watermark Parameters',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text('Opacity: ${(_opacity * 100).toInt()}%'),
                  Slider(
                    value: _opacity,
                    min: 0.05,
                    max: 0.60,
                    divisions: 11,
                    onChanged: (val) => setState(() => _opacity = val),
                  ),
                  const SizedBox(height: 10),
                  Text('Rotation Angle: ${_angle.toStringAsFixed(2)} rad'),
                  Slider(
                    value: _angle,
                    min: -1.0,
                    max: 1.0,
                    divisions: 20,
                    onChanged: (val) => setState(() => _angle = val),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'User Identifier',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: _userId),
                    onSubmitted: (val) => setState(() => _userId = val),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Client IP Address',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: _clientIp),
                    onSubmitted: (val) => setState(() => _clientIp = val),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
