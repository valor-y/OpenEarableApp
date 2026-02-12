import 'dart:async';

import 'package:flutter/material.dart';
import 'package:open_wearable/apps/just_headbang/model/beat_detection.dart';
import 'package:open_wearable/apps/just_headbang/services/beat_detection_service.dart';
import 'package:open_wearable/apps/just_headbang/viewmodel/sensor_viewmodel.dart';

/// A real-time scrolling chart that overlays sensor headbang intensity
/// with beat markers from the [BeatDetectionService].
class SensorBeatChart extends StatefulWidget {
  final SensorViewModel sensorViewModel;
  final BeatDetectionService beatDetectionService;

  /// How many seconds of data to display in the visible window.
  final double windowSeconds;

  const SensorBeatChart({
    super.key,
    required this.sensorViewModel,
    required this.beatDetectionService,
    this.windowSeconds = 5.0,
  });

  @override
  State<SensorBeatChart> createState() => _SensorBeatChartState();
}

class _SensorBeatChartState extends State<SensorBeatChart> {
  /// Rolling buffer of (elapsed-seconds, intensity) pairs.
  final List<_ChartPoint> _sensorPoints = [];

  /// Rolling buffer of beat timestamps (elapsed seconds).
  final List<double> _beatTimes = [];

  StreamSubscription<BeatTimestamp>? _beatSub;
  DateTime? _startTime;

  static const int _maxPoints = 500;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    widget.sensorViewModel.addListener(_onSensorUpdate);
    _beatSub = widget.beatDetectionService.getRealTimeBeats().listen(_onBeat);
  }

  @override
  void dispose() {
    widget.sensorViewModel.removeListener(_onSensorUpdate);
    _beatSub?.cancel();
    super.dispose();
  }

  void _onSensorUpdate() {
    final data = widget.sensorViewModel.latestData;
    if (data == null || _startTime == null) return;

    final elapsed =
        data.timestamp.difference(_startTime!).inMilliseconds / 1000.0;

    _sensorPoints.add(_ChartPoint(elapsed, data.headbangIntensity));
    if (_sensorPoints.length > _maxPoints) {
      _sensorPoints.removeAt(0);
    }

    // Trigger repaint
    setState(() {});
  }

  void _onBeat(BeatTimestamp beat) {
    if (_startTime == null) return;
    final elapsed = beat.timestamp.inMilliseconds / 1000.0;
    _beatTimes.add(elapsed);

    // Prune old beats outside the window
    final cutoff = (_sensorPoints.isNotEmpty ? _sensorPoints.last.time : 0.0) -
        widget.windowSeconds * 2;
    _beatTimes.removeWhere((t) => t < cutoff);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Legend
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              _LegendDot(color: Colors.cyanAccent, label: 'Intensity'),
              const SizedBox(width: 16),
              _LegendDot(color: Colors.redAccent, label: 'Beat'),
            ],
          ),
        ),
        // Chart
        Container(
          height: 160,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: CustomPaint(
            size: const Size(double.infinity, 160),
            painter: _ChartPainter(
              sensorPoints: List.of(_sensorPoints),
              beatTimes: List.of(_beatTimes),
              windowSeconds: widget.windowSeconds,
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  Internal helpers
// ──────────────────────────────────────────────────────────────

class _ChartPoint {
  final double time; // seconds since start
  final double value;
  _ChartPoint(this.time, this.value);
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<_ChartPoint> sensorPoints;
  final List<double> beatTimes;
  final double windowSeconds;

  _ChartPainter({
    required this.sensorPoints,
    required this.beatTimes,
    required this.windowSeconds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (sensorPoints.isEmpty) {
      // Draw a "waiting for data" hint
      final tp = TextPainter(
        text: const TextSpan(
          text: 'Waiting for sensor data…',
          style: TextStyle(color: Colors.white38, fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2),
      );
      return;
    }

    final latestTime = sensorPoints.last.time;
    final windowStart = latestTime - windowSeconds;

    // Compute the max intensity in the visible window for dynamic scaling
    double maxVal = 1.0;
    for (final p in sensorPoints) {
      if (p.time >= windowStart && p.value > maxVal) {
        maxVal = p.value;
      }
    }
    // Add 10 % headroom
    maxVal *= 1.1;

    // Helper to map time → x
    double timeToX(double t) =>
        ((t - windowStart) / windowSeconds) * size.width;

    // Helper to map value → y (0 at bottom, max at top)
    double valueToY(double v) =>
        size.height - (v / maxVal).clamp(0.0, 1.0) * size.height;

    // ── Grid lines ──
    final gridPaint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 0.5;
    for (int i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // ── Beat markers (vertical lines) ──
    final beatPaint = Paint()
      ..color = Colors.redAccent.withOpacity(0.6)
      ..strokeWidth = 2.0;
    for (final bt in beatTimes) {
      if (bt < windowStart || bt > latestTime) continue;
      final x = timeToX(bt);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), beatPaint);
    }

    // ── Sensor intensity line ──
    final linePaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.cyanAccent.withOpacity(0.35),
          Colors.cyanAccent.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePath = Path();
    final fillPath = Path();
    bool started = false;

    for (final p in sensorPoints) {
      if (p.time < windowStart) continue;
      final x = timeToX(p.time);
      final y = valueToY(p.value);
      if (!started) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
        started = true;
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Close the fill path at bottom
    if (started) {
      final lastX = timeToX(sensorPoints.last.time);
      fillPath.lineTo(lastX, size.height);
      fillPath.close();
      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(linePath, linePaint);
    }

    // ── Y-axis labels ──
    for (int i = 0; i <= 4; i++) {
      final val = maxVal * (4 - i) / 4;
      final y = size.height * i / 4;
      final tp = TextPainter(
        text: TextSpan(
          text: val.toStringAsFixed(1),
          style: const TextStyle(color: Colors.white24, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(4, y));
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => true;
}
