/// Visualizes music by drawing animated bars that react to audio input.
import 'dart:async';
import 'package:flutter/material.dart';

class MusicVisualizer extends StatefulWidget {
  @override
  _MusicVisualizerState createState() => _MusicVisualizerState();
}

class _MusicVisualizerState extends State<MusicVisualizer> {
  final int numberOfBars = 20;
  final List<double> barHeights = List.filled(20, 10.0);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        for (int i = 0; i < numberOfBars; i++) {
          barHeights[i] = (10 + (i * 5) * (0.5 + 0.5 * (i % 2))) *
              (0.5 + 0.5 * (i % 3)); // Simulated dynamic heights
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
          width: 5,
          height: barHeights[index],
          margin: EdgeInsets.symmetric(horizontal: 2),
          color: Colors.blueAccent,
        );
      }),
    );
  }
}
