import 'dart:async';
import 'package:flutter/material.dart';

/// Visualizes sensor data by drawing animated bars that react to head movements.
class SensorOverlay extends StatefulWidget {
  @override
  _SensorOverlayState createState() => _SensorOverlayState();
}
class _SensorOverlayState extends State<SensorOverlay> {
  final int numberOfBars = 10;
  final List<double> barHeights = List.filled(10, 10.0);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        for (int i = 0; i < numberOfBars; i++) {
          barHeights[i] = (10 + (i * 3) * (0.5 + 0.5 * (i % 2))) *
              (0.5 + 0.5 * (i % 4)); // Simulated dynamic heights
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(numberOfBars, (index) {
        return Container(
          width: 8,
          height: barHeights[index],
          margin: EdgeInsets.symmetric(horizontal: 3),
          color: Colors.redAccent,
        );
      }),
    );
  }
}